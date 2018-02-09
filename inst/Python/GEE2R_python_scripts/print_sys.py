import ee
import pandas as pd
import sys
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

#path = sys.argv[1]
#print sys.argv[1]
path = "/home/jesjehle/R/x86_64-pc-linux-gnu-library/3.4/GEE2R/Python/GEE2R_python_scripts/connection.csv"
# load system params from R
params = pd.read_csv(path, delimiter=',')

#print params

print params["assetPath"][0]
#print params["chirps_precipitation"][1]
#print params["jrc_distanceToWater"][1]
#print params["modis_treeCover"][1]
#print df["modis_nonTreeVegetation"][1]
#print df["modis_nonVegetated"][1]
#print df["srtm_slope"][1]
#print df["modis_quality"][1]
#print df["oxford_friction"][1]
#print df["oxford_accessibility"][1]
#print df["assetPath"][1]
#print df["spatialReducer"][1]
#print df["resolution"][1]
#print df["name"][1]
#print df["year_start"][1]
#print df["year_end"][1]

