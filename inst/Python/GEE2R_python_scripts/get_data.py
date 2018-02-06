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

if 'jrc_distanceToWater' in sysargv:
    jrc_distanceToWater = filter_jrc_distanceToWater(sysargv[1], sysargv[2], sysargv[sysargv.index("jrc_permanentWater") + 1])
    euclidean =  ee.Kernel.euclidean(100)
    distance = jrc_distanceToWater\
        .distance(euclidean, False)
    featureClassDistance = final.reduceOverRegion(image=distance, extractionPolygon=polygon, scale=1000, reducer=sysargv[4])


# reduce multiband image with given reducer over polygon
featureClass = final.reduceOverRegion(image=image, extractionPolygon=polygon, scale=int(sysargv[5]), reducer=sysargv[4])

# define filter
filter = ee.Filter.equals({
  leftField: 'system:index',
  rightField: 'system:index'
})


# define the join.
innerJoin = ee.Join.inner();

# apply the join.
joined = innerJoin.apply(featureClass, featureClassDistance,  filter);

# map over feature to extract and reformat properties
def catProperties(pair):
    f1 = ee.Feature(pair.get('primary'))
    f2 = ee.Feature(pair.get('secondary'))
    return f1.set(f2.toDictionary())



joined_finel = joined.map(catProperties)


# export feature collection to drive
status = final.exportTableToDrive(joined_finel, sysargv[6], sysargv[7], "TRUE")

print status
