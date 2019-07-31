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

# start GRASS GIS in NC full location and create a new mapset
g.mapset -c mapset=modis_ndvi

# add modis_lst to path
g.mapsets -p
g.mapsets mapset=modis_lst operation=add

# set region to an LST map
g.list type=raster mapset=modis_lst
g.region -p raster=MOD11B3.A2015001.h11v05.single_LST_Day_6km@modis_lst

# get bounding box in ll
g.region -bg
#~ ll_n=40.59247652
#~ ll_s=29.48543350
#~ ll_w=-91.37851025
#~ ll_e=-67.97322249
#~ ll_clon=-79.67586637
#~ ll_clat=35.03895501

# download MOD13C2 (https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod13c2_v006)
i.modis.download settings=$HOME/gisdata/SETTING \
 product=ndvi_terra_monthly_5600 \
 startday="2015-01-01" \
 endday="2017-12-31" \
 folder=$HOME/gisdata/mod13

# move to latlong location

# import into latlong location: NDVI, EVI, QA, NIR, SWIR, Pixel reliability
i.modis.import files=$HOME/gisdata/mod13/listfileMOD13C2.006.txt \
 spectral="( 1 1 1 0 1 0 1 0 0 0 0 0 1 )"

# set region to bb
g.region -p n=40.59247652 s=29.48543350 w=-91.37851025 e=-67.97322249 \
 align=MOD13C2.A2017335.006.single_CMG_0.05_Deg_Monthly_NDVI

# subset to region and remove global maps
for map in `g.list type=raster pattern="MOD13C2*"` ; do
 r.mapcalc expression="$map = $map" --o
done

# get list of maps to reproject
g.list type=raster pattern="MOD13C2*" output=list_proj.txt

# move back to NC location

# reproject
for map in `cat list_proj.txt` ; do
 r.proj input=$map \
  location=latlong_wgs84 \
  mapset=testing \
  resolution=5600
done

# check projected data
r.info map=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI

### END OF DO NOT RUN ###


#
# Get familiar with NDVI data
#


# download ready to use mapset and unzip in NC location

# start GRASS GIS in `modis_ndvi` mapset - *nix
grass76 $HOME/grassdata/nc_spm_08_grass7/modis_ndvi

# start GRASS GIS in the OSGeo4W console in `modis_ndvi` mapset - Windows
grass76 %HOME%\grassdata\nc_spm_08_grass7\modis_ndvi

# add `modis_lst` to accessible mapsets path
g.mapsets -p
g.mapsets mapset=modis_lst operation=add

# list files and get info and stats
g.list type=raster mapset=.
r.info map=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI
r.univar map=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI


#
# Use of reliability band
#


# set computational region
g.region -p vector=nc_state \
 align=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI

# keep only NDVI most reliable pixels (one map) - *nix
PR=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_pixel_reliability
NDVI=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_NDVI

r.mapcalc \
 expression="${NDVI}_filt = if(${PR} != 0, null(), ${NDVI})"

# keep only NDVI most reliable pixels (one map) - windows
SET PR=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_pixel_reliability
SET NDVI=MOD13C2.A2015274.006.single_CMG_0.05_Deg_Monthly_NDVI

r.mapcalc expression="%NDVI%_filt = if(%PR% != 0, null(), %NDVI%)"

# for all NDVI maps (Windows users run bash.exe and once done, exit)

# list of maps
PR=`g.list type=raster pattern="*_pixel_reliability" separator=" "`
NDVI=`g.list type=raster pattern="*_Monthly_NDVI" separator=" "`
# convert list to array
PR=($PR)
NDVI=($NDVI)

