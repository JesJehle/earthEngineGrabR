import ee
import pandas as pd

import final

# yearStart = 1
# yearEnd = 2
# assetPath = 3
# spatialReducer = 4
# resolution = 5
# outputFormat = 6
# name = 7
# products

# chirps_precipitation
# jrc_permanentWater
# modis_treeCover
# modis_nonTreeVegetation
# modis_nonVegetated
# srtm_elevation
# srtm_slope
# modis_quality


# load system params from R
params = pd.read_csv("connection.csv", delimiter=',')

print params

