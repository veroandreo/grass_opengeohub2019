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


# Install packagess
install.packages("raster")
install.packages("rgrass7")
install.packages("mapview")
install.packages("biomod2")

# Load libraries
library(raster)
library(rgrass7)
library(mapview)
library(biomod2)


#
# Read vector data
#


# Use sf for vectors
use_sf()

# Read vector layers
Aa_pres <- readVECT("aedes_albopictus")
Aa_abs <- readVECT("background_points")


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
mapview(predictors[[1]]) + Aa_pres


#
# Data preparation and formatting
#


# Response variable
n_pres <- length(Aa_pres@data[,1])
n_abs <- length(Aa_abs@data[,1])
 
myRespName <- 'Aedes_albopictus'

pres <- rep(1, n_pres)
abs <- rep(0, n_abs)
myResp <- c(pres,abs)

myRespXY <- rbind(cbind(Aa_pres@coords[,1],Aa_pres@coords[,2]), 
				  cbind(Aa_abs@coords[,1],Aa_abs@coords[,2]))

# Explanatory variables

# Stack raster layers
myExpl_r <- raster::stack(predictors)

myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                     expl.var = myExpl,
                                     resp.xy = myRespXY,
                                     resp.name = myRespName)


#
# Run model
#


# Default options
myBiomodOption <- BIOMOD_ModelingOptions()

# Run model
myBiomodModelOut <- BIOMOD_Modeling(
  myBiomodData,
  models = c('RF'),  
  models.options = myBiomodOption,
  NbRunEval=2,     
  DataSplit=80,
  Prevalence=0.5,
  VarImport=3,
  models.eval.meth = c('TSS','ROC'),
  SaveObj = TRUE,
  rescal.all.models = TRUE,
  do.full.models = FALSE,
  modeling.id = paste(myRespName,"FirstModeling",sep=""))

myBiomodModelOut


#
# Model evaluation
#


# Extract all evaluation data
myBiomodModelEval <- get_evaluations(myBiomodModelOut)

# TSS: True Skill Statistics
myBiomodModelEval["TSS","Testing.data","RF",,]

# ROC: Receiver-operator curve
myBiomodModelEval["ROC","Testing.data",,,]

# Variable importance
get_variables_importance(myBiomodModelOut)


#
# Model predictions
#


myBiomodProj <- BIOMOD_Projection(
                modeling.output = myBiomodModelOut, 
                new.env = myExpl,                     
                proj.name = "current", 
                selected.models = "all", 
                compress = FALSE, 
                build.clamping.mask = FALSE)

mod_proj <- get_predictions(myBiomodProj)
mod_proj

# Plot predicted potential distribution
plot(mod_proj, main = "Predicted potential distribution - RF")

