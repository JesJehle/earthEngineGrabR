import ee
import sys
# Initialize the Earth Engine object, using the authentication credentials.

ee.Initialize()

stripes = ee.FeatureCollection("users/JesJehle/Strips")

srtm = ee.Image('CGIAR/SRTM90_V4')

slope = ee.Terrain.slope(srtm)

elevation_slope = srtm.addBands(slope)\
    .reduceRegions(stripes, ee.Reducer.mode(), 90)\
    .select(['ID', 'elevation', 'slope'],
            ['ID', 'elevation', 'slope'], False)


print elevation_slope.getDownloadUrl()


