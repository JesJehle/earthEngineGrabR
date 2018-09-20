
#' download_data
#' @param info Output of the get_data function.
#' @param path The local path where the file should be stored, default is working directory.
#' @param clear If the file should be removed from Google Drive after the download.
#' @return nothing
#' @export
download_data <- function(info, path = getwd(), clear = T){
  
  filename <- paste0(info$description, ".", info$output)
  path_full <- paste0(path, "/", filename)
  test <- googledrive::drive_find(filename,  verbose = F)
  
  if(!(nrow(test) >= 1)) stop(paste0(filename, " is not yet transferred to your Google Drive, be patient"))
  if(!(nrow(test) >= 1)) stop(paste0("Mutiple files have the same name: ", filename))
  
  googledrive::drive_download(file = filename, path = path_full, overwrite = T)
  if(clear == T){
    # delete file
    googledrive::drive_rm(filename, verbose = F)
    # delete folder
    googledrive::drive_rm("GEE2R_temp", verbose = F)
    
  }
}


#' download_data_waiting
#' @param info Output of the get_data function.
#' @param path The local path where the file should be stored, default is working directory.
#' @param clear If the file should be removed from Google Drive after the download.
#' @return nothing
#' @export
download_data_waiting <- function(filename, path = getwd(), clear = T, verbose = T){
  
  filename <- as.character(filename)
  path_full <- file.path(path, filename)
  test <- googledrive::drive_find(filename, verbose = F)
  
  # cat("data products are in progress on the Earth Engine servers")
  while (nrow(test) < 1) {
    Sys.sleep(2)
    if (verbose == T) cat(".")
    test <- googledrive::drive_find(filename, verbose = F)
  }
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
