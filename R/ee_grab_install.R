




#' Install dependencies and run authentications
#'
#' @param clean_credentials \code{logical}, if \code{True} already present credential are deleted recreated by a reauthenticate. Default is set to \code{True}.
#' @param clean_environment \code{logical}, if \code{True} already installed environments are deleted to be reinstalled again. Default is set to \code{False}.
#' @description \code{ee_grab_install()} installs the required dependencies and guides the user through the authentication processes to activate the different API's.
#' @export
#'
#'
#' @section Installation of Dependencies:
#'
#' To encapsulate the dependencies from the user's system and simplify the installation,  the \code{earthEngineGrabR} uses a conda environment.
#' By running \code{ee_grab_install()} first a conda environemt "earthEngineGrabR" is created.
#' All Further all dependencies are installed inside the "earthEngineGrabR" environment.
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
#'
#'
ee_grab_install <-
  function(clean_credentials = T,
           clean_environment = F) {
    library(reticulate)
    # install dependencies -----------------------------------------------------------------------------------------
    
    # initialize environments
    conda_env_name <- "earthEngineGrabR"
    
    # if clean_environment is set to true already an existing environment is deleted
    if (clean_environment)
      clean_environments(conda_env_name)
    
    # test if environment for dependeicies already exists
    env_test <- grepl(conda_env_name, conda_list()$name)
    
    # install dependencies via an anaconda environment if test is not treu
    if (!sum(env_test) > 0) {
      tryCatch({
        conda_create(envname=conda_env_name)
        conda_install(envname=conda_env_name, package="earthengine-api", forge = TRUE)
      },
      error = function(err)
        stop(paste("Installation problem\n", err), call. = F))
    }
    
    # install dependencies via an anaconda environment if test is not treu
    # if (!sum(env_test) > 0) {
    #   tryCatch({
    #     if (Sys.info()[["sysname"]] != "Linux") {
    #       conda_create(conda_env_name, packages = c("Python = 2.7", "gdal"))
    #
    #       conda_install(conda_env_name, packages = c("earthengine-api", "shapely"))
    #
    #     } else {
    #
    #       conda_create(conda_env_name,
    #                    packages = c("Python = 2.7", "gdal=2.1.0", "geos=3.5.0"))
    #       conda_install(conda_env_name,
    #                     packages = c("earthengine-api", "shapely", 'oauth2client'))
    #     }},
    #     error = function(err)
    #       stop(paste("Installation problem\n", err), call. = F)
    #
    #   )
    # }
    use_condaenv(conda_env_name, required = TRUE)
    
    # test import of all modules.
    tryCatch({
      test_ee <- py_module_available("ee")
      
      if (!test_ee)
        stop("Module ee could not be imported", call. = F)
      
    }, error = function(err) {
      test_python()
      test_anaconda()
      stop(paste("Installation problem\n", err), call. = F)
    },
    warning = function(w) {
      warning(w)
    })
    
    # run authentication ---------------------------------------------------------------
    
    # if no credential are found run authentication
    if (!test_credentials(with_error = F)) {
      run_oauth_all()
    } else {
      # if credential are found but clean_credentials is set to  true, credentials are deleted and recreated during a new authentication
      if (clean_credentials) {
        delete_credentials()
        run_oauth_all()
      }
    }
    cat(
      "\n \nThe required dependencies are installed and all API's are authenticated for further sessions.\nThere should be no need to run ee_grab_install() again."
    )
  }
