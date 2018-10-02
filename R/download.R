
#' wait_for_file_on_drive
#' @param filename name of the file to scan drive for
wait_for_file_on_drive <- function(filename, verbose = T){
  
  test <- googledrive::drive_find(filename, verbose = F)
  
    while (nrow(test) < 1) {
    Sys.sleep(1)
    if (verbose) cat(".")
    test <- googledrive::drive_find(filename, verbose = F)
    }
  return(T)
}


#' download_data_waiting
#' @param ee_response Output of the request_data function.
#' @param clear If the file should be removed from Google Drive after the download.
#' @return nothing
download_data <- function(ee_response,
                          clear = T,
                          verbose = T,
                          temp_path) {
  
  for (i in seq_along(ee_response)) {
    if (i == 1) {
      if (verbose)
        cat("\nwaiting for Earth Engine", "\n")
    }
    
    path_full <- file.path(temp_path, ee_response[i])
    
    wait_for_file_on_drive(ee_response[i])
    
    if (verbose == T)
      cat("\n")
    googledrive::drive_download(
      file = ee_response[i],
      path = path_full,
      overwrite = T,
      verbose = F
    )
    
    if (verbose)
      cat(paste0('download: ', get_name_from_path(ee_response[i]), "\n"))
    # delete folder
    if (clear)
      googledrive::drive_rm(ee_response[i], verbose = F)
  }
  
}



#' import data
#' @param productList List of products files produced in the ee_grab function
#' @param verbose If true, messages reporting the processing state are printed.
#' @return nothing
import_data <- function(product_list, verbose = T, temp_path){
  
  #product_list <- unlist(productList) 

  downloads <- list.files(temp_path)
  downloads_clean <- grep('geojson', downloads, value = T)
  
  while (sum(product_list %in% downloads_clean) != length(product_list)) {
    if (verbose) cat("\nwaiting for Earth Engine", "\n")
    if (verbose) cat(".")
    Sys.sleep(2)
    downloads <- list.files(temp_path)
    downloads_clean <- grep('geojson', downloads, value = T)
  }
  
  ## import data
  if (verbose) cat("\nimport: finished", "\n")
  join <- sf::st_read(file.path(temp_path, downloads_clean[1]), quiet = TRUE)
  file.remove(file.path(temp_path, downloads_clean[1]))
  if(length(downloads_clean) > 1) {
    for(i in 2:length(downloads_clean)) {
      data <- sf::st_read(file.path(temp_path, downloads_clean[i]), quiet = TRUE)
      file.path(temp_path, downloads_clean[i])
      data_no_geom <- sf::st_set_geometry(data, NULL)
      join <- suppressMessages(dplyr::left_join(join, data_no_geom))
    }
  }
  return(join)
 # if(clean) unlink(temp_path, recursive = T)
}
