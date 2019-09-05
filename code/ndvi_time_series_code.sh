#!/bin/bash

########################################################################
# Commands for NDVI time series exercise
# Author: Veronica Andreo
# Date: October, 2018. Edits: December 2018, April 2019
########################################################################


#
# Data download and preparation
#


### DO NOT RUN ###

#~ # start GRASS GIS in NC full location and create a new mapset
#~ g.mapset -c mapset=modis_ndvi

#~ # add modis_lst to path
#~ g.mapsets -p
#~ g.mapsets mapset=modis_lst operation=add

#~ # set region to an LST map
#~ g.list type=raster mapset=modis_lst
#~ g.region -p raster=MOD11B3.A2015001.h11v05.single_LST_Day_6km@modis_lst

#~ # get bounding box in ll
#~ g.region -bg
#~ ll_n=40.59247652
#~ ll_s=29.48543350
#~ ll_w=-91.37851025
#~ ll_e=-67.97322249
#~ ll_clon=-79.67586637
#~ ll_clat=35.03895501

#~ # download MOD13C2
#~ i.modis.download settings=$HOME/gisdata/SETTING \
  #~ product=ndvi_terra_monthly_5600 \
  #~ startday="2015-01-01" \
  #~ endday="2017-12-31" \
  #~ folder=$HOME/gisdata/mod13

#~ # move to latlong location

#~ # import into latlong location: NDVI, EVI, QA, NIR, SWIR, Pixel reliability
#~ i.modis.import files=$HOME/gisdata/mod13/listfileMOD13C2.006.txt \
  #~ spectral="( 1 1 1 0 1 0 1 0 0 0 0 0 1 )"

#~ # set region to bb
#~ g.region -p n=40.59247652 s=29.48543350 w=-91.37851025 e=-67.97322249 \
  #~ align=MOD13C2.A2017335.006.single_CMG_0.05_Deg_Monthly_NDVI

#~ # subset to region and remove global maps
#~ for map in `g.list type=raster pattern="MOD13C2*"` ; do
  #~ r.mapcalc expression="$map = $map" --o
#~ done

#~ # get list of maps to reproject
#~ g.list type=raster pattern="MOD13C2*" output=list_proj.txt

#~ # move back to NC location

#~ # reproject
#~ for map in `cat list_proj.txt` ; do
  #~ r.proj input=$map \
    #~ location=latlong_wgs84 \
    #~ mapset=testing \
    #~ resolution=5600
#~ done

#~ # check projected data
#~ r.info map=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI

### END OF DO NOT RUN ###


#
# Get familiar with NDVI data
#


# Download ready to use mapset and unzip in NC location

# List maps and get basic info and stats
g.list type=raster mapset=.
r.info map=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI
r.univar map=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI

# Set computational region
g.region -p vector=nc_state \
  align=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI

# Set mask
r.mask vector=nc_state


#
# Use of reliability band
#


# *nix: Keep only NDVI most reliable pixels (one map) 
PR=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_pixel_reliability
NDVI=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_NDVI

r.mapcalc \
  expression="${NDVI}_filt = if(${PR} != 0, null(), ${NDVI})"

# Windows: Keep only NDVI most reliable pixels (one map) 
SET PR=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_pixel_reliability
SET NDVI=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_NDVI

r.mapcalc \
  expression="%NDVI%_filt = if(%PR% != 0, null(), %NDVI%)"

# For all NDVI maps (Windows users run bash.exe and once done, exit)

# List of maps
PR=$(g.list type=raster pattern="*_pixel_reliability" separator=" ")
NDVI=$(g.list type=raster pattern="*_Monthly_NDVI" separator=" ")

# Convert list to array
PR=($PR)
NDVI=($NDVI)

