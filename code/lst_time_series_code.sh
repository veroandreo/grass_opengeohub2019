#!/bin/bash

########################################################################
# Commands for the TGRASS lecture at GEOSTAT Summer School in Prague
# Author: Veronica Andreo
# Date: July - August, 2018 - Edited October, 2018 and July, 2019 
########################################################################


########### Before the workshop (done for you in advance) ##############

# Install i.modis add-on (requires pymodis library - www.pymodis.org)
g.extension extension=i.modis

# Download and import MODIS LST data 
# Note: User needs to be registered at Earthdata: 
# https://urs.earthdata.nasa.gov/users/new
i.modis.download settings=$HOME/gisdata/SETTING \
  product=lst_terra_monthly_5600 \
  tile=h11v05 \
  startday=2015-01-01 endday=2017-12-31 \
  folder=/tmp

# Import LST Day 
# optionally also LST Night: spectral="( 1 1 0 0 0 1 0 0 0 0 0 0 0 )"
i.modis.import files=/tmp/listfileMOD11B3.006.txt \
  spectral="( 1 0 0 0 0 0 0 0 0 0 0 0 )"


############## For the workshop (what you have to do) ##################

## Download the ready to use mapset 'modis_lst' from:
## https://gitlab.com/veroandreo/grass-gis-geostat-2018
## and unzip it into North Carolina full LOCATION 'nc_spm_08_grass7'

# Get list of raster maps in the 'modis_lst' mapset
g.list type=raster

# Get info from one of the raster maps
r.info map=MOD11B3.A2015060.h11v05.single_LST_Day_6km


## Region settings and MASK

# Set region to NC state boundary with LST maps' resolution
g.region -p vector=nc_state \
  align=MOD11B3.A2015060.h11v05.single_LST_Day_6km

#~ projection: 99 (Lambert Conformal Conic)
#~ zone:       0
#~ datum:      nad83
#~ ellipsoid:  a=6378137 es=0.006694380022900787
#~ north:      323380.12411493
#~ south:      9780.12411493
#~ west:       122934.46411531
#~ east:       934934.46411531
#~ nsres:      5600
#~ ewres:      5600
#~ rows:       56
#~ cols:       145
#~ cells:      8120

# Set a MASK to NC state boundary
r.mask vector=nc_state

# you should see this statement in the terminal from now on
#~ [Raster MASK present]


## Time series

# Create the STRDS
t.create type=strds temporaltype=absolute output=LST_Day_monthly \
  title="Monthly LST Day 5.6 km" \
  description="Monthly LST Day 5.6 km MOD11B3.006, 2015-2017"

# Check if the STRDS is created
t.list type=strds

# Get info about the STRDS
t.info input=LST_Day_monthly


## Add time stamps to maps (i.e., register maps)

# in Unix systems
t.register -i input=LST_Day_monthly \
 maps=`g.list type=raster pattern="MOD11B3*LST_Day*" separator=comma` \
 start="2015-01-01" increment="1 months"

# in MS Windows, first create the list of maps
g.list type=raster pattern="MOD11B3*LST_Day*" output=map_list.txt
t.register -i input=LST_Day_monthly \
 file=map_list.txt start="2015-01-01" increment="1 months"

# Check info again
t.info input=LST_Day_monthly

# Check the list of maps in the STRDS
t.rast.list input=LST_Day_monthly

# Check min and max per map
t.rast.list input=LST_Day_monthly columns=name,min,max

 
## Let's see a graphical representation of our STRDS
g.gui.timeline inputs=LST_Day_monthly


## Temporal calculations: K*50 to Celsius 
 
# Re-scale data to degrees Celsius
t.rast.algebra basename=LST_Day_monthly_celsius suffix=gran\
  expression="LST_Day_monthly_celsius = LST_Day_monthly * 0.02 - 273.15"

# Check info
t.info LST_Day_monthly_celsius


## Time series plots

# LST time series plot for the city center of Raleigh
g.gui.tplot strds=LST_Day_monthly_celsius \
  coordinates=641428.783478,229901.400746 \
  title="Monthly LST. City center of Raleigh, NC " \
  xlabel="Time" ylabel="LST" \
  csv=raleigh_monthly_LST.csv


## Get specific lists of maps

# Maps with minimum value lower than or equal to 5
t.rast.list input=LST_Day_monthly_celsius order=min \
 columns=name,start_time,min where="min <= '5.0'"

