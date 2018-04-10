import ee
import sys
# Initialize the Earth Engine object, using the authentication credentials.

ee.Initialize()

stripes = ee.FeatureCollection(str(sys.argv[3]))

jrc_year = ee.ImageCollection("JRC/GSW1_0/YearlyHistory")\
    .filter(ee.Filter.calendarRange(int(sys.argv[1]), int(sys.argv[2]), 'year'))\
    .reduce(ee.Reducer.mode())\
    .gte(2)\
    .reduceRegions(stripes, ee.Reducer.count(), 90)\
    .select(['count', 'ID'], ['water_30m_2', 'ID'], False)


print jrc_year.getDownloadUrl()
