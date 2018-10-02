

#' create_image_collection
#' @param productID Strong of the Image/ImageCollection ID found in Earth Engine Data Explorer
#' @param productName A name for the data product specified by the user.
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description Climate Hazards Group InfraRed Precipitation with Station data (CHIRPS) is a 30+ year quasi-global rainfall dataset. CHIRPS incorporates 0.05° resolution satellite imagery with in-situ station data to create gridded rainfall time series for trend analysis and seasonal drought monitoring.
#' @return depend on output
#' @export
create_image_product <- function(productID = "CGIAR/SRTM90_V4",
                                 productName = "srtm",
                                 spatialReducer = "mean",
                                 resolution = 3000) {


  # parameter validation
  is_type(productID, "character")
  is_type(productName, "character")
  match.arg(spatialReducer, choices = c("mean", "median", "min", "max", "mode"))
  is_type(resolution, "numeric")


  product_name_new <- paste0(productName, "_", spatialReducer)
  productInfo <- list(
    productID = productID,
    productName = product_name_new,
    spatialReducer = spatialReducer,
    resolution = resolution,
    productNameFull = paste0(product_name_new, ".", "geojson"),
    data_type = "Image",
    outputFormat = "GeoJSON"
  )
  return(productInfo)
}




#' create_product_collection
#' @param productID Strong of the Image/ImageCollection ID found in Earth Engine Data Explorer
#' @param productName A name for the data product specified by the user.
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description Climate Hazards Group InfraRed Precipitation with Station data (CHIRPS) is a 30+ year quasi-global rainfall dataset. CHIRPS incorporates 0.05° resolution satellite imagery with in-situ station data to create gridded rainfall time series for trend analysis and seasonal drought monitoring.
#' @return depend on output
#' @export
create_collection_product <- function(productID = "UCSB-CHG/CHIRPS/DAILY",
                                      productName = "chirps",
                                      spatialReducer = "mean",
                                      temporalReducer = "mean",
                                      timeStart = "2017-01-01",
                                      timeEnd = "2017-02-01",
                                      resolution = 3000) {

  # parameter validation
  is_type(productID, "character")
  is_type(productName, "character")
  is_type(resolution, "numeric")
  is_type(timeStart, "character")
  is_type(timeEnd, "character")
  match.arg(spatialReducer, choices = c("mean", "median", "min", "max", "mode"))
  match.arg(temporalReducer, choices = c("mean", "median", "min", "max", "mode", "sum"))

  timeStart <- as.Date(timeStart, format = "%Y-%m-%d", tryFormats = c("%Y-%m-%d"))
  timeEnd <- as.Date(timeEnd, format = "%Y-%m-%d", tryFormats = c("%Y-%m-%d"))

  if (is.na(timeStart)) stop(paste(timeStart, "is not a valid Date"), call. = F)
  if (is.na(timeEnd)) stop(paste(timeEnd, "is not a valid Date"), call. = F)

  timeStart <- as.character(timeStart)
  timeEnd <- as.character(timeEnd)



  product_name_new <-
    paste0(
      productName,
      "_",
      spatialReducer,
      "_",
      timeStart,
      "_",
      timeEnd,
      "_",
      temporalReducer
    )

  productInfo <- list(
    productID = productID,
    productName = product_name_new,
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    timeStart = timeStart,
    timeEnd = timeEnd,
    resolution = resolution,
    productNameFull = paste0(product_name_new, ".", "geojson"),
    data_type = "ImageCollection",
    outputFormat = "GeoJSON"
  )
  return(productInfo)
}
