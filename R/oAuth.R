
#' Execute command in new terminal window for all operating systems
#' @export
exec_auth_new_window <- function(command, gnome = T, credential_path, credential_name) {
  # write credentials path
  
  # path to open new terminal script
  terminal_path = clean_spaces(system.file("Python/terminal.py", package = "earthEngineGrabR"))
  # make functions available
  reticulate::source_python(file = terminal_path)
  
  # arguments <- c('terminal.py', '--wait', '-m', 'gnome-terminal', 'earthengine', 'authenticate')
  # ee_credentials = "earthengine authenticate"
  # use gnome in linux
  if (gnome) {
    arguments <- c(terminal_path, '--wait', '-m', 'gnome-terminal', command)
  } else {
    arguments <- c(terminal_path, '--wait', command)
  }
  # execute command in new terminal window
  main(argv = arguments)
  
  # wait until credentails are created
  while (!(file.exists(paste0(credential_path, "/", credential_name)))) {
    Sys.sleep(1)
  }
}



#' The function installs additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_init <- function() {

# install python dependencies -----------------------------
  reticulate::py_available(initialize = T)
  reticulate::py_install("google-api-python-client")
  reticulate::py_install("pyCrypto")
  reticulate::py_install("earthengine-api")
  reticulate::py_install("pandas")
  reticulate::py_install("google-auth-oauthlib")

# get virtual env path  
  path_to_env <- paste0(reticulate::virtualenv_root(), "/r-reticulate/bin/")
# get credentials path -------------------------------------

  os <- reticulate::import("os")
  # credential_path <- os$path$expanduser('~/.config/earthengine/credentials')
  credential_path <- os$path$expanduser('~/.config/earthengine')
  
  delete_credentials(credential_path)

# authenticate ee api ---------------------------------------
  # credential_path <- clean_spaces(system.file("data", package="earthEngineGrabR"))
  write.table(t(credential_path), file = "./path.csv", sep = ",", row.names = F, col.names = F)
  
  exec_auth_new_window(command = c(paste0(path_to_env,'earthengine'), 'authenticate'), credential_path = credential_path, credential_name = "credentials")
  
  cat("Earth Engine Python API is authenticated \n")
  

# authentication fusion table api ------------------------------

  path_to_interpreter <- paste0(path_to_env, "python")
  path_ft_init <- clean_spaces(system.file("Python/gdal_auth_gee2r.py", package="earthEngineGrabR"))
  
  # make gdal_auth_gee2r executable
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
    system(paste("chmod +x", path_ft_init))
  }
  
  exec_auth_new_window(command = c(path_to_interpreter, path_ft_init), credential_path = credential_path, credential_name = "refresh_token.json")
  
  cat("Fusion Table API for upload is authenticated \n")
  

# authentication google drive api ---------------------------------

  
  httr_credential_path = paste0(credential_path, ".httr-oauth")
  
  googledrive::drive_auth(cache = httr_credential_path, verbose = F)
  while (!(file.exists(httr_credential_path))) {
    Sys.sleep(1)
  }
  
  cat("Googledrive API is authenticated \n")
  

# authentication fusion table get id api ----------------------------------

  
  id <- get_ft_id("test", credential_path = credential_path, credential_name = ".httr-oauth")
  
  cat("Fusiontable API for ID is authenticated")
  
}


#' deletes credentials to re initialize
#' @export
delete_credentials = function(credential_path) {
  # httr oauth2, googledrive and fusiontable api
  if(file.exists(paste0(credential_path, "/", ".httr-oauth"))) {
    file.remove(paste0(credential_path, "/", ".httr-oauth"))
  }
  # earth engine credentials
  if(file.exists(paste0(credential_path, "/", "credentials"))) {
    file.remove(paste0(credential_path, "/", "credentials"))
  }
  # GDAL API refresh token
  #path <- system.file("Python/install_scripts/refresh_token.txt", package="GEE2R")
  
  if(file.exists(paste0(credential_path, "/", "refresh_token.json"))) {
    file.remove(paste0(credential_path, "/", "refresh_token.json"))
  }
}


#' Find path to specified credentials folder
#' @return  path to credentials folder
#' @export
get_credential_path <- function() {
  # define values
  path2credentials <- '~/.config/earthengine'
  os <- reticulate::import("os")
  credential_path <- os$path$expanduser(path2credentials)
  return(credential_path)
}



#' get_ft_id
#' @param ft_name name of the fusiontable
#' @return fusiontable ID or NA of no fusiontable with given name
#' @export
get_ft_id <- function(ft_name, credential_path, credential_name) {
  
  library(magrittr)
  # for initial Oauth2.0 authentification
  client_id <- "313069417367-efu6s6pldp8pbf86il3grjdv8kpgp5d4.apps.googleusercontent.com"
  client_secret <-  "9sKMt27c8uQprUja2y5Mk4o_" 
  scope <- "https://www.googleapis.com/auth/fusiontables"
  authorize <- "https://accounts.google.com/o/oauth2/auth"
  access <- "https://accounts.google.com/o/oauth2/token"
  
  ft_api_endpoints <- httr::oauth_endpoint(authorize = authorize, access = access)
  # name for application
  name <- "upload fusion table"
  
  myapp <- httr::oauth_app(name,
                           key = client_id,
                           secret = client_secret)
  
  #  Get OAuth credentials
  ft_token <- httr::oauth2.0_token(
    endpoint = ft_api_endpoints, 
    app =  myapp,
    scope = scope,
    cache = paste0(credential_path , '/', credential_name))
  # "~/.config/earthengine/.httr-oauth"
  gtoken <- httr::config(token = ft_token)
  
  # request for FT ID
  request <- httr::GET("https://www.googleapis.com/fusiontables/v1/tables", gtoken) 
  
  # filter response for ID
  ft_id <-  try(jsonlite::fromJSON(httr::content(request, type = "text", encoding = "UTF-8"), simplifyVector = T) %>% 
                  as.data.frame() %>% 
                  dplyr::filter(items.name == as.character(ft_name)) %>% 
                  dplyr::select("items.tableId")
                , silent = T)
  if(class(ft_id) == "try-error"){
    result <- NA
  } else {
    result <- ft_id
  }
  
  return(result)
}

