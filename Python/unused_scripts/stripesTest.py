


import ee

# Initialize the Earth Engine object, using the authentication credentials.
ee.Initialize()

stripes = ee.FeatureCollection("users/JesJehle/Strips")
chirps = ee.ImageCollection("UCSB-CHG/CHIRPS/PENTAD")

chirps2000 = ee.Image(chirps.first())


chirpsStripes = chirps2000.reduceRegions(stripes, ee.Reducer.max(), 30)


print(chirpsStripes)

