#!/usr/bin/env python

# Markus Neteler, 2018
#
# based on
# https://grasswiki.osgeo.org/wiki/Working_with_GRASS_without_starting_it_explicitly#Python:_GRASS_GIS_7_with_an_external_library:_grass-session
#
# Requirements:
#               'sudo pip install grass-session'


# define where to process the data in the temporary grass-session
mygisdb = '/tmp/grassdata'
mylocation = 'world'
mymapset = 'user'

# the next line starts the GRASS GIS session
from grass_session import Session

# import some convenient GRASS GIS Python API parts
from grass.script import core as gcore
import grass.script as gscript
import grass.script.setup as gsetup
# import grass python libraries
from grass.pygrass.modules.shortcuts import general as g
from grass.pygrass.modules.shortcuts import raster as r
from grass.pygrass.modules.shortcuts import vector as v
from grass.pygrass.modules.shortcuts import temporal as t

# set some common environmental variables, like for raster compression settings:
import os
os.environ.update(dict(GRASS_COMPRESS_NULLS='1'))
#  needs G75:          GRASS_COMPRESSOR='ZSTD'))


# create a PERMANENT mapset; create a Session instance
PERMANENT = Session()
# hint: EPSG code lookup: https://epsg.io
PERMANENT.open(gisdb=mygisdb, location=mylocation,
               create_opts='EPSG:4326')

# exit from PERMANENT right away in order to perform analysis in our own mapset
PERMANENT.close()

# create a new mapset in the same location
user = Session()
user.open(gisdb=mygisdb, location=mylocation, mapset=mymapset,
               create_opts='')

# execute some command inside user mapset

# import admin0 vector data - it downloads and imports including topological cleaning on the fly
#   Data source: https://www.naturalearthdata.com/downloads/10m-cultural-vectors/
#   VSI driver for remote access: http://www.gdal.org/gdal_virtual_file_systems.html#gdal_virtual_file_systems_vsicurl
inputfile = "/vsizip/vsicurl/https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip"

# note the pythonic underscore
v.in_ogr(input=inputfile, output="countries", overwrite = True)

# show the attribute column names
v.info(map="countries", flags="c")

# list vector maps available in the current mapset
g.list(type="vector", flags="m")

# now do anaylsis with the map...

# exit from user mapset (the data will remain)
user.close()
