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


