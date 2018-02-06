import sys
import ee
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

sysargv = sys.argv[:]
# print sysargv
ee.Initialize()

# import polygons
polygon = final.getExtractionPolygon(pathToAsset= sysargv[3])

# combine all selected images into a multiband image
image = final.creatMultiBandImage(sysargv=sysargv)

# reduce multiband image with given reducer over polygon
featureClass = final.reduceOverRegion(image=image, extractionPolygon=polygon, scale=int(sysargv[5]), reducer=sysargv[4])

# export feature collection to drive
status = final.exportTableToDrive(featureClass, sysargv[6], sysargv[7], "TRUE")

print status
