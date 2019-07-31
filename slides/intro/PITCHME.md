---?image=assets/img/grass_template.png&position=bottom&size=100% 30%
@title[Front page]

@snap[north span-100]
<h1>Introduction to @color[green](GRASS GIS)</h1>
@snapend

@snap[south message-box-white span-100]
@size[30px](OpenGeoHub Summer School 2019, M&uuml;nster)
@snapend

---
@title[About the trainers]

@snap[north span-35]
### Who are we?
@snapend

@snap[west span-50 text-center]
@img[about-team-pic span-50](assets/img/markus_round.png)
<br>
@css[bio-by/line](Markus Neteler<br>Founder of <a href="https://www.mundialis.de/en/">mundialis</a>, Germany)
<br>
@css[bio-byline](@fa[github pad-fa] <a href="https://github.com/neteler/">neteler</a>)
@snapend

@snap[east span-50 text-center]
@img[about-team-pic span-50](assets/img/vero_round_small.png)
<br>
@css[bio-by/line](Veronica Andreo<br>Researcher for <a href="https://www.conicet.gov.ar/?lan=en">CONICET</a>, Argentina)
<br>
@css[bio-byline](@fa[github pad-fa] <a href="https://github.com/veroandreo/">veroandreo</a>)
@snapend

---?image=assets/img/grass_template.png&position=bottom&size=100% 30%

# Brief intro to GRASS GIS

---
@title[GRASS GIS history 1]

@snap[north span-100]
<h2>GRASS GIS: Brief history</h2>
<br><br>
@snapend

