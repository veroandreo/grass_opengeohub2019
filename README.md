# GRASS GIS presentations at the OpenGeoHub Summer School 2019, M&uuml;nster

## Presentations

- [Brief intro to GRASS GIS - Tuesday](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/intro)
- [TGRASS for environmental monitoring 1: LST - Wednesday](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/tgrass_lst)
- [GRASS and R for disease ecology applications - Thursday](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/tgrass_rstats_disease_ecology)
- [TGRASS for environmental monitoring 2: NDVI - Friday](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/tgrass_ndvi)

## Software

We will use **GRASS GIS 7.6.1** (current stable version). It can be installed either 
through standalone installers/binaries or through OSGeo-Live (which includes all
OSGeo software and packages). See this 
[**installation guide**](https://gitpitch.com/veroandreo/grass-gis-conae/master?p=slides/00_installation&grs=gitlab) 
for details (Follow only the GRASS GIS part).


### Standalone installers for different OS:

##### MS Windows

There are two different options:
1. Standalone installer: [32-bit version](https://grass.osgeo.org/grass76/binary/mswindows/native/x86/WinGRASS-7.6.1-1-Setup-x86.exe) | [64-bit version](https://grass.osgeo.org/grass76/binary/mswindows/native/x86_64/WinGRASS-7.6.1-1-Setup-x86_64.exe) 
2. OSGeo4W package (network installer): [32-bit version](http://download.osgeo.org/osgeo4w/osgeo4w-setup-x86.exe) | [64-bit version](http://download.osgeo.org/osgeo4w/osgeo4w-setup-x86_64.exe) 

For Windows users, **we strongly recommend installing GRASS GIS through the OSGeo4W package** (second option), 
since it allows to install all OSGeo software. If you choose this option, 
*make sure you select GRASS GIS and msys*. The latter one will allow 
the use of loops, back ticks, autocomplete, history and other nice bash shell
features.

##### Ubuntu Linux

Install GRASS GIS 7.6.1 from the "unstable" package repository:

```
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install grass grass-gui grass-dev
```

##### Fedora, openSuSe Linux

For other Linux distributions including **Fedora** and **openSuSe**, simply install GRASS GIS with the respective package manager. See also [here](https://grass.osgeo.org/download/software/)

### OSGeo-live: 

[OSGeo-live](https://live.osgeo.org/) is a self-contained bootable DVD, USB thumb
drive or Virtual Machine based on Lubuntu, that allows you to try a wide variety
of open source geospatial software without installing anything. There are 
different options to run OSGeo-live:

* [Run OSGeo-live in a Virtual Machine](https://live.osgeo.org/en/quickstart/virtualization_quickstart.html)
* [Run OSGeo-live from a bootable USB flash drive](https://live.osgeo.org/en/quickstart/usb_quickstart.html)

For a quick-start guide, see: https://live.osgeo.org/en/quickstart/osgeolive_quickstart.html

### GRASS GIS Add-ons that will be used during the course

* [i.modis](https://grass.osgeo.org/grass7/manuals/addons/i.modis.html): Toolset to download and process MODIS products. It requires [pyModis](http://www.pymodis.org/info.html#how-to-install-pymodis) library.
* [v.strds.stats](https://grass.osgeo.org/grass7/manuals/addons/v.strds.stats.html): Estimates zonal statistics from space-time raster datasets based on a polygon vector map.
* [r.hants](https://grass.osgeo.org/grass7/manuals/addons/r.hants.html): Gap filling with Harmonic Analysis of Time Series (HANTS) method.
* [r.seasons](https://grass.osgeo.org/grass7/manuals/addons/r.seasons.html): Extracts seasons from a time series.
* [r.regression.series](https://grass.osgeo.org/grass7/manuals/addons/r.regression.series.html): Calculates linear regression parameters between two time series.
* [v.in.pygbif](https://grass.osgeo.org/grass7/manuals/addons/v.in.pygbif.html): Searches and imports [GBIF](https://www.gbif.org/) species distribution data. It requires [pygbif](https://pygbif.readthedocs.io/en/stable/) library.
* [r.bioclim](https://grass.osgeo.org/grass7/manuals/addons/r.bioclim.html): Calculates bioclimatic indices as those in [WorldClim](https://www.worldclim.org/bioclim).

Install with `g.extension extension=name_of_addon`

## Other software

We will use the software **MaxEnt** for the tutorial related to disease ecology. The software can be downloaded from: https://biodiversityinformatics.amnh.org/open_source/maxent/

## Data

Please, create a folder in your `$HOME` directory, or under `Documents` if in Windows, and name it **grassdata**. Then, download the following ready to use *locations* and unzip them within `grassdata`:

* [North Carolina (70 Mb)](https://github.com/veroandreo/grass_opengeohub2019/raw/master/data/nc_basic_ogh_2019.zip)
* [Northern Italy (1 Gb)](https://apps.mundialis.de/workshops/geostat2019/grassdata_eu_laea_northern_italy_LST_1km_daily_celsius_reconstructed.zip)

In the end, your `grassdata` folder should look like this:

```
  grassdata/
  ├── eu_laea
  │   ├── italy_LST_daily
  │   └── PERMANENT
  └── nc_basic_ogh_2019
      ├── modis_lst
      ├── modis_ndvi
      ├── PERMANENT
      └── user1
```

## The trainer

[**Verónica Andreo**](https://veroandreo.gitlab.io/) is a researcher for [CONICET](http://www.conicet.gov.ar/?lan=en)
working at the Argentinean Space Agency [(CONAE)](http://ig.conae.unc.edu.ar/)
in Córdoba, Argentina. Her main interests are remote sensing and GIS tools
for disease ecology research fields and applications. 
Vero is an [OSGeo](http://www.osgeo.org/) Charter member and a [FOSS4G](http://foss4g.org/) 
enthusiast and advocate. 
She is part of the [GRASS GIS Development team](https://grass.osgeo.org/home/credits/) 
and she also teaches introductory and advanced courses and workshops, especially 
on GRASS GIS [time series modules](https://grasswiki.osgeo.org/wiki/Temporal_data_processing)
and their applications.

## References

- Neteler, M. and Mitasova, H. (2008): *Open Source GIS: A GRASS GIS Approach*. Third edition. ed. Springer, New York. [Book site](https://grassbook.org/)
- Neteler, M., Bowman, M.H., Landa, M. and Metz, M. (2012): *GRASS GIS: a multi-purpose Open Source GIS*. Environmental Modelling & Software, 31: 124-130 [DOI](http://dx.doi.org/10.1016/j.envsoft.2011.11.014)
- Gebbert, S. and Pebesma, E. (2014). *A temporal GIS for field based environmental modeling*. Environmental Modelling & Software, 53, 1-12. [DOI](https://doi.org/10.1016/j.envsoft.2013.11.001)
- Gebbert, S. and Pebesma, E. (2017). *The GRASS GIS temporal framework*. International Journal of Geographical Information Science, 31, 1273-1292. [DOI](http://dx.doi.org/10.1080/13658816.2017.1306862)
- Gebbert, S., Leppelt, T. and Pebesma, E. (2019). *A Topology Based Spatio-Temporal Map Algebra for Big Data Analysis*. Data, 4, 86. [DOI](https://doi.org/10.3390/data4020086)

## License

All the course material:

[![Creative Commons License](assets/img/ccbysa.png)](http://creativecommons.org/licenses/by-sa/4.0/) Creative Commons Attribution-ShareAlike 4.0 International License

Presentations were created with [gitpitch](https://gitpitch.com/):

* MIT License
