import sys
import ee
import final

# load system params from R
sysargv = sys.argv[:]


ee.Initialize()

# import polygons
polygon = final.getExtractionPolygon(sysargv[4])

# combine all selected images into a multiband image
image = final.creatMultiBandImage(sysargv)

# reduce multiband image with given reducer over polygon
featureClass = final.reduceOverRegion(image, polygon, int(sysargv[6]), sysargv[5])

# export feature collection to drive
status = final.exportTableToDrive(featureClass, sysargv[7], sysargv[8], "TRUE")

print status
