import ee
import sys
# Initialize the Earth Engine object, using the authentication credentials.

ee.Initialize()

stripes = ee.FeatureCollection(str(sys.argv[3]))

glc_treecover = ee.ImageCollection("GLCF/GLS_TCC")\
    .filterBounds(stripes)\
    .filter(ee.Filter.calendarRange(int(sys.argv[1]), int(sys.argv[2]), 'year'))\
    .reduce(ee.Reducer.mode())\
    .reduceRegions(stripes, ee.Reducer.median(), 90)\
    .select(['tree_canopy_cover_mode', 'ID', 'uncertainty_mode'], ['glcf_treecover', 'ID', 'glcf_treecover_uncertainty'], False)


print glc_treecover.getDownloadUrl()



