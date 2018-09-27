
#' wait_for_file_on_drive
#' @param filename name of the file to scan drive for
#' @export
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
#' @param info Output of the get_data function.
#' @param path The local path where the file should be stored, default is working directory.
#' @param clear If the file should be removed from Google Drive after the download.
#' @return nothing
#' @export
download_data <- function(filename, path = getwd(), clear = T, verbose = T){
  
  path_full <- file.path(path, filename)

  # cat("data products are in progress on the Earth Engine servers")
  
  wait_for_file_on_drive(filename)

  if (verbose == T) cat("\n")
  googledrive::drive_download(file = filename, path = path_full, overwrite = T, verbose = F)
  if (verbose == T) cat(paste0('download: ', get_name_from_path(filename), "\n"))
  if(clear == T){
    # delete file
    googledrive::drive_rm(filename, verbose = F)
    # delete folder
    # googledrive::drive_rm("GEE2R_temp")
    
  }
}

#' import data
#' @param productList List of products files produced in the ee_grab function
#' @param verbose If true, messages reporting the processing state are printed.
#' @return nothing
#' @export
import_data <- function(productList, verbose = T){
  
  product_list <- unlist(productList) 
  downloads <- list.files(getwd())
  downloads_clean <- grep('geojson', downloads, value = T)
  
  while (sum(product_list %in% downloads_clean) != length(product_list)) {
    if (verbose) cat("waiting for Earth Engine", "\n")
    if (verbose) cat(".")
    Sys.sleep(2)
    downloads <- list.files(getwd())
    downloads_clean <- grep('geojson', downloads, value = T)
  }
  
  ## import data
  if (verbose) cat("import: finished", "\n")
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
  return(join)
}
