import ee

# ee.Initialize()

#info_output = {}

productID = "CIESIN/GPWv4/ancillary-data-grid"

# print(len(info_output))

# if info_output:
# print(len(info_output))


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


info = get_info(productID)

print(info)
