#!/bin/bash

########################################################################
# Commands for GRASS - R interface exercise: 
# Modelling Aedes albopictus potential distribution in Northern Italy
# Author: Veronica Andreo
# Date: August, 2019
########################################################################


#
# Download data from GBIF for Aedes albopictus
#


# set computational region
g.region -p raster=lst_2010.001_avg

# install extension (requires pygbif: pip install pygbif)
g.extension extension=v.in.pygbif

# import data from gbif
v.in.pygbif output=aedes_albopictus \
  taxa="Aedes albopictus" \
  date_from="2010-01-01" \
  date_to="2018-12-31" 


# 
# Create background points
#


# create buffer around Aedes albopictus records
v.buffer input=aedes_albopictus \
  output=aedes_buffer \
  distance=1000

# create a vector to limit background points
r.mapcalc \
  expression="rast_mask = if(lst_2010.001_avg, 1, null())"
  
r.to.vect input=rast_mask \
  output=vect_mask \
  type=area

# generate random background points
v.random output=background_points \
  npoints=1000 \
  restrict=test \
  seed=3749


#
# Generate environmental variables
#


# Create time series 
t.create type=strds \
  temporaltype=absolute \
  output=lst_daily \
  title="Average Daily LST" \
  description="Average daily LST - 2010-2018"

# Get list of maps 
g.list type=raster \
  pattern="lst_*" \
  output=list_lst.txt

# Register maps in strds  
t.register -i input=lst_daily \
  file=list_lst.txt \
  increment="1 days" \
  start="2010-01-01"
  
# Overall average 
t.rast.series \
  input=lst_daily \
  output=lst_average \
  method=average

# Overall stddev 
t.rast.series \
  input=lst_daily \
  output=lst_sd \
  method=stddev
  
# Annual average 
t.rast.aggregate \
  input=lst_daily \
  output=lst_yearly_average \
  basename=lst_yearly_average \
  suffix=gran \
  granularity="1 years" \
  method=average

# Monthly climatology
for i in `seq -w 1 12` ; do 
 
  # average
  t.rast.series input=lst_daily \
    method=average \
    where="strftime('%m', start_time)='${i}'" \
    output=lst_average_${i}
 
done
 
# Seasonal climatology
for i in "12 01 02" "03 04 05" "06 07 08" "09 10 11" ; do
 
  set -- $i ; echo $1 $2 $3
 
  # average
  t.rast.series input=lst_daily \
	method=average \
	where="strftime('%m',start_time)='"${1}"' or strftime('%m',start_time)='"${2}"' or strftime('%m', start_time)='"${3}"'" \
	output=lst_seasonal_${1}
  
done

# Spring warming: slope(daily Tmean february-march-april)

t.rast.aggregate input=lst_daily \
  output=spring_warming \
  basename=spring_warming \
  method=slope \
  granularity="1 years" \
  where="strftime('%m',start_time)='02' or strftime('%m',start_time)='03' or strftime('%m', start_time)='04'" \
  suffix=gran

# Autumnal cooling: slope(daily Tmean august-september-october)
 
t.rast.aggregate input=lst_daily_average \
  output=autumnal_cooling basename=autumnal_cooling \
  method=slope granularity="1 years" \
  where="strftime('%m',start_time)='08' or strftime('%m',start_time)='09' or strftime('%m', start_time)='10'" \
  suffix=gran nprocs=7
 
# Start/end and length of growing season

# install extension
g.extension r.seasons

# mosquito season (threshold=10C, min duration 150 days)

for YEAR in ${YEARS[*]} ; do 

  t.rast.list -u lst_daily_average \
    columns=name \
    where="strftime('%Y',start_time)='${YEAR}'" \
    output=list_${YEAR}.txt
  
  r.seasons file=list_${YEAR} \
    prefix=mosq_season_${YEAR}_ \
    n=1 \
    nout=mosq_season_${YEAR}_ \
    threshold=14157.5 \
    min_length=150 \
    max_gap=12

  # length
  r.mapcalc expression="mosq_season_length_${YEAR}_1 = \
    mosq_season_${YEAR}_1_end1 - mosq_season_${YEAR}_1_start1 + 1"
  
  r.mapcalc expression="mosq_season_length_${YEAR}_2 = \
    mosq_season_${YEAR}_1_end2 - mosq_season_${YEAR}_1_start2 + 1" 

done

