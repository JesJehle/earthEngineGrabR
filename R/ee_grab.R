











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

# validate fusion table and get info about feature collection in earth engine


# upload vector data is fusion table --------------------

  table_id <-  upload_data(target = target)
  
  list = list()
  

# loop over data products

  for(i in seq_along(products)) {
    params <- rbind(cbind(products[[i]]), ft_id = table_id$ft_id, outputFormat, resolution)
     
    #write params to file
    write.table(t(params), file = "./params.csv", sep = ",", row.names = F, col.names = T)
  
  
    command = "python"
  # path to python scripts
    path2script <- system.file("Python/GEE2R_python_scripts/get_data.py", package="earthEngineGrabR")
  # test for spaces in path
    if (length(grep(" ", path2script) > 0)) {
     path2script <-  shQuote(path2script)
   }
  # for information
  # message(paste0("send request to earth engine, answer depends on the number of polygons in your shapefile. \n Your Shapefile in ", assetPath, " consists of ", message, " features."))
  
  # if a file with the same name is present on google drive it is deleted
    filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    googledrive::drive_rm(filename, verbose = F)
    
    list[i] <- filename


  # invoce system call on the commandline 
    drop = system2(command,
                       args =  path2script,
                       stdout = T,
                       wait = T)
  
  json_data <- rjson::fromJSON(file ="./exportInfo.json")
  exportInfo <- rjson::fromJSON(json_data)
  file.remove("./exportInfo.json")
  file.remove("./params.csv")
  #print(paste0("the projection of result is", drop))
  if (exportInfo$state == "READY") {
    if (verbose == T) cat("processing:", products[[i]]$productName,'\n') 
  }
  }

   for(i in seq_along(products)) {
     if (i == 1) {
       if (verbose == T) cat("waiting for Earth Engine", "\n")
     }
     download_data_waiting(filename = list[i], verbose = verbose)
   }
  

  product_list <- unlist(list) 
  downloads <- list.files(getwd())
  downloads_clean <- grep('geojson', downloads, value = T)

  while (sum(product_list %in% downloads_clean) != length(product_list)) {
    if (verbose == T) cat("waiting for Earth Engine", "\n")
    if (verbose == T) cat(".")
    Sys.sleep(2)
    downloads <- list.files(getwd())
    downloads_clean <- grep('geojson', downloads, value = T)
  }
  
    ## import data
  if (verbose == T) cat("import: finished", "\n")
    join <- sf::st_read(downloads_clean[1], quiet = TRUE)
    file.remove(downloads_clean[1])
    if(length(downloads_clean) > 1) {
      for(i in 2:length(downloads_clean)) {
        data <- sf::st_read(downloads_clean[i], quiet = TRUE)
        file.remove(downloads_clean[i])
        data_no_geom <- sf::st_set_geometry(data, NULL)
        join <- suppressMessages(dplyr::left_join(join, data_no_geom))
      }
    }
    #delete_if_exist(target)
    googledrive::drive_rm("GEE2R_temp", verbose = F)
  
   return(join)
}












