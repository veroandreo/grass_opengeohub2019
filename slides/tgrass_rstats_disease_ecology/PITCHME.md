---?image=assets/img/grass_template.png&position=bottom&size=100% 30%
@title[Front page]

@snap[north span-100]
<br>
<h2>Analyzing space-time satellite data for disease ecology applications with @color[green](GRASS GIS) and R stats</h2>
@snapend

@snap[south message-box-white span-100]
Verónica Andreo
<br><br><br>
@size[30px](OpenGeoHub Summer School 2019, M&uuml;nster)
@snapend


---
@title[About the trainer]

@snap[west]
@css[bio-about](PhD in Biology<br>MSc in Remote Sensing and GIS<br>Researcher @ Tropical Medicine Institute<br>Applications of RS & GIS for disease ecology<br><br><i>Keywords:</i> RS, GIS, Time series, SDM,<br>Disease Ecology, Rodents, Hantavirus)
<br><br><br>
@css[bio-about](<a href="https://grass.osgeo.org/">GRASS GIS</a> Dev Team<br><a href="https://www.osgeo.org/">OSGeo</a> Charter member<br>FOSS4G enthusiast and advocate)
@snapend

@snap[east]
@css[bio-headline](About me)
<br><br>
![myphoto](assets/img/vero_round_small.png)
<br><br>
@css[bio-contact](@fa[github pad-fa] <a href="https://github.com/veroandreo/">veroandreo</a> @fa[twitter pad-fa] <a href="https://twitter.com/VeronicaAndreo">@VeronicaAndreo</a><br>@fa[envelope pad-fa] veroandreo@gmail.com)
@snapend


---?image=assets/img/grass_template.png&position=bottom&size=100% 30%
### GRASS and @fab[r-project text-12] for disease ecology


---
### [**rgrass7**](https://cran.r-project.org/web/packages/rgrass7/index.html)

<br>
- `initGRASS()`: starts a GRASS GIS session from R
- `execGRASS()`: executes GRASS GIS commands
- `gmeta()`: shows GRASS location metadata
- `readVECT()` and `readRAST()`: read vector and raster maps from GRASS into *sf/sp* objects 
- `writeVECT()` and `writeRAST()`: write *sf/sp* objects into GRASS GIS database

