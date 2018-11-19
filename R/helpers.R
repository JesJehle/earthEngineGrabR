
#' skips test in testthat evaluation if requirement are not met. The function tests for credentials python modules and test files on google drive
#' @noRd
skip_test_if_not_possible <- function() {
  
  # skip_on_cran()
  credentials_test <- try(test_credentials(), silent = T)
  if (!credentials_test) skip(paste("Testing is not possible. \n", "credentials: ", credentials_test))
  # test the installation of required python modules

  #module_test_ee <- test_import_ee_gdal_conda()

  #module_test <- module_test_conda[[1]] | module_test_virtual[[1]]

  #if (!module_test) skip(paste("Testing is not possible. \n", "modules: ", module_test))

  # test environment
  ## check test data on google drive and upload if neccessary

}


#' delete_on_drive
#' @param filename ldkjsf
#' @noRd
delete_on_drive <- function(filename) {
  gd_auth()
  test <- nrow(googledrive::drive_find(filename, verbose = F)) > 0
  if (test) googledrive::drive_rm(filename)
}


#' get_temp_path
#' @description creates folder and returns path for the storage of local temp files, if folder alreday exists it gets deleted and new created.
#' @param create logical weather to create a new folder
#' @noRd
get_temp_path <- function(create = T) {
  path <- file.path(dirname(tempdir()), "earthEngineGrabR-tmp")
  if (create) {
    if (dir.exists(path)) unlink(path, recursive = T)
    dir.create(path)
  }
  return(path)
}


#' is_type
#' @description test of param is of type type and raises an appropriate error
#' @param param the parameter to test
#' @param type the required type of the parameter
#' @noRd
is_type <- function(param, type) {
  if (class(param) != type) stop(paste(deparse(substitute(param)), "must be of class", type), call. = F)
}



#' get_name_from_path
#' @param path A file path
#' @return basename without extension
#' @noRd
get_name_from_path <- function(path) {
  name <- tools::file_path_sans_ext(basename(path))
  return(name)
}



#' Add quotes to paths with spaces
#' @noRd
clean_spaces <- function(path) {
  if (length(grep(" ", path) > 0)) {
    path <- shQuote(path)
  }
  return(path)
}
