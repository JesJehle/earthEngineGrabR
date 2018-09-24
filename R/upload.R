




#' delete_if_exist
#' @param path_file path of file to check
#' @export
delete_if_exist <- function(path) {
  file_name <- get_name_from_path(path)
  test <- try(nrow(googledrive::drive_find(file_name, verbose = F)), silent = T)
  if(!(class(test) == "try-error")){
    googledrive::drive_rm(file_name, verbose = F)
  }
}

#' get_ft_id_gd extracts fusion table ID
#' @param ft_name Name of fusion table in google drive
#' @export
get_ft_id_gd <- function(ft_name) {
  info <- googledrive::drive_find(ft_name, verbose = F)
  if(nrow(info) < 1) stop(paste("No file found with given fusion table name", ft_name))
  if(nrow(info) > 1) stop(paste("Ambiguous filename: ", ft_name, "Found multiple files with the same name: ", info$name))
  return(info)
}


#' upload vector data as fusion table and parse file to allow large uploads
#' @param path2file Path to vector data
#' @param fileName Name of fusion table in google drive
#' @export
upload2ft <- function(path2file, fileName) {
  
  ogr2ft_path = clean_spaces(system.file("Python/upload.py", package = "earthEngineGrabR"))
  
  # make functions available
  source_python(file = ogr2ft_path)
  
  convert(path2file, fileName)
  
}


#' old upload vector data and return fusion table ID
#' @param verbose specifies weather information is about the process is printed to the console
#' @param target path to vector data to be uploaded
#' @return Fusion table ID
#' @export
upload_data_old <- function(verbose = T, target) {
  target_name <- get_name_from_path(target)
  # test if file is already uploaded
  test <- try(nrow(googledrive::drive_find(target_name, verbose = F)) == 1, silent = T)
  if (!test) {
    if (verbose == T)
      cat("upload:", target_name, "\n")
    upload2ft(target, target_name)
  } else {
    if (verbose == T)
      cat("upload:", target_name, "is already uploaded", "\n")
  }
  credential_path <- get_credential_root()
  table_id <- get_ft_id(
    ft_name = target_name,
    credential_path = credential_path,
    credential_name = ".httr-oauth"
  )
  # if is na delete credentials and re-authenticate before rerunning get_ft_id
  if (is.na(table_id)) {
    file.remove(file.path(credential_path, ".httr-oauth"))
    table_id <- get_ft_id(ft_name = target_name, credential_path = credential_path, credential_name = ".httr-oauth")
  }
  
  if (is.na(table_id))
    stop("problem with uploading your files")
  table_id$ft_id <- paste0("ft:", table_id$items.tableId)
  
  return(table_id)
}


#' upload vector data and return fusion table ID
#' @param verbose specifies weather information is about the process is printed to the console
#' @param target path to vector data to be uploaded
#' @return Fusion table ID
#' @export
upload_data <- function(verbose = T, target) {
  target_name <- get_name_from_path(target)
  # test if file is already uploaded
  test <- try(nrow(googledrive::drive_find(target_name, verbose = F)) == 1, silent = T)
  if (!test) {
    if (verbose == T)
      cat("upload:", target_name, "\n")
    upload2ft(target, target_name)
  } else {
    if (verbose == T)
      cat("upload:", target_name, "is already uploaded", "\n")
  }
  credential_path <- get_credential_root()
  table_id <- get_ft_id_gd(target_name)

  # if is na delete credentials and re-authenticate before rerunning get_ft_id

  table_id$ft_id <- paste0("ft:", table_id$id)
  
  return(table_id)
}


