
#' get_data
#' calls get_data_image or get_data_collections, dependent on the info object
#' @param info Data frame information generated gy ee_grab()
#' @param data_type either ImageCollection of Image,
#' @export
get_data <- function(info, data_type = "ImageCollection") {
  type <- match.arg(data_type, c("ImageCollection", "Image"))
  activate_environments("earthEngineGrabR")
  ee_helpers = system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  source_python(file = ee_helpers)
  
  if (type == "ImageCollection") {
    status <- get_data_collection(
      info$productID,
      info$productName,
      info$spatialReducer,
      info$ft_id,
      info$outputFormat,
      info$resolution,
      info$temporalReducer,
      info$timeStart,
      info$timeEnd
      )
    }
  if (type == "Image") {
    status <- get_data_image(
      info$productID,
      info$productName,
      info$spatialReducer,
      info$ft_id,
      info$outputFormat,
      info$resolutio
    )
  }
  return(status)
}



#' get_data_info
#' retreves info with a given product ID over earthEngine
#' @param productID String that speciefies a data products in ee
#' @export
get_data_info <- function(productID) {
  
  activate_environments("earthEngineGrabR")
  ee_helpers = system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  source_python(file = ee_helpers)
  product_info <- get_info(productID)
  return(product_info)
}




















