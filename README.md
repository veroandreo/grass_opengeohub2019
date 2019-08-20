# GRASS GIS presentations at the OpenGeoHub Summer School 2019, M&uuml;nster

## Presentations

- [Brief intro to GRASS GIS](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/intro)
- [TGRASS for environmental monitoring 1: LST](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/tgrass_lst)
- [TGRASS for environmental monitoring 2: NDVI](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/tgrass_ndvi)
- [GRASS and R for disease ecology applications](https://gitpitch.com/veroandreo/grass_opengeohub2019/master?p=slides/tgrass_rstats_disease_ecology)


## Software

We will use **GRASS GIS 7.6.1** (current stable version). It can be installed either 
through standalone installers/binaries or through OSGeo-Live (which includes all
OSGeo software and packages). See the 
[**Installation guide**](https://gitpitch.com/veroandreo/grass-gis-conae/master?p=slides/00_installation&grs=gitlab) 
presentation for details.


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
sudo apt-get install grass
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
* [r.seasons](https://grass.osgeo.org/grass7/manuals/addons/r.seasons.html): Extracts seasons from a time series.
* [r.regression.series](https://grass.osgeo.org/grass7/manuals/addons/r.regression.series.html): Calculates linear regression parameters between two time series.
* [v.strds.stats](https://grass.osgeo.org/grass7/manuals/addons/v.strds.stats.html): Estimates zonal statistics from space-time raster datasets based on a polygon vector map.
* [v.in.pygbif](https://grass.osgeo.org/grass7/manuals/addons/v.in.pygbif.html): Searches and imports [GBIF](https://www.gbif.org/) species distribution data. it requires [pygbif](https://pygbif.readthedocs.io/en/stable/) library.
* [r.bioclim](https://grass.osgeo.org/grass7/manuals/addons/r.bioclim.html): Calcuates bioclimatic indices.

Install with `g.extension extension=name_of_addon`

## Data

* [North Carolina location (full dataset, 150Mb)](https://grass.osgeo.org/sampledata/north_carolina/nc_spm_08_grass7.zip): download and unzip within `$HOME/grassdata`.
* [modis_lst mapset (2Mb)](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/raw/master/data/modis_lst.zip?inline=false): download and unzip within the North Carolina location in `$HOME/grassdata/nc_spm_08_grass7`.
* [modis_ndvi mapset (15 Mb)](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/raw/master/data/modis_ndvi.zip?inline=false): download and unzip within the North Carolina location in `$HOME/grassdata/nc_spm_08_grass7`.
* [italy_lst](): download and unzip within `$HOME/grassdata`.

Your `grassdata` folder should look like this:

```
  grassdata/
  ├── eu_laea
  │   ├── italy_lst
  │   └── PERMANENT
  └── nc_spm_08_grass7
      ├── landsat
      ├── modis_lst
      ├── modis_ndvi
      ├── PERMANENT
      └── user1
```

## The trainer

**Verónica Andreo** is a researcher for [CONICET](http://www.conicet.gov.ar/?lan=en)
working at the Institute of Tropical Medicine [(INMeT)](https://www.argentina.gob.ar/salud/inmet)
in Puerto Iguazú, Argentina. Her main interests are remote sensing and GIS tools
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
