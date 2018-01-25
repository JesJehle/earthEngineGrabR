import sys
import ee
import final

#sysargv = ['blub',"users/JesJehle/Strips", 1,12, 2000, 2000, 'mean', 'mean', 1000, 'no_size_test', 3000, "chirps_precipitation", "jrc_permanentWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", 'modis_quality']

sysargv = sys.argv[:]
#print sys.argv

ee.Initialize()

try:
#    5 / "aber"
    polygon = final.getExtractionPolygon(sysargv[1])
    polygon.limit(1).getInfo()
    size = polygon.size().getInfo()
    print size
except Exception:
    import traceback
    exceptiondata = traceback.format_exc().splitlines()
    exceptionarray = exceptiondata[-1]
    print exceptionarray



