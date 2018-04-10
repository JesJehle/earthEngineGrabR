import ee
import sys
# Initialize the Earth Engine object, using the authentication credentials.

sys.argv = ['blub', 1,12, 2000, 2000, True, "users/JesJehle/Strips", "precipitation", "surface_water", "treecover", "non_tree_vegetation", "elevation", "slope"]

ee.Initialize()

## load stripes
stripes = ee.FeatureCollection(str(sys.argv[5]))

## chirps
chirps = ee.ImageCollection("UCSB-CHG/CHIRPS/PENTAD") \
    .filter(ee.Filter.calendarRange(int(sys.argv[1]), int(sys.argv[2]), 'month')) \
    .filter(ee.Filter.calendarRange(int(sys.argv[3]), int(sys.argv[4]), 'year'))\
    .reduce(ee.Reducer.mode())\
    .reduceRegions(stripes, ee.Reducer.mode(), 30)\
    .select(['mode', 'ID'], ['precipitation', 'ID'], False)


## jrc surface water
jrc_year = ee.ImageCollection("JRC/GSW1_0/YearlyHistory")\
    .filter(ee.Filter.calendarRange(int(sys.argv[3]), int(sys.argv[4]), 'year'))\
    .reduce(ee.Reducer.mode())\
    .gte(2)\
    .reduceRegions(stripes, ee.Reducer.count(), 30)\
    .select(['count', 'ID'], ['water_30m_2', 'ID'], False)



## modis treecover
modis_treecover = ee.ImageCollection("MODIS/051/MOD44B")\
    .filter(ee.Filter.calendarRange(int(sys.argv[3]), int(sys.argv[4]), 'year'))\
    .reduce(ee.Reducer.mode())\
    .reduceRegions(stripes, ee.Reducer.median(), 30)\
    .select(['ID','Percent_Tree_Cover_mode', 'Percent_NonTree_Vegetation_mode','Percent_NonVegetated_mode', 'Quality_mode'],
            ['ID', 'modis_treecover', 'Percent_NonTree_Vegetation', 'Percent_NonVegetated', 'modis_quality'], False)


## srtm
srtm = ee.Image('CGIAR/SRTM90_V4')
slope = ee.Terrain.slope(srtm)

elevation_slope = srtm.addBands(slope)\
    .reduceRegions(stripes, ee.Reducer.mode(), 30)\
    .select(['ID', 'elevation', 'slope'],
            ['ID', 'elevation', 'slope'], False)


collection = ee.FeatureCollection([
    ee.Feature(None, ee.Dictionary.fromLists(
        chirps.aggregate_array('ID'),
        chirps.aggregate_array('precipitation'))),
    ee.Feature(None, ee.Dictionary.fromLists(
        jrc_year.aggregate_array('ID'),
        jrc_year.aggregate_array('water_30m_2'))),
    ee.Feature(None, ee.Dictionary.fromLists(
        elevation_slope.aggregate_array('ID'),
        elevation_slope.aggregate_array('elevation'))),
    ee.Feature(None, ee.Dictionary.fromLists(
        elevation_slope.aggregate_array('ID'),
        elevation_slope.aggregate_array('slope')))

])


collection_modis = ee.FeatureCollection([
    ee.Feature(None, ee.Dictionary.fromLists(
        modis_treecover.aggregate_array('ID'),
        modis_treecover.aggregate_array('modis_treecover'))),
    ee.Feature(None, ee.Dictionary.fromLists(
        modis_treecover.aggregate_array('ID'),
        modis_treecover.aggregate_array('Percent_NonTree_Vegetation'))),
    ee.Feature(None, ee.Dictionary.fromLists(
        modis_treecover.aggregate_array('ID'),
        modis_treecover.aggregate_array('Percent_NonVegetated'))),
    ee.Feature(None, ee.Dictionary.fromLists(
        modis_treecover.aggregate_array('ID'),
        modis_treecover.aggregate_array('modis_quality'))),
])


print collection.getDownloadUrl()
print collection_modis.getDownloadUrl()

