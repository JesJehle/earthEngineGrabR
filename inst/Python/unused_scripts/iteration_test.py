

import sys
import ee
import final
import pygeoj


sysargv = ['blub', 1,12, 2000, 2000, 'mean', "users/JesJehle/Strips", 'mean', 1000, 'no_size_test', 500, "ID", "false", "message", "chirps_precipitation", "jrc_permanentWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", 'modis_quality']
#arguments = c(month_start, month_end, year_start, year_end, time_reducer, asset_path, spatial_reducer, scale, test,format(numPolygons, scientific=F), polygonIndex, raster, message, products)

#sysargv = sys.argv[:]
#print sys.argv

ee.Initialize()

testfile = pygeoj.load("stripes")


#for i in range(0, len(testfile)):
 #   geom = ee.Geometry.MultiPolygon(testfile[i].geometry.coordinates)
 #   prop = ee.Dictionary(testfile[i].properties)
 #   ee_feature = ee.Feature(geom, prop)
 #   l[i] = ee_feature

#print l


image = final.creatMultiBandImage(sysargv)

#clipped = image.clip(polygon.union())

#indexList_new = ee.List(image.bandNames().slice(0,ee.Number(image.bandNames().length()).subtract(1)))


n = len(testfile)
steps = 100
diff = n - steps
start = 0
end = steps
l = range(start, n)


def reduceOverRegion(image, extractionPolygon, scale, reducer):
    def reduceFeature(feature):
        reduce = select_reducer(reducer)
        feature_new = feature.set(ee.Image(image).reduceRegion(reduce, feature.geometry(), ee.Number(scale),  bestEffort = True))
        return feature_new
    bandsPerFeature = extractionPolygon.map(reduceFeature)
    # select(ee.List(['system:index', 'ID']).cat(image.bandNames()), ee.List(['system:index', 'ID']).cat(image.bandNames()),False)
    return bandsPerFeature




while diff > 0:
    for i in range(start, end):
        geom = ee.Geometry.MultiPolygon(testfile[i].geometry.coordinates)
        prop = ee.Dictionary(testfile[i].properties)
        ee_feature = ee.Feature(geom, prop)
        l[i] = ee_feature

    polygonIter = ee.FeatureCollection(l[start:end])
    print polygonIter.geometry().projection().getInfo()
    feature_one = polygonIter.first()
    feature_one_re = ee.Algorithms.ProjectionTransform(feature_one)
    print feature_one_re.geometry().projection().getInfo()
    print feature_one_re.geometry().getInfo()
    feature = image.reduceRegion(ee.Reducer.mean(), feature_one_re.geometry(), 100, bestEffort=True)
    image_clip = image.clip(feature_one_re)
    print image_clip.getInfo()
    print feature.getInfo()
    featureClass = final.reduceOverRegions(image, polygonIter, int(sysargv[8]), sysargv[7])
    print featureClass.getInfo()
    print featureClass.getDownloadUrl()
    start = start + steps
    end = end + steps
    diff = n - end

else:
    end = start + diff + steps
    for i in range(start, end):
        geom = ee.Geometry.MultiPolygon(testfile[i].geometry.coordinates)
        prop = ee.Dictionary(testfile[i].properties)
        ee_feature = ee.Feature(geom, prop)
        l[i] = ee_feature

    polygonIter = ee.FeatureCollection(l[start:end])
    featureClass = final.reduceOverRegion(image, polygonIter, int(sysargv[8]), sysargv[7])
    print featureClass.getDownloadUrl()



# print indexList.getInfo()
#print selectors
#indexList = ee.List([str(sysargv[11])]).cat(image.bandNames().slice(0,ee.Number(image.bandNames().length())))
#selectors = indexList.getInfo()



#final.exportToAsset(image.clip(polygon.union()), "example")


#task = ee.batch.Export.table.toDrive(featureClass,'exportTableExample', fileFormat='CSV')

#task.start()