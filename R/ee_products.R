

#' Defines request for image data
#' @param datasetID \code{string} that specifies the dataset in Earth Engine. The dataset ID can be found in the \href{link to tutorial }{snippet section} of the dataset in the Earth Engine \href{https://developers.google.com/earth-engine/datasets/}{Data Catalog}.
#' @param spatialReducer \code{string} that specifies the spatial aggregation of the data within the polygons of the targetArea. The spatial reducer can be one of \code{"mean", "median", "min", "max", "mode"}
#' @param scale \code{integer} that controls the \href{https://developers.google.com/earth-engine/scale}{scale of analysis} in Earth Engine. The scale controls the resolution of the data in which the computations are performed. In Earth Engine data is ingested at multiple scales, in an image pyramid. When you use an image, Earth Engine chooses a level of the pyramid with the closest scale less than or equal to the scale specified by your scale argument and resamples (using nearest neighbour by default) as necessary.
#' @param bandSelection \code{string} or a \code{vector} of \code{strings} of bands names to select from the requested dataset. By default bandSelection is set to \code{NULL} and all bands of the dataset are used.
#' @description \code{ee_data_image()} and \code{ee_data_collection()} are used to define the requested earth enigne data for the \code{ee_grab()} function.   
#' @return object of class \code{list} that defines the data request for \code{ee_grab()}.
#' @export
#' 
#' 
#' 
#' @section Image and Image Collections in Earth Engine:
#' 
#' In Earth Engine raster data is stored as an \code{Image} object. 
#' Images are composed of one or more bands and each band has its own name, data type, scale, mask and projection. A time series or stack of Images is stored as an Image Collection.
#' To request data from an Image use \code{ee_data_image()} to define the request. 
#' To request data from a time series of Images stored in an Image Collection use \code{ee_data_collection()} instead.
#' 
#' 
ee_data_image <- function(datasetID = "CGIAR/SRTM90_V4",
                          spatialReducer = "mean",
                          scale = 3000,
                          bandSelection = NULL) {


  # parameter validation
  is_type(datasetID, "character")
  match.arg(spatialReducer, choices = c("mean", "median", "min", "max", "mode"))
  is_type(scale, "numeric")
  if (!is.null(bandSelection)) is_type(bandSelection, "character")
  if (length(bandSelection) > 1 & !is.vector(bandSelection)) stop("bandSelection is not a vector. \nIf you want to select multiple bands, pass them inside a vector.", call. = F)
  


  product_name_new <- paste0(gsub("/", "-", datasetID), "_", "s-", spatialReducer)
  productInfo <- list(
    datasetID = datasetID,
    productName = product_name_new,
    spatialReducer = spatialReducer,
    scale = scale,
    productNameFull = paste0(product_name_new, ".", "geojson"),
    data_type = "Image",
    outputFormat = "GeoJSON",
    bandSelection = bandSelection
  )
  return(productInfo)
}


#' Defines request for collection data
#' @param datasetID \code{string} that specifies the dataset in Earth Engine. The dataset ID can be found in the \href{link to tutorial }{snippet section} of the dataset in the Earth Engine \href{https://developers.google.com/earth-engine/datasets/}{Data Catalog}.
#' @param spatialReducer \code{string} that specifies the spatial aggregation of the data within the polygons of the targetArea. The spatial reducer can be one of \code{"mean", "median", "min", "max", "mode"}
#' @param temporalReducer \code{string} that specifies the temporal aggregation of the filtered image collection. The spatial reducer can be one of \code{"mean", "median", "min", "max", "mode", "sum"}
#' @param timeStart \code{string} with the date format of yyyy-mm-dd, to filter the image collection.
#' @param timeEnd \code{string} with the date format of yyyy-mm-dd, to filter the image collection. The date selection is inclusive for the dateStart date and exclusive for the timeEnd date. Therefore, to select a single day use the date of the day as time start and the day after as timeEnd date.
#' @param bandSelection \code{string} or a \code{vector} of \code{strings} of bands names to select from the requested dataset. By default bandSelection is set to \code{NULL} and all bands of the dataset are used.
#' @description \code{ee_data_image()} and \code{ee_data_collection()} are used to define the requested earth enigne data for the \code{ee_grab()} function.   
#' @return object of class \code{list} that defines request for collection data in \code{ee_grab()}.
#' @export
#' 
#' @section Image and Image Collections in Earth Engine:
#' 
#' In Earth Engine raster data is stored as an \code{Image} object. 
#' Images are composed of one or more bands and each band has its own name, data type, scale, mask and projection. A time series or stack of Images is stored as an Image Collection.
#' To request data from an Image use \code{ee_data_image()} to define the request. 
#' To request data from a time series of Images stored in an Image Collection use \code{ee_data_collection()} instead.
#' 
#' 
#' 
ee_data_collection <- function(datasetID = "UCSB-CHG/CHIRPS/DAILY",
                                      spatialReducer = "mean",
                                      temporalReducer = "mean",
                                      timeStart = "2017-01-01",
                                      timeEnd = "2017-02-01",
                                      scale = 3000,
                                      bandSelection = NULL) {

  # parameter validation
  is_type(datasetID, "character")
  is_type(scale, "numeric")
  is_type(timeStart, "character")
  is_type(timeEnd, "character")
  
  if (!is.null(bandSelection)) is_type(bandSelection, "character")
  if (length(bandSelection) > 1 & !is.vector(bandSelection)) stop("bandSelection is not a vector. \nIf you want to select multiple bands, pass them inside a vector.", call. = F)
  
  match.arg(spatialReducer, choices = c("mean", "median", "min", "max", "mode"))
  match.arg(temporalReducer, choices = c("mean", "median", "min", "max", "mode", "sum"))

  timeStart <- as.Date(timeStart, format = "%Y-%m-%d", tryFormats = c("%Y-%m-%d"))
  timeEnd <- as.Date(timeEnd, format = "%Y-%m-%d", tryFormats = c("%Y-%m-%d"))

  if (is.na(timeStart)) stop(paste(timeStart, "is not a valid Date"), call. = F)
  if (is.na(timeEnd)) stop(paste(timeEnd, "is not a valid Date"), call. = F)
  
  if (identical(timeStart, timeEnd)) stop(
    "timeStart and timeEnd have the identical date: ", 
    timeStart, 
    "\nTo select only the single day ",
    timeStart,  
    " use the date range of timeStart: ", timeStart,  " and timeEnd: ", timeEnd + 1, 
  ".\nThe date selection is inclusive for the dateStart date and exclusive for the timeEnd date. 
  Therefore, to select a single day use the date of the day as time start and the day after as timeEnd date."
  , call. = FALSE)

  timeStart <- as.character(timeStart)
  timeEnd <- as.character(timeEnd)

  product_name_new <-
    paste0(
      gsub("/", "-", datasetID),
      "_",
      paste0("s-", spatialReducer),
      "_",
      paste0("t-", temporalReducer),
      "_",
      timeStart,
      "to",
      timeEnd
    )

  productInfo <- list(
    datasetID = datasetID,
    productName = product_name_new,
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    timeStart = timeStart,
    timeEnd = timeEnd,
    scale = scale,
    productNameFull = paste0(product_name_new, ".", "geojson"),
    data_type = "ImageCollection",
    outputFormat = "GeoJSON",
    bandSelection = bandSelection
  )
  return(productInfo)
}