#~ name|start_time|min
#~ LST_Day_monthly_celsius_2015_02|2015-02-01 00:00:00|-1.31
#~ LST_Day_monthly_celsius_2017_01|2017-01-01 00:00:00|-0.89
#~ LST_Day_monthly_celsius_2015_01|2015-01-01 00:00:00|-0.25
#~ LST_Day_monthly_celsius_2016_01|2016-01-01 00:00:00|-0.17
#~ LST_Day_monthly_celsius_2016_02|2016-02-01 00:00:00|0.73
#~ LST_Day_monthly_celsius_2017_12|2017-12-01 00:00:00|1.69
#~ LST_Day_monthly_celsius_2016_12|2016-12-01 00:00:00|3.45

# Maps with maximum value higher than 30
t.rast.list input=LST_Day_monthly_celsius order=max \
 columns=name,start_time,max where="max > '30.0'"

#~ name|start_time|max
#~ LST_Day_monthly_celsius_2017_04|2017-04-01 00:00:00|30.85
#~ LST_Day_monthly_celsius_2017_09|2017-09-01 00:00:00|32.45
#~ LST_Day_monthly_celsius_2016_05|2016-05-01 00:00:00|32.97
#~ LST_Day_monthly_celsius_2015_09|2015-09-01 00:00:00|33.49
#~ LST_Day_monthly_celsius_2017_05|2017-05-01 00:00:00|34.35
#~ LST_Day_monthly_celsius_2015_05|2015-05-01 00:00:00|34.53
#~ LST_Day_monthly_celsius_2017_08|2017-08-01 00:00:00|35.81
#~ LST_Day_monthly_celsius_2016_09|2016-09-01 00:00:00|36.33
#~ LST_Day_monthly_celsius_2016_08|2016-08-01 00:00:00|36.43

# Maps between two given dates
t.rast.list input=LST_Day_monthly_celsius columns=name,start_time \
 where="start_time >= '2015-05' and start_time <= '2015-08-01 00:00:00'"

#~ name|start_time
#~ LST_Day_monthly_celsius_2015_05|2015-05-01 00:00:00
#~ LST_Day_monthly_celsius_2015_06|2015-06-01 00:00:00
#~ LST_Day_monthly_celsius_2015_07|2015-07-01 00:00:00
#~ LST_Day_monthly_celsius_2015_08|2015-08-01 00:00:00

# Maps from January
t.rast.list input=LST_Day_monthly_celsius columns=name,start_time \
 where="strftime('%m', start_time)='01'"

#~ name|start_time
#~ LST_Day_monthly_celsius_2015_01|2015-01-01 00:00:00
#~ LST_Day_monthly_celsius_2016_01|2016-01-01 00:00:00
#~ LST_Day_monthly_celsius_2017_01|2017-01-01 00:00:00


## Descriptive statistics for STRDS

# Print univariate stats for maps within STRDS
t.rast.univar input=LST_Day_monthly_celsius

#~ id|start|end|mean|min|max|mean_of_abs|stddev|variance|coeff_var|sum|null_cells|cells
#~ LST_Day_monthly_celsius_2015_01@modis_lst|2015-01-01 00:00:00|2015-02-01 00:00:00|7.76419671326958|-0.25|11.89|7.76431935246506|1.77839501064634|3.1626888138918|22.905074102604|31654.6300000001|4043|8120
#~ LST_Day_monthly_celsius_2015_02@modis_lst|2015-02-01 00:00:00|2015-03-01 00:00:00|7.23198184939909|-1.30999999999995|12.37|7.23262447878345|2.05409396877013|4.21930203253782|28.4029193040744|29484.7900000001|4043|8120
#~ LST_Day_monthly_celsius_2015_03@modis_lst|2015-03-01 00:00:00|2015-04-01 00:00:00|16.0847706647044|8.27000000000004|22.0700000000001|16.0847706647044|2.22005586700676|4.92864805263112|13.8022226942802|65577.61|4043|8120
#~ LST_Day_monthly_celsius_2015_04@modis_lst|2015-04-01 00:00:00|2015-05-01 00:00:00|22.2349889624724|10.05|28.21|22.2349889624724|2.14784334478279|4.6132310337277|9.65974549574931|90652.05|4043|8120
#~ LST_Day_monthly_celsius_2015_05@modis_lst|2015-05-01 00:00:00|2015-06-01 00:00:00|26.7973632572971|16.89|34.53|26.7973632572971|2.43267997291578|5.91793185062553|9.07805723107235|109252.85|4043|8120

