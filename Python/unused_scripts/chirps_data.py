
import ee
import sys
# Initialize the Earth Engine object, using the authentication credentials.
ee.Initialize()

if 1 == 0:
    reducer = ee.Reducer.min()
else:
    reducer = ee.Reducer.max()

stripes = ee.FeatureCollection("users/JesJehle/Strips")

chirps = ee.ImageCollection("UCSB-CHG/CHIRPS/PENTAD")

chirps2000 = ee.Image(chirps.first())

chirpsStripes = chirps2000.reduceRegions(stripes, reducer, 30)

print chirpsStripes.getDownloadUrl()



