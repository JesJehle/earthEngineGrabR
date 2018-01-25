
import ee
import sys
import geojsonio
import pygeoj
import os
import geopandas as gpd

#path = "~/Documents/Ms_Arbeit/Data"
#os.chdir(path)
#stripes = gpd.read_file('stripes')
#geojson_test.is_valid
# print(stripes.head())
#stripes_geojson = stripes.to_json()
# print(stripes_geojson)



testfile = pygeoj.load("stripes")

# testfile = testfile_sub[0:10]
#print(testfile)
#print testfile[320]
#states = gpd.read_file("stripes")
#print(type(testfile))

ee.Initialize()

# print(len(testfile))
#first_geom = ee.Geometry.MultiPolygon(testfile[320].geometry.coordinates)
#first_prop = ee.Dictionary(testfile[320].properties)
#ee_first_feature = ee.Feature(first_geom, first_prop)
#print ee_first_feature.getInfo()

#first_geom = ee.Geometry.MultiPolygon(testfile[1].geometry.coordinates)
#first_prop = ee.Dictionary(testfile[1].properties)
#ee_second_feature = ee.Feature(first_geom, first_prop)
#print ee_second_feature.getInfo()

#print testfile[1]

# ee_list = ee.List(ee_first_feature).add(ee_second_feature)

#feature_list = [ee_first_feature, ee_second_feature]


#ee_featureCollection = ee.FeatureCollection(ee_first_feature)

#print len(testfile)

# list try



l = range(0,len(testfile))


for i in range(0, len(testfile)):
    geom = ee.Geometry.MultiPolygon(testfile[i].geometry.coordinates)
    prop = ee.Dictionary(testfile[i].properties)
    ee_feature = ee.Feature(geom, prop)
    l[i] = ee_feature

#print l

ee_featureCollection_1 = ee.FeatureCollection(l[1000:len(testfile)])
#print ee_featureCollection_1.getDownloadUrl()



ee_featureCollection_2 = ee.FeatureCollection(l[0:3000])
print ee_featureCollection_2.getDownloadUrl()




## feature collection try

#for i in range(2, 1000):
#    geom = ee.Geometry.MultiPolygon(testfile[i].geometry.coordinates)
#    prop = ee.Dictionary(testfile[i].properties)
#    ee_feature = ee.Feature(geom, prop)
#    ee_featureCollection_temp = ee.FeatureCollection(ee_feature)
#    ee_featureCollection = ee_featureCollection.merge(ee_featureCollection_temp)


#print ee_list.getInfo()
# ee_featureCollection = ee.FeatureCollection(ee_list)
# print(ee_featureCollection.getInfo())

# print ee_featureCollection.getDownloadUrl()


#print(ee_list)



#print(ee_list)

# print(ee_list)
#print(id)

#feature = testfile[1]
# print(feature)

#test = testfile[1].geometry.coordinates
#print(test)



#ee_testfile = ee.Geometry.MultiPolygon(test)
#print(ee_testfile)
#ee_test_all = ee.Algorithms.GeometryConstructors.MultiGeometry(list)


# print(ee_testfile)

#print(ee_test_all)

# print(type(sys.argv[1]))


# Initialize the Earth Engine object, using the authentication credentials.



#ee.Initialize()