# iterate over the 2 arrays
for ((i=0;i<${#PR[@]};i++)) ; do
 echo ${PR[$i]} ${NDVI[$i]};
 r.mapcalc --o \
  expression="${NDVI[$i]}_filt = if(${PR[$i]} != 0, null(), ${NDVI[$i]})"
done


#
# Create NDVI time series
#


# create STRDS
t.create output=ndvi_monthly \
 type=strds temporaltype=absolute \
 title="Filtered monthly NDVI" \
 description="Filtered monthly NDVI - MOD13C2 - 2015-2017"

# check if it was created
t.list type=strds

# list NDVI filtered files
g.list type=raster pattern="*filt" output=ndvi_list.txt

# register maps
t.register -i input=ndvi_monthly \
 type=raster file=ndvi_list.txt \
 start="2015-01-01" increment="1 months"

# print time series info
t.info input=ndvi_monthly

# print list of maps in time series
t.rast.list input=ndvi_monthly


#
# Estimate percentage of missing data
#


# set mask
r.mask vector=nc_state

# How much missing data we have after filtering for pixel reliability?
t.rast.univar input=ndvi_monthly

# count valid data
t.rast.series input=ndvi_monthly \
 method=count output=ndvi_count_valid

# estimate percentage of missing data
r.mapcalc \
 expression="ndvi_missing = ((36 - ndvi_count_valid) * 100.0)/36"


#
# Temporal gap-filling: HANTS
#


# install extension
g.extension extension=r.hants

# *nix
# list maps
maplist=`t.rast.list input=ndvi_monthly method=comma`

# gapfill: r.hants
r.hants in=$maplist range=-2000,10000 nf=5 fet=500 base_period=12

# Windows
# list maps
FOR /F %c IN ('t.rast.list "-u" "input=ndvi_monthly" "method=comma"') DO SET maplist=%c

r.hants in=%maplist% range=-2000,10000 nf=5 fet=500 base_period=12

# patch original with filled (one map - *nix)
NDVI_ORIG=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI_filt
NDVI_HANTS=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI_filt_hants

r.patch input=${NDVI_ORIG},${NDVI_HANTS} \
 output=${NDVI_HANTS}_patch

# patch original with filled (one map - windows)
SET NDVI_ORIG=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI_filt
SET NDVI_HANTS=MOD13C2.A2015001.006.single_CMG_0.05_Deg_Monthly_NDVI_filt_hants

r.patch input=%NDVI_ORIG%,%NDVI_HANTS% \
 output=%NDVI_HANTS%_patch

# patch original with filled (all maps, Windows users run bash.exe, once done type exit)
# list of maps
ORIG=`g.list type=raster pattern="*_filt" separator=" "`
FILL=`g.list type=raster pattern="*_hants" separator=" "`
# convert list to array
ORIG=($ORIG)
FILL=($FILL)

# iterate over the 2 arrays
for ((i=0;i<${#ORIG[@]};i++)) ; do
 echo ${ORIG[$i]} ${FILL[$i]};
 r.patch input=${ORIG[$i]},${FILL[$i]} output=${FILL[$i]}_patch --o
done

# create new time series 
t.create output=ndvi_monthly_patch \
 type=strds temporaltype=absolute \
 title="Patched monthly NDVI" \
 description="Filtered, gap-filled and patched monthly NDVI - MOD13C2 - 2015-2017"

# list NDVI patched files
g.list type=raster pattern="*patch" output=list_ndvi_patched.txt

# register maps
t.register -i input=ndvi_monthly_patch \
 type=raster file=list_ndvi_patched.txt \
 start="2015-01-01" increment="1 months"

# print time series info
t.info input=ndvi_monthly_patch


#
# Obtain phenological information
#


# get month of maximum and month of minimum
t.rast.series input=ndvi_monthly_patch method=minimum output=ndvi_min
t.rast.series input=ndvi_monthly_patch method=maximum output=ndvi_max

# get month of maximum and minimum
t.rast.mapcalc -n inputs=ndvi_monthly_patch output=month_max_ndvi \
  expression="if(ndvi_monthly_patch == ndvi_max, start_month(), null())" \
  basename=month_max_ndvi

t.rast.mapcalc -n inputs=ndvi_monthly_patch output=month_min_ndvi \
  expression="if(ndvi_monthly_patch == ndvi_min, start_month(), null())" \
  basename=month_min_ndvi

# get the earliest month in which the maximum and minimum appeared
t.rast.series input=month_max_ndvi method=maximum output=max_ndvi_date
t.rast.series input=month_min_ndvi method=minimum output=min_ndvi_date

# remove month_max_lst strds 
t.remove -rf inputs=month_max_ndvi,month_min_ndvi

# time series of slopes
t.rast.algebra \
 expression="slope_ndvi = (ndvi_monthly_patch[1] - ndvi_monthly_patch[0]) / td(ndvi_monthly_patch)" \
 basename=slope_ndvi
 
# get max slope per year
t.rast.aggregate input=slope_ndvi output=ndvi_slope_yearly \
 basename=NDVI_max_slope_year suffix=gran \
 method=maximum granularity="1 years"

# install extension
g.extension extension=r.seasons

# start, end and length of growing season - *nix
r.seasons input=`t.rast.list -u input=ndvi_monthly_patch method=comma` \
 prefix=ndvi_season n=3 \
 nout=ndvi_season threshold_value=3000 min_length=5

# start, end and length of growing season - Windows
FOR /F %c IN ('t.rast.list "-u" "input=ndvi_monthly_patch" "separator=," "method=comma"') DO SET ndvi_list=%c

r.seasons input=%ndvi_list% prefix=ndvi_season n=3 nout=ndvi_season threshold_value=3000 min_length=5

# create a threshold map: min ndvi + 0.1*ndvi
r.mapcalc expression="threshold_ndvi = ndvi_min*1.1"


#
# Estimate NDWI
#


# create time series of NIR and MIR
t.create output=NIR \
 type=strds temporaltype=absolute \
 title="NIR monthly" \
 description="NIR monthly - MOD13C2 - 2015-2017"

t.create output=MIR \
 type=strds temporaltype=absolute \
 title="MIR monthly" \
 description="MIR monthly - MOD13C2 - 2015-2017"
 
# list NIR and MIR files
g.list type=raster pattern="*NIR*" output=list_nir.txt
g.list type=raster pattern="*MIR*" output=list_mir.txt

# register maps
t.register -i input=NIR \
 type=raster file=list_nir.txt \
 start="2015-01-01" increment="1 months"

t.register -i input=MIR \
 type=raster file=list_mir.txt \
 start="2015-01-01" increment="1 months"
 
# print time series info
t.info input=NIR
t.info input=MIR

# estimate NDWI time series
t.rast.algebra basename=ndwi_monthly \
 expression="ndwi_monthly = if(NIR > 0 && MIR > 0, (float(NIR - MIR) / float(NIR + MIR)), null())"


#
# Frequency of inundation
#


# reclassify
t.rast.mapcalc -n input=ndwi_monthly output=flood \
 basename=flood expression="if(ndwi_monthly > 0.8, 1, null())"

# flooding frequency
t.rast.series input=flood output=flood_freq method=sum


#
# Regression between NDWI and NDVI
#


# install extension
g.extension extension=r.regression.series

# use in *nix
xseries=`t.rast.list input=ndvi_monthly_patch method=comma`
yseries=`t.rast.list input=ndwi_monthly method=comma`

r.regression.series xseries=$xseries yseries=$yseries \
 output=ndvi_ndwi_rsq method=rsq

# use in Windows
FOR /F %c IN ('t.rast.list "-u" "input=ndvi_monthly_patch" "method=comma"') DO SET xseries=%c
FOR /F %c IN ('t.rast.list "-u" "input=ndwi_monthly" "method=comma"') DO SET yseries=%c

r.regression.series xseries=%xseries% yseries=%yseries% \
 output=ndvi_ndwi_rsq method=rsq

