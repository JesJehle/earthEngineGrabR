


#' ee_grab
#' @param products List of dataproduct functions starting with eeProduct
#' @param target A path to a local geofile, if file is already uploaded, the upload is skipped. 
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ.
#' @param verbose if true, prints messages about the state of processing
#' @param resolution Resolution of the dataproducts.
#' @return Object of class sf.
#' @export
ee_grab <- function(
  target = NULL, 
  outputFormat = "GeoJSON",
  resolution = 100,
  products = list(
    eeProduct_modis_treeCover()
    ), 
  verbose = T
  )

{

# upload vector data is fusion table --------------------
    reticulate::source_python(file = gee2r_path)

  table_id <-  upload_data(target = target)
  
  list = list()
  
# loop over data products

  for(i in seq_along(products)) {
    params <- rbind(cbind(products[[i]]), ft_id = table_id$ft_id, outputFormat, resolution)
    
    df <- data.frame(t(params))
    
  # if a file with the same name is present on google drive it is deleted
    filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    googledrive::drive_rm(filename, verbose = F)
    
    gee2r_path = clean_spaces(system.file("Python/GEE2R_python_scripts/final.py", package = "earthEngineGrabR"))
    
    # make functions available
    
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
    
    list[i] <- filename

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












