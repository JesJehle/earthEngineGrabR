



#' Install dependencies and run authentications
#' 
#' @param clean_credentials \code{logical}, if \code{True} already present credential are deleted recreated by a reauthenticate. Default is set to \code{True}. This argument is used for development and not meant to be changed by the user.
#' @param clean_environment \code{logical}, if \code{True} already installed environments are deleted to be reinstalled again. Default is set to \code{False}. This argument is used for development and not meant to be changed by the user.
#' @description \code{ee_grab_install()} installs the required dependencies and guides the user through the authentication processes to activate the different API's.
#' @export
#' 
#' 
#' @section Installation of Dependencies:
#' 
#' To encapsulate the dependencies from the users system, and at the same time simplify the installation the \code{earthEngineGrabR}, uses a conda environment.
#' By running \code{ee_grab_install()} first the conda envritonemt "earthEngineGrabR" is created. 
#' Further all dependencies are installed inside the "earthEngineGrabR" envrironment.
#' 

#' @section Authentication of API's:
#' 
#' The earthEngineGrabR connects to 3 Google API's: 
#' 
#'   \href{https://www.gdal.org/drv_gft.html}{Google Fusion Table} API for uploading data. 
#'   
#'   \href{https://developers.google.com/earth-engine/}{Google Earth Engine} API for data aquisition and processing.  
#'   
#'   \href{https://github.com/tidyverse/googledrive}{Google Drive} API for data download. 
#'
#' To authenticate to the API's the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. 
#' To simplify this procedure the ee_grab_install function successively opens a browser window to log into the Google account.
#' If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into the R console, which creates persistent credentials. 
#' This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @import reticulate
#' @section 
#' 
ee_grab_install <- function(clean_credentials = T, clean_environment = F) {
  # initialize or clean environments --------------------------------------------------------------------------------------
  # for testing purpose clean all environment installations
  library(reticulate)
  if (clean_environment) clean_environments()
  # acrivate conda or virtual environment depended on which environment is installed
  # test python dependencies ----------------------------------------------------------------------------------------------------------
  # install python dependencies ----------------------------------------------------------------------------------------------
  # test if anaconda is installed on the system
  #test_anaconda()
    # install dependencies via an anaconda environment if it's no yet installed
  conda_env_name <- "earthEngineGrabR"
  
  conda_create(conda_env_name, packages = c("Python = 2.7", "gdal==2.1.0", "geos=3.5.0"))
  
  conda_install(conda_env_name, packages = c("earthengine-api", "shapely"))
  
  use_condaenv("earthEngineGrabR")
  # install_ee_dependencies("earthEngineGrabR")
    # test import of all modules.
  
  tryCatch({
    
  test_ee <- try(import("ee"))
  test_gdal <- try(import("gdal"))
  
  if (class(test_ee)[1] == "try-error") stop("ee import no possible", call. = F)
  if (class(test_gdal)[1] == "try-error") stop("gdal import no possible", call. = F)
  }, error = function(err) {
    test_python()
    test_anaconda()
  })
  
  # run authentication ---------------------------------------------------------------
  run_oauth_all(clean_credentials)
}




















