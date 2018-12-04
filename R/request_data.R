

#' get_data
#' calls get_data_image or get_data_collections, dependent on the info object
#' @param info Data frame information generated gy ee_grab()
#' @param data_type either ImageCollection of Image,
#' @export
#' @noRd
get_data <- function(info, test = F) {
  #activate_environments("earthEngineGrabR")
  
  ee_helpers <- system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  load_test <- try(source_python(file = ee_helpers), silent = T)
  count <- 1
  while (class(load_test) == "try-error" & count < 5) {
    load_test <- try(source_python(file = ee_helpers), silent = T)
    count <- count + 1
  }
  
  
  if (info$data_type == "ImageCollection") {
    status <- tryCatch({
      get_data_collection(
        info$datasetID,
        info$productName,
        info$spatialReducer,
        info$ftID,
        info$outputFormat,
        info$resolution,
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
        info$resolution,
        info$bandSelection,
        test
      )
    }, error = function(err) {
      return(paste0("Error on Earth Engine servers for data product: ", info$productName, "\n", err))
    })
  }
  return(status)
}


#' set_resolution
#' set resolution of requested data if not set
#' @param datasetID String that speciefies the data in ee
#' @noRd
#' @export
set_resolution <- function(products) {
  # check if data is a list of lists, if not creat one.
  if (class(products[[1]]) != "list") {
    products <- list(products)
  }

  if (class(products[[1]]) != "list") {
    products <- list(products)
  }
  for (i in seq_along(products)) {
    if (is.null(products[[i]]$resolution)) {
      res <- earthEngineGrabR:::check_scale(products[[i]]$datasetID)
      products[[i]]$resolution <- res
    }
  }
  return(products)
}
  
  





#' check_scale
#' checks for equality in native resolutions among the Bands of a dataset.
#' @param datasetID String that speciefies the data in ee
#' @noRd
#' @export
check_scale <- function(datasetID) {
  earthEngineGrabR:::activate_environments("earthEngineGrabR")
  
  ee_helpers <- system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  load_test <- try(source_python(file = ee_helpers), silent = T)
  count <- 1
  while (class(load_test) == "try-error" & count < 5) {
    load_test <- try(source_python(file = ee_helpers), silent = T)
    count <- count + 1
  }
  
  product_scale <- get_scales(datasetID)
  
  if (length(product_scale) > 1) {
    
  scales_df <- data.frame('Bands' = names(product_scale), 'Resolution' = unlist(product_scale))
  rownames(scales_df) <- NULL
  
   stop(
      "Bands in ",
      datasetID,
      " have different native resolutions:\n",
      paste(capture.output(print(scales_df)), collapse = "\n"), 
      "\n\n",
      "Apply a resolution to all bands by setting the resolution argument or choose only Bands with an equal resolution by selecting bands using the bandSelection argument.",
      call. = F
    ) 
  }
  return(product_scale)
}



#' get_data_info
#' retreves info with a given product ID over earthEngine
#' @param datasetID String that speciefies the data in ee
#' @noRd
get_data_info <- function(datasetID) {
  activate_environments("earthEngineGrabR")
  
  ee_helpers <- system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  load_test <- try(source_python(file = ee_helpers), silent = T)
  count <- 1
  while (class(load_test) == "try-error" & count < 5) {
    load_test <- try(source_python(file = ee_helpers), silent = T)
    count <- count + 1
  }
  
  
  product_info <- get_info(datasetID)
  return(product_info)
}



#' request_data
#' @description Starts processing on earth engine retrieves info from data product
#' @param product_info list object created by ee_product functions
#' @param target_id String of fusion table id created by upload_data()
#' @return ee_responses for each correctly exported data product
#' @export
request_data <- function(product_info, target_id, verbose = T, test = F) {
  # check if data is a list of lists, if not creat one.

  if (class(product_info[[1]]) != "list") {
    product_info <- list(product_info)
  }
  
  #activate_environments("earthEngineGrabR")

  ee_responses <- c()
  ee_taskIDs <- c()

  # loop over data
  
  for (i in seq_along(product_info)) {
    p <- product_info[[i]]
    p$ftID <- target_id
    
    # get data
    status <- earthEngineGrabR:::get_data(p, test = test)
    if (class(status) == "character") {
      if (verbose) warning(status, call. = F)
    } else {
      if (status$state == "READY") {
        if (verbose) cat("\nrequest:", product_info[[i]]$productName, "\n")
        ee_responses[i] <- p$productNameFull
        ee_taskIDs[i] <- status$id
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
  
  ee_responses_df <- list("ee_response_names" = as.character(na.omit(ee_responses)), "ee_response_ids" = as.character(na.omit(ee_taskIDs)))
  
  ee_response <- earthEngineGrabR:::check_processing(ee_responses_df, verbose)
  
  return(ee_response)
}



# check_processing for all active tasks on earth engine
#' @param status Output of get_data function loop
#' @noRd
#' @export
check_processing <- function(status, verbose) {
  check <- c()
  for (i in seq_along(status$ee_response_ids)) {
    check[i] <-
      check_status(status$ee_response_ids[i],
                   status$ee_response_names[i],
                   verbose)
  }
  
  ee_responses_checked <-
    status$ee_response_names[check == "COMPLETED"]
  if (length(ee_responses_checked) == 0)
    stop("With the given ee_data function no valid data could be requested.",
         call. = F)
  return(as.character(ee_responses_checked))
}

# check status of a running task on earth engine
#' @param taskID Task ID returned by get_data function.
#' @param taskName Task name returned by get_data function.
#' @noRd
#' @export
check_status <- function(taskID, taskName, verbose) {
  ee <- import("ee", delay_load = T)
  status <- ee$data$getTaskStatus(taskID)
  status_state <- status[[1]]$state
  counter <- 1
  while (!status_state == "COMPLETED") {
    counter <- counter + 1
    Sys.sleep(4)

    status <- ee$data$getTaskStatus(taskID)
    status_state <- status[[1]]$state
    if (counter > 4) {
      if (counter == 5) {
        cat(paste(
          "\nWaiting for long running task: ",
          taskName, "\n"))
      } else {
        cat(".")
      }
    }
    
    if (status_state == "FAILED") {
      if (verbose) {
        warning(
          paste(
            "Error on Earth Engine servers for data product :",
            taskName,
            "\nCould not export the data"
          ),
          call. = F
        )
      }
      break()
    }
  }
  
  return(status_state)
}



