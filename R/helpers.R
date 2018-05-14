

#' Add quotes to paths with spaces
#' @export
clean_spaces <- function(path) {
  if (length(grep(" ", path) > 0)) {
    path <-  shQuote(path)
  }
  return(path)
}

