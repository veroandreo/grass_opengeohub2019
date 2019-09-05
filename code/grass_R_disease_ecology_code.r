########################################################################
# R commands for the session: 
# "Analysis of space-time satellite data for disease ecology 
# applications with GRASS GIS and R stats" at OpenGeoHub Summer School,
# Muenster (Germany)
#
# Modelling Aedes albopictus potential distribution in Northern Italy
#
# Original example contributed by Carol Garzon Lopez 
# Adapted by Veronica Andreo
#
# Date: October, 2018
# Updated: August, 2019
########################################################################


#
# Install and load required packages
#


# Install packages
install.packages("rgrass7")
install.packages("raster")
install.packages("sf")
install.packages("mapview")
install.packages("biomod2")

# Load libraries
library(rgrass7)
library(raster)
library(sf)
library(mapview)
library(biomod2)


#
# Read vector data
#


# Use sf for vectors
use_sf()

# Read vector layers
Aa_pres <- readVECT("aedes_albopictus")
background <- readVECT("background_points")


#
# Read raster data
#


# Use sp for rasters (stars support on the way)
use_sp()

# List rasters by pattern
worldclim <- execGRASS("g.list", 
                        parameters = list(
                        type = "raster",
                        pattern = "worldclim*"))

avg <- execGRASS("g.list", 
                  parameters = list(
                  type = "raster",
                  pattern = "avg*"))

median <- execGRASS("g.list", 
                     parameters = list(
                     type = "raster",
                     pattern = "median*", 
                     exclude = "*[1-5]"))

# Concatenate map lists
to_import <- c(attributes(worldclim)$resOut,
               attributes(avg)$resOut,
               attributes(median)$resOut)

# Read raster layers
predictors <- list()
for (i in to_import){
  predictors[i] <- raster(readRAST(i))
}

# Quick visualization in mapview
mapview(predictors[[3]]) + Aa_pres


#
# Data preparation and formatting
#


# Response variable
n_pres <- dim(Aa_pres)[1]
n_backg <- dim(background)[1]
 
myRespName <- 'Aedes.albopictus'

pres <- rep(1, n_pres)
backg <- rep(0, n_backg)
myResp <- c(pres, backg)

myRespXY <- rbind(st_coordinates(Aa_pres),
		          st_coordinates(background))


# Explanatory variables

# Stack raster layers
myExpl <- raster::stack(predictors)


# All together
myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                     expl.var = myExpl,
                                     resp.xy = myRespXY,
                                     resp.name = myRespName)


#
# Run model
#


# Set options
myBiomodOption <- BIOMOD_ModelingOptions(
  MAXENT.Phillips = 
    list( path_to_maxent.jar = "/home/veroandreo/software/maxent/maxent.jar",
          lq2lqptthreshold = 100,
          l2lqthreshold = 100))

# Run model
myBiomodModelOut <- BIOMOD_Modeling(
  myBiomodData,
  models = c('MAXENT.Phillips'),  
  models.options = myBiomodOption,
  NbRunEval=5,     
  DataSplit=80,
  VarImport=10,
  models.eval.meth = c('ROC','ACCURACY'),
  SaveObj = TRUE,
  rescal.all.models = FALSE,
  do.full.models = FALSE,
  modeling.id = paste(myRespName,"FirstModeling",sep="_"))

# Inspect the model
myBiomodModelOut


#
# Model evaluation
#


# Extract evaluation data
myBiomodModelEval <- get_evaluations(myBiomodModelOut)

# Accuracy
myBiomodModelEval["ACCURACY","Testing.data",,,]

# ROC: Receiver-operator curve
myBiomodModelEval["ROC","Testing.data",,,]

# Variable importance
get_variables_importance(myBiomodModelOut)


#
# Model predictions
#


# Set parameters for model projection
myBiomodProj <- BIOMOD_Projection(
                modeling.output = myBiomodModelOut, 
                new.env = myExpl,                     
                proj.name = "current", 
                selected.models = "all", 
                compress = FALSE, 
                build.clamping.mask = FALSE)

# Obtain predictions
mod_proj <- get_predictions(myBiomodProj)
mod_proj

# Plot predicted model
plot(mod_proj)
plot(mod_proj[[2]], main = "Predicted potential distribution")


#
# Optionally, write data back to GRASS GIS
#


# Only one layer
g <- as(mod_proj[[4]], 'SpatialGridDataFrame')
writeRAST(g, "maxent_albopictus", flags = "overwrite")

# Export all MaxEnt runs
for(i in seq_along(1:length(mod_proj@layers))){
  writeRAST(as(mod_proj[[i]], 'SpatialGridDataFrame'), 
            paste0("maxent_albopictus_", i, sep=""))
}

