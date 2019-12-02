


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

