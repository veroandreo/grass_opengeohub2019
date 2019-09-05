#!/bin/bash

########################################################################
# GRASS GIS commands for the session: 
# "Analysis of space-time satellite data for disease ecology 
# applications with GRASS GIS and R stats" at OpenGeoHub Summer School,
# Muenster (Germany)
#
# Modelling Aedes albopictus potential distribution in Northern Italy
#
# Author: Veronica Andreo
#
# Date: August, 2019
########################################################################


#
# Download data from GBIF for Aedes albopictus in Northern Italy
#


# Set computational region
g.region -p raster=lst_2014.001_avg

# Install extension (requires pygbif: pip install pygbif)
g.extension extension=v.in.pygbif

# Import data from GBIF
v.in.pygbif output=aedes_albopictus \
  taxa="Aedes albopictus" \
  date_from="2014-01-01" \
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
  expression="rast_mask = if(lst_2014.001_avg, 1, null())"
  
r.to.vect input=rast_mask \
  output=vect_mask \
  type=area

# Subtract buffers from vector mask
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
  description="Average daily LST in degree C - 2014-2018"

# Get list of maps 
g.list type=raster \
  pattern="lst_201*" \
  output=list_lst.csv

# Register maps in strds  
t.register -i input=lst_daily \
  file=list_lst.csv \
  increment="1 days" \
  start="2014-01-01"

# Get info about the strds
t.info input=lst_daily


#
# Generate environmental variables from LST STRDS
#


## Bioclimatic variables
  
# Long term monthly avg, min and max LST
for i in $(seq -w 1 12) ; do 
  
  # average
  t.rast.series input=lst_daily \
    method=average \
    where="strftime('%m', start_time)='${i}'" \
    output=lst_average_${i}
  
  # minimum
  t.rast.series input=lst_daily \
    method=minimum \
    where="strftime('%m', start_time)='${i}'" \
    output=lst_minimum_${i}
  
  # maximum
  t.rast.series input=lst_daily \
    method=maximum \
    where="strftime('%m', start_time)='${i}'" \
    output=lst_maximum_${i}  

done

# Install extension
g.extension extension=r.bioclim
 
# Estimate temperature related bioclimatic variables
r.bioclim \
  tmin=$(g.list type=raster pattern="lst_minimum_??" separator=",") \
  tmax=$(g.list type=raster pattern="lst_maximum_??" separator=",") \
  tavg=$(g.list type=raster pattern="lst_average_??" separator=",") \
  output=worldclim_ 


## Spring warming

# Annual spring warming: slope(daily Tmean february-march-april)
t.rast.aggregate input=lst_daily \
  output=annual_spring_warming \
  basename=spring_warming \
  suffix=gran \
  method=slope \
  granularity="1 years" \
  where="strftime('%m',start_time)='02' or \
         strftime('%m',start_time)='03' or \
         strftime('%m', start_time)='04'"

# Average spring warming
t.rast.series input=annual_spring_warming \
  output=avg_spring_warming \
  method=average


## Autumnal cooling

# Annual autumnal cooling: slope(daily Tmean august-september-october)
t.rast.aggregate input=lst_daily \
  output=annual_autumnal_cooling \
  basename=autumnal_cooling \
  suffix=gran \
  method=slope \
  granularity="1 years" \
  where="strftime('%m',start_time)='08' or \
         strftime('%m',start_time)='09' or \
         strftime('%m', start_time)='10'"

# Average autumnal cooling
t.rast.series input=annual_autumnal_cooling \
  output=avg_autumnal_cooling \
  method=average


## Start/end and length of mosquito growing season

# Install extension
g.extension extension=r.seasons

# Detect seasons
for YEAR in $(seq 2014 2018) ; do 

  # Get map list per year
  t.rast.list -u lst_daily \
    columns=name \
    where="strftime('%Y',start_time)='${YEAR}'" \
    output=list_${YEAR}.txt

  # Mosquito season (threshold: 10C, min duration: 150 days)
  r.seasons file=list_${YEAR}.txt \
    prefix=mosq_season_${YEAR}_ \
    n=1 \
    nout=mosq_season_${YEAR} \
    threshold_value=10 \
    min_length=150 \
    max_gap=12

  # Length core season
  r.mapcalc expression="mosq_season_length_${YEAR}_1 = \
    mosq_season_${YEAR}_1_end1 - mosq_season_${YEAR}_1_start1 + 1"
  
  # Length extended season
  r.mapcalc expression="mosq_season_length_${YEAR}_2 = \
    mosq_season_${YEAR}_1_end2 - mosq_season_${YEAR}_1_start2 + 1" 
 
done

# Average length of mosquito season
r.series \
  input=$(g.list type=raster pattern=mosq_season_length*1 separator=",") \
  output=avg_mosq_season_1_length \
  method=average
  
r.series \
  input=$(g.list type=raster pattern=mosq_season_length*2 separator=",") \
  output=avg_mosq_season_2_length \
  method=average


## Number of days with LSTmean >= 20 and <= 30

# Keep only pixels meeting the condition
t.rast.algebra -n \
  expression="tmean_higher20_lower30 = if(lst_daily >= 20.0 && \
  lst_daily <= 30.0, 1, null())" \
  basename=tmean_higher20_lower30 \
  suffix=gran 

# Count how many times per year the condition is met
t.rast.aggregate input=tmean_higher20_lower30 \
  output=count_tmean_higher20_lower30 \
  basename=tmean_higher20_lower30 \
  suffix=gran \
  method=count \
  granularity="1 years"

# Inspect values
t.rast.list \
  count_tmean_higher20_lower30 \
  columns=name,start_time,end_time,min,max

