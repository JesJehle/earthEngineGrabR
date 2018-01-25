import ee
import sys
# Initialize the Earth Engine object, using the authentication credentials.

ee.Initialize()

stripes = ee.FeatureCollection(str(sys.argv[3]))

modis_treecover = ee.ImageCollection("MODIS/051/MOD44B")\
    .filter(ee.Filter.calendarRange(int(sys.argv[1]), int(sys.argv[2]), 'year'))\
    .reduce(ee.Reducer.mode())\
    .reduceRegions(stripes, ee.Reducer.median(), 90)\
    .select(['ID','Percent_Tree_Cover_mode', 'Percent_NonTree_Vegetation_mode','Percent_NonVegetated_mode', 'Quality_mode'],
            ['ID', 'modis_treecover', 'Percent_NonTree_Vegetation', 'Percent_NonVegetated', 'modis_quality'], False)


print modis_treecover.getDownloadUrl()




