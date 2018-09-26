
#' Runs google drive authorisation via googledrive::drive_auth() and saves credentials 
#' @export
run_gd_auth <- function(credential_name = "gd-credentials.rds"){
  
  credential_path <- get_credential_root()
  gd_credential_path = file.path(credential_path, credential_name)
  if(file.exists(gd_credential_path)) file.remove(gd_credential_path)
  
  saveRDS(googledrive::drive_auth(reset = T, cache = F, verbose = F), gd_credential_path)
  
  while (!(file.exists(gd_credential_path))) {
    Sys.sleep(1)
  }
  cat("Googledrive API is authenticated \n")
}
 
#' Run ee authentication
#' @export
run_ee_oauth <- function(){
#  library(reticulate)
#  use_condaenv("earthEngineGrabR", required = T)
  # source python functions
  
  oauth_func_path <- system.file("Python/ee_authorisation_function.py", package = "earthEngineGrabR")
  source_python(oauth_func_path)
  
  request_ee_code()
  
  code <- readline("Enter authorisation code here: ")
  
  test <- try(request_ee_token(code), silent = T)
  
  while (class(test) == "try-error") {
    cat("Problem with Authentication key input. \nPlease follow the authentication steps in the browser and copy paste the authentication token into the R console again.")
    request_ee_code()
    code <- readline("enter authorisation code here: ")
    test <- try(request_ee_token(code), silent = T)
  }
  cat("Earth Engine Python API is authenticated \n")
  
}

#' Run ft authentication
#' @export
run_ft_oauth <- function() {

  # source python functions
  oauth_func_path <- system.file("Python/ee_authorisation_function.py", package = "earthEngineGrabR")
  source_python(oauth_func_path)
  request_ft_code()
  code <- readline("Enter authorisation code here: ")
  test <- try(request_ft_token(code), silent = T)
  
  while (class(test) == "try-error") {
    cat("Problem with Authentication key input. \nPlease follow the authentication steps in the browser and copy paste the authentication token into the R console again.")
    request_ft_code()
    code <- readline("enter authorisation code here: ")
    test <- try(request_ft_token(code), silent = T)
  }
  cat("Fusion Table API for upload is authenticated \n")
}

#' runs earh engine, fusion table and google drive authentication
#' @param clean_credentials logical weather to delete existing credentials, default = T
#' @export
run_oauth_all <- function(clean_credentials = T) {
  credential_path <- get_credential_root()
  
  # delet credentials if spedified
  if (clean_credentials) {
    delete_credentials()
  }
  # ee authorisation
  run_ee_oauth()
  # fusion table authorisation
  run_ft_oauth()
  # authentication google drive api 
  run_gd_auth()
}




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
        "To activate the newly installed conda environment a manual restart of R is necessary. \nPlease restart R now and run ee_grab_init() again to proceed"
      )
    }
}
#}


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
    stop("Without a working installation of GDAL the earthEngineGrabR Library is not able to work properly. \nPlease first install GDAL and run ee_grab_init() afterwards.", call. = FALSE)
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
         \nThis Workaround requires a virtual environemt, therefore please install it and run ee_grab_init again.")
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
  stop("To activate the newly installed virtual environment a manual restart of R is necessary. \nPlease restart R now and run ee_grab_init(conda=F) to use the workaround via the virtual environment.")
  }
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


#' The function installs additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_init <- function(clean_credentials = T, conda = T, clean_environment = F) {
  # initialize or clean environments --------------------------------------------------------------------------------------
  # for testing purpose clean all environment installations
  if (clean_environment) clean_environments()
  # acrivate conda or virtual environment depended on which environment is installed
  activate_environments()
  # test python dependencies ----------------------------------------------------------------------------------------------------------
  test_python()
  # install python dependencies ----------------------------------------------------------------------------------------------
  if(conda) {
    # test if anaconda is installed on the system
    test_anaconda()
    # install dependencies via an anaconda environment if it's no yet installed
    install_ee_dependencies("earthEngineGrabR")
    # test import of all modules.
    import_test <- test_import_ee_gdal_conda()
    # if test fails a workaround via the use of a virtual environment is used.
    if(!import_test[[1]]) {
      warning(paste("Problems with loading modules", import_test[[2]], "Further a workaround via the use of virtual environments is used."))
      # test for requirements for the workaround
      test_for_gdal_workaround()
      # remove the conda environmet, since it's not needed anymore
      reticulate::conda_remove("earthEngineGrabR")
      # install dependencies for workaround
      install_ee_dependencies_workaround("earthEngineGrabR")
    }
  } else {
    # test import via the virtual environment
    import_test <- test_import_ee_gdal_virtual()
    # if test fails again, fatal error!!!    
    if(!import_test[[1]]) {
      stop(paste("Sorry! The installation still fails with the error: ", import_test[[2]]))
      }
  }
  # run authentication ---------------------------------------------------------------
  run_oauth_all(clean_credentials)
  
  # set path to credentials
  
}


#' retreves credentials and runs google drive authorisation via googledrive::drive_auth()
#' @export
gd_auth <- function(credential_name = "gd-credentials.rds") {
  credential_path <- file.path(get_credential_root(), credential_name)
  googledrive::drive_auth(credential_path)
}


#' Test if credentials can be found in the default location and raises an error message of not.
#' @param with_error A logical weather to raise an informative error in case of missing credentials.
#' @export
test_credentials <- function(with_error = F, credentials = c("gd-credentials.rds", "credentials", "ft_credentials.json"), silent_match = F) {
  
  credentials_match <-
    try(match.arg(
      credentials,
      c("gd-credentials.rds", "credentials", "ft_credentials.json"),
      several.ok = T
    ), silent = silent_match)
  
  credential_path <- get_credential_root()
  
  test <- credentials_match %in% list.files(credential_path)
  for(t in test) {
    if(!(t) & with_error) {
      stop(paste("Following credentials could not be found: \n", paste(credentials, test, collapse = " ")))
    }
    # test if all credential test are positiv
  return(sum(test) == length(test))
  }
}


#' deletes credentials to re initialize
#' @export
delete_credentials = function(credentials = c("gd-credentials.rds", "credentials", "ft_credentials.json")) {
  credential_path <- get_credential_root()
  credentials_match <-
    match.arg(
      credentials,
      c("gd-credentials.rds", "credentials", "ft_credentials.json"),
      several.ok = T
    )
  
  for (i in credentials_match) {
    if (file.exists(file.path(credential_path, i))) {
      file.remove(file.path(credential_path, i))
    }
  }
}


#' Find path to specified credentials folder
#' @return  path to credentials folder
#' @export
get_credential_root <- function() {
  # define values
  path2credentials <- '~/.config/earthengine'
  credential_path <- path.expand(path2credentials)
  return(credential_path)
}
















