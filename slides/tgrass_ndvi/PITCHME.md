---?image=assets/template/img/grass.png&position=bottom&size=100% 30%
@title[Front page]

@snap[north span-100]
<br>
<h2>Procesamiento y análisis de series temporales en @color[green](GRASS GIS)</h2>
@snapend

@snap[south message-box-white]
<br>Dra. Verónica Andreo<br>CONICET - INMeT<br><br>Instituto Gulich. Córdoba, 2019<br>
@snapend

---?image=assets/template/img/grass.png&position=bottom&size=100% 30%

## Hands-on to NDVI time series @fa[layer-group text-gray]

---

@snap[north-west span-60]
<h3>Overview</h3>
@snapend

@snap[west span-100]
<br><br>
@ol[list-content-verbose]
- Data for the exercise
- Get familiar with the data
- Use reliability band
- Create NDVI time series
- Gap-filling: HANTS
- Aggregation
- Phenology indices
- NDWI and flooding frequency
- Regression between NDVI and NDWI
@olend
@snapend

---

@snap[north span-100]
<h3>Data for the exercise</h3>
@snapend

@snap[west span-50]
@ul[](false)
- MODIS product: <a href="https://lpdaac.usgs.gov/products/mod13c2v006/">MOD13C2 Collection 6</a>
- Global monthly composites
- Spatial resolution: 5600m 
@ulend
@snapend

@snap[east span-50]
![NDVI global](assets/img/mod13c2_global_ndvi.png)
@snapend

+++

@snap[north span-100]
<h3>Data for the exercise</h3>
@snapend

@snap[midpoint span-100]
@ol[](false)
- @fa[download] Download [*modis_ndvi*](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/raw/master/data/modis_ndvi.zip?inline=false) mapset
- Unzip it within North Carolina location
@olend
@snapend

@snap[south span-100]
@fa[download] Download the [code](https://github.com/veroandreo/grass_opengeohub2019/raw/master/code/ndvi_time_series_code.sh?inline=false) to follow this exercise
<br><br>
@snapend

+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Preparation of the dataset

@[17-18](Start GRASS GIS in NC location and create a new mapset)
@[20-22](Add modis_lst mapset to path)
@[24-26](Set region to an LST map)
@[28-35](Get bounding box in ll)
@[37-42](Download MOD13C2)
@[46-48](Move into latlong_wgs84 location and import)
@[50-52](Set region to bb obtained from NC)
@[54-57](Subset to region)
@[59-60](List of maps that will be reprojected)
@[64-70](Reprojection - in target location)
@[72-73](Check projected data)

---?code=code/ndvi_time_series_code.sh&lang=bash&title=Get familiar with NDVI data

@[85-89](Start GRASS GIS in modis_ndvi mapset)
@[91-93](Add modis_lst to accessible mapsets path)
@[95-98](List files and get info and stats)

+++

> @fa[tasks] **Task**: 
> - Display EVI, NIR and QA maps and get information about minimum and maximum values
> - What do you notice about the values?

---

Use of reliability band
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

> @fa[tasks] **Task**: Compare stats among original and filtered NDVI maps for the same date

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

### Temporal gap-filling: HANTS

- Harmonic Analysis of Time Series (HANTS)
- Implemented in [r.hants](https://grass.osgeo.org/grass7/manuals/addons/r.hants.html) add-on

<img src="assets/img/evi_evi_hants.png" width="60%">

+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Temporal gap-filling: HANTS

@[194-195](Install r.hants extension)
@[197-202](List maps and gap-fill with r.hants - *nix)
@[204-208](List maps and gap-fill with r.hants - windows)

+++

> @fa[tasks] **Task**: Test different parameter settings in [r.hants](https://grass.osgeo.org/grass7/manuals/addons/r.hants.html) and compare results

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

---

### Aggregation with granularity

<br>

> @fa[tasks] **Task**: 
> - Obtain average NDVI every two months
> - Visualize the resulting time series with [g.gui.animation](https://grass.osgeo.org/grass76/manuals/g.gui.animation.html)

---?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology

@[261-263](Month of maximum and month of minimum)
@[265-272](Replace STRDS values with start_month if they match overall min or max)
@[274-276](Get the earliest month in which the maximum and minimum appeared)
@[278-279](Remove intermediate time series)

+++

> @fa[tasks] **Task**: Display the resulting maps with [g.gui.mapswipe](https://grass.osgeo.org/grass76/manuals/g.gui.mapswipe.html)

+++

> @fa[tasks] **Task**: Associate max LST with max NDVI, max LST date with max NDVI date

<br>
@snap[south-east span-40]
@fa[lightbulb]
Hint: [r.covar](https://grass.osgeo.org/grass76/manuals/r.covar.html)
@snapend

+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology

@[281-284](Get time series of slopes among consequtive maps)
@[286-289](Get maximum slope per year)

+++

> @fa[tasks] **Task**: Obtain a map with the highest growing rate per pixel in the period 2015-2017 and display it

+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology

@[291-292](Install extension)
@[294-297](Determine start, end and length of growing season - *nix)
@[299-302](Determine start, end and length of growing season - windows)

+++

> @fa[tasks] **Task**: Plot the resulting maps

+++?code=code/ndvi_time_series_code.sh&lang=bash&title=Phenology

@[304-305](Create a threshold map to use in r.seasons)

+++

> @fa[tasks] **Task**: Use threshold map in [r.seasons](https://grass.osgeo.org/grass7/manuals/addons/r.seasons.html) and compare output maps with the outputs of using a threshold value only

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
Hint: [t.rast.univar](https://grass.osgeo.org/grass76/manuals/t.rast.univar.html)
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

**Thanks for your attention!!**

![GRASS GIS logo](assets/img/grass_logo_alphab.png)

---

## THE END! 

<br>
@fa[grin-beam-sweat fa-3x fa-spin text-green]


@snap[south span-50]
@size[18px](Presentation powered by)
<br>
<a href="https://gitpitch.com/">
<img src="assets/img/gitpitch_logo.png" width="20%"></a>
@snapend
