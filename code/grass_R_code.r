########################################################################
# Commands for GRASS - R interface presentation and demo
# Author: Veronica Andreo
# Date: July - August, 2018
########################################################################


#
# Start R from GRASS
#


# Install packages
install.packages("rgrass7")
library("rgrass7")

# print grass session info
gmeta()

# set region
execGRASS("g.region", raster="lst", flags="p")

# generate random points and sample the datasets
execGRASS("v.random", output="samples", npoints=1000, flags = c("overwrite"))

# this will restrict sampling to the boundaries NC
# we are overwriting vector samples, so we need to use overwrite flag
execGRASS("v.random", output="samples", 
					  npoints=1000, 
					  restrict="nc_state", 
					  flags=c("overwrite"))

# create attribute table
execGRASS("v.db.addtable", map="samples", 
						   columns=c("elev_state_500m double precision", 
						   "ndvi double precision", 
						   "lst double precision"))

# sample individual rasters
execGRASS("v.what.rast", map="samples", raster="lst", column="lst")
execGRASS("v.what.rast", map="samples", raster="ndvi", column="ndvi")
execGRASS("v.what.rast", map="samples", raster="elev_state_500m", column="elev_state_500m")

# explore the dataset in R:
samples <- readVECT("samples")
str(samples)
summary(samples)
plot(samples@data[2:4])

# compute multivariate linear model:
linmodel <- lm(lst ~ elev_state_500m + ndvi, samples@data)
summary(linmodel)

# predict LST using this model:
execGRASS("r.mapcalc", 
          expression="lst_pred = 29.8 - 0.0042 * elev_state_500m - 0.0012 *ndvi",
          flags = c("overwrite"))

# set color ramp, read raster and plot
execGRASS("r.colors", map="lst_pred", color="celsius")
lst_pred <- readRAST("lst_pred")
plot(lst_pred)

# compare simple linear model to real data:
execGRASS("r.mapcalc", expression="diff = lst - lst_pred", flags = c("overwrite"))
execGRASS("r.colors", map="diff", color="differences")

# read raster and plot
diff <- readRAST("diff")
plot(diff)


#
# Start GRASS from R
#


# find out the path to the GRASS GIS library
# OSGeo4W users: nothing to do
# Linux, Mac OSX users:
grass74 --config path

# Call GRASS GIS 7 functionality from R
# define the GRASS settings:

## MS-Windows users:
library(rgrass7)
# initialisation and the use of North Carolina sample dataset
initGRASS(gisBase = "C:/OSGeo4W/apps/grass/grass74",
         gisDbase = "C:/Users/username/grassdata/",
         location = "nc_spm_08_grass7",
         mapset = "user1", 
         SG = "elevation")

## Linux, Mac OSX users:
library(rgrass7)
# initialisation and the use of North Carolina sample dataset
initGRASS(gisBase = "/usr/local/grass74", 
		  home = tempdir(), 
          gisDbase = "/home/veroandreo/grassdata/",
          location = "nc_spm_08_grass7", 
          mapset = "user1", 
          SG = "elevation")

# Note: the optional SG parameter is a 'SpatialGrid' object to define
# the 'DEFAULT_WIND' of the temporary location.

# set computational region to default
execGRASS("g.region", raster="elevation", flags=c("d","p"))
# alternatively:
# system("g.region -dp")

# verify metadata
gmeta()

# list available vector maps:
execGRASS("g.list", parameters = list(type = "vector"))

# list selected vector maps (wildcard):
execGRASS("g.list", parameters = list(type = "vector", 
					pattern = "elev*"))

# save selected vector maps into R vector:
my_vmaps <- execGRASS("g.list", parameters = list(type = "vector", 
												  pattern = "elev*"))
attributes(my_vmaps)
attributes(my_vmaps)$resOut

# list available raster maps:
execGRASS("g.list", parameters = list(type = "raster"))

# list selected raster maps (wildcard):
execGRASS("g.list", parameters = list(type = "raster", 
									  pattern = "lsat7_2002*"))

# get two raster maps into R space
ncdata <- readRAST(c("geology_30m", "elevation"), cat=c(TRUE, FALSE))

# calculate data and object summaries
summary(ncdata)
summary(ncdata$elevation)
summary(ncdata$geology_30m)

# verify the new R object:
str(ncdata)
str(ncdata@data)

# plot
image(ncdata, "elevation", col = terrain.colors(20))

# boxplot and histogram
boxplot(ncdata@data$elevation ~ ncdata@data$geology_30m, medlwd = 1)
hist(ncdata@data$elevation)

# query raster map and transfer result into R
goutput <- execGRASS("r.what", map="elev_state_500m", 
							   points="geodetic_pts", 
							   separator=",", intern=TRUE)
str(goutput)

# parse it
con <- textConnection(goutput)
go1 <- read.csv(con, header=FALSE)
str(go1)

# square root of elevation
ncdata$sqdem <- sqrt(ncdata$elevation)

# export data from R back into a GRASS raster map:
writeRAST(ncdata, "sqdemNC", zcol="sqdem", ignore.stderr=TRUE, flags = "overwrite")

# check that it was imported properly:
execGRASS("r.info", parameters=list(map="sqdemNC"))


#
# GRASS within R in batch mode
#


# load library
library(rgrass7)
# initialisation and the use of north carolina dataset
initGRASS(gisBase = "/usr/local/grass74", 
          home = tempdir(), 
          gisDbase = "/home/veroandreo/grassdata/",
          location = "nc_spm_08_grass7", 
          mapset = "user1", 
          SG="elevation",
          override = TRUE)
# set region to default
system("g.region -dp")
# verify
gmeta()
# read data into R
ncdata <- readRAST(c("geology_30m", "elevation"), cat=c(TRUE, FALSE))
# summary of geology map
summary(ncdata$geology_30m)
proc.time()
