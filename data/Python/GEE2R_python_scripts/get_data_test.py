import sys
import ee
import final

sysargv = ['blub', 1,12, 2000, 2000, 'mean', "users/JesJehle/Strips", 'mean', 100, 'no_size_test', 500,  "GeoJSON", "exampleFile", 'FALSE', "chirps_precipitation", "jrc_permanentWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", 'modis_quality']
#arguments = c(month_start, month_end, year_start, year_end, time_reducer, asset_path, spatial_reducer, scale, test, format(numPolygons, scientific=F), output, name, False, products)

#sysargv = sys.argv[:]
#print sys.argv

ee.Initialize()

if 'size_test' in sysargv:
    polygon = final.sizeTest(sysargv[10])
else:
    polygon = final.getExtractionPolygon(sysargv[6])


image = final.creatMultiBandImage(sysargv)

#clipped = image.clip(polygon.union())

#indexList_new = ee.List(image.bandNames().slice(0,ee.Number(image.bandNames().length()).subtract(1)))


featureClass = final.reduceOverRegion(image, polygon, int(sysargv[8]), sysargv[7])

status = final.exportTableToDrive(featureClass, str(sysargv[11]), sysargv[12], sysargv[13])

print status

# print indexList.getInfo()
#print selectors
#indexList = ee.List([str(sysargv[11])]).cat(image.bandNames().slice(0,ee.Number(image.bandNames().length())))
#selectors = indexList.getInfo()




#task = ee.batch.Export.table.toDrive(featureClass,'exportTableExample', fileFormat='CSV')

#task.start()