########################################################################
# Commands for the FOSS4G workshop in Bucharest
# Author: Veronica Andreo
# Date: July, 2019 
########################################################################

# Load rgrass library
library(rgrass7)

# List available vectors
execGRASS("g.list", parameters = list(type="vector", mapset="."))

# Read in GRASS vector maps
raleigh_summer_lst <- readVECT("raleigh_summer_lst")
raleigh_surr_summer_lst <- readVECT("raleigh_surr_summer_lst")

# Quick and dirty plots
spplot(raleigh_summer_lst[,c(7:9)])
spplot(raleigh_surr_summer_lst[,c(4:6)])


# Convert to sf (https://github.com/r-spatial/sf)
library(sf)
raleigh_summer_lst <- st_as_sf(raleigh_summer_lst)
raleigh_surr_summer_lst <- st_as_sf(raleigh_surr_summer_lst)

# Remove columns we don't need 
raleigh_summer_lst <- raleigh_summer_lst[,-c(2:6)]
raleigh_surr_summer_lst <- raleigh_surr_summer_lst[,-c(2:3)]

# Paste the 2 vectors together
raleigh <- rbind(raleigh_summer_lst,raleigh_surr_summer_lst)

# Quick sf plot
plot(raleigh[c(2:4)], border = 'grey', axes = TRUE, key.pos = 4)


# Let's try with ggplot library
library(ggplot2)
library(dplyr)
library(tidyr)

# Arrange data from wide to long format
raleigh2 <- 
  raleigh %>% 
  select(LST_Day_mean_3month_2015_07_01_average, 
         LST_Day_mean_3month_2016_07_01_average,
         LST_Day_mean_3month_2017_07_01_average, 
         geometry) %>% 
  gather(YEAR, LST_summer, -geometry)

# Replace values in YEAR column
raleigh2$YEAR <- rep(c(2015:2017),2)

# Plot
ggplot() + 
  geom_sf(data = raleigh2, aes(fill = LST_summer)) + 
  facet_wrap(~YEAR, ncol = 3) +
  scale_fill_distiller(palette = "YlOrRd",
                       direction = 1) +
  scale_y_continuous()


# For quick visualizations with basemaps: mapview 
library(mapview)
mapview(raleigh)
