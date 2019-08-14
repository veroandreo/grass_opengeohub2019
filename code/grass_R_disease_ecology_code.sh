#!/bin/bash

########################################################################
# Commands for GRASS - R interface exercise: 
# Modelling Aedes albopictus potential distribution in Northern Italy
# Author: Veronica Andreo
# Date: August, 2019
########################################################################


#
# Download data from GBIF for Aedes albopictus in Northern Italy
#


# Set computational region
g.region -p raster=lst_2010.001_avg

# Install extension (requires pygbif: pip install pygbif)
g.extension extension=v.in.pygbif

# Import data from GBIF
v.in.pygbif output=aedes_albopictus \
  taxa="Aedes albopictus" \
  date_from="2010-01-01" \
  date_to="2018-12-31" 


# 
# Create background points
#


# Create buffer around Aedes albopictus records
v.buffer input=aedes_albopictus \
  output=aedes_buffer \
  distance=1000

# Create a vector mask to limit background points
r.mapcalc \
  expression="rast_mask = if(lst_2010.001_avg, 1, null())"
  
r.to.vect input=rast_mask \
  output=vect_mask \
  type=area

# Substract buffers from vector mask
v.overlay ainput=vect_mask \
  binput=aedes_buffer \
  operator=xor \
  output=mask_background

# Generate random background points
v.random output=background_points \
  npoints=1000 \
  restrict=mask_background \
  seed=3749


#
# Create daily LST STRDS
#


# Create time series 
t.create type=strds \
  temporaltype=absolute \
  output=lst_daily \
  title="Average Daily LST" \
  description="Average daily LST - 2010-2018"

# Get list of maps 
g.list type=raster \
  pattern="lst_*avg" \
  output=list_lst.txt

# Register maps in strds  
t.register -i input=lst_daily \
  file=list_lst.txt \
  increment="1 days" \
  start="2010-01-01"

# Get info about the strds
t.info input=lst_daily

# Convert K to Celsius
t.rast.algebra \
  expression="lst_daily_celsius = lst_daily * 0.02 - 273.15" \
  basename=lst suffix=gran


#
# Generate environmental variables from LST STRDS
#

  
# Monthly climatology to feed r.bioclim
for i in `seq -w 1 12` ; do 
  
  # average
  t.rast.series input=lst_daily_celsius \
    method=average \
    where="strftime('%m', start_time)='${i}'" \
    output=lst_average_${i}
  
  # minimum
  t.rast.series input=lst_daily_celsius \
    method=minimum \
    where="strftime('%m', start_time)='${i}'" \
    output=lst_minimum_${i}
  
  # maximum
  t.rast.series input=lst_daily_celsius \
    method=maximum \
    where="strftime('%m', start_time)='${i}'" \
    output=lst_maximum_${i}  

done

# Bioclimatic variables

# Install extension
g.extension extension=r.bioclim
 
# Estimate Temperature related biclimatic variables
r.bioclim \
  tmin=`g.list type=raster pattern="lst_minimum_??" separator=,` \
  tmax=`g.list type=raster pattern="lst_maximum_??" separator=,` \
  tavg=`g.list type=raster pattern="lst_average_??" separator=,` \
  toutscale=1  


# Annual spring warming: slope(daily Tmean february-march-april)
t.rast.aggregate input=lst_daily_celsius \
  output=annual_spring_warming \
  basename=spring_warming \
  method=slope \
  granularity="1 years" \
  where="strftime('%m',start_time)='02' or strftime('%m',start_time)='03' or strftime('%m', start_time)='04'" \
  suffix=gran

# Average spring warming
t.rast.series input=annual_spring_warming \
  output=average_spring_warming \
  method=average


# Annual autumnal cooling: slope(daily Tmean august-september-october)
t.rast.aggregate input=lst_daily_celsius \
  output=annual_autumnal_cooling \
  basename=autumnal_cooling \
  method=slope \
  granularity="1 years" \
  where="strftime('%m',start_time)='08' or strftime('%m',start_time)='09' or strftime('%m', start_time)='10'" \
  suffix=gran

