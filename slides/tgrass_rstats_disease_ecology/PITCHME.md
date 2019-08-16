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
- `readVECT()` and `readRAST()`: read vector and raster maps from GRASS into *sp* objects 
- `writeVECT()` and `writeRAST()`: write *sp* objects into GRASS GIS database

<br>
An [update to support sf and stars](https://github.com/rsbivand/rgrass7/issues/6)
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
  - we do not need to initialize GRASS with `initGRASS()`, just type `R` or `rstudio &` in the GRASS GIS terminal
  - we access GRASS GIS funtionalities and database through `execGRASS()`
  - we use `readVECT()`, `readRAST()` to read data from GRASS DB to do analysis and plots in R
  - we write data (back) to GRASS GIS database with `writeVECT()` and `writeRAST()`


+++
- Using @color[#8EA33B](**GRASS GIS within an R session**), i.e. we connect to GRASS GIS database from within R (or RStudio).
  - we need to start GRASS GIS with `initGRASS()` (usually by creating a throw away location)
  - we access GRASS GIS funtionalities through `execGRASS()` (usually to apply them on data outside GRASS DB)


+++
For more detailed examples, check the following links:

- [R and GRASS](https://gitpitch.com/veroandreo/curso-grass-gis-rioiv/master?p=slides/06_R_grass&grs=gitlab#/4) presentation, course taught in Argentina (in English)
- [Example of GRASS - R for raster time series](https://grasswiki.osgeo.org/wiki/Temporal_data_processing/GRASS_R_raster_time_series_processing)


+++
### [**link2GI**](https://cran.r-project.org/web/packages/link2GI/index.html)

<br><br>
See the [vignette on how to set GRASS database with link2GI](https://github.com/gisma/link2gi2018/tree/master/R/vignette) for further details


---?image=assets/img/grass_template.png&position=bottom&size=100% 30%

## Hands-on to space-time analysis for disease ecology with GRASS and @fab[r-project text-12]


---
@snap[north-west span-60]
### Overview
@snapend

@snap[west span-100]
<br><br>
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
@ul[](false)
- Reconstructed MODIS LST by [mundialis](https://www.mundialis.de/en/) based on [Metz et al. 2017](https://www.mdpi.com/2072-4292/9/12/1333/htm)
- Daily average LST
- 1 km spatial resolution
@ulend
<br><br>
@snapend

@snap[east span-60 text-center]
<br>
![LST July 2018](assets/img/lst_north_italy_july2018.png)
<br>
@size[20px](LST, July 2018 - Northern Italy.)
<br>
@size[20px](Note SUHI over Milan city.)
@snapend

+++

### @fa[download text-green] get sample location and code @fa[download text-green]

<br>
- [eu_laea location with LST mapset](): download and unzip within your grassdata folder
- [GRASS code](https://raw.githubusercontent.com/veroandreo/grass_opengeohub2019/master/code/grass_R_disease_ecology_code.sh)
- [R code](https://raw.githubusercontent.com/veroandreo/grass_opengeohub2019/master/code/grass_R_disease_ecology_code.r)


---?code=code/grass_R_disease_ecology_code.sh&lang=bash&title=Importing species records

@[22-23](Set computational region)
@[25-26](Install v.in.pygbif)
@[28-32](Import data from GBIF)


---?code=code/grass_R_disease_ecology_code.sh&lang=bash&title=Creating random background points

@[40-43](Create buffer around *Aedes albopictus* records)
@[45-51](Create a vector mask to limit background points)
@[53-57](Substract buffers from vector mask)
@[59-63](Generate random background points)


+++
> **Task**: Display with different colors the GBIF records and the random points.

<br>
@img[span-80](assets/img/points_aedes_background.png)


---?code=code/grass_R_disease_ecology_code.sh&lang=bash&title=Create daily LST STRDS

@[71-76](Create time series)
@[78-81](Get list of maps)
@[83-87](Register maps in STRDS)
@[89-90](Get info about the STRDS)
@[92-96](Convert K to Celsius)


+++?code=code/grass_R_disease_ecology_code.sh&lang=bash&title=Generate environmental variables from LST STRDS

@[104-127](Long term monthly avg, min and max LST)
@[129-130](Install r.bioclim)
@[132-137](Estimate temperature related bioclimatic variables)
@[140-149](Annual spring warming)
@[151-154](Average spring warming)
@[157-166](Annual autumnal cooling)
@[168-171](Average autumnal cooling)
@[174-177](Install r.seasons)
@[179-186](Detect seasons: get map list per year)
@[188-195](Detect mosquito season)
@[197-205](Detect seasons: estimate length of mosquito season)
@[207-216](Average length of mosquito season)
@[219-226](Number of days with LSTmean >= 20 and <= 30)
@[228-234](Count how many times per year the condition is met)
@[236-239](Inspect values)
@[241-244](Mean number of days with LSTmean >= 20 and <= 30)
@[247-255](Number of consecutive days with LSTmean >= 35)
@[257-262](Replace values by zero)
@[264-270](Calculate consecutive days with LSTmean >= 35)
@[272-274](Inspect values)
@[276-279](Median number of consecutive days with LSTmean >= 35 (2014-2018))
@[]()
@[]()
@[]()
@[]()
@[]()
@[]()


+++?code=code/grass_R_disease_ecology_code.r&lang=r&title=Install and load packages

@[16-20](Install packages)
@[22-26](Load packages)


+++?code=code/grass_R_disease_ecology_code.r&lang=r&title=Initialize GRASS GIS

@[34-41](Set parameters to start GRASS)
@[43-50](Initialize GRASS GIS)


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Read vector and raster data

@[58-60](Read vector data)
@[62-71](Read raster data)


+++
> **Task**: Display raster maps and points in RStudio using **sf** and **mapview**


+++
![Mapview: LST + *A. albopictus* presence points](assets/img/mapview_LST_pres.png)


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Data formatting

@[83-94](Response variable)
@[96-104](Explanatory variables)


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Run Random Forest model

@[112-113](Default options)
@[115-128](Run model)


+++
> **Task**: Explore the model output


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Model evaluation

@[138-139](Extract all evaluation data)
@[141-142](TSS: True Skill Statistics)
@[144-145](ROC: Receiver-operator curve)
@[147-148](Variable importance)


---?code=code/grass_R_disease_ecology_code.r&lang=r&title=Model predictions

@[156-162](Model projection settings)
@[164-165](Obtain predictions from model)
@[167-168](Plot predicted potential distribution)


+++
![Predicted distribution with RF](assets/img/pred_distrib.png)


---
> **Task**: Explore algorithms available in `BIOMOD_Modeling()` and try with a different one. Compare the results. 


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
