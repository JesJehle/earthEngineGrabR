
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
  path_full <- paste0(path, "/", filename)
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

