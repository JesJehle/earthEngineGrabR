import ee
# import pandas.read_csv as read_csv
import final

# load system params from R

# print(params)

# params
# productName     "modis_treeCover_percent_2000_2002"
# spatialReducer  "mean"
# temporalReducer "mean"
# yearStart       2000
# yearEnd         2002
# byYear          FALSE
# ft_id           "ft:1PChi65b4Tit6wdQU2qcTBw6w7nFSGTGBlMxuFKeE"
# outputFormat    "GeoJSON"
# resolution      100

def get_data(
        productName,
        spatialReducer,
        temporalReducer=None,
        yearStart=None,
        yearEnd=None,
        ft_id,
        outputFormat,
        resolution):


    ee.Initialize()

    # import polygons
    # polygon = final.getExtractionPolygon(pathToAsset= params["assetPath"][0])
    polygon = ee.FeatureCollection(ee.String(ft_id))
    # combine all selected images into a multiband image
    # environmental_variable = final.creatMultiBandImage(params=params)

    product_image = creat_dataProduct(productName = productName,
                                yearStart=yearStart,
                                yearEnd=yearEnd,
                                temporalReducer=temporalReducer)


    # reduce multiband image with given reducer over polygon
    # featureClass = final.reduceOverRegions(multiBandImage=environmental_variable, extractionPolygon=polygon, scale=int(params["resolution"][0]), reducer=params["spatialReducer"][0])
    product_reduced = reduceOverRegions(image=product_image,
                                           extractionPolygon=polygon,
                                           scale=int(resolution), reducer=spatialReducer,
                                           productName=productName)

    # projection = featureClass.getInfo()
    # print(projection)
    # define filter

    # export feature collection to drive
    status = exportTableToDrive(product_reduced, outputFormat, productName, "TRUE")

    print(status)

    #jsonData = json.dumps(status)

    #with open('exportInfo.json', 'w') as f:
    #    json.dump(jsonData, f)







