import ee


def select_reducer(reducer):
    if reducer == 'mean':
        reducer = ee.Reducer.mean()
    elif reducer == 'median':
        reducer = ee.Reducer.median()
    elif reducer == 'mode':
        reducer = ee.Reducer.mode()
    elif reducer == 'sum':
        reducer = ee.Reducer.sum()
    elif reducer == 'min':
        reducer = ee.Reducer.min()
    elif reducer == 'max':
        reducer = ee.Reducer.max()
    else:
        print 'Parameter should be mean, median, mode or sum'
        sys.exit()
    return reducer


def reduceOverRegions(image, extractionPolygon, scale, reducer, productName):
    reduce = select_reducer_with_outputName(reducer, productName)
    bandsPerFeature = image\
        .reduceRegions(extractionPolygon, reduce, ee.Number(scale))
    return bandsPerFeature

# active
def exportTableToDrive(featureCollection, format, name, export):
    # format = CSV, GeoJSON, KML, KMZ
    task = ee.batch.Export.table.toDrive(
        collection=featureCollection,
        description=str(name),
        fileFormat = str(format),
        folder = "GEE2R_temp")

    if str(export) == str('TRUE'):
        task.start()
        status = task.status()
    else:
        status = task

    return status


def get_info(productID):

    ee.Initialize()

    info_output = {}

    try:
        product = ee.Image(productID)
        info = product.getInfo()

        info_output['data_type'] = info['type']
        info_output['bands'] = ee.Image(product.first()).bandNames().getInfo()
        info_output['epsg'] = info['bands'][0]['crs']
        info_output['tile'] = product.get('title').getInfo()


    except Exception:
        pass
    try:
        product_all = ee.ImageCollection(productID)
        product_single = ee.Image(product_all.first())
        info = product_single.getInfo()

        last = ee.Image(product_all.sort("system:time_start", False).first())
        first = ee.Image(product_all.sort("system:time_start").first())

        date_first = ee.Date(first.get('system:time_start')).format("Y-M-d").getInfo()
        date_last = ee.Date(last.get('system:time_start')).format("Y-M-d").getInfo()

        info_output['range'] = [date_first, date_last]

        info_output['number_of_images'] = product_all.size().getInfo()
        info_output['data_type'] = 'ImageCollection'
        info_output['bands'] = product_single.bandNames().getInfo()
        info_output['epsg'] = info['bands'][0]['crs']
        info_output['tile'] = product_all.get('title').getInfo()



    except Exception:
        raise IOError('With the given ID no data set was found')

    return info_output



