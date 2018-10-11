



#' get_data
#' calls get_data_image or get_data_collections, dependent on the info object
#' @param info Data frame information generated gy ee_grab()
#' @param data_type either ImageCollection of Image,
#' @noRd
get_data <- function(info, test = F) {
  activate_environments("earthEngineGrabR")
  ee_helpers <- system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  source_python(file = ee_helpers)

  if (info$data_type == "ImageCollection") {
    status <- tryCatch({
      get_data_collection(
        info$datasetID,
        info$productName,
        info$spatialReducer,
        info$ftID,
        info$outputFormat,
        info$scale,
        info$temporalReducer,
        info$timeStart,
        info$timeEnd,
        info$bandSelection,
        test
      )
    }, error = function(err) {
      return(paste0("Error on Earth Engine servers for data product: ", info$productName, "\n", err))
    })
  }

  if (info$data_type == "Image") {
    status <- tryCatch({
      get_data_image(
        info$datasetID,
        info$productName,
        info$spatialReducer,
        info$ftID,
        info$outputFormat,
        info$scale,
        info$bandSelection,
        test
      )
    }, error = function(err) {
      return(paste0("Error on Earth Engine servers for data product: ", info$productName, "\n", err))
    })
  }
  return(status)
}



#' get_data_info
#' retreves info with a given product ID over earthEngine
#' @param datasetID String that speciefies the data in ee
#' @noRd
get_data_info <- function(datasetID) {
  activate_environments("earthEngineGrabR")
  ee_helpers <- system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  source_python(file = ee_helpers)
  product_info <- get_info(datasetID)
  return(product_info)
}


#' request_data
#' @description Starts processing on earth engine retrieves info from data product
#' @param product_info list object created by ee_product functions
#' @param target_id String of fusion table id created by upload_data()
#' @return ee_responses for each correctly exported data product
request_data <- function(product_info, target_id, verbose = T, test = F) {
  # check if data is a list of lists, if not creat one.
  if (class(product_info[[1]]) != "list") {
    product_info <- list(product_info)
  }

  activate_environments("earthEngineGrabR")
  ee_helpers <- system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  source_python(file = ee_helpers)

  ee_responses <- c()

  # loop over data

  for (i in seq_along(product_info)) {
    p <- product_info[[i]]
    p$ftID <- target_id

    # get data
    status <- get_data(p, test = test)
    if (class(status) == "character") {
      if (verbose) warning(status, call. = F)
    } else {
      if (status$state == "READY") {
        if (verbose) cat("\nrequest:", product_info[[i]]$productName, "\n")
        ee_responses[i] <- p$productNameFull
      } else {
        if (verbose) {
          warning(
            paste(
              "Error on Earth Engine servers for data product :",
              product_info[[i]]$productName,
              "\nCould not export the data"
            ), call. = F
          )
        }
      }
    }
  }
  
  if (length(ee_responses) == 0) stop("With the given product argument no valid data could be requested.", call. = F)
  return(na.omit(ee_responses))
}
