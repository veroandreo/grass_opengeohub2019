---?image=assets/img/grass_template.png&position=bottom&size=100% 30%
@title[Front page]

@snap[north span-100]
<br>
<h2>Analyzing space-time satellite data with @color[green](GRASS GIS) for environmental monitoring</h2>
@snapend

@snap[south message-box-white]
Verónica Andreo
<br><br><br><br>
@size[30px](OpenGeoHub Summer School 2019, M&uuml;nster)
@snapend


---
@title[The TGRASS framework]

## The TGRASS framework

@ul
- TGRASS is the temporal enabled GRASS GIS designed to easily handle time series data
- TGRASS is fully @color[#8EA33B](based on metadata) and does not duplicate any dataset
- @color[#8EA33B](Snapshot) approach, i.e., adds time stamps to maps
- A collection of time stamped maps (snapshots) of the same variable are called @color[#8EA33B](space-time datasets or STDS)
- Maps in a STDS can have different spatial and temporal extents
@ulend

<!---
TGRASS uses an SQL database to store the temporal and spatial extension
of STDS, as well as the topological relationships among maps and among
STDS in each mapset.
--->


+++
@title[STDS]

## @fa[layer-group text-green] Space-time datasets

- Space time raster datasets (**ST@color[#8EA33B](R)DS**)
- Space time 3D raster datasets (**ST@color[#8EA33B](R3)DS**)
- Space time vector datasets (**ST@color[#8EA33B](V)DS**)

<br><br><br>
@fa[bullhorn text-green] Suppot for [**image collections**](https://github.com/OSGeo/grass/pull/63) is on the way! 


+++
@title[Other TGRASS notions]

## Other TGRASS notions

@ul
- Time can be defined as @color[#8EA33B](intervals) (start and end time) or @color[#8EA33B](instances) (only start time)
- Time can be @color[#8EA33B](absolute) (e.g., 2017-04-06 22:39:49) or @color[#8EA33B](relative) (e.g., 4 years, 90 days)
- @color[#8EA33B](Granularity) is the greatest common divisor of the temporal extents (and possible gaps) of all maps in the space-time cube
@ulend


+++
### Other TGRASS notions

- @color[#8EA33B](Topology) refers to temporal relations between time intervals in a STDS.

<img src="assets/img/temp_relation.png">


+++
### Other TGRASS notions

- @color[#8EA33B](Temporal sampling) is used to determine the state of one process during a second process.

<img src="assets/img/temp_samplings.png" width="55%">


+++
@title[Temporal modules]

## @fa[tools text-green] Spatio-temporal modules

- @color[#8EA33B](**t.\***): General modules to handle STDS of all types
- @color[#8EA33B](**t.rast.\***): Modules that deal with STRDS
- @color[#8EA33B](**t.rast3d.\***): Modules that deal with STR3DS
- @color[#8EA33B](**t.vect.\***): Modules that deal with STVDS


---?image=assets/img/grass_template.png&position=bottom&size=100% 30%
@title[TGRASS workflow]

## TGRASS framework and workflow


+++?image=assets/img/tgrass_flowchart.png&position=center&size=auto 93%


---?image=assets/img/grass_template.png&position=bottom&size=100% 30%

## Hands-on to NDVI time series for environmental monitoring @fa[layer-group text-13 text-green]
<br>

---
@snap[north-west span-60]
<h3>Overview</h3>
@snapend

@snap[west span-100]
<br><br>
@ol[list-content-verbose]
- Data for the session
- Get familiar with the data
- Use of reliability band
- Create NDVI time series
- Gap-filling: HANTS
- Phenological indices
- NDWI time series
- Regression between NDVI and NDWI
@olend
@snapend


---
@title[Sample mapset and code]

### Data for the session

- MODIS Vegetation product: <a href="https://lpdaac.usgs.gov/products/mod13c2v006/">MOD13C2 Collection 6</a>
- Global monthly composites
- Spatial resolution: 5600m 

<br>
@img[span-60](assets/img/mod13c2_global_ndvi.png)


+++
### @fa[download text-green] get sample mapset and code @fa[download text-green]

<br>
- [modis_ndvi mapset](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/raw/master/data/modis_ndvi.zip?inline=false): download and unzip it within North Carolina location: `$HOME/grassdata/nc_spm_08_grass7/modis_ndvi`
- [GRASS code](https://github.com/veroandreo/grass_opengeohub2019/raw/master/code/ndvi_time_series_code.sh?inline=false) to follow the session


---?image=assets/img/grass_template.png&position=bottom&size=100% 30%

## Let's start GRASS GIS! @fa[grin-hearts text-15 text-pink fa-spin]


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Get familiar with NDVI data

@[85-88](List files and get info and stats)
@[90-92](Set computational region)
@[94-95](Set a MASK to focus only on NC state)


+++
> @fa[tasks] **Task**: 
> - Display EVI, NIR and QA maps and get information about minimum and maximum values
> - What do you notice about the values?

Note:

Values are scaled as follows 

- NDVI and EVI, from -2000 to 10000
- Bands, from 0 to 10000
- QA band, from 0 to 65534


---
### Use of reliability band

<br>
> @fa[tasks] **Task**: 
> - Read about this reliability band at the [MOD13 User guide](https://lpdaac.usgs.gov/documents/103/MOD13_User_Guide_V6.pdf) (pag 27)
> - Display one of the pixel reliability bands along with NDVI band of the same date
> - Select only pixels with value 0 (Good quality) in the pixel reliability band. What do you notice?


Note:

- -1 Fill/NoData  Not Processed
- 0  Good Data  Use with confidence
- 1  Marginal data  Useful, but look at other QA information
- 2  Snow/Ice  Target covered with snow/ice 
- 3  Cloudy  Target not visible, covered with cloud
- 4  Estimated  From MODIS historic time series 


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Use of reliability band

@[103-108](*nix - Keep only best quality pixels)
@[110-115](Windows - Keep only best quality pixels)
@[117-132](Keep only best quality pixels - all maps)


+++
> @fa[tasks] **Task**: Compare stats among original and filtered NDVI maps for the same date using [r.univar](https://grass.osgeo.org/grass76/manuals/r.univar.html). Do stats differ?

<br><br>
To decode QA bits from the QA band there's a specific GRASS GIS module: [i.modis.qc](https://grass.osgeo.org/grass76/manuals/i.modis.qc.html)


Note:

- One gets a band per QA bit and per date and then, it should be applied to each NDVI date as we did with the pixel reliability band


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Create time series

@[140-144](Create the STRDS)
@[146-147](Check STRDS was created)
@[149-150](Create file with list of maps)
@[152-155](Register maps)
@[157-158](Print time series info)
@[160-161](Print list of maps in STRDS)


+++
> @fa[tasks] **Task**: Visually explore the values of the time series in different points. 
> Use [g.gui.tplot](https://grass.osgeo.org/grass76/manuals/g.gui.tplot.html) 
> and select different points interactively.

<br>
@img[span-65](assets/img/monthly_ndvi.png)


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Missing data

@[169-170](Get time series stats)
@[172-175](Count valid data)
@[177-179](Get total number of maps)
@[181-184](Estimate percentage of missing data)


+++
> @fa[tasks] **Task**: 
> - Display the map representing the percentage of missing data and explore values
> - Get univariate statistics of this map

@snap[south-east span-40]
@fa[lightbulb] Hint: [r.univar](https://grass.osgeo.org/grass76/manuals/r.univar.html)
@snapend


---
### Temporal gap-filling

- Harmonic Analysis of Time Series (HANTS).
- Implemented in [r.hants](https://grass.osgeo.org/grass7/manuals/addons/r.hants.html) add-on

<br>
<img src="assets/img/evi_evi_hants.png" width="60%">

<br>
@size[22px](See <a href="https://www.tandfonline.com/doi/abs/10.1080/014311600209814">Roerink et al. 2000</a> for more details)

Note:

- there are different techniques to inpute/fill missing data both in space and time
- in tgrass, we have t.rast.gapfill, r.series.lwr and r.hants
- since ndvi is a cyclic variable, we'll use HANTS


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Temporal gap-filling: HANTS

@[192-193](Install r.hants extension)
@[195-200](*nix - List maps and gap-fill with r.hants)
@[202-206](Windows - List maps and gap-fill with r.hants)
@[211-223](Patch original and gapfilled maps)
@[225-229](Create time series with patched data)
@[231-238](List and register maps in time series)
@[240-241](Print time series info)


+++
> @fa[tasks] **Task**: 
> - Graphically assess the results of HANTS reconstruction in pixels with higher percentage of missing data 
> - Obtain univariate statistics for the new time series

@snap[south-east span-60]
@fa[lightbulb] Hints: [g.gui.tplot](https://grass.osgeo.org/grass76/manuals/g.gui.tplot.html) and [t.rast.univar](https://grass.osgeo.org/grass76/manuals/t.rast.univar.html)
@snapend


---

### Phenology

- The study of periodic plant and animal life cycle events and how these are influenced by seasonal and interannual variations in climate
- We will estimate indices to characterize different aspects of phenology:
    - min and max NDVI values
    - dates of min and max NDVI values
    - rate of change
    - length, start and end of growing season
   

+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenological indices

@[249-256](Obtain maximum and minimum NDVI)
@[258-262](Replace STRDS values with start_month if they match overall max)
@[264-267](Get the earliest month in which the maximum appeared)
@[269-276](Get NDVI minimum per year starting in December)
@[278-281](Get index of minimum raster)
@[283-295](Create index to month reclassification rules)
@[297-299](Reclass index to month)
@[301-302](Remove intermediate time series)


+++
> @fa[tasks] **Task**: Display `max_ndvi_date` and `min_ndvi_date` maps from the terminal using wx monitors

@snap[south-east span-50]
@fa[lightbulb] Hints: [d.mon](https://grass.osgeo.org/grass76/manuals/d.mon.html) and [d.rast](https://grass.osgeo.org/grass76/manuals/d.rast.html)
@snapend


+++
> @fa[tasks] **Task**: Associate max and min LST with max and min NDVI, and max and min LST dates with max and min NDVI dates. 

<br>
@snap[south-east span-50]
@fa[lightbulb]
Hints: [g.mapsets](https://grass.osgeo.org/grass76/manuals/g.mapsets.html) and [r.covar](https://grass.osgeo.org/grass76/manuals/r.covar.html)
@snapend


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenological indices

@[304-306](Add modis_lst to accessible mapsets path)
@[308-310](Correlation)
@[312-316](Get time series of slopes among consequtive maps)
@[318-324](Get maximum slope per year)


+++
> @fa[tasks] **Task**: Obtain a map with the highest growing rate per pixel in the period 2015-2017 and display it from the terminal

@img[span-65](assets/img/ndvi_max_slope.png)

<br>
@snap[south-east span-50]
@fa[lightbulb]
Hint: [t.rast.series](https://grass.osgeo.org/grass76/manuals/t.rast.series.html)
@snapend


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenological indices

@[326-327](Install extension)
@[329-336](Determine start, end and length of growing season - *nix)
@[338-341](Determine start, end and length of growing season - windows)


+++
> @fa[tasks] **Task**: Display some of the resulting maps. What do they represent?

<br>
@snap[south-east span-60]
@fa[lightbulb]
Check [r.seasons](https://grass.osgeo.org/grass7/manuals/addons/r.seasons.html) manual page
@snapend


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenological indices

@[343-344](Create a threshold map to use in r.seasons)
@[346-352](Use a threshold map instead of a threshold value)


+++
> @fa[tasks] **Task**: Use the threshold map in [r.seasons](https://grass.osgeo.org/grass7/manuals/addons/r.seasons.html) and compare output maps with the outputs of using a unique threshold value

@img[span-45](assets/img/ndvi_fixed_thres.png)
@img[span-45](assets/img/ndvi_variable_threshold.png)
<br>
@size[20px](Number of seasons with fixed threshold and using a varying threshold map)


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Water index time series

@[360-369](Create time series of NIR and MIR)
@[371-373](List NIR and MIR files)
@[375-384](Register maps)
@[386-388](Print time series info)
@[390-393](Estimate NDWI time series)


+++
> @fa[tasks] **Task**: Get maximum and minimum values for each NDWI map and explore the time series plot in different points interactively

<br>
@snap[south-east span-60]
@fa[lightbulb]
Hints: [t.rast.list](https://grass.osgeo.org/grass76/manuals/t.rast.list.html) and [g.gui.tplot](https://grass.osgeo.org/grass76/manuals/g.gui.tplot.html)
@snapend


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Regression analysis

@[405-406](Install extension)
@[408-412](Rescale NDVI values)
@[414-419](*nix: Perform regression between NDVI and NDWI time series)
@[421-428](Windows: Perform regression between NDVI and NDWI time series)


+++
> @fa[tasks] **Task**: Where is the highest correlation among NDVI and NDWI?


---
## QUESTIONS?

<img src="assets/img/gummy-question.png" width="45%">


---
@snap[north span-100]
<br>
**Thanks for your attention!!**
@snapend

@snap[south span-60]
@img[about-team-pic span-30](assets/img/vero_round_small.png)
<br>
Verónica Andreo
<br>
@css[bio-contact](@fa[github pad-fa] <a href="https://github.com/veroandreo/">veroandreo</a><br>@fa[twitter pad-fa] <a href="https://twitter.com/VeronicaAndreo">@VeronicaAndreo</a><br>@fa[envelope pad-fa] veroandreo@gmail.com)
<br><br>
@snapend

---
## The end! @fa[grin-beam-sweat fa-3x fa-spin text-green fragment]


@snap[south span-50]
@size[18px](Presentation powered by)
<a href="https://gitpitch.com/">
<img src="assets/img/gitpitch_logo.png" width="30%"></a>
<br>
@snapend
