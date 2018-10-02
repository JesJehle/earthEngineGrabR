

#' The function installs additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_install function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_install <- function(clean_credentials = T, conda = T, clean_environment = F) {
  # initialize or clean environments --------------------------------------------------------------------------------------
  # for testing purpose clean all environment installations
  if (clean_environment) clean_environments()
  # acrivate conda or virtual environment depended on which environment is installed
  activate_environments()
  # test python dependencies ----------------------------------------------------------------------------------------------------------
  test_python()
  # install python dependencies ----------------------------------------------------------------------------------------------
  if (conda) {
    # test if anaconda is installed on the system
    test_anaconda()
    # install dependencies via an anaconda environment if it's no yet installed
    install_ee_dependencies("earthEngineGrabR")
    # test import of all modules.
    import_test <- test_import_ee_gdal_conda()
    # if test fails a workaround via the use of a virtual environment is used.
    if (!import_test[[1]]) {
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
    if (!import_test[[1]]) {
      stop(paste("Sorry! The installation still fails with the error: ", import_test[[2]]))
    }
  }
  # run authentication ---------------------------------------------------------------
  run_oauth_all(clean_credentials)

  # set path to credentials
}
