#' find a folder in a speciefied subdirectory
#' @param foldername the name of the folder to search
#' @param root_dir the initial directory the to search
#' @return the given folder with the path
#' @export
find_folder <- function(foldername, root_dir){
  directories <- list.dirs(path.expand(root_dir))
  found_folder <- list("start")
  
  for (folder in directories) {
    if (foldername %in% dir(folder)) {
      found_folder[length(found_folder)] <- file.path(folder, foldername)
    }
  }
  return(found_folder)
}

#' find a file in a speciefied subdirectory
#' @param filename the name of the file to search, with extension
#' @param root_dir the initial directory the to search
#' @return the given file with the path
#' @export
find_file <- function(filename, root_dir) {
  directories <- list.dirs(path.expand(root_dir))
  found_file <- list("start")
  for (folder in directories) {
    files <- list.files(folder)
    if (filename %in% files) {
      found_file[length(found_file)] <- file.path(folder, filename)
    }
  }
  return(found_file)
}





#' Add quotes to paths with spaces
#' @export
clean_spaces <- function(path) {
  if (length(grep(" ", path) > 0)) {
    path <-  shQuote(path)
  }
  return(path)
}

