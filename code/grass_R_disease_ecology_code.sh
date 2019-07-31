#!/bin/bash

########################################################################
# Commands for GRASS - R interface exercise: 
# Modelling Aedes albopictus potential distribution in NC
# Author: Veronica Andreo
# Date: October, 2018
########################################################################


#
# Download data from GBIF for Aedes albopictus
#


# install extension (requires pygbif: pip install pygbif)
g.extension extension=v.in.pygbif

# set region
g.region vector=nc_state align=MOD11B3.A2015001.h11v05.single_LST_Day_6km@modis_lst
r.mask vector=nc_state

# import data from gbif
v.in.pygbif output=aedes_albopictus taxa="Aedes albopictus" \
 date_from="2013-01-01" date_to="2018-09-30" 

# clip to NC state
v.clip input=aedes_albopictus clip=nc_state \
 output=aedes_albopictus_clip


# 
# Create background points
#


# create buffer around Aedes albopictus records
v.buffer input=aedes_albopictus_clip \
 output=aedes_buffer distance=3000

# generate random points
v.random output=background_points npoints=100 \
 restrict=nc_state seed=4836


#
# Generate environmental variables
#


# add modis_lst and modis_ndvi to path in user1 mapset
g.mapsets mapset=modis_lst,modis_ndvi operation=add

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

# average NDVI
t.rast.series input=ndvi_monthly_patch@modis_ndvi method=average \
 output=ndvi_average --o

# average NDWI
t.rast.series input=ndwi_monthly@modis_ndvi method=average \
 output=ndwi_average --o





### Some extra examples ###


## Example of t.rast.accumulate and t.rast.accdetect application

# Accumulation
t.rast.accumulate input=LST_Day_monthly output=lst_acc limits=15,32 \
start="2015-03-01" cycle="7 months" offset="5 months" basename=lst_acc \
suffix=gran scale=0.02 shift=-273.15 method=mean granularity="1 month"

# First cycle at 100°C - 190°C GDD
t.rast.accdetect input=lst_acc occ=insect_occ_c1 start="2015-03-01" \
cycle="7 months" range=100,200 basename=insect_c1 indicator=insect_ind_c1


## Example to count consecutive maps meeting a certain condition

# Create 100 maps with random values for temperatures - *nix
for map in `seq 1 100` ; do
 r.mapcalc -s expression="daily_temp_${map} = rand(-20,30)"
 echo daily_temp_${map} >> map_list.txt
done

# Create 100 maps with random values for temperatures - windows
FOR /L %s IN (1,1,100) DO (
 r.mapcalc -s expression="daily_temp_%s = rand(-20,30)";
 ECHO daily_temp_%s >> map_list.txt
)

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

