get_data_image <- function(
  productID,
  productName,
  spatialReducer,
  ft_id,
  outputFormat,
  resolution
) {
  
  ee$Initialize()
  
  polygon = ee$FeatureCollection(ft_id)

  product_image = ee$Image(productID)

    product_reduced = reduceOverRegions(image = product_image,
                                      extractionPolygon = polygon,
                                      scale = resolution, 
                                      reducer = spatialReducer,
                                      productName = productName)
  

  
  # export feature collection to drive
  status = exportTableToDrive(product_reduced, outputFormat, productName, "TRUE")
  

return(status)  
  
}


get_data_collection <- function(
  productID,
  productName,
  spatialReducer,
  temporalReducer = "mean",
  timeStart = "2000-3-20",
  timeEnd = "2005-2-20",
  ft_id,
  outputFormat,
  resolution
) {
  
  ee$Initialize()
  
  polygon = ee$FeatureCollection(ft_id)
  
  product = ee$ImageCollection(productID)
  # reduce = select_reducer(temporalReducer)
  product_filtered = product$filterDate(timeStart, timeEnd)
  product_reduced = product_filtered$reduce(ee$Reducer$mean())
  
 
  product_reduced = reduceOverRegions(image = product_reduced,
                                      extractionPolygon = polygon,
                                      scale = resolution, 
                                      reducer = spatialReducer,
                                      productName = productName)
  
  
  
  # export feature collection to drive
  status = exportTableToDrive(product_reduced, outputFormat, productName, "TRUE")
  
  
  return(status)  
  
}




