
#' Runs google drive authorisation via googledrive::drive_auth() and saves credentials
#' @noRd
run_gd_oauth <- function(credential_name = "gd-credentials.rds") {
  credential_path <- get_credential_root()
  gd_credential_path <- file.path(credential_path, credential_name)
  if (file.exists(gd_credential_path)) file.remove(gd_credential_path)

  saveRDS(googledrive::drive_auth(reset = T, cache = F, verbose = F), gd_credential_path)

  while (!(file.exists(gd_credential_path))) {
    Sys.sleep(1)
  }
  cat("Googledrive API is authenticated \n")
}

#' Run ee authentication
#' @noRd
run_ee_oauth <- function() {
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
#' @noRd
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
#' @noRd
run_oauth_all <- function(clean_credentials = T) {
  activate_environments()
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
  run_gd_oauth()
}



#' retreves credentials and runs google drive authorisation via googledrive::drive_auth()
#' @noRd
gd_auth <- function(credential_name = "gd-credentials.rds") {
  credential_path <- file.path(get_credential_root(), credential_name)
  googledrive::drive_auth(credential_path)
}



#' activate environment
#' @noRd
activate_environments <- function(env_name = "earthEngineGrabR") {
  earthEngineGrabR:::test_credentials()
  library(reticulate)
  conda_test <- try(use_condaenv(env_name, required = T), silent = T)
  if (class(conda_test) == "try-error") {
    stop("Could not find a valid conda or virtual environment. \nPlease run ee_grab_install() to install a valid environment.", call. = F)
  }
  try(gd_auth(), silent = T)
}




#' Test if credentials can be found in the default location and raises an error message of not.
#' @param with_error A logical weather to raise an informative error in case of missing credentials.
#' @noRd
test_credentials <- function(credentials = c("gd-credentials.rds", "credentials", "ft_credentials.json"), silent_match = F, with_error = F) {
  credentials_match <-
    try(match.arg(
      credentials,
      c("gd-credentials.rds", "credentials", "ft_credentials.json"),
      several.ok = T
    ), silent = silent_match)

  credential_path <- get_credential_root()

  test <- credentials_match %in% list.files(credential_path)
  for (t in test) {
    if (!(t) & with_error) {
      stop(paste("Following credentials could not be found: \n", paste(credentials, test, collapse = " "), "\nPlease run ee_grab_install() to create the required credentials"), call. = F)
    }
    # test if all credential test are positiv
    return(sum(test) == length(test))
  }
}


#' deletes credentials to re initialize
#' @noRd
delete_credentials <- function(credentials = c("gd-credentials.rds", "credentials", "ft_credentials.json")) {
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
#' @noRd
get_credential_root <- function() {
  # define values
  path2credentials <- "~/.config/earthengine"
  credential_path <- path.expand(path2credentials)
  return(credential_path)
}
