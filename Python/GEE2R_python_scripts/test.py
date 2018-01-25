import sys
import ee
import final

#sysargv = ['blub', 1,12, 2000, 2000, 'mean', "users/JesJehle/Strips", 'mean', 1000, 'no_size_test', 500, "ID", "false", message, "chirps_precipitation", "jrc_permanentWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", 'modis_quality']
#arguments = c(month_start, month_end, year_start, year_end, time_reducer, asset_path, spatial_reducer, scale, test,format(numPolygons, scientific=F), polygonIndex, raster, message, products)

sysargv = sys.argv[:]
#print sys.argv

ee.Initialize()

if 'size_test' in sysargv:
    polygon = final.sizeTest(sysargv[10])
else:
    poly = final\
        .getExtractionPolygon(sysargv[6])
    polygon = poly\
        .toList(int(sysargv[13]))
 #       .slice(1,4000))



image = final.creatMultiBandImage(sysargv)

#clipped = image.clip(polygon.union())

#indexList_new = ee.List(image.bandNames().slice(0,ee.Number(image.bandNames().length()).subtract(1)))


n = int(sysargv[13])
steps = 5000
diff = n - steps
start = 0
end = steps

while diff > 0:
    polygonIter = ee.FeatureCollection(polygon.slice(start, end))
    featureClass = final.reduceOverRegions(image, polygonIter, int(sysargv[8]), sysargv[7])
    print featureClass.getDownloadUrl()
    start = start + steps
    end = end + steps
    diff = n - end

else:
    end = start + diff + steps
    polygonIter = ee.FeatureCollection(polygon.slice(start, end))
    featureClass = final.reduceOverRegions(image, polygonIter, int(sysargv[8]), sysargv[7])
    print featureClass.getDownloadUrl()



# print indexList.getInfo()
#print selectors
#indexList = ee.List([str(sysargv[11])]).cat(image.bandNames().slice(0,ee.Number(image.bandNames().length())))
#selectors = indexList.getInfo()



#final.exportToAsset(image.clip(polygon.union()), "example")


#task = ee.batch.Export.table.toDrive(featureClass,'exportTableExample', fileFormat='CSV')

#task.start()