# Iterate over the 2 arrays
for ((i=0;i<${#PR[@]};i++)) ; do
  echo ${PR[$i]} ${NDVI[$i]};
  r.mapcalc \
    expression="${NDVI[$i]}_filt = if(${PR[$i]} != 0, null(), ${NDVI[$i]})"
done


#
# Create NDVI time series
#


# Create STRDS
t.create output=ndvi_monthly \
  type=strds temporaltype=absolute \
  title="Filtered monthly NDVI" \
  description="Filtered monthly NDVI - MOD13C2 - 2015-2017"

# Check if it was created
t.list type=strds

# List NDVI filtered files
g.list type=raster pattern="*filt" output=ndvi_list.txt

# Register maps
t.register -i input=ndvi_monthly \
  type=raster file=ndvi_list.txt \
  start="2015-01-01" increment="1 months"

# Print time series info
t.info input=ndvi_monthly

# Print list of maps in time series
t.rast.list input=ndvi_monthly


#
# Estimate percentage of missing data
#


# How much missing data we have after filtering for pixel reliability?
t.rast.univar input=ndvi_monthly

# Count valid data
t.rast.series input=ndvi_monthly \
  method=count \
  output=ndvi_count_valid

# Get total number of maps
eval $(t.info -g type=strds input=ndvi_monthly)
echo $number_of_maps

# Estimate percentage of missing data
r.mapcalc \
  expression="ndvi_missing = \
  (($number_of_maps - ndvi_count_valid) * 100.0)/$number_of_maps"


#
# Temporal gap-filling: HANTS
#


# install extension
g.extension extension=r.hants

# *nix
# List maps
maplist=$(t.rast.list input=ndvi_monthly method=comma)

# gapfill: r.hants
r.hants in=$maplist range=-2000,10000 nf=5 fet=500 base_period=12

# Windows
# list maps
FOR /F %c IN ('t.rast.list "-u" "input=ndvi_monthly" "method=comma"') DO SET maplist=%c

r.hants in=%maplist% range=-2000,10000 nf=5 fet=500 base_period=12

# Patch original with filled maps
# Windows users run bash.exe, once done type exit

# Get list of maps
ORIG=$(g.list type=raster pattern="*_filt" separator=" ")
FILL=$(g.list type=raster pattern="*_hants" separator=" ")

# Convert list to array
ORIG=($ORIG)
FILL=($FILL)

# Iterate over the 2 arrays
for ((i=0;i<${#ORIG[@]};i++)) ; do
  echo ${ORIG[$i]} ${FILL[$i]};
  r.patch input=${ORIG[$i]},${FILL[$i]} output=${FILL[$i]}_patch --o
done

# Create new time series 
t.create output=ndvi_monthly_patch \
  type=strds temporaltype=absolute \
  title="Patched monthly NDVI" \
  description="Filtered, gap-filled and patched monthly NDVI - MOD13C2 - 2015-2017"

# List NDVI patched files
g.list type=raster pattern="*patch" \
  output=list_ndvi_patched.txt

# Register maps
t.register -i input=ndvi_monthly_patch \
  type=raster file=list_ndvi_patched.txt \
  start="2015-01-01" increment="1 months"

# Print time series info
t.info input=ndvi_monthly_patch


#
# Obtain phenological information
#


# Get NDVI maximum and minimum
t.rast.series input=ndvi_monthly_patch \
  method=maximum \
  output=ndvi_max

t.rast.series input=ndvi_monthly_patch \
  method=minimum \
  output=ndvi_min

# Get month of maximum
t.rast.mapcalc -n inputs=ndvi_monthly_patch \
  output=month_max_ndvi \
  expression="if(ndvi_monthly_patch == ndvi_max, start_month(), null())" \
  basename=month_max_ndvi

# Get the earliest month in which the maximum appeared
t.rast.series input=month_max_ndvi \
  method=minimum \
  output=max_ndvi_date
  
# Get NDVI minimum per year starting in December
t.rast.aggregate input=ndvi_monthly_patch \
  where="start_time >= '2015-12-01' AND start_time <= '2017-11-30'" \
  method=min_raster \
  granularity="12 months" \
  output=annual_index_min_ndvi \
  basename=index_ndvi_min \
  suffix=gran

# Get index of minimum raster
t.rast.series input=annual_index_min_ndvi \
  method=minimum \
  output=min_ndvi_index

# Index to month reclass rules
echo "0 = 12
1 = 1
2 = 2
3 = 3
4 = 4
5 = 5
6 = 6
7 = 7
8 = 8
9 = 9
10 = 10
11 = 11" >> index2month.txt

# Reclass index to month
r.reclass input=min_ndvi_index output=min_ndvi_date \
  rules=index2month.txt

# Remove intermediate strds 
t.remove -rf inputs=month_max_ndvi,annual_index_min_ndvi

# Add `modis_lst` to accessible mapsets path
g.mapsets -p
g.mapsets mapset=modis_lst operation=add

# Estimate global correlations
r.covar -r map=LST_Day_max,LST_Day_min,ndvi_max,ndvi_min
r.covar -r map=max_lst_date,min_lst_date,max_ndvi_date,min_ndvi_date

# Time series of slopes
t.rast.algebra \
  expression="slope_ndvi = (ndvi_monthly_patch[1] - ndvi_monthly_patch[0]) / td(ndvi_monthly_patch)" \
  basename=slope_ndvi \
  suffix=gran
 
# Get max slope per year
t.rast.aggregate input=slope_ndvi \
  output=ndvi_slope_yearly \
  basename=NDVI_max_slope_year \
  suffix=gran \
  method=maximum \
  granularity="1 years"

# Install extension
g.extension extension=r.seasons

# *nix: Start, end and length of growing season
r.seasons input=$(t.rast.list -u input=ndvi_monthly_patch method=comma) \
  prefix=ndvi_season \
  n=3 \
  nout=ndvi_season \
  threshold_value=3000 \
  min_length=5 \
  max_gap=4

# Windows: Start, end and length of growing season 
FOR /F %c IN ('t.rast.list "-u" "input=ndvi_monthly_patch" "separator=," "method=comma"') DO SET ndvi_list=%c

r.seasons input=%ndvi_list% prefix=ndvi_season n=3 nout=ndvi_season threshold_value=3000 min_length=5 max_gap=1

# Create a threshold map: min ndvi + 0.1*ndvi
r.mapcalc expression="threshold_ndvi = ndvi_min*1.1"

r.seasons input=$(t.rast.list -u input=ndvi_monthly_patch method=comma) \
  prefix=ndvi_season_thres \
  n=3 \
  nout=ndvi_season_thres \
  threshold_map=threshold_ndvi \
  min_length=5 \
  max_gap=4


#
# Estimate NDWI
#


# Create time series of NIR and MIR
t.create output=NIR \
  type=strds temporaltype=absolute \
  title="NIR monthly" \
  description="NIR monthly - MOD13C2 - 2015-2017"

t.create output=MIR \
  type=strds temporaltype=absolute \
  title="MIR monthly" \
  description="MIR monthly - MOD13C2 - 2015-2017"
 
# List NIR and MIR files
g.list type=raster pattern="*NIR*" output=list_nir.txt
g.list type=raster pattern="*MIR*" output=list_mir.txt

# Register maps
t.register -i input=NIR \
  type=raster file=list_nir.txt \
  start="2015-01-01" \
  increment="1 months"

t.register -i input=MIR \
  type=raster file=list_mir.txt \
  start="2015-01-01" \
  increment="1 months"
 
# Print time series info
t.info input=NIR
t.info input=MIR

# Estimate NDWI time series
t.rast.algebra basename=ndwi_monthly suffix=gran \
  expression="ndwi_monthly = if(NIR > 0 && MIR > 0, \
  (float(NIR - MIR) / float(NIR + MIR)), null())"

# List maps in NDWI time series
t.rast.list ndwi_monthly \
  columns=name,start_time,end_time,min,max


#
# Regression between NDWI and NDVI
#


# Install extension
g.extension extension=r.regression.series

# Rescale NDVI values
t.rast.algebra \
  expression="ndvi_monthly_rescaled = ndvi_monthly_patch * 0.0001" \
  basename=ndvi_rescaled \
  suffix=gran

# *nix
xseries=$(t.rast.list input=ndvi_monthly_rescaled method=comma)
yseries=$(t.rast.list input=ndwi_monthly method=comma)

r.regression.series xseries=$xseries yseries=$yseries \
  output=ndvi_ndwi_rsq method=rsq

# Windows
FOR /F %c IN ('t.rast.list "-u" "input=ndvi_monthly_rescaled" "method=comma"') DO SET xseries=%c
FOR /F %c IN ('t.rast.list "-u" "input=ndwi_monthly" "method=comma"') DO SET yseries=%c

r.regression.series xseries=%xseries% yseries=%yseries% \
  output=ndvi_ndwi_rsq method=rsq

