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
- Phenology indices
- Regression between NDVI and NDWI
@olend
@snapend

---
@snap[north span-100]
<h3>Data for the session</h3>
@snapend

@snap[west span-50]
@ul[](false)
- MODIS Vegetation product: <a href="https://lpdaac.usgs.gov/products/mod13c2v006/">MOD13C2 Collection 6</a>
- Global monthly composites
- Spatial resolution: 5600m 
@ulend
@snapend

@snap[east span-50]
![NDVI global](assets/img/mod13c2_global_ndvi.png)
@snapend

+++
@title[Sample mapset and code]

### @fa[download text-green] get sample mapset and code @fa[download text-green]

- [modis_ndvi mapset](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/raw/master/data/modis_ndvi.zip?inline=false): download and unzip it within North Carolina location: `$HOME/grassdata/nc_spm_08_grass7/modis_ndvi`
- [GRASS code](https://github.com/veroandreo/grass_opengeohub2019/raw/master/code/ndvi_time_series_code.sh?inline=false) to follow the session


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Get familiar with NDVI data

@[85-89](Start GRASS GIS in modis_ndvi mapset)
@[91-93](Add modis_lst to accessible mapsets path)
@[95-98](List files and get info and stats)


+++
> @fa[tasks] **Task**: 
> - Display EVI, NIR and QA maps and get information about minimum and maximum values
> - What do you notice about the values?


---
### Use of reliability band

<br>
> @fa[tasks] **Task**: 
> - Read about this reliability band at the MOD13 [User guide](https://lpdaac.usgs.gov/documents/103/MOD13_User_Guide_V6.pdf) (pag 27).
> - Display one of the pixel reliability bands along with NDVI band of the same date.
> - Select only pixels with value 0 (Good quality) in the pixel reliability band. What do you notice?


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Use of reliability band

@[106-108](Set computational region)
@[110-115](Keep only best quality pixels - *nix)
@[117-121](Keep only best quality pixels - windows)
@[123-137](Keep only best quality pixels - all maps)


+++
> @fa[tasks] **Task**: Compare stats among original and filtered NDVI maps for the same date. Do they differ?


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Create time series

@[145-149](Create the STRDS)
@[151-152](Check STRDS was created)
@[154-155](Create file with list of maps)
@[157-160](Register maps)
@[162-163](Print time series info)
@[165-166](Print list of maps in STRDS)


+++
> @fa[tasks] **Task**: Visually explore the values of the time series in different points. 
> Use [g.gui.tplot](https://grass.osgeo.org/grass76/manuals/g.gui.tplot.html) 
> and select different points interactively.


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Missing data

@[174-175](Set mask)
@[177-178](Get time series stats)
@[180-182](Count valid data)
@[184-186](Estimate percentage of missing data)

+++
> @fa[tasks] **Task**: 
> - Display the map representing the percentage of missing data and explore values. 
> - Get univariate statistics of this map.


---
### Temporal gap-filling

- Harmonic Analysis of Time Series (HANTS). [Roerink et al. 2000](https://www.tandfonline.com/doi/abs/10.1080/014311600209814)
- Implemented in [r.hants](https://grass.osgeo.org/grass7/manuals/addons/r.hants.html) add-on

<br>
<img src="assets/img/evi_evi_hants.png" width="60%">


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Temporal gap-filling: HANTS

@[194-195](Install r.hants extension)
@[197-202](List maps and gap-fill with r.hants - *nix)
@[204-208](List maps and gap-fill with r.hants - windows)


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Temporal gap-filling: HANTS

@[210-215](Patch original and gapfilled map - *nix)
@[217-222](Patch original and gapfilled map - windows)
@[224-236](Patch original and gapfilled maps)
@[238-242](Create time series with patched data)
@[244-250](Register maps in time series)
@[252-253](Print time series info)


+++
> @fa[tasks] **Task**: 
> - Graphically assess the results of HANTS reconstruction in pixels with higher percentage of missing data 
> - Obtain univariate statistics for the new time series


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology indices

@[261-263](Month of maximum and month of minimum)
@[265-272](Replace STRDS values with start_month if they match overall min or max)
@[274-276](Get the earliest month in which the maximum and minimum appeared)
@[278-279](Remove intermediate time series)


+++
> @fa[tasks] **Task**: Display the resulting maps with [g.gui.mapswipe](https://grass.osgeo.org/grass76/manuals/g.gui.mapswipe.html)


+++
> @fa[tasks] **Task**: Associate max LST with max NDVI, max LST date with max NDVI date. 

<br>
@snap[south-east span-40]
@fa[lightbulb]
Hint: Check for [r.covar](https://grass.osgeo.org/grass76/manuals/r.covar.html)
@snapend


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology indices

@[281-284](Get time series of slopes among consequtive maps)
@[286-289](Get maximum slope per year)


+++
> @fa[tasks] **Task**: Obtain a map with the highest growing rate per pixel in the period 2015-2017 and display it

<br>
@snap[south-east span-40]
@fa[lightbulb]
Hint: Check for [t.rast.series](https://grass.osgeo.org/grass76/manuals/t.rast.series.html)
@snapend


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology indices

@[291-292](Install extension)
@[294-297](Determine start, end and length of growing season - *nix)
@[299-302](Determine start, end and length of growing season - windows)


+++
> @fa[tasks] **Task**: Plot the resulting maps. What do they represent?

<br>
@snap[south-east span-40]
@fa[lightbulb]
Check [r.seasons](https://grass.osgeo.org/grass7/manuals/addons/r.seasons.html) manual page
@snapend


+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology indices

@[304-305](Create a threshold map to use in r.seasons)


+++
> @fa[tasks] **Task**: Use the threshold map in [r.seasons](https://grass.osgeo.org/grass7/manuals/addons/r.seasons.html) and compare output maps with the outputs of using a unique threshold value


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Water index time series

@[313-322](Create time series of NIR and MIR)
@[324-326](List NIR and MIR files)
@[328-335](Register maps)
@[337-339](Print time series info)
@[341-343](Estimate NDWI time series)


+++
> @fa[tasks] **Task**: Get maximum and minimum values for each NDWI map and explore the time series plot in different points interactively

<br>
@snap[south-east span-40]
@fa[lightbulb]
Hint: Check for [t.rast.univar](https://grass.osgeo.org/grass76/manuals/t.rast.univar.html) and [g.gui.tplot](https://grass.osgeo.org/grass76/manuals/g.gui.tplot.html)
@snapend


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Frequency of flooding

@[351-353](Reclassify maps according to threshold)
@[355-356](Get flooding frequency)


+++
> @fa[tasks] **Task**: Which are the areas that have been flooded most frequently?


---?code=code/ndvi_time_series_code.sh&lang=bash&title=Regression analysis

@[364-365](Install extension)
@[367-372](Perform regression between NDVI and NDWI time series - *nix)
@[374-379](Perform regression between NDVI and NDWI time series - windows)


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
## The end! 

<br>
@fa[grin-beam-sweat fa-3x fa-spin text-green]


@snap[south span-50]
@size[18px](Presentation powered by)
<br>
<a href="https://gitpitch.com/">
<img src="assets/img/gitpitch_logo.png" width="20%"></a>
@snapend
