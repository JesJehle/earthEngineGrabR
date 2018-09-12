
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


#' Use a specific virtual or conda environment dependent on the operating system
#' @importFrom magrittr %>%
#' @export
use_env <- function(env_name = "r-reticulate"){
  
  # activate environment for windows
  if (Sys.info()["sysname"] == "Windows"){
    
    reticulate::use_condaenv("r-reticulate", required = T) 
    
    conda_reticulate_path <- reticulate::conda_list() %>% 
      dplyr::filter(name == "earthEngineGrabR")  
    reticulate::use_python(conda_reticulate_path$python)
    # because reticulate still cant find modules I found a workaround by explicitly importing a module. All further source_pythen() functions work ???
    
    modul_path <- find_folder(foldername = "site-packages", root_dir = dirname(conda_reticulate_path$python))
    
    reticulate::import_from_path("ee", path = unlist(modul_path))
    reticulate::import_from_path("gdal", path = unlist(modul_path))
    
    
  } else {
    # acrivate the environemt for linux and mac
    root <- path.expand(reticulate::virtualenv_root())
    vir_path <- file.path(root, env_name)
    reticulate::use_virtualenv(vir_path, required = T)
    
    # because reticulate still cant find modules I found a workaround by explicitly importing a module. All further source_pythen() functions work ???
    # find path of ee modul in the active virtual environment
 
    modul_path <- find_folder('site-packages', vir_path)
    version <- reticulate::py_discover_config()
    modul_path_clean <- unlist(modul_path[grep(version$version, modul_path)])
    
    reticulate::import_from_path("ee", path = modul_path_clean)
                     
    # "~/.virtualenvs/r-reticulate/lib/python2.7/site-packages/"

    
  }
}



#' Run ee authentication
#' @export
run_ee_oauth <- function(){

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
}

#' The function installs python dependencies
#' @export
install_ee_dependencies <- function(conda_env_name) {
  reticulate::conda_create(conda_env_name, packages = c("Python = 2.7", "gdal"))
  pip_packages <- c("google-api-python-client", "pyCrypto", "earthengine-api")
  py_install(pip_packages, envname = conda_env_name)
}


#' test python and anaconda installation
#' @export
test_python_conda <- function() {
  # test python installation
  if (!(reticulate::py_available(initialize = T))) {
    print('no python found')
    stop()
  }
  test <- try(reticulate::conda_list(), silent = T)
  if (class(test) == "try-error") {
    print('no Anaconda found')
    stop()
  }
} 

# reticulate::py_install("google-api-python-client")
# reticulate::py_install("pyCrypto")
# reticulate::py_install( "earthengine-api")
# reticulate::py_install("google-auth-oauthlib")

#' verify earthEngineGrabR conda environment
#' @export
verify_ee_conda_env <- function(conda_env) {
  
  if (conda_env %in% conda_list()$name) {
    use_condaenv(conda_env)
  } else {
    print('no earthEngineGrabR conda environment found, run ee_grab_init()')
  }
}

  # test python installation





#' The function installs additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_init_new <- function(clean = T) {
  library(reticulate)
  try(use_condaenv("earthEngineGrabR", required = T), silent = T)
  test_python_conda()
  
  # install python dependencies -----------------------------

    if (!("earthEngineGrabR" %in% reticulate::conda_list()$name)) {
    install_ee_dependencies("earthEngineGrabR")
    }
  
  library(reticulate)
  use_condaenv("earthEngineGrabR", required = T)
  
  # set path to credentials
  
  credential_path <- get_credential_root()
  
  # delet credentials
  if (clean) {
    delete_credentials(credential_path)
  }

  # run authentication ---------------------------------------------------------------

  # ee authorisation
  run_ee_oauth()
  cat("Earth Engine Python API is authenticated \n")
  
  # fusion table authorisation
  run_ft_oauth()
  cat("Fusion Table API for upload is authenticated \n")
  
  # authentication google drive api 
  
  httr_credential_path = file.path(credential_path, ".httr-oauth")
  
  googledrive::drive_auth(cache = httr_credential_path, verbose = F)
  while (!(file.exists(httr_credential_path))) {
    Sys.sleep(1)
  }
  cat("Googledrive API is authenticated \n")
  

  # authentication fusion table get id api
  
  id <- get_ft_id("test", credential_path = credential_path, credential_name = ".httr-oauth")
  
  cat("Fusiontable API for ID is authenticated")
  
}


