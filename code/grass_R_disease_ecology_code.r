########################################################################
# Commands for GRASS - R interface exercise: 
# Modelling Aedes albopictus potential distribution in NC
#
# Original example contributed by Carol Garzon Lopez 
# Adapted by Veronica Andreo
# Date: October, 2018
########################################################################


#
# Install and load required packages
#


# install packagess
# install.packages("raster")
# install.packages("rgrass7")
# install.packages("mapview")
# install.packages("biomod2")

# load libraries
library(raster)
library(rgrass7)
library(mapview)
library(biomod2)


#
# Set GRASS GIS variables for initialization
#


# path to GRASS binaries
myGRASS <- "/usr/local/grass74"
# path to GRASS database
myGISDbase <- "/home/veroandreo/grassdata/"
# path to location
myLocation <- "nc_spm_08_grass7"
# path to mapset
myMapset <- "user1"

# start GRASS GIS from R
initGRASS(gisBase = myGRASS, 
		  home = tempdir(), 
		  gisDbase = myGISDbase, 
		  location = myLocation, 
          mapset = myMapset,
          SG="elevation",
          override = TRUE)


#
# Read raster and vector data
#


# read vector layers
Aa_pres <- readVECT("aedes_albopictus_clip")
Aa_abs <- readVECT("background_points")

# read raster layers
LST_mean <- readRAST("LST_average")                                                                                                                                       
LST_min <- readRAST("LST_minimum")
LST_mean_summer <- readRAST("LST_average_sum")
LST_mean_winter <- readRAST("LST_average_win")
NDVI_mean <- readRAST("ndvi_average")
NDWI_mean <- readRAST("ndwi_average")




# visualize in mapview
mapview(NDVI_mean)
mapview(LST_mean) + Aa_pres


#
# Data preparation and formatting
#


# response variable
n_pres <- length(Aa_pres[,1])
n_abs <- length(Aa_abs@data[,1])
 
myRespName <- 'Aedes_albopictus'

pres <- rep(1, n_pres)
abs <- rep(0, n_abs)
myResp <- c(pres,abs)

myRespXY <- rbind(cbind(Aa_pres@coords[,1],Aa_pres@coords[,2]), 
				  cbind(Aa_abs@coords[,1],Aa_abs@coords[,2]))

# explanatory variables
myExpl <- stack(raster(LST_mean),raster(LST_min),
				raster(LST_mean_summer),raster(LST_mean_winter),
				raster(NDVI_mean),raster(NDWI_mean))

myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                     expl.var = myExpl,
                                     resp.xy = myRespXY,
                                     resp.name = myRespName)


#
# Run model
#


# default options
myBiomodOption <- BIOMOD_ModelingOptions()

# run model
myBiomodModelOut <- BIOMOD_Modeling(
  myBiomodData,
  models = c('RF'),  # algoritmos de analisis para hacer el modelo
  models.options = myBiomodOption,
  NbRunEval=2,     
  DataSplit=80,   # porcentaje de los datos para evaluación
  Prevalence=0.5,
  VarImport=3,
  models.eval.meth = c('TSS','ROC'), # metricas para evaluar el modelo
  SaveObj = TRUE,
  rescal.all.models = TRUE,
  do.full.models = FALSE,
  modeling.id = paste(myRespName,"FirstModeling",sep=""))

myBiomodModelOut


#
# Model evaluation
#


# extract all evaluation data
myBiomodModelEval <- get_evaluations(myBiomodModelOut)

# TSS: True Skill Statistics
myBiomodModelEval["TSS","Testing.data","RF",,]

# ROC: Receiver-operator curve
myBiomodModelEval["ROC","Testing.data",,,]

# variable importance
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

# plot predicted potential distribution
plot(mod_proj, main = "Predicted potential distribution - RF")

