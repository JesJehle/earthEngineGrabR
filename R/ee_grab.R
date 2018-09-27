


#' ee_grab
#' @param products List of dataproduct functions starting with eeProduct
#' @param target A path to a local geofile, if file is already uploaded, the upload is skipped. 
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ.
#' @param verbose if true, prints messages about the state of processing
#' @param resolution Resolution of the dataproducts.
#' @return Object of class sf.
#' @export
ee_grab <- function(target = system.file("data/territories.shp", package =
                                               "earthEngineGrabR"),
                        outputFormat = "GeoJSON",
                        resolution = 100,
                        products = list(create_product()),
                        verbose = T)
  {
  activate_environments("earthEngineGrabR")
  # authorise google drive

  # upload vector data is fusion table --------------------
  table_id <-  upload_data(target = target, verbose = verbose)
  
  googledrive::drive_rm("GEE2R_temp", verbose = F)
  
  product_list = c()
  
  # check if products is a list of lists, if not creat one.
  
  if (class(products[[1]]) != "list"){
    products <- list(products) 
  }
  
  # loop over data products
  
  for (i in seq_along(products)) {
    p = products[[i]]
    p$outputFormat = outputFormat
    p$ft_id = table_id$ft_id
    p$resolution = resolution
    
    #filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    #googledrive::drive_rm(filename, verbose = F)
    
    # make functions available
    
    product_info <- get_data_info(p$productID)
    
    if(verbose) {
      for(pr in seq_along(product_info)) {
        cat(paste0(names(product_info)[pr], ": ", product_info[pr],"\n"))
      }
      }
    # get data
    status <- get_data(p, product_info$data_type)
    
    filename <- paste0(status$description, ".", casefold(p$outputFormat))
    
    
    #print(paste0("the projection of result is", drop))
    if (status$state == "READY") {
      if (verbose) cat("processing:", products[[i]]$productName, '\n')
      product_list[i] <- filename
      
    } else {
      if (verbose) cat("Processing error on earth engine servers for: ", products[[i]]$productName, '\n')
    }
  
  # product_list_clean <- na.omit(product_list)
  files_path <- tempdir()

  for (i in seq_along(product_list)) {
    if (i == 1) {
      if (verbose) cat("waiting for Earth Engine", "\n")
    }
    download_data(filename = product_list[i], 
                  path = getwd(),
                  verbose = verbose)
  }
  final_data <- import_data(product_list,
                            files_dir = getwd(),
                            verbose = verbose)
  #delete_if_exist(target)
  googledrive::drive_rm("GEE2R_temp", verbose = F)
  
  return(final_data)
  }
}