# Get extended statistics
t.rast.univar -e input=LST_Day_monthly_celsius

# Write the univariate stats output to a csv file
t.rast.univar input=LST_Day_monthly_celsius separator=comma \
  output=stats_LST_Day_monthly_celsius.csv


## Temporal aggregations (full series)

# Get maximum LST in the STRDS
t.rast.series input=LST_Day_monthly_celsius \
  output=LST_Day_max method=maximum

# Get minimum LST in the STRDS
t.rast.series input=LST_Day_monthly_celsius \
  output=LST_Day_min method=minimum

# Change color pallete to celsius
r.colors map=LST_Day_min,LST_Day_max color=celsius


## Display the new maps with mapswipe and compare them to elevation

# LST_Day_max & elevation
g.gui.mapswipe first=LST_Day_max second=elev_state_500m

# LST_Day_min & elevation
g.gui.mapswipe first=LST_Day_min second=elev_state_500m


## Temporal operations with time variables

# Get month of maximum LST
t.rast.mapcalc -n inputs=LST_Day_monthly_celsius output=month_max_lst \
  expression="if(LST_Day_monthly_celsius == LST_Day_max, start_month(), null())" \
  basename=month_max_lst
 
# Get basic info
t.info month_max_lst

# Get the earliest month in which the maximum appeared (method minimum)
t.rast.series input=month_max_lst method=minimum output=max_lst_date

# Remove month_max_lst strds 
# we were only interested in the resulting aggregated map
t.remove -rf inputs=month_max_lst

# Note that the flags "-rf" force (immediate) removal of both 
# the STRDS and the maps registered in it.


## Display maps in a wx monitor

# Open a monitor
d.mon wx0

# Display the raster map
d.rast map=max_lst_date

# Display boundary vector map
d.vect map=nc_state type=boundary color=#4D4D4D width=2

# Add raster legend
d.legend -t raster=max_lst_date title="Month" \
  labelnum=6 title_fontsize=20 font=sans fontsize=18

# Add scale bar
d.barscale length=200 units=kilometers segment=4 fontsize=14

# Add North arrow
d.northarrow style=1b text_color=black

# Add text
d.text -b text="Month of maximum LST 2015-2017" \
  color=black align=cc font=sans size=12


## Temporal aggregation ( with granularity)
 
# 3-month mean LST
t.rast.aggregate input=LST_Day_monthly_celsius \
  output=LST_Day_mean_3month \
  basename=LST_Day_mean_3month suffix=gran \
  method=average granularity="3 months"

# Check info
t.info input=LST_Day_mean_3month

# Check map list
t.rast.list input=LST_Day_mean_3month

#~ name|mapset|start_time|end_time
#~ LST_Day_mean_3month_2015_01|modis_lst|2015-01-01 00:00:00|2015-04-01 00:00:00
#~ LST_Day_mean_3month_2015_04|modis_lst|2015-04-01 00:00:00|2015-07-01 00:00:00
#~ LST_Day_mean_3month_2015_07|modis_lst|2015-07-01 00:00:00|2015-10-01 00:00:00
#~ LST_Day_mean_3month_2015_10|modis_lst|2015-10-01 00:00:00|2016-01-01 00:00:00
#~ LST_Day_mean_3month_2016_01|modis_lst|2016-01-01 00:00:00|2016-04-01 00:00:00
#~ LST_Day_mean_3month_2016_04|modis_lst|2016-04-01 00:00:00|2016-07-01 00:00:00
#~ LST_Day_mean_3month_2016_07|modis_lst|2016-07-01 00:00:00|2016-10-01 00:00:00
#~ LST_Day_mean_3month_2016_10|modis_lst|2016-10-01 00:00:00|2017-01-01 00:00:00
#~ LST_Day_mean_3month_2017_01|modis_lst|2017-01-01 00:00:00|2017-04-01 00:00:00
#~ LST_Day_mean_3month_2017_04|modis_lst|2017-04-01 00:00:00|2017-07-01 00:00:00
#~ LST_Day_mean_3month_2017_07|modis_lst|2017-07-01 00:00:00|2017-10-01 00:00:00
#~ LST_Day_mean_3month_2017_10|modis_lst|2017-10-01 00:00:00|2018-01-01 00:00:00


## Display seasonal LST using frames