# wnv transmision season (threshold(EIPmedian)=14.3, min duration 120 days)

for YEAR in ${YEARS[*]} ; do 

  r.seasons file=list_${YEAR} \
    prefix=wnv_season_eip50_${YEAR}_ \
    n=1 \
    nout=wnv_season_eip50_${YEAR} \
    threshold=14372.5 \
    min_length=120 \
    max_gap=12
 
  # length
  r.mapcalc expression="wnv_season_length_eip50_${YEAR}_1 = \
    wnv_season_eip50_${YEAR}_1_end1 - wnv_season_eip50_${YEAR}_1_start1 + 1"
  
  r.mapcalc expression="wnv_season_length_eip50_${YEAR}_2 = \
    wnv_season_eip50_${YEAR}_1_end2 - wnv_season_eip50_${YEAR}_1_start2 + 1" 
 
done

# get median start and end of season

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

  # max season
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

t.rast.algebra \
  expression="tmean_higher20_lower30 = if(lst_daily >= 14657.5 && lst_daily <= 15157.5, lst_daily, null())" \
  basename=tmean_higher20_lower30 \
  suffix=gran

t.rast.aggregate input=tmean_higher20_lower30 \
  output=count_tmean_higher20_lower30 \
  basename=tmean_higher20_lower30 \
  method=count \
  granularity="1 years" \
  suffix=gran

t.info count_tmean_higher20_lower30

t.rast.list \
  count_tmean_higher20_lower30 \
  columns=name,start_time,end_time,min,max


# accumulation
t.rast.accumulate -n input=reconstructed_lst \
 output=mosq_daily_bedd \
 basename=mosq_daily_bedd \
 suffix=gran \
 start="2003-04-01" stop="2016-10-31" \
 cycle="7 months" offset="5 months" \
 granularity="1 day" \
 method=bedd limits=7,34 \
 scale=0.02 shift=-273.15 

t.info mosq_daily_bedd

t.rast.list mosq_daily_bedd \
  columns=name,start_time,end_time,min,max

# MOSQUITOES CYCLES detection

# arrays
cycle=(`seq 1 20`)
cycle_beg=(`seq 1 230 4600`)
cycle_end=(`seq 230 230 4600`)