# Average number of days with LSTmean >= 20 and <= 30
t.rast.series input=count_tmean_higher20_lower30 \
  output=avg_count_tmean_higher20_lower30 \
  method=average


## Number of consecutive days with LSTmean >= 33

# Create annual mask
t.rast.aggregate input=lst_daily \
  output=annual_mask \
  basename=annual_mask \
  suffix=gran \
  granularity="1 year" \
  method=count

# Replace values by zero
t.rast.mapcalc \
  input=annual_mask \
  output=annual_mask_0 \
  expression="if(annual_mask, 0)" \
  basename=annual_mask_0

# Calculate consecutive days with LSTmean >= 33
t.rast.algebra \
  expression="higher35_consec_days = annual_mask_0 {+,contains,l} \
  if(lst_daily >= 33.0 && lst_daily[-1] >= 33.0 || \
  lst_daily[1] >= 33.0 && lst_daily >= 33.0, 1, 0)" \
  basename=higher35_days \
  suffix=gran \
  nproc=7

# Inspect values
t.rast.list input=higher35_consec_days \
  columns=name,start_time,end_time,min,max

# Median number of consecutive days with LSTmean >= 33
t.rast.series input=higher35_consec_days \
  output=median_higher35_consec_days \
  method=median


## Growing Degree Days

# Accumulation of degree days
t.rast.accumulate -n input=lst_daily \
  output=mosq_daily_bedd \
  basename=mosq_daily_bedd \
  suffix=gran \
  start="2014-03-01" stop="2018-10-01" \
  cycle="7 months" offset="5 months" \
  method=bedd limits=11,30

# Get basic info
t.info input=mosq_daily_bedd

# Inspect values
t.rast.list input=mosq_daily_bedd \
  columns=name,start_time,end_time,min,max


## Detection of mosquito generations

# Arrays
cycle=($(seq 1 9))
cycle_beg=($(seq 1 300 2700))
cycle_end=($(seq 300 300 2700))
# Length of the array
count=${#cycle[@]}

for i in $(seq 1 $count) ; do

  echo "cycle: "${cycle[$i-1]}" - "${cycle_beg[$i-1]} ${cycle_end[$i-1]}

  # Identify generations
  t.rast.accdetect input=mosq_daily_bedd \
    occurrence=mosq_occurrence_cycle_${cycle[$i-1]} \
    indicator=mosq_indicator_cycle_${cycle[$i-1]} \
    basename=mosq_cycle_${cycle[$i-1]} \
    start="2014-03-01" stop="2018-10-01" \
    cycle="7 months" offset="5 months" \
    range=${cycle_beg[$i-1]},${cycle_end[$i-1]}

  # Extract areas that have full generations
  
  # Indicator takes values 1, 2 or 3 for start, middle and end of cycle
  t.rast.aggregate input=mosq_indicator_cycle_${cycle[$i-1]} \
    output=mosq_cycle${cycle[$i-1]}_yearly \
    basename=mosq_c${cycle[$i-1]}_yearly \
    granularity="1 year" \
    method=maximum \
    suffix=gran

  # Keep only complete generations
  t.rast.mapcalc input=mosq_cycle${cycle[$i-1]}_yearly \
    output=mosq_cycle${cycle[$i-1]}_yearly_clean \
    basename=mosq_clean_c${cycle[$i-1]} \
    expression="if(mosq_cycle${cycle[$i-1]}_yearly == 3, \
    ${cycle[$i-1]}, null())"
  
  # Duration of each mosquito generation
  
  # Beginning
  t.rast.aggregate input=mosq_occurrence_cycle_${cycle[$i-1]} \
    output=mosq_min_day_cycle${cycle[$i-1]} \
    basename=occ_min_day_c${cycle[$i-1]} \
    method=minimum \
    granularity="1 year" \
    suffix=gran
	
  # End
  t.rast.aggregate input=mosq_occurrence_cycle_${cycle[$i-1]} \
    output=mosq_max_day_cycle${cycle[$i-1]} \
    basename=occ_max_day_c${cycle[$i-1]} \
    method=maximum \
    granularity="1 year" \
    suffix=gran
	
  # Difference
  t.rast.mapcalc \
    input=mosq_min_day_cycle${cycle[$i-1]},mosq_max_day_cycle${cycle[$i-1]} \
    output=mosq_duration_cycle${cycle[$i-1]} \
    basename=mosq_duration_cycle${cycle[$i-1]} \
    expression="mosq_max_day_cycle${cycle[$i-1]} - \
    mosq_min_day_cycle${cycle[$i-1]} + 1"

done


# Maximum number of generations per pixel per year
for i in $(seq 1 5) ; do 
  g.list type=raster separator="," pattern="mosq_clean_c*_${i}"
  r.series \
    input=$(g.list type=raster pattern="mosq_clean_c*_${i}" separator=",") \
    output=mosq_generations_${i} \
    method=maximum
done

# Median number of generations per pixel
r.series \
  input=$(g.list type=raster pattern="mosq_generations_*" separator=",") \
  output=median_mosq_generations \
  method=median

# Median duration of generations per year per pixel
for i in $(seq 1 5) ; do 
  g.list type=raster separator="," pattern="mosq_duration_cycle*_${i}"
  r.series \
    input=$(g.list type="raster pattern=mosq_duration_cycle*_${i}" separator=",") \
    output=mosq_generation_median_duration_${i} \
    method=median
done

# Median duration of generations per pixel
r.series \
  input=$(g.list type=raster pattern="mosq_generation_median_duration_*" separator=",") \
  output=median_mosq_generation_duration \
  method=median


#
# Start RStudio from within GRASS GIS
#

rstudio &
