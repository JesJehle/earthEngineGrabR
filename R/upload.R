


#' delete_if_exist
#' @param path_file path of file to check
#' @noRd
delete_if_exist <- function(path) {
  file_name <- get_name_from_path(path)
  test <- try(nrow(googledrive::drive_find(file_name, verbose = F)), silent = T)
  if (!(class(test) == "try-error")) {
    googledrive::drive_rm(file_name, verbose = F)
  }
}

#' get_ft_id_gd extracts fusion table ID
#' @param ft_name Name of fusion table in google drive
#' @noRd
get_ft_id_gd <- function(ft_name) {
  info <- googledrive::drive_find(ft_name, verbose = F)
  if (nrow(info) < 1) stop(paste("No file found with given fusion table name", ft_name), call. = F)
  if (nrow(info) > 1) stop(paste("Ambiguous filename: ", ft_name, "Found multiple files with the same name: ", info$name), call. = F)
  ft_id <- paste0("ft:", info$id)
  return(ft_id)
}


#' upload vector data as fusion table and parse file to allow large uploads
#' @param file_path Path to vector data
#' @param fileName Name of fusion table in google drive
#' @noRd
upload_as_ft <- function(file_path, fileName) {
  ogr_to_ft_path <- clean_spaces(system.file("Python/upload.py", package = "earthEngineGrabR"))

  # make functions available
  source_python(file = ogr_to_ft_path)

  tryCatch({
    convert(file_path, fileName)
  },
  error = function(err) {
    stop(paste("could not upload targetArea file", file_path, "\n", err), call. = F)
  }
  )
}


#' upload vector data and return fusion table ID
#' @param verbose specifies weather information is about the process is printed to the console
#' @param targetArea path to vector data to be uploaded
#' @return Fusion table ID
#' @noRd
upload_data <- function(targetArea, verbose = T) {

  # delete if exists
  googledrive::drive_rm("GEE2R_temp", verbose = F)

  target_name <- get_name_from_path(targetArea)
  # test if file is already uploaded
  test <- try(nrow(googledrive::drive_find(target_name, verbose = F)) == 1, silent = T)
  if (!test) {
    if (verbose == T) {
      cat("\nupload:", target_name, "\n")
    }
    upload_as_ft(targetArea, target_name)
  } else {
    if (verbose == T) {
      cat("\nupload:", target_name, "is already uploaded", "\n")
    }
  }
  credential_path <- get_credential_root()
  table_id <- get_ft_id_gd(target_name)

  return(table_id)
}