# Average autumnal cooling
t.rast.series input=annual_autumnal_cooling \
  output=average_autumnal_cooling \
  method=average


# Start/end and length of mosquito growing season

# Install extension
g.extension extension=r.seasons

YEARS=`seq 2010 2018`

for YEAR in ${YEARS[*]} ; do 

  t.rast.list -u lst_daily_celsius \
    columns=name \
    where="strftime('%Y',start_time)='${YEAR}'" \
    output=list_${YEAR}.txt

  # mosquito season (threshold=10C, min duration 150 days)
  r.seasons file=list_${YEAR} \
    prefix=mosq_season_${YEAR}_ \
    n=1 \
    nout=mosq_season_${YEAR}_ \
    threshold=10 \
    min_length=150 \
    max_gap=12

  # length
  r.mapcalc expression="mosq_season_length_${YEAR}_1 = \
    mosq_season_${YEAR}_1_end1 - mosq_season_${YEAR}_1_start1 + 1"
  
  r.mapcalc expression="mosq_season_length_${YEAR}_2 = \
    mosq_season_${YEAR}_1_end2 - mosq_season_${YEAR}_1_start2 + 1" 

  # WNV transmision season (threshold(EIPmedian)=14.3, min duration 120 days)
  r.seasons file=list_${YEAR} \
    prefix=wnv_season_eip50_${YEAR}_ \
    n=1 \
    nout=wnv_season_eip50_${YEAR} \
    threshold=14.3 \
    min_length=120 \
    max_gap=12
 
  # length
  r.mapcalc expression="wnv_season_length_eip50_${YEAR}_1 = \
    wnv_season_eip50_${YEAR}_1_end1 - wnv_season_eip50_${YEAR}_1_start1 + 1"
  
  r.mapcalc expression="wnv_season_length_eip50_${YEAR}_2 = \
    wnv_season_eip50_${YEAR}_1_end2 - wnv_season_eip50_${YEAR}_1_start2 + 1" 
 
done

# Median start and end of season
for i in "mosq" "wnv" ; do 

  # core season
  r.series \
    input=`g.list type=raster sep=comma pattern=${i}_season_20??_1_start1` \
    output=${i}_season_median_start1 \
    method=median

  r.series \
    input=`g.list type=raster sep=comma pattern=${i}_season_20??_1_end1` \
    output=${i}_season_median_end1 \
    method=median

  # extended season
  r.series \
    input=`g.list type=raster sep=comma pattern=${i}_season_20??_1_start2` \
    output=${i}_season_median_start2 \
    method=median

  r.series \
    input=`g.list type=raster sep=comma pattern=${i}_season_20??_1_end2` \
    output=${i}_season_median_end2 \
    method=median
 
done


# Number of days with Tmean >= 20 <= 30 (optimal develop T mosquitoes)

# Keep only pixels meeting the condition
t.rast.algebra \
  expression="tmean_higher20_lower30 = if(lst_daily_celsius >= 20 && lst_daily <= 30, lst_daily_celsius, null())" \
  basename=tmean_higher20_lower30 \
  suffix=gran

# Count how many times per year the condition is met
t.rast.aggregate input=tmean_higher20_lower30 \
  output=count_tmean_higher20_lower30 \
  basename=tmean_higher20_lower30 \
  method=count \
  granularity="1 years" \
  suffix=gran

# Inspect values
t.rast.list \
  count_tmean_higher20_lower30 \
  columns=name,start_time,end_time,min,max


# Number of consecutive days with Tmean >= 35

# Create annual mask
t.rast.aggregate input=lst_daily \
  output=annual_mask \
  basename=annual_mask suffix=gran \
  granularity="1 year" \
  method=count

