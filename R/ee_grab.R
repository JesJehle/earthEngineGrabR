


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
                        products = list(create_image_product()),
                        verbose = T)
  {
  activate_environments("earthEngineGrabR")
  # authorise google drive

  # upload vector data is fusion table --------------------
  target_id <-  upload_data(target = target, verbose = verbose)
  
  # check if products is a list of lists, if not creat one.
  
  if (class(products[[1]]) != "list"){
    products <- list(products) 
  }

  # request data products form google earth engine servers
  ee_response <- request_data(products, target_id$ft_id)
  # create temp dir
  temp_path <- get_temp_path()
  # download data products form google drive
  download_data(ee_response = ee_response, verbose = verbose, temp_path = temp_path)
  # import data to R
  product_data <- import_data(ee_response, verbose = verbose, temp_path = temp_path)
  # remove tmp files local and from drive
  googledrive::drive_rm("GEE2R_temp", verbose = F)
  unlink(temp_path, recursive = T)
  
  return(product_data)
  
  }










