import ee
import sys
# Initialize the Earth Engine object, using the authentication credentials.

ee.Initialize()


stripes = ee.FeatureCollection(str(sys.argv[5]))

chirps = ee.ImageCollection("UCSB-CHG/CHIRPS/PENTAD") \
    .filter(ee.Filter.calendarRange(int(sys.argv[1]), int(sys.argv[2]), 'month')) \
    .filter(ee.Filter.calendarRange(int(sys.argv[3]), int(sys.argv[4]), 'year'))\
    .reduce(ee.Reducer.mode())\
    .reduceRegions(stripes, ee.Reducer.mode(), 90)\
    .select(['mode', 'ID'], ['precipitation', 'ID'], False)

print chirps.getDownloadUrl()