# Calculate consecutive days with Tmean >= 35
t.rast.algebra basename=higher35_days suffix=gran \
  expression="higher35_consec_days = annual_mask {+,contains,l} if(lst_daily_celsius >= 35.0 && lst_daily_celsius[-1] >= 35.0 || lst_daily_celsius[1] >= 35.0 && lst_daily_celsius >= 35.0, 1, 0)"

# Inspect values
t.rast.list input=higher35_consec_days \
  columns=name,start_time,end_time,min,max

# Median number of consecutive days with LSTmean >= 35 (2010-2018)
t.rast.series input=higher35_consec_days \
  output=_median_higher35_consec_days \
  method=median


# Growing Degree Days

# Accumulation of degree days
t.rast.accumulate -n input=lst_daily_celsius \
  output=mosq_daily_bedd \
  basename=mosq_daily_bedd \
  suffix=gran \
  start="2010-03-01" stop="2018-09-30" \
  cycle="7 months" offset="5 months" \
  granularity="1 day" \
  method=bedd limits=10,30

t.info mosq_daily_bedd

t.rast.list mosq_daily_bedd \
  columns=name,start_time,end_time,min,max


# Mosquito cycles detection (Full cycle: 1350 DD)

# arrays
cycle=(`seq 1 5`)
cycle_beg=(`seq 1 1350 4600`)
cycle_end=(`seq 1350 1350 4600`)

# length of the array
count=${#cycle[@]}

for i in `seq 1 $count` ; do

  echo "cycle: "${cycle[$i-1]}" - "${cycle_beg[$i-1]} ${cycle_end[$i-1]}

  # identify cycles
  t.rast.accdetect input=mosq_daily_bedd \
    occurrence=mosq_occurrence_cycle${cycle[$i-1]} \
    indicator=mosq_indicator_cycle${cycle[$i-1]} \
    basename=mosq_cycle${cycle[$i-1]} \
    start="2010-03-01" stop="2018-09-30" \
    cycle="7 months" offset="5 months" \
    range=${cycle_beg[$i-1]},${cycle_end[$i-1]}

  # yearly spatial occurrence 

  # extract areas that have full cycles
  # indicator takes 1, 2 or 3 for start, middle and end of cycle
  t.rast.aggregate input=mosq_indicator_cycle${cycle[$i-1]} \
    output=mosq_cycle${cycle[$i-1]}_yearly \
    basename=mosq_c${cycle[$i-1]}_yearly \
    granularity="1 year" \
    method=maximum \
    suffix=gran

  # keep only complete cycles
  t.rast.mapcalc input=mosq_cycle${cycle[$i-1]}_yearly \
    output=mosq_cycle${cycle[$i-1]}_yearly_clean \
    basename=mosq_clean_c${cycle[$i-1]} \
    expression="if(mosq_cycle${cycle[$i-1]}_yearly == 3, ${cycle[$i-1]}, null())"
  
  # duration of the mosquito cycle
	
  # beginning
  t.rast.aggregate input=mosq_occurrence_cycle${cycle[$i-1]} \
    output=mosq_min_day_cycle${cycle[$i-1]} \
    basename=occ_min_day_c${cycle[$i-1]} \
    method=minimum \
    granularity="1 year" \
    suffix=gran
	
  # end
  t.rast.aggregate input=mosq_occurrence_cycle${cycle[$i-1]} \
    output=mosq_max_day_cycle${cycle[$i-1]} \
    basename=occ_max_day_c${cycle[$i-1]} \
    method=maximum \
    granularity="1 year" \
    suffix=gran
	
  # difference
  t.rast.mapcalc input=mosq_min_day_cycle${cycle[$i-1]},mosq_max_day_cycle${cycle[$i-1]} \
    output=mosq_duration_cycle${cycle[$i-1]} \
    basename=mosq_duration_cycle${cycle[$i-1]} \
    expression="mosq_max_day_cycle${cycle[$i-1]} - mosq_min_day_cycle${cycle[$i-1]} + 1"

done


# Start RStudio from within GRASS GIS
rstudio &


