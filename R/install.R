
# installations -----------------------------------------------------------------------------------------------------------------------------------------------

#' The function installs python dependencies
#' @export
install_ee_dependencies <- function(conda_env_name) {
  # virtual_exists <-
  #   try(conda_env_name %in% reticulate::virtualenv_list(), silent = T)
  # if (class(virtual_exists) == "try-error") {
  if (!(conda_env_name %in% reticulate::conda_list()$name)) {
    reticulate::conda_create(conda_env_name, packages = c("Python = 2.7", "gdal"))
    reticulate::conda_install(packages = c("earthengine-api"),
                              envname = conda_env_name)
    # Reticulate-bug, to activate the environment the r manual restart of R is necessary
    stop(
      "To activate the newly installed conda environment a manual restart of R is necessary. \nPlease restart R now and run ee_grab_install() again to proceed"
    )
  }
}


#' The function installs python dependencies
#' @export
install_ee_dependencies_workaround <- function(conda_env_name) {
  if (!(conda_env_name %in% reticulate::virtualenv_list())) {
    reticulate::virtualenv_create(conda_env_name)
    reticulate::py_install("google-api-python-client", conda_env_name)
    reticulate::py_install("pyCrypto", conda_env_name)
    reticulate::py_install( "earthengine-api", conda_env_name)
    reticulate::py_install("google-auth-oauthlib", conda_env_name)
    
    warning(paste("Problems with loading modules", "Further a workaround via the use of virtual environments is used."))
    stop("To activate the newly installed virtual environment a manual restart of R is necessary. \nPlease restart R now and run ee_grab_install(conda=F) to use the workaround via the virtual environment.")
  }
}


# tests ---------------------------------------------------------------------------------------------------------------------------------------


#' test python and anaconda installation 
#' @export
test_dependencies <- function() {
  # test python and anaconda installation installation
  test_python()
  # test anaconda installation
  test_anaconda()
  
} 


#' test anaconda installation 
#' @export
test_anaconda <- function() {
  conda_test <- try(reticulate::conda_list(), silent = T)
  if (class(conda_test) == "try-error") {
    stop('No Anaconda is found on the system, on Windows and Mac the earthEngineGrabR library depends on an Anacona environment so please install Anaconda Python first: \n https://www.anaconda.com/download')
  }
}


#' test local gdal installation for vir-env workaround
#' @export
test_gdal_installation <- function(){
  # 1. look for local installation of GDAL in the default usr/lib
  info <- reticulate::py_discover_config("gdal")
  
  if(!is.null(info$required_module_path)) {
    cat(paste("For the default python interpreter in", info$python), "following gdal installations are found: ", info$required_module_path)
  } else {
    
    cat(paste("No installation of GDAL is found. \n"))
    cat(paste("To install GDAL and it's python-GDAL copy paste following commands in a terminal of your choice: \n"))
    cat("########################\n")
    cat("sudo add-apt-repository ppa:ubuntugis/ppa \n")
    cat("sudo apt-get update \n")
    cat("sudo apt-get install gdal-bin \n")
    cat("sudo apt-get -y install python-gdal \n")
    cat("########################\n")
    stop("Without a working installation of GDAL the earthEngineGrabR Library is not able to work properly. \nPlease first install GDAL and run ee_grab_install() afterwards.", call. = FALSE)
  }
}

#' test python installation 
#' @export
test_python <- function() {
  python_test <- try(reticulate::py_available(initialize = T), silent = T)
  if (!python_test) {
    stop('No Python version is found \nTo use the earthEngineGrabR library first install Anaconda Python \nTo install Anaconda and Python go to: \n https://www.anaconda.com/download')
  }
}

#' test virtual environment installation 
#' @export
test_virtual_env <- function() {
  virtual_test <- try(reticulate::virtualenv_list(), silent = T)
  if (class(virtual_test) == "try-error") {
    cat("NO virtual environment installation found.\n")
    cat("To install virtual environments copy paste following command in a terminal of your choice: \n")
    cat("########################\n")
    cat("sudo apt-get install virtualenv\n")
    cat("sudo apt-get install python-virtualenv\n")
    cat("########################\n")
    stop("Because of a reticulate bug a workaround is neccessary.
         \nThis Workaround requires a virtual environemt, therefore please install it and run ee_grab_install again.")
  } 
  }


#' test python and virtual environment installation for gdal workaround
#' @export
test_for_gdal_workaround <- function() {
  # test python installation and virtual environment
  test_python()
  # test vor virtual environment
  test_virtual_env()
  # test gdal installation
  test_gdal_installation()
} 




#' test import of gdal and ee for virtual env
#' @export
test_import_ee_gdal_virtual <- function() {
  try({  
    reticulate::use_virtualenv("earthEngineGrabR", required = T)
    ee_path <- reticulate::py_discover_config("ee")
    gdal_path <- reticulate::py_discover_config("gdal")
  }, silent = T)
  
  ee_test <- try(reticulate::import_from_path("ee", path = ee_path$required_module_path), silent = T)
  gdal_test <- try(reticulate::import_from_path("gdal", path = gdal_path$required_module_path), silent = T)
  
  if(class(ee_test)[1] == "try-error") return(list(F, ee_test[1]))
  if(class(gdal_test)[1] == "try-error") return(list(F, gdal_test[1])) else return(T)
}



#' test import of gdal and ee for conda
#' @export
test_import_ee_gdal_conda <- function() {
  try({
    reticulate::use_condaenv("earthEngineGrabR", required = T)
    ee_path <- reticulate::py_discover_config("ee")
    gdal_path <- reticulate::py_discover_config("gdal")
  }, silent = T)    
  
  ee_test <- try(reticulate::import_from_path("ee", path = ee_path$required_module_path), silent = T)
  gdal_test <- try(reticulate::import_from_path("gdal", path = gdal_path$required_module_path), silent = T)
  
  if(class(ee_test)[1] == "try-error") return(list(F, ee_test[1]))
  if(class(gdal_test)[1] == "try-error") return(list(F, gdal_test[1])) else return(T)
}

# activations ------------------------------------------------------------------------------------------------------------------------------------


#' clean virtual and conda environments
#' @export
clean_environments <- function(env_name = "earthEngineGrabR") {
  try(reticulate::conda_remove(env_name))
  try(reticulate::virtualenv_remove(env_name))
}


#' activate environment
#' @export
activate_environments <- function(env_name = "earthEngineGrabR") {
  library(reticulate)
  try(use_condaenv(env_name, required = T), silent = T)
  try(use_virtualenv(env_name, required = T), silent = T)
  try(gd_auth(), silent = T)
}
