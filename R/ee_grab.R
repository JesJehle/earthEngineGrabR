


#' ee_grab
#' @param products List of dataproduct functions starting with eeProduct
#' @param target A path to a local geofile, if file is already uploaded, the upload is skipped. 
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ.
#' @param verbose if true, prints messages about the state of processing
#' @param resolution Resolution of the dataproducts.
#' @return Object of class sf.
#' @export
ee_grab <- function(
  target = system.file("data/territories.shp", package="earthEngineGrabR"), 
  outputFormat = "GeoJSON",
  resolution = 100,
  products = list(
    eeProduct_modis_treeCover()
    ), 
  verbose = T
  )

{

  library(reticulate)
  try(use_condaenv("earthEngineGrabR", required = T), silent = T)
  verify_ee_conda_env("earthEngineGrabR")
  
# upload vector data is fusion table --------------------

  table_id <-  upload_data(target = target)
  
  product_list = list()
  
# loop over data products

  for(i in seq_along(products)) {
    params <- rbind(cbind(products[[i]]), ft_id = table_id$ft_id, outputFormat, resolution)
    
    df <- data.frame(t(params))
    
  # if a file with the same name is present on google drive it is deleted
    filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    googledrive::drive_rm(filename, verbose = F)
    
    # make functions available
    ee_helpers = clean_spaces(system.file("Python/final.py", package = "earthEngineGrabR"))
    source_python(file = ee_helpers)
    # get data
    
    status <- get_data(
      df$productName[[1]],
      df$spatialReducer[[1]],
      df$ft_id[[1]],
      df$outputFormat[[1]],
      df$resolution[[1]],
      df$temporalReducer[[1]],
      df$yearStart[[1]],
      df$yearEnd[[1]]
    )
    
    filename <- paste0(status$description,".", casefold(outputFormat))
    
    product_list[i] <- filename

  #print(paste0("the projection of result is", drop))
  if (status$state == "READY") {
    if (verbose == T) cat("processing:", products[[i]]$productName,'\n') 
  }
  }

   for(i in seq_along(products)) {
     if (i == 1) {
       if (verbose == T) cat("waiting for Earth Engine", "\n")
     }
     download_data_waiting(filename = list[i], verbose = verbose)
   }
    final_data <- import_data(list)
    #delete_if_exist(target)
    googledrive::drive_rm("GEE2R_temp", verbose = F)
  
   return(final_data)
}


#' ee_grab_dev
#' @param products List of dataproduct functions starting with eeProduct
#' @param target A path to a local geofile, if file is already uploaded, the upload is skipped. 
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ.
#' @param verbose if true, prints messages about the state of processing
#' @param resolution Resolution of the dataproducts.
#' @return Object of class sf.
#' @export
ee_grab_dev <- function(target = system.file("data/territories.shp", package =
                                               "earthEngineGrabR"),
                        outputFormat = "GeoJSON",
                        resolution = 100,
                        products = list(creat_product()),
                        verbose = T)
  
{
  library(reticulate)
  activate_environments("earthEngineGrabR")
  
  # upload vector data is fusion table --------------------
  
  table_id <-  upload_data(target = target)
  
  googledrive::drive_rm("GEE2R_temp", verbose = F)
  
  product_list = list()
  
  # loop over data products
  
  for (i in seq_along(products)) {
    p = products[[i]]
    p$outputFormat = outputFormat
    p$ft_id = table_id$ft_id
    p$resolution = resolution
    
    #filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    #googledrive::drive_rm(filename, verbose = F)
    
    # make functions available
    ee_helpers = system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
    
    source_python(file = ee_helpers)
    
    product_info <- get_info(p$productID)
    for(i in seq_along(product_info)){
      cat(paste0("\n", names(product_info)[i], ": ", product_info[[i]]))
    }
    # get data
    
    if (product_info$data_type == "ImageCollection") {
      status <- get_data_collection(
        productID = p$productID,
        productName = p$productName,
        spatialReducer = p$spatialReducer,
        ft_id = p$ft_id,
        outputFormat = p$outputFormat,
        resolution = p$resolution,
        temporalReducer = p$temporalReducer,
        timeStart = p$timeStart,
        timeEnd = p$timeEnd
      )
    }
    if (product_info$data_type == "Image") {
      status <- get_data_image(
        productID = p$productID,
        productName = p$productName,
        spatialReducer = p$spatialReducer,
        ft_id = p$ft_id,
        outputFormat = p$outputFormat,
        resolution = p$resolutio
      )
    }
    
    filename <-
      paste0(status$description, ".", casefold(outputFormat))
    
    product_list[i] <- filename
    
    #print(paste0("the projection of result is", drop))
    if (status$state == "READY") {
      if (verbose == T)
        cat("processing:", products[[i]]$productName, '\n')
    }
  }
  
  for (i in seq_along(products)) {
    if (i == 1) {
      if (verbose == T) cat("waiting for Earth Engine", "\n")
    }
    download_data_waiting(filename = product_list[i], verbose = verbose)
  }
  final_data <- import_data(product_list)
  #delete_if_exist(target)
  googledrive::drive_rm("GEE2R_temp", verbose = F)
  
  return(final_data)
}