# length of the array
count=${#cycle[@]}

for i in `seq 1 $count` ; do

  echo "cycle: "${cycle[$i-1]}" - "${cycle_beg[$i-1]} ${cycle_end[$i-1]}

  # identify cycles
  t.rast.accdetect input=mosq_daily_bedd \
    occurrence=mosq_occurrence_cycle${cycle[$i-1]} \
    indicator=mosq_indicator_cycle${cycle[$i-1]} \
    basename=mosq_cycle${cycle[$i-1]} \
    start="2003-04-01" stop="2016-10-31" \
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
    method=minimum granularity="1 year" \
    suffix=gran nprocs=7
	
  # end
  t.rast.aggregate input=mosq_occurrence_cycle${cycle[$i-1]} \
    output=mosq_max_day_cycle${cycle[$i-1]} \
    basename=occ_max_day_c${cycle[$i-1]} \
    method=maximum granularity="1 year" \
    suffix=gran nprocs=7
	
  # difference
  t.rast.mapcalc input=mosq_min_day_cycle${cycle[$i-1]},mosq_max_day_cycle${cycle[$i-1]} \
    output=mosq_duration_cycle${cycle[$i-1]} \
    basename=mosq_duration_cycle${cycle[$i-1]} \
    expression="mosq_max_day_cycle${cycle[$i-1]} - mosq_min_day_cycle${cycle[$i-1]} + 1"
    nprocs=7

done
  
### Transmision of WNV ###

#~ base T = 14.3 (12.6)
#~ cut-off = 32
#~ EIPmedian = 109
#~ lifespan = 12

# accumulation
t.rast.accumulate -n input=reconstructed_lst \
  output=wnv_daily_bedd \
  basename=wnv_daily_bedd suffix=gran \
  start="2003-04-01" stop="2016-10-31" \
  cycle="7 months" offset="5 months" \
  granularity="1 day" \
  method=bedd limits=14.3,32 \
  scale=0.02 shift=-273.15

# get max, divide by 109 to know max number of EIP per year 
t.info -g wnv_daily_bedd | grep max_

# EIP detection

# arrays
eip=(`seq 1 28`)
eip_beg=(`seq 1 109 2944`)
eip_end=(`seq 109 109 3052`)

# length of the array
count=${#eip[@]}

for i in `seq 1 $count` ; do
 
 # detect EIP
 t.rast.accdetect input=wnv_daily_bedd \
  occurrence=wnv_occurrence_eip${eip[$i-1]} \
  indicator=wnv_indicator_eip${eip[$i-1]} \
  basename=wnv_eip${eip[$i-1]} \
  start="2003-04-01" stop="2016-10-31" \
  cycle="7 months" offset="5 months" \
  range=${eip_beg[$i-1]},${eip_end[$i-1]}
   
 # extract areas with all EIP
 t.rast.aggregate input=indicator_eip${eip[$i-1]} \
  output=eip${eip[$i-1]}_yearly \
  basename=eip${eip[$i-1]}_yearly \
  granularity="1 year" method=maximum \
  suffix=gran nprocs=7

 t.rast.mapcalc input=eip${eip[$i-1]}_yearly \
  output=eip${eip[$i-1]}_yearly_clean \
  basename=eip${eip[$i-1]}_yearly_clean \
  expression="if(eip${eip[$i-1]}_yearly == 3, ${eip[$i-1]}, null())" \
  nprocs=7
 
 # estimate duration of EIP
 # first day
 t.rast.aggregate input=wnv_occurrence_eip${eip[$i-1]} \
  output=wnv_min_day_eip${eip[$i-1]} \
  basename=occ_min_day_eip${eip[$i-1]} \
  method=minimum granularity="1 year" \
  suffix=gran nprocs=6

 # last day
 t.rast.aggregate input=wnv_occurrence_eip${eip[$i-1]} \
  output=wnv_max_day_eip${eip[$i-1]} \
  basename=occ_max_day_eip${eip[$i-1]} \
  method=maximum granularity="1 year" \
  suffix=gran nprocs=6

 # difference
 t.rast.mapcalc input=wnv_min_day_eip${eip[$i-1]},wnv_max_day_eip${eip[$i-1]} \
  expression="wnv_max_day_eip${eip[$i-1]} - wnv_min_day_eip${eip[$i-1]}" \
  output=wnv_duration_eip${eip[$i-1]} \
  basename=wnv_duration_eip${eip[$i-1]} \
  nprocs=6	
 
 # min duration of each EIP and year of occurrence
 t.rast.series input=wnv_duration_eip${eip[$i-1]} \
  method=minimum output=wnv_min_duration_eip${eip[$i-1]}
 t.rast.series input=wnv_duration_eip${eip[$i-1]} \
  method=min_raster output=wnv_year_of_min_duration_eip${eip[$i-1]}
 
done


# add some example of counting consecutive days



# average LST
t.rast.series input=LST_Day_monthly_celsius@modis_lst method=average \
 output=LST_average --o

# minimum LST
t.rast.series input=LST_Day_monthly_celsius@modis_lst method=minimum \
 output=LST_minimum --o

# average LST of summer
t.rast.series input=LST_Day_monthly_celsius@modis_lst method=average \
 where="strftime('%m', start_time)='07' OR strftime('%m', start_time)='08' OR strftime('%m', start_time)='09'" \
 output=LST_average_sum --o

# average LST of winter
t.rast.series input=LST_Day_monthly_celsius@modis_lst method=average \
 where="strftime('%m', start_time)='12' OR strftime('%m', start_time)='01' OR strftime('%m', start_time)='02'" \
 output=LST_average_win --o 




### Some extra examples ###

## Example to count consecutive maps meeting a certain condition

# Create time series and register maps
t.create type=strds temporaltype=absolute \
  output=temperature_daily title="Daily Temperature" \
  description="Test dataset with daily temperature"

t.register -i type=raster input=temperature_daily \
  file=map_list.txt start="2014-03-07" \
  increment="1 days"

# Check general information of the daily strds
t.info type=strds input=temperature_daily

# Create weekly mask
t.rast.aggregate input=temperature_daily output=weekly_mask \
  basename=mask_week granularity="1 weeks" method=count

# Calculate consecutive days with negative temperatures
t.rast.algebra base=neg_temp_days \
  expression="consecutive_days = weekly_mask {+,contains,l} if(temperature_daily < -2 && temperature_daily[-1] < -2 || temperature_daily[1] < -2 && temperature_daily < -2, 1, 0)"