# Set STRDS color table to celsius degrees
t.rast.colors input=LST_Day_mean_3month color=celsius

# Start a new graphics monitor, the data will be rendered to
# /tmp/map.png image output file of size 640x360px
d.mon cairo out=frames.png width=640 height=360 resolution=4

# create a first frame
d.frame -c frame=first at=0,50,0,50
d.rast map=LST_Day_mean_3month_2015_07
d.vect map=nc_state type=boundary color=#4D4D4D width=2
d.text text='Jul-Sep 2015' color=black font=sans size=10

# create a second frame
d.frame -c frame=second at=0,50,50,100
d.rast map=LST_Day_mean_3month_2015_10
d.vect map=nc_state type=boundary color=#4D4D4D width=2
d.text text='Oct-Dec 2015' color=black font=sans size=10

# create a third frame
d.frame -c frame=third at=50,100,0,50
d.rast map=LST_Day_mean_3month_2015_01
d.vect map=nc_state type=boundary color=#4D4D4D width=2
d.text text='Jan-Mar 2015' color=black font=sans size=10

# create a fourth frame
d.frame -c frame=fourth at=50,100,50,100
d.rast map=LST_Day_mean_3month_2015_04
d.vect map=nc_state type=boundary color=#4D4D4D width=2 
d.text text='Apr-Jun 2015' color=black font=sans size=10

# release monitor
d.mon -r


## Time series animation

# Animation of seasonal LST
g.gui.animation strds=LST_Day_mean_3month


## Long term monthly averages (Monthly climatoligies)

# January average LST
t.rast.series input=LST_Day_monthly_celsius method=average \
  where="strftime('%m', start_time)='01'" \
  output=LST_average_jan

# for all months - *nix
for MONTH in `seq -w 1 12` ; do 
 t.rast.series input=LST_Day_monthly_celsius method=average \
  where="strftime('%m', start_time)='${MONTH}'" \
  output=LST_average_${MONTH}
done

# for all months - windows
FOR %c IN (01,02,03,04,05,06,07,08,09,10,11,12) DO (
 t.rast.series input=LST_Day_monthly_celsius method=average \
  where="strftime('%m', start_time)='%c'" \
  output=LST_average_%c
)


## Anomalies

# Get general average
t.rast.series input=LST_Day_monthly_celsius \
 method=average output=LST_average

# Get general SD
t.rast.series input=LST_Day_monthly_celsius \
 method=stddev output=LST_sd

# Get annual averages
t.rast.aggregate input=LST_Day_monthly_celsius \
 method=average granularity="1 years" \
 output=LST_yearly_average basename=LST_yearly_average

# Estimate annual anomalies
t.rast.algebra basename=LST_year_anomaly \
 expression="LST_year_anomaly = (LST_yearly_average - map(LST_average)) / map(LST_sd)"

# Set difference color table
t.rast.colors input=LST_year_anomaly color=difference

# Animation of annual anomalies
g.gui.animation strds=LST_year_anomaly


## Extract zonal statistics for areas

# Install v.strds.stats add-on
g.extension extension=v.strds.stats

# List maps in seasonal time series
t.rast.list LST_Day_mean_3month

# Extract summer average LST for Raleigh urban area
v.strds.stats input=urbanarea \
  strds=LST_Day_mean_3month \
  where="NAME == 'Raleigh'" \
  t_where="strftime('%m', start_time)='07'" \
  method=average \
  output=raleigh_summer_lst 


## SUHI vs surroundings from 2015 to 2017

# Create outside buffer - 30km
v.buffer input=raleigh_summer_lst \
  distance=30000 \
  output=raleigh_summer_lst_buf30

# Create otside buffer - 15km
v.buffer input=raleigh_summer_lst \
  distance=15000 \
  output=raleigh_summer_lst_buf15

# Remove 15km buffer area from the 30km buffer area
v.overlay ainput=raleigh_summer_lst_buf15 \
  binput=raleigh_summer_lst_buf30 \
  operator=xor \
  output=raleigh_surr

# Extract zonal stats for Raleigh surroundings
v.strds.stats input=raleigh_surr \
  strds=LST_Day_mean_3month \
  t_where="strftime('%m', start_time)='07'" \
  method=average \
  output=raleigh_surr_summer_lst 

# Take a look at mean summer LST in Raleigh and surroundings
v.db.select raleigh_summer_lst
v.db.select raleigh_surr_summer_lst




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

