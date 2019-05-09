


#' delete_if_exist
#' @param path_file path of file to check
#' @noRd
delete_if_exist <- function(path) {
  file_name <- get_name_from_path(path)
  test <- try(googledrive::drive_find(file_name, verbose = F), silent = T)
  if (!(class(test) == "try-error")) {
    googledrive::drive_rm(file_name, verbose = F)
  }
}

#' get_ft_id_gd extracts fusion table ID
#' @param ft_name Name of fusion table in google drive
#' @noRd
get_ft_id_gd <- function(ft_name) {
  info <- find_ft_on_drive(ft_name)
  ft_id <- paste0("ft:", info$id)
  return(ft_id)
}


#' upload vector data as fusion table and parse file to allow large uploads
#' @param file_path Path to vector data
#' @param fileName Name of fusion table in google drive
#' @noRd
upload_as_ft <- function(file_path, fileName) {
  
  file_path_clean <- path.expand(file_path)
  
  # make functions available
  ogr_to_ft_path <- clean_spaces(system.file("Python/upload.py", package = "earthEngineGrabR"))
  load_test <- try(source_python(file = ogr_to_ft_path), silent = T)
  count <- 1
  while (class(load_test) == "try-error" & count < 5) {
    load_test <- try(source_python(file = ee_helpers), silent = T)
    count <- count + 1
  }
  tryCatch({
    convert(file_path_clean, fileName)
  },
  error = function(err) {
    ogr_to_ft_path <- clean_spaces(system.file("Python/upload.py", package = "earthEngineGrabR"))
    source_python(file = ogr_to_ft_path)
    stop(paste("could not upload targetArea file", file_path, "\n", err), call. = F)
  }
  )
}

#' find fusion table file on drive 
#' @param ft_name Name
#' @noRd
find_ft_on_drive <- function(ft_name){
  found <- googledrive::drive_find(ft_name, verbose = F, type = "fusiontable")
  if (nrow(found) == 0) {
    return(NULL)
  } else {
    found_unique <- found[found$name == ft_name,]
    if (nrow(found_unique) > 1) stop('No unique fusiontable name.\nFound multiple fustiontables on google drive with name: ', ft_name, 
                                     '\nPlease rename target file, or rename files on google drive', call. = F)
    return(found_unique)
  }
}


#' upload vector data and return fusion table ID
#' @param verbose specifies weather information is about the process is printed to the console
#' @param targetArea path to vector data to be uploaded
#' @return Fusion table ID
#' @noRd
upload_data <- function(targetArea, verbose = T, testCase = NULL) {
  target_name <- earthEngineGrabR:::get_name_from_path(targetArea)
  # test if file is already uploaded
  test <- find_ft_on_drive(target_name)
  
  if (is.null(test)) {
    if (verbose == T) {
      cat("\nupload:", target_name, "\n")
    }
    upload_as_ft(targetArea, target_name)
  } else {
    cat("\nupload:", target_name, "is already uploaded", "\n")
    reupload <- NULL
    while (is.null(reupload)) {
      if (is.null(testCase)) {
      reupload <-
        readline(prompt = "Should the file be deleted and uploaded again? [Y/N]: ")
      } else {
        reupload <- testCase
      }
      reupload_clean <- tolower(reupload)
      if (!(reupload_clean %in% c("n", "y"))) {
        reupload <- NULL
      }
    }
    if (reupload_clean == "y") {
      earthEngineGrabR:::delete_on_drive(target_name)
      upload_as_ft(targetArea, target_name)
    }
  }
  
  credential_path <- get_credential_root()
  table_id <- get_ft_id_gd(target_name)
  
  return(table_id)
}