<br>
An [update to support stars for GRASS raster maps](https://github.com/rsbivand/rgrass7/issues/6)
is on the way! Kudos to Roger Bivand!


+++
GRASS GIS and @fab[r-project text-12] can be used together in two ways:
<br><br>
- Using [R within a GRASS GIS session](https://grasswiki.osgeo.org/wiki/R_statistics/rgrass7#R_within_GRASS)
- Using [GRASS GIS within an R session](https://grasswiki.osgeo.org/wiki/R_statistics/rgrass7#GRASS_within_R)

<br><br>
@size[22px](Details and examples at the <a href="https://grasswiki.osgeo.org/wiki/R_statistics/rgrass7">GRASS and R wiki</a>)


+++
- Using @color[#8EA33B](**R within a GRASS GIS session**), i.e. starting R (or RStudio) from the GRASS GIS terminal
<br><br>
  - we do not need to initialize GRASS with `initGRASS()`, just type `R` or `rstudio &` in the GRASS GIS terminal
  - we access GRASS GIS funtionalities and database through `execGRASS()`
  - we use `readVECT()`, `readRAST()` to read data from GRASS DB to do analysis and plots in R
  - we write data (back) to GRASS GIS database with `writeVECT()` and `writeRAST()`


+++
- Using @color[#8EA33B](**GRASS GIS within an R session**), i.e. we connect to GRASS GIS database from within R (or RStudio).
<br><br>
  - we need to start GRASS GIS with `initGRASS()` (usually by creating a throw away location)
  - we access GRASS GIS funtionalities through `execGRASS()` (usually to apply them on data outside GRASS DB)


+++
For more detailed examples check:
<br><br>
- [R and GRASS](https://gitpitch.com/veroandreo/curso-grass-gis-rioiv/master?p=slides/06_R_grass&grs=gitlab#/4) presentation
- [Example of GRASS - R for raster time series](https://grasswiki.osgeo.org/wiki/Temporal_data_processing/GRASS_R_raster_time_series_processing) wiki


+++
### [**link2GI**](https://cran.r-project.org/web/packages/link2GI/index.html)

<br><br>
See the [vignette on how to set GRASS database with link2GI](https://github.com/gisma/link2gi2018/tree/master/R/vignette) for further details


---?image=assets/img/grass_template.png&position=bottom&size=100% 30%
## Hands-on to space-time analysis for disease ecology with GRASS GIS and @fab[r-project text-12]


---
@snap[north-west span-60]
<br>
### Overview
@snapend

@snap[west span-100]
<br>
@ol[](false)
- Importing species records
- Creating random background points
- Creating environmental layers
- Reading data into R
- Model species distribution
- Model evaluation and visualization
@olend
@snapend


---
@snap[north span-100]
### Data for the session
@snapend

@snap[west span-50]
@ol[](false)
- Records of *Aedes albopictus* (Asian tiger mosquito) in Northern Italy from [GBIF](https://www.gbif.org/)
- Environmental layers derived from reconstructed daily MODIS LST products
@olend
@snapend

@snap[east span-50]
![Aedes](assets/img/aedes_albopictus.jpg)
@snapend


+++
@snap[north span-100]
### Data for the session: LST
@snapend

@snap[west span-40]
<br>
@ul[](false)
- MODIS LST reconstructed by [mundialis](https://www.mundialis.de/en/) based on [Metz et al. 2017](https://www.mdpi.com/2072-4292/9/12/1333/htm)
- Daily average LST
- 1 km spatial resolution
- Converted to Celsius degrees
@ulend
<br><br>
@snapend

@snap[east span-60 text-center]
<br><br>
![LST July 2018](assets/img/lst_north_italy_july2018.png)
<br>
@size[20px](LST, July 2018 - Northern Italy.)
@snapend


+++
### @fa[download text-green] get sample location and code @fa[download text-green]

<br>
- [eu_laea location with LST mapset](https://apps.mundialis.de/workshops/geostat2019/grassdata_eu_laea_northern_italy_LST_1km_daily_celsius_reconstructed.zip): download and unzip within your grassdata folder
- [GRASS code](https://raw.githubusercontent.com/veroandreo/grass_opengeohub2019/master/code/grass_R_disease_ecology_code.sh)
- [R code](https://raw.githubusercontent.com/veroandreo/grass_opengeohub2019/master/code/grass_R_disease_ecology_code.r)


---?code=code/grass_R_disease_ecology_code.sh&lang=bash&title=Importing species records and creating random background points

@[22-23](Set computational region)
@[25-26](Install v.in.pygbif)
@[28-32](Import data from GBIF)
@[40-43](Create buffer around *Aedes albopictus* records)
@[45-51](Create a vector mask to limit background points)
@[53-57](Substract buffers from vector mask)
@[59-63](Generate random background points)


+++
@img[span-70](assets/img/points_aedes_background.png)


---?code=code/grass_R_disease_ecology_code.sh&lang=bash&title=Create daily LST STRDS

@[71-76](Create time series)
@[78-81](Get list of maps)
@[83-87](Register maps in STRDS)
@[89-90](Get info about the STRDS)

Note:
    Let's do some quick visualization from the terminal. What would you do?


+++?code=code/grass_R_disease_ecology_code.sh&lang=bash&title=Generate environmental variables from LST STRDS

@[100-121](Long term monthly avg, min and max LST)
@[123-124](Install r.bioclim)
@[126-131](Estimate temperature related bioclimatic variables)
@[134-145](Annual spring warming)
@[147-150](Average spring warming)
@[153-164](Annual autumnal cooling)
@[166-169](Average autumnal cooling)
@[172-175](Install r.seasons)
@[177-184](Get map list per year)
@[186-193](Detect mosquito season)
@[195-203](Estimate length of mosquito season)
@[205-214](Average length of mosquito season)
@[217-224](Number of days with LSTmean >= 20 and <= 30)
@[226-232](Count how many times per year the condition is met)
@[234-237](Inspect values)
@[239-242](Average number of days with LSTmean >= 20 and <= 30)
@[245-253](Number of consecutive days with LSTmean >= 35)
@[255-260](Replace values by zero)
@[262-268](Calculate consecutive days with LSTmean >= 35)
@[270-272](Inspect values)
@[274-277](Median number of consecutive days with LSTmean >= 35)
@[280-289](Accumulation of degree days)
@[291-296](Get basic info and inspect values)
@[299-306](Detection of mosquito generations)
@[308-319](Identify generations)
@[321-336](Extract areas that have full generations)
@[338-354](Beginning and End of each mosquito generation)
@[356-364](Duration of each mosquito generation)
@[367-374](Maximum number of generations per pixel per year)
@[376-380](Median number of generations per pixel)
@[382-389](Median duration of generations per pixel per year)
@[391-395](Median duration of generations per pixel)
@[398-404](Start RStudio from within GRASS GIS)

Note:
    Show some plots, i.e., areas with full generations, 
    median number of generations per pixel,
    median duration of mosquito generation
   
   
+++?code=code/grass_R_disease_ecology_code.r&lang=r&title=Within R...

@[22-27](Install packages)
@[29-34](Load packages)
@[42-43](Use sf to read vector data)
@[45-47](Import *Ae. albopictus* and background points)
@[55-56](Use sp to read raster data)
@[58-73](List rasters by patterns)
@[75-78](Concatenate raster map lists)
@[80-84](Read raster maps)
@[86-87](Quick visualization in mapview)


+++
![Mapview: LST + *A. albopictus* presence points](assets/img/aedes_envvar_mapview.png)


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Data formatting

@[95-106](Response variable)
@[109-112](Explanatory variables)
@[115-119](Pasting altogether)


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=MaxEnt model

@[127-132](Set options)
@[134-146](Run model)
@[148-149](Inspect the model)
@[152-158](Extract all evaluation data)
@[160-161](Accuracy)
@[163-164](ROC: Receiver-operator curve)
@[166-167](Variable importance)


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Model predictions

@[175-182](Model projection settings)
@[184-186](Obtain predictions from model)
@[188-190](Plot predicted potential distribution)


+++
![Predicted distribution with MaxEnt](assets/img/aedes_maxent_runs.png)


+++
> **Task**: Explore the algorithms available in `BIOMOD_Modeling()` and try with a different one. Compare assumptions and results. 


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Write model predictions into GRASS GIS DB

@[193-200](Export only one MaxEnt run)
@[202-208](Export all MaxEnt runs)


---
## QUESTIONS?

<img src="assets/img/gummy-question.png" width="45%">


---
**Thanks for your attention!!**

![GRASS GIS logo](assets/img/grass_logo_alphab.png)


---
@snap[south span-50]
@size[18px](Presentation powered by)
<br>
<a href="https://gitpitch.com/">
<img src="assets/img/gitpitch_logo.png" width="20%"></a>
@snapend
