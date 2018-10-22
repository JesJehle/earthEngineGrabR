

# tests ---------------------------------------------------------------------------------------------------------------------------------------


#' test anaconda installation
#' @noRd
test_anaconda <- function() {
  conda_test <- try(reticulate::conda_list(), silent = T)
  if (class(conda_test) == "try-error") {
    stop("No Anaconda is found on the system, on Windows and Mac the earthEngineGrabR library depends on an Anacona environment so please install Anaconda Python first: \n https://www.anaconda.com/download")
  }
}


#' test python installation
#' @noRd
test_python <- function() {
  python_test <- try(reticulate::py_available(initialize = T), silent = T)
  if (!python_test) {
    stop("No Python version is found \nTo use the earthEngineGrabR library first install Anaconda Python \nTo install Anaconda and Python go to: \n https://www.anaconda.com/download")
  }
}

# activations ------------------------------------------------------------------------------------------------------------------------------------

#' clean virtual and conda environments
#' @noRd
clean_environments <- function(env_name = "earthEngineGrabR") {
  try(reticulate::conda_remove(env_name))
  #try(reticulate::virtualenv_remove(env_name))
}
