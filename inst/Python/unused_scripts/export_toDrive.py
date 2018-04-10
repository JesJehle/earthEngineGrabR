import sys
import ee
import final

sysargv = ['blub', 1,12, 2000, 2000, 'mean', "users/JesJehle/Strips", 'mean', 100, 'size_test', 50, "ID", "false", 'message', "chirps_precipitation", "jrc_permanentWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", 'modis_quality']
#arguments = c(month_start, month_end, year_start, year_end, time_reducer, asset_path, spatial_reducer, scale, test,format(numPolygons, scientific=F), polygonIndex, raster, message, products)

#sysargv = sys.argv[:]
#print sys.argv

ee.Initialize()

# polygon = final.sizeTest(sysargv[10])


image = final.creatMultiBandImage(sysargv)


#clipped = image.clip(polygon.union())

#indexList_new = ee.List(image.bandNames().slice(0,ee.Number(image.bandNames().length()).subtract(1)))


# featureClass = final.reduceOverRegions(image, polygon, int(sysargv[8]), sysargv[7])

region = ee.Geometry.Point([23.66455078125, -11.996338401936226])\
    .buffer(10000)\
    .bounds()

raster = image.clip(region, GeoJSON, )

status = final.exportImageToDrive(raster, 50, 'exampleRaster')

print status
# print indexList.getInfo()
#print selectors
#indexList = ee.List([str(sysargv[11])]).cat(image.bandNames().slice(0,ee.Number(image.bandNames().length())))
#selectors = indexList.getInfo()



#final.exportToAsset(image.clip(polygon.union()), "example")

