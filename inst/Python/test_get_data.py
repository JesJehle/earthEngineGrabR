import ee
#from ee_get_data import get_info

ee.Initialize()
data = ee.Image("CGIAR/SRTM90_V4")
print(data.getInfo())

#info = get_info("MODIS/006/MOD08_M3")

#print(info['data_type'])
#print(info)
# productID = "MODIS/006/MOD08_M3"
#productID  = "CGIAR/SRTM90_V4"

#ee.Initialize()

# product_all = ee.ImageCollection(productID)
#product_single = ee.Image(productID)

#product_single = ee.Image(product_all.first())
# title = product_all.get('title').getInfo()
#title = product_single.get('title').getInfo()

#info = product_single.getInfo()
#print(info['properties'])

#print(info.keys())
#print(info['id'])
#print(info['properties'])
#print(info['version'])
#print(info['type'])
#print(info['bands'])
#print(title)


