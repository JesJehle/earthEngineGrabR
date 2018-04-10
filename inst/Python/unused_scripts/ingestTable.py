# -*- coding: utf-8 -*-
# Import the Earth Engine Python Package
import ee
import json
# Initialize the Earth Engine object, using the authentication credentials.
ee.Initialize()

# Print the information for an image asset.
#taskID = ee.data.newTaskId().getInfo()


params =  [{'sources':'/home/jesjehle/Documents/Ms_Arbeit/Data/Strips_shapefiles/RR16StripsAlignedForFig.shp', 'id': 'users/JesJehle/RR16StripsAlignedForFig' }]

print json.dumps(params)
#ee.data.startTableIngestion(taskID, params =  params)

#image = ee.Image('srtm90_v4')
#print(image.getInfo())

#print params['sources']


