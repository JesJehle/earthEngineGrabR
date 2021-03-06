import ee
from ee import EEException


def select_reducer_with_outputName(reducer, product_name):
    if reducer == 'mean':
        reducer = ee.Reducer.mean().setOutputs(product_name)
    elif reducer == 'median':
        reducer = ee.Reducer.median().setOutputs(product_name)
    elif reducer == 'mode':
        reducer = ee.Reducer.mode().setOutputs(product_name)
    elif reducer == 'sum':
        reducer = ee.Reducer.sum().setOutputs(product_name)
    elif reducer == 'min':
        reducer = ee.Reducer.min().setOutputs(product_name)
    elif reducer == 'max':
        reducer = ee.Reducer.max().setOutputs(product_name)
    else:
        print('Parameter should be mean, median, mode or sum')
    return reducer


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
        print('Parameter should be mean, median, mode or sum')
    return reducer


def reduceOverRegions(image, extractionPolygon, scale, reducer, name):
    reduce = select_reducer_with_outputName(reducer, name)
    bandsPerFeature = image\
        .reduceRegions(extractionPolygon, reduce, ee.Number(scale))
    return bandsPerFeature


# active
def exportTableToDrive(featureCollection, format, name, export, test=False):

    if test:
        folder = "earthEngineGrabR-test"
    else:
        folder = "earthEngineGrabR-tmp"
    # format = CSV, GeoJSON, KML, KMZ

    task = ee.batch.Export.table.toDrive(
        collection=featureCollection,
        description=str(name),
        fileFormat=str(format),
        folder=folder
    )

    if str(export) == str('TRUE'):
        task.start()
        status = task.status()
    else:
        status = task

    return status


def get_ee_object(id):
    """ checks if id points to an image or collection and return ee object """
    ee.Initialize()

    test = None
    # check if id is an image
    try:
        object_image = ee.Image(id)
        test = object_image.getInfo()
        return object_image
    except EEException as e:
        pass
    # check if id is a collection
    try:
        object_all = ee.ImageCollection(id)
        object_collection = ee.Image(object_all.first())
        test = object_collection.getInfo()
        return object_collection
    except EEException as e:
        pass
    # if it is neither an image or collection it's not a valid id
    if test is None:
        raise ValueError(e)
    # else:
    #    return object


def get_scales(id):

    ee.Initialize()
    """ Function to request native resolution of an ee asset.
    If bands have different resolutions, it return a dictionary
    with bands names as keys and native resolutions as values. """

    object = get_ee_object(id)
    object.getInfo()
    # try to get native scale for
    try:
        scale = object.projection().nominalScale().getInfo()
        scale_int = int(scale)
        return scale_int
    except EEException:
        band_names = object.bandNames().getInfo()
        scales = {}
        for name in band_names:
            scale = object.select(name) \
                .projection() \
                .nominalScale() \
                .getInfo()
            scales[str(name)] = int(scale)

        return scales


def get_info(productID):

    ee.Initialize()

    info_output = {}

    try:
        product = ee.Image(productID)
        info = product.getInfo()

        info_output['data_type'] = info['type']
        info_output['bands'] = product.bandNames().getInfo()
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
        pass

        if len(info_output) == 0:
            raise IOError('With the given ID no data set was found')

    return info_output


def get_data_image(
        productID,
        productName,
        spatialReducer,
        asset_path,
        outputFormat,
        resolution,
        bandSelection=None,
        test=False):

    ee.Initialize()

    polygon = ee.FeatureCollection(asset_path)

    if bandSelection == None:
        product_image = ee.Image(productID)
    else:
        product_image = ee.Image(productID).select(bandSelection)

    product_names = [n + "_" + "s-" + spatialReducer for n in product_image.bandNames().getInfo()]
    # with only one band reduceRegions renames output to reducer name e.g mean, with multiple bands original band names are used.
    # to rename bands first, the selected bands are renames and second in the case of only one band, the output of the reducer is changed with .setOutputs(), .setOutputs() is ignored if the image has multiple bands ????

    product_image_renamed = product_image.rename(product_names)

    product_reduced = reduceOverRegions(image=product_image_renamed,
                                        extractionPolygon=polygon,
                                        scale=resolution,
                                        reducer=spatialReducer,
                                        name=[product_names[0]])
    # export feature collection to google drive
    status = exportTableToDrive(product_reduced, outputFormat, productName, "TRUE", test=test)

    return status


def get_data_collection(
        productID,
        productName,
        spatialReducer,
        asset_path,
        outputFormat,
        resolution,
        temporalReducer='mean',
        timeStart='2000-3-20',
        timeEnd='2005-2-20',
        bandSelection=None,
        test=False):

    ee.Initialize()
    polygon = ee.FeatureCollection(asset_path)

    if bandSelection is None:
        product_collection = ee.ImageCollection(productID)
    else:
        product_collection = ee.ImageCollection(productID).select(bandSelection)

    product_filtered = product_collection.filterDate(timeStart, timeEnd)

    if product_filtered.size().getInfo() == 0:
        raise ValueError("No images found with the given daterange of " +
                         timeStart + " to " + timeEnd + ".")

    reduce_time = select_reducer(temporalReducer)

    product_reduced_time = product_filtered.reduce(reduce_time)
    band_names = ee.Image(product_collection.first()).bandNames().getInfo()

    product_name = [n + "_s-" + spatialReducer + "_t-" + temporalReducer +
                    "_" + timeStart + "_to_" + timeEnd for n in band_names]
    product_reduced_time_renamed = product_reduced_time.rename(product_name)

    product_reduced = reduceOverRegions(image=product_reduced_time_renamed,
                                        extractionPolygon=polygon,
                                        scale=resolution,
                                        reducer=spatialReducer,
                                        name=[product_name[0]])

    # export feature collection to drive
    status = exportTableToDrive(product_reduced, outputFormat, productName, "TRUE", test=test)
    return status