@snap[south-west list-content-verbose span-100]
@ul[](false)
- @color[#8EA33B](**GRASS GIS**) (Geographic Resources Analysis Support System), is a FOSS GIS software suite used for geospatial data management and analysis, image processing, graphics and maps production, spatial modeling, and visualization. 
- Used in academic and commercial settings around the world, as well as by many governmental agencies and consulting companies.
- Originally developed by the U.S. Army Construction Engineering Research Laboratories as a tool for land management and environmental planning by the military (USA-CERL, 1982-1995).
@ulend
<br>
@snapend

+++?image=assets/img/grass_template.png&position=bottom&size=100% 30%
@title[GRASS GIS history 2]

@snap[north span-90]
<br>
A bit of (geek) GRASS GIS history...
@snapend

<iframe width="560" height="315" scrolling="no" src="//av.tib.eu/player/12963" frameborder="0" allowfullscreen></iframe>

+++?color=linear-gradient(90deg, #8EA33B 50%, white 50%)
@title[Advantages and Disadvantages]

@snap[north-west span-50 h3-white]
### Advantages
@snapend

@snap[west text-white span-50]
@ul(false)
- open source, you can use, modify, improve, share
- strong user community, commercial support
- large amount of tools
- both GUI and CLI (easy for scripting) interface
- Python API and libraries
@ulend
@snapend

@snap[north-east span-50 h3-green]
### Disadvantages
@snapend

@snap[east text-green span-50]
@ul(false)
- complicated startup for newcomers
- native format (requires importing data, possibility of linking external formats)
- vector topology (confusing for beginners, sometimes tricky to import broken GIS data)
@ulend
@snapend

+++?color=linear-gradient(90deg, #8EA33B 50%, white 50%)
@title[When to use and not to use GRASS]

@snap[north-west span-50 h3-white text-center]
### When to use GRASS GIS?
@snapend

@snap[south-west text-white span-50]
@ul(false)
- doing (heavy) geospatial data analysis
- working with topological vector data
- analysing space-time datasets
- doing Python scripting
- deploying server-side applications (e.g. as WPS process)
@ulend
@snapend

@snap[north-east span-50 h3-green text-center]
### When to use rather something else?
@snapend

@snap[east text-green span-50]
@ul(false)
- want to vizualize geodata in easy and quick way (use QGIS instead)
- scared of location and mapsets @fa[smile-wink]
@ulend
@snapend

---

@size[56px](Working with GRASS GIS is not much different than any other GIS...)

---

@snap[midpoint span-100]
Well, except for this...
<br>
@img[span-55](assets/img/start_screen1.png)
@snapend

---

## Basic notions

@ul
- The @color[#8EA33B](**GRASS DATABASE**) (or "GISDBASE") is an existing directory containing all GRASS GIS LOCATIONs. 
- A @color[#8EA33B](**LOCATION**) is defined by its coordinate system, map projection and geographical boundaries.
- @color[#8EA33B](**MAPSET**) is a subdirectory within Locations. In a **MAPSET** you can organize GIS maps thematically, geographically, by project or however you prefer.
@ulend

+++
@title[GRASS DB, Location and Mapsets]

When GRASS GIS is started, it connects to the Database, Location and Mapset specified by the user

<br>
<img src="assets/img/grass_database.png" width="65%">

<br>
@size[24px](<a href="https://grass.osgeo.org/grass76/manuals/grass_database.html">GRASS database</a>)
<br>

+++

- **Why this structure?**

 - GRASS GIS has a @color[#8EA33B](*native format*) for raster and vector data, therefore
   they must be *imported* or *linked* into a GRASS Location/Mapset (see [r.external](https://grass.osgeo.org/grass76/manuals/r.external.html) for example).

+++

- **What are the advantages?**

 - GRASS DATABASE, LOCATIONs and MAPSETs are folders that @color[#8EA33B](*can be easily shared with other users*).
 - The GRASS DATABASE can be @color[#8EA33B](*local or remote*), and @color[#8EA33B](*special permissions*) can be set to specific mapsets in a LOCATION.
 - All data in a LOCATION have necessarily the @color[#8EA33B](same CRS).

---?color=linear-gradient(90deg, #8EA33B 50%, white 50%)
@title[Data types in GRASS GIS]

@snap[west h4-white span-50]
#### Data types in GRASS GIS
@snapend

@snap[east text-green span-45 text-left]
@ul[split-screen-list](false)
- [Raster](https://grass.osgeo.org/grass76/manuals/rasterintro.html) (including [satellite imagery](https://grass.osgeo.org/grass76/manuals/imageryintro.html))
- [3D raster or voxel](https://grass.osgeo.org/grass76/manuals/raster3dintro.html)
- [Vector](https://grass.osgeo.org/grass76/manuals/vectorintro.html): point, line, boundary, area, face
- [Space-time datasets](https://grass.osgeo.org/grass76/manuals/temporalintro.html): collections of raster (**STRDS**), raster 3D (**STR3DS**) or vector (**STVDS**) maps
@ulend
@snapend

---

## @fa[tools text-green] Modules

More than [500 modules](https://grass.osgeo.org/grass76/manuals/full_index.html) but well structured:

| Prefix                                                               | Function class   | Type of command                     | Example
|--------------------------------------------------------------------- |:---------------- |:----------------------------------- |:-------------------------------------------------------------------------------------------------------------------
| [g.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#g)    | general          | general data management             | [g.rename](https://grass.osgeo.org/grass76/manuals/g.rename.html): renames map
| [d.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#d)    | display          | graphical output                    | [d.rast](https://grass.osgeo.org/grass76/manuals/d.rast.html): display raster map 
| [r.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#r)    | raster           | raster processing                   | [r.mapcalc](https://grass.osgeo.org/grass76/manuals/r.mapcalc.html): map algebra
| [v.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#r)    | vector           | vector processing                   | [v.clean](https://grass.osgeo.org/grass76/manuals/v.clean.html): topological cleaning
| [i.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#i)    | imagery          | imagery processing                  | [i.pca](https://grass.osgeo.org/grass76/manuals/i.pca.html): Principal Components Analysis on imagery group
| [r3.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#r3)  | voxel            | 3D raster processing                | [r3.stats](https://grass.osgeo.org/grass76/manuals/r3.stats.html): voxel statistics
| [db.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#db)  | database         | database management                 | [db.select](https://grass.osgeo.org/grass76/manuals/db.select.html): select value(s) from table
| [ps.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#ps)  | postscript       | PostScript map creation             | [ps.map](https://grass.osgeo.org/grass76/manuals/ps.map.html): PostScript map creation
| [t.\*](https://grass.osgeo.org/grass76/manuals/full_index.html#t)    | temporal         | space-time datasets                 | [t.rast.aggregate](https://grass.osgeo.org/grass76/manuals/t.rast.aggregate.html): raster time series aggregation

+++

<img src="assets/img/module_tree_and_search.png" width="75%">
<br>
Module tree and module search engine

---

## @fa[tools text-green] Add-ons

Plugins or **Add-ons** can be installed from
a centralized [OSGeo repository](https://grass.osgeo.org/grass7/manuals/addons/) 
or from github (or similar repositories) using 
[g.extension](https://grass.osgeo.org/grass76/manuals/g.extension.html) command.
<br><br>
```bash
 # install extension from GRASS GIS Add-on repository
 g.extension extension=r.hants
 
 # install extension from github repository
 g.extension extension=r3.slice \
   url=https://github.com/petrasovaa/r3.slice
``` 

---

## Computational region

![Show computational region](assets/img/region.png)

+++

@snap[west]
The @color[#8EA33B](**computational region**) is the *actual setting of the region 
boundaries and the actual raster resolution*.
<br><br>
The @color[#8EA33B](**computational region**) can be set and changed by means of
[g.region](https://grass.osgeo.org/grass76/manuals/g.region.html) to the
extent of a vector map, a raster map or manually to some area of interest. 
<br><br>
*Output raster maps* will have their extent and resolution equal to
those of the current computational region, while vector maps are 
always considered in their original extent.
@snapend

+++

## Computational region

- **Which are the advantages?**

  - Keep your results consistent
  - Avoid clipping maps prior to subarea analysis
  - Test an algorithm or computationally demanding process in small areas
  - Fine-tune the settings of a certain module
  - Run different processes in different areas

<br><br>
@size[18px](More details at the [Computational region wiki](https://grasswiki.osgeo.org/wiki/Computational_region))

---

## MASK

- A raster map named MASK can be created to mask out areas
- All cells that are *NULL* in the MASK map will be ignored (also all areas outside the computational region).
- Masks are set with [r.mask](https://grass.osgeo.org/grass76/manuals/r.mask.html) or creating a raster map called **MASK**. 

+++

Vector maps can be also used as masks

<br>
![MASK](assets/img/masks.png)

<br>
@size[22px](a- Elevation raster and lakes vector maps. b- Only the raster data inside the masked area are used for further analysis. c- Inverse mask.)

+++

### MASK examples


```bash
# use vector as mask
r.mask vector=lakes

# use vector as mask, set inverse mask
r.mask -i vector=lakes

# mask categories of a raster map
r.mask raster=landclass96 maskcats="5 thru 7"

# create a raster named MASK
r.mapcalc expression="MASK = if(elevation < 100, 1, null())"

# remove mask
r.mask -r
```

<br><br>
@size[22px](**Note**: A mask is only actually applied when reading a GRASS raster map, i.e., when used as input in a module.)

---

## Interfaces

GRASS GIS offers different interfaces for the interaction between user and software. 

<br>
### Let's see them!

<br>
@fa[angle-double-down text-green fa-3x]

+++

### Graphical User Interface (GUI)

![GRASS GIS GUI](assets/img/GUI_description.png)

+++

### @fa[terminal] Command line 

The most powerful way to use GRASS GIS!!

<img src="assets/img/grass_command_line.png" width="70%">

+++

### Advantages of the command line

@ul
- Run `history` to see all your previous commands
- History is stored individually per MAPSET
- Search in history with `CTRL-R`
- Save the commands to a file: `history > my_protocol.sh`, polish/annotate the protocol and re-run with: `sh my_protocol.sh`
- Call module's GUI and "Copy" the command for further replication
@ulend

+++

The GUI's simplified command line offers a *Log file* button to save the history to a file

<img src="assets/img/command_prompt_gui.png" width="43%">

+++

### Python 

The simplest way to execute a Python script is through the @color[#8EA33B](Simple Python editor)

<img src="assets/img/simple_python_editor.png" width="80%">

+++

... or write your Python script in your favorite editor and run it:

```python
 #!/usr/bin/env python

 # simple example for pyGRASS usage: raster processing via modules approach
 from grass.pygrass.modules.shortcuts import general as g
 from grass.pygrass.modules.shortcuts import raster as r
 g.message("Filter elevation map by a threshold...")
 
 # set computational region
 input = 'elevation'
 g.region(raster=input)
 output = 'elev_100m'
 thresh = 100.0

 r.mapcalc("%s = if(%s > %d, %s, null())" % (output, input, thresh, input), overwrite = True)
 r.colors(map=output, color="elevation")
``` 

+++?code=code/intro_grass_session_vector_import.py&lang=python&title=... or use the **grass-session** Python library

@[17-28](Import libraries)
@[36-48](Create Location and Mapset)
@[50-66](Run modules)
@[68-69](Clean and close)

<br><br>
@size[18px](Credits: Pietro Zambelli. See <a href="https://github.com/zarch/grass-session">grass-session GitHub</a> for further details.)

+++

### QGIS

There are two ways to use GRASS GIS functionalities within QGIS:
<br>
- [GRASS GIS plugin](https://docs.qgis.org/3.4/en/docs/user_manual/grass_integration/grass_integration.html)
- [Processing toolbox](https://docs.qgis.org/3.4/en/docs/user_manual/processing/toolbox.html)

+++

![GRASS GIS modules through GRASS Plugin](assets/img/qgis_grass_plugin.png)
<br>
@size[18px](Using GRASS GIS modules through the GRASS Plugin in QGIS)

+++

![GRASS modules through Processing Toolbox](assets/img/qgis_processing.png)
<br>
@size[18px](Using GRASS GIS modules through the Processing Toolbox)

+++

### R + rgrass7

GRASS GIS and R can be used together in two ways:
<br><br>
- Using [R within a GRASS GIS session](https://grasswiki.osgeo.org/wiki/R_statistics/rgrass7#R_within_GRASS)
- Using [GRASS GIS within an R session](https://grasswiki.osgeo.org/wiki/R_statistics/rgrass7#GRASS_within_R)
<br><br>

@size[22px](Details and examples at the <a href="https://grasswiki.osgeo.org/wiki/R_statistics/rgrass7">GRASS and R wiki</a>)

+++

![Calling R from within GRASS](assets/img/RwithinGRASS_and_Rstudio_from_grass.png)

+++

### WPS - OGC Web Processing Service

- [Web Processing Service](https://en.wikipedia.org/wiki/Web_Processing_Service) is an [OGC](https://en.wikipedia.org/wiki/Open_Geospatial_Consortium) standard. 
- [ZOO-Project](http://zoo-project.org/) and [PyWPS](http://pywps.org/) allow the user to run GRASS GIS commands in a simple way through the web.


+++

Shall we add Actinia here as in Vashek presentation: https://wenzeslaus.github.io/grass-gis-talks/ncgis2019_getting_started.html#/15 ?

---

## Some useful commands and cool stuff

+++

- [r.import](https://grass.osgeo.org/grass76/manuals/r.import.html) and
  [v.import](https://grass.osgeo.org/grass76/manuals/v.import.html):
  import of raster and vector maps with reprojection, subsetting and
  resampling on the fly.

```bash 
 ## IMPORT RASTER DATA: SRTM V3 data for NC
 
 # set computational region to e.g. 10m elevation model:
 g.region raster=elevation -p
 
 # import with reprojection on the fly
 r.import input=n35_w079_1arc_v3.tif output=srtmv3_resamp10m \
  resample=bilinear extent=region resolution=region \
  title="SRTM V3 resampled to 10m resolution"

 ## IMPORT VECTOR DATA
 
 # import SHAPE file, clip to region extent and reproject to 
 # current location projection
 v.import input=research_area.shp output=research_area extent=region
``` 

+++

- [g.list](https://grass.osgeo.org/grass76/manuals/g.list.html): Lists
  available GRASS data base files of the user-specified data type
  (i.e., raster, vector, 3D raster, region, label) optionally using
  the search pattern.

```bash 
 g.list type=vector pattern="r*"
 g.list type=vector pattern="[ra]*"
 g.list type=raster pattern="{soil,landuse}*"
``` 

+++

- [g.remove](https://grass.osgeo.org/grass76/manuals/g.remove.html),
  [g.rename](https://grass.osgeo.org/grass76/manuals/g.rename.html)
  and [g.copy](https://grass.osgeo.org/grass76/manuals/g.copy.html):

  These modules remove maps from the GRASSDBASE, rename maps and copy
  maps either in the same mapset or from other mapset. 

<br>
@css[message-box](Always perform these tasks from within GRASS)

+++

- [g.region](https://grass.osgeo.org/grass76/manuals/g.region.html):
  Manages the boundary definitions and resolution for the computational region.

```bash 
 ## Subset a raster map
 # 1. Check region settings
 g.region -p
 # 2. Change region relative to current N and W values
 g.region n=n-3000 w=w+4000
 # 3. Subset map
 r.mapcalc "new_elev = elevation"
 r.colors new_elev color=viridis
 # 4. Display maps
 d.mon wx0
 d.rast elevation
 d.rast new_elev
``` 

+++

- [r.info](https://grass.osgeo.org/grass76/manuals/r.info.html) and
  [v.info](https://grass.osgeo.org/grass76/manuals/v.info.html):
  useful to get basic info about maps as well as their history.

```bash
 # info for raster map
 r.info elevation
 # info for vector map
 v.info nc_state
 # history of vector map
 v.info nc_state -h
```

+++

- [--exec in the grass76 startup command](https://grass.osgeo.org/grass76/manuals/grass7.html): 
  This flag allows to run modules or complete workflows written in Bash
  shell or Python without starting GRASS GIS.

```bash
 # running a module
 grass76 $HOME/grassdata/nc_spm_08_grass7/PERMANENT/ --exec r.info elevation
 
 # running a script
 grass76 $HOME/grassdata/nc_spm_08_grass7/PERMANENT/ --exec sh test.sh

 ## test.sh might be as simple as:
 
 #!/bin/bash

 g.region -p
 g.list type=raster
 r.info elevation
``` 

---

# HELP!!!

+++

### KEEP CALM and GRASS GIS

- [g.manual](https://grass.osgeo.org/grass76/manuals/g.manual.html):
  in the main GUI under Help or just pressing *F1*
- `--help` or `--h` flag after the module name
- [GRASS wiki](https://grasswiki.osgeo.org/wiki/GRASS-Wiki): examples,
  explanations and help on particular modules or tasks,
  [tutorials](https://grasswiki.osgeo.org/wiki/Category:Tutorial),
  applications, news, etc.
- [Jupyter/IPython notebooks](https://grasswiki.osgeo.org/wiki/GRASS_GIS_Jupyter_notebooks)
  with example workflows for different applications
- grass-user mailing list: Just [subscribe](https://lists.osgeo.org/mailman/listinfo/grass-user) and
  post or check the [archives](https://lists.osgeo.org/pipermail/grass-user/).

+++

## Other (very) useful links

- [GRASS intro workshop held at NCSU](https://ncsu-osgeorel.github.io/grass-intro-workshop/)
- [Unleash the power of GRASS GIS at US-IALE 2017](https://grasswiki.osgeo.org/wiki/Unleash_the_power_of_GRASS_GIS_at_US-IALE_2017)
- [GRASS GIS course in Jena 2018](http://training.gismentors.eu/grass-gis-workshop-jena-2018/index.html)
- [GRASS GIS course IRSAE 2018](http://training.gismentors.eu/grass-gis-irsae-winter-course-2018/index.html)
- [GRASS GIS course in Argentina 2018](https://gitlab.com/veroandreo/curso-grass-gis-rioiv)

---

## References

- Neteler, M., Mitasova, H. (2008): *Open Source GIS: A GRASS GIS Approach*. Third edition. ed. Springer, New York. [Book site](https://grassbook.org/)
- Neteler, M., Bowman, M.H., Landa, M. and Metz, M. (2012): *GRASS GIS: a multi-purpose Open Source GIS*. Environmental Modelling & Software, 31: 124-130 [DOI](http://dx.doi.org/10.1016/j.envsoft.2011.11.014)

---

## QUESTIONS?

<img src="assets/img/gummy-question.png" width="45%">

---

We should add some exercises, no??

---

<!---
@snap[north span-90]
<br><br><br>
Let's move on to: 
<br>
[TGRASS presentation](https://gitpitch.com/veroandreo/tgrass-foss4g2019/master?p=slides/tgrass)
@snapend
--->

@snap[south span-50]
@size[18px](Presentation powered by)
<br>
<a href="https://gitpitch.com/">
<img src="assets/img/gitpitch_logo.png" width="20%"></a>
@snapend