#' deletes credentials to re initialize
#' @export
delete_credentials = function(credential_path) {
  # httr oauth2, googledrive and fusiontable api
  if(file.exists(file.path(credential_path, ".httr-oauth"))) {
    file.remove(file.path(credential_path, ".httr-oauth"))
  }
  # earth engine credentials
  if(file.exists(file.path(credential_path, "credentials"))) {
    file.remove(file.path(credential_path, "credentials"))
  }
  # GDAL API refresh token
  #path <- system.file("Python/install_scripts/refresh_token.txt", package="GEE2R")
  
  if(file.exists(file.path(credential_path, "ft_credentials.json"))) {
    file.remove(file.path(credential_path, "ft_credentials.json"))
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



#' get_ft_id
#' @importFrom magrittr %>% 
#' @param ft_name name of the fusiontable
#' @return fusiontable ID or NA of no fusiontable with given name
#' @export
get_ft_id <- function(ft_name, credential_path, credential_name) {
  

  # for initial Oauth2.0 authentification
  client_id <- "313069417367-fh552cjdtbavtkudj034qbl67msbvkeg.apps.googleusercontent.com"
  client_secret <-  "_Gxo64oU3f34V2BcOFmaAZAO"
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
    cache = file.path(credential_path, credential_name))
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













#' The function installs additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @importFrom magrittr %>%
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_init_conda <- function() {
  
  # install python dependencies -----------------------------
  reticulate::py_available(initialize = T)
  reticulate::py_install(c("google-api-python-client", "pyCrypto", "earthengine-api", "pandas", "google-auth-oauthlib"), method = "conda")
  #reticulate::py_install("pyCrypto")
  #reticulate::py_install("earthengine-api")
  #reticulate::py_install("pandas")
  #reticulate::py_install("google-auth-oauthlib")
  
  # get virtual env path  
  #if (Sys.info()["sysname"] %in% c("Windows")) {
  
  conda_reticulate_path <- reticulate::conda_list() %>% 
    dplyr::filter(name == "r-reticulate")  
  
  path_to_interpreter <- conda_path$python
  path_to_scripts <- gsub('python.exe', 'Scripts/', path_to_interpreter)
  # path_to_scripts <- "C:/Anaconda/envs/r-reticulate/Scripts/"
  
  
  # get credentials path -------------------------------------
  credential_path <- path.expand("~/.config/earthengine")
  
  # credential_path <- os$path$expanduser('~/.config/earthengine/credentials')
  
  delete_credentials(credential_path)
  
  # authenticate ee api ---------------------------------------
  # credential_path <- clean_spaces(system.file("data", package="earthEngineGrabR"))
  
  write.table(t(credential_path), file = "./path.csv", sep = ",", row.names = F, col.names = F)
  
  exec_auth_new_window(command = c(paste0(path_to_scripts,'earthengine'), 'authenticate'), credential_path = credential_path, credential_name = "credentials")
  
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
  
  
  httr_credential_path = file.path(credential_path, ".httr-oauth")
  
  googledrive::drive_auth(cache = httr_credential_path, verbose = F)
  while (!(file.exists(httr_credential_path))) {
    Sys.sleep(1)
  }
  
  cat("Googledrive API is authenticated \n")
  
  
  # authentication fusion table get id api ----------------------------------
  
  
  id <- get_ft_id("test", credential_path = credential_path, credential_name = ".httr-oauth")
  
  cat("Fusiontable API for ID is authenticated")
  
}





#' The function installs additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @importFrom magrittr %>%
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_init <- function() {
  
  # install python dependencies -----------------------------
  reticulate::py_available(initialize = T)
  reticulate::py_install(c("google-api-python-client", "pyCrypto", "earthengine-api", "pandas", "google-auth-oauthlib"))
  #reticulate::py_install("pyCrypto")
  #reticulate::py_install("earthengine-api")
  #reticulate::py_install("pandas")
  #reticulate::py_install("google-auth-oauthlib")
  
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
  
  
  httr_credential_path = file.path(credential_path, ".httr-oauth")
  
  googledrive::drive_auth(cache = httr_credential_path, verbose = F)
  while (!(file.exists(httr_credential_path))) {
    Sys.sleep(1)
  }
  
  cat("Googledrive API is authenticated \n")
  
  
  # authentication fusion table get id api ----------------------------------
  
  
  id <- get_ft_id("test", credential_path = credential_path, credential_name = ".httr-oauth")
  
  cat("Fusiontable API for ID is authenticated")
  
}










