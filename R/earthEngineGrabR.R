

"/anaconda3/bin/gdal"
"/anaconda3/bin/pip"



#' The function installes additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
ee_grab_init_old2 <- function() {
  # to clear credentials
  delete_credentials()
  
  if (Sys.info()["sysname"] == "Linux") {
    # try without sudo permission
    res_nosudo <- system2("pip", "install GEE2R" 
                          #   stdout = NULL, 
                          #  stderr=NULL
    )
    
    # if fails try with sudo permission
    if(res_nosudo != 0) {
      waitPW = 1  
      while(waitPW != 0) {
        waitPW = 0  
        res_install <- system('sudo -HkS pip install GEE2R', 
                              #  ignore.stdout = T, 
                              #  ignore.stderr = T, 
                              input=readline("To authorise the installation of the GEE2R python dependencies, enter your sudo password: "))
        # whait untile credential file is created    
        while (!(exists("res_install"))) {
          Sys.sleep(1)
        }
        waitPW = res_install + waitPW
      }
    }
    #    Sys.sleep(10)
    path <- system.file("Python/install_scripts/authenticate_linux.sh", package="earthEngineGrabR")
    # if (grep(" ", path) > 0) {
    #   path <-  shQuote(path)
    # }
    # path = "../Python/install_scripts/authenticate_linux.sh"
    command = "bash"
    
    res_authenticate <- system2(command, args = path)
    while (!(file.exists("~/.config/earthengine/credentials"))) {
      Sys.sleep(1)
      
    }
    
  } 
  
  if (Sys.info()["sysname"] == "Windows") {
    
    res_install <- system2("pip", "install GEE2R")
    while (!(exists("res_install"))) {
      Sys.sleep(1)
    }
    path <- system.file("Python/install_scripts/authenticate_windows.bat", package="earthEngineGrabR")
    
    system2(path)
    while (!(file.exists("~/.config/earthengine/credentials"))) {
      Sys.sleep(1)
    }

  }
  cat("Google earth python api is installed and authenticated")
  
  ## authenticate googledrive
  #try(test <- googledrive::drive_find(), silent = T)
  googledrive::drive_auth(cache = "~/.config/earthengine/.httr-oauth")
  while (!(file.exists("~/.config/earthengine/.httr-oauth"))) {
    Sys.sleep(1)
  }
  
  cat("Googledrive package to communicate with your google drive account is authenticated")
  
  
  # path to authentification script
  path <- system.file("Python/install_scripts/gdal_auth_gee2r.py", package="earthEngineGrabR")
  call <- paste0("python ", path)
  system(paste0("gnome-terminal -x sh -c ", "\"", call, "\""))
  
  while (!(file.exists("~/.config/earthengine/refresh_token.txt"))) {
    Sys.sleep(1)
  }
  
  cat("Fusiontable API is authenticated")
  
  ## fusion table upload
  id <- get_ft_id("test")
  cat("Fusiontable API for upload is authenticated")
}




#' The function installes additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
ee_grab_init_old <- function(credentials_path = system.file("data", package="earthEngineGrabR")) {
  # to clear credentials
  delete_credentials()
  write.table(t(credentials_path), file = "./path.csv", sep = ",", row.names = F, col.names = F)
  
  ########## Mac 

  # quick and dirty solution to test package
  # not working!!!
  if (Sys.info()["sysname"] %in% c("Darwin")) {


  system("/anaconda3/bin/pip install GEE2R")
  }
  
  ###########################
  ########## Linux ##########
  ###########################
  
  if (Sys.info()["sysname"] %in% c("Linux")) {
    
    ##### install dependencies ######
    
    # try without sudo permission
    res_nosudo <- system2("pip", "install GEE2R" 
                          #   stdout = NULL, 
                          #  stderr=NULL
    )
    
    # if fails try with sudo permission
    if(res_nosudo != 0) {
      waitPW = 1  
      while(waitPW != 0) {
        waitPW = 0  
        res_install <- system('sudo -HkS pip install GEE2R', 
                              #  ignore.stdout = T, 
                              #  ignore.stderr = T, 
                              input=readline("To authorise the installation of the GEE2R python dependencies, enter your sudo password: "))
        # whait untile credential file is created    
        while (!(exists("res_install"))) {
          Sys.sleep(1)
        }
        waitPW = res_install + waitPW
      }
    }
  
    ##### earthengine API ######
    
  command = "python"
  terminal_path = system.file("Python/install_scripts/terminal.py", package="earthEngineGrabR")
  if (length(grep(" ", terminal_path) > 0)) {
    terminal_path <-  shQuote(terminal_path)
  }
  
  ee_credentials = "earthengine authenticate"
  
  call = paste(command, terminal_path, "--wait", "-m gnome-terminal", ee_credentials)
  # invoce installation
  system(call)
  
  while (!(file.exists("~/.config/earthengine/credentials"))) {
    Sys.sleep(1)
  }
  
  cat("Google earth python api is installed and authenticated \n")
  
  ##### googledrive API ######
  
  httr_credential_path_linux = paste0(credentials_path, ".httr-oauth")
  
    googledrive::drive_auth(cache = httr_credential_path_linux, verbose = F)
  while (!(file.exists(httr_credential_path_linux))) {
    Sys.sleep(1)
  }
  cat("Googledrive package to communicate with your google drive account is authenticated \n")
  
  ##### fusion table API ######
  
  path_ft_init <- system.file("Python/install_scripts/gdal_auth_gee2r.py", package="earthEngineGrabR")
  if (length(grep(" ", path_ft_init) > 0)) {
    path_ft_init <-  shQuote(path_ft_init)
  }
  if (Sys.info()["sysname"] %in% c("Linux")) {
    system_call = paste(command, terminal_path, "--wait", "-m gnome-terminal", path_ft_init)
  } else {
    system_call = paste(command, terminal_path, "--wait", path_ft_init)
  }
  
  # make gdal_init executable
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
    system(paste("chmod +x", path_ft_init))
  }
  
  # invoce installation
  system(system_call)
  
  refresh_credential_path_linux = paste0(credentials_path, "refresh_token.txt")

  while (!(file.exists(refresh_credential_path_linux))) {
    Sys.sleep(1)
  }
  cat("Fusiontable API is authenticated \n")
  
  ##### fusion table GDAL API ######
  id <- get_ft_id("test")
  cat("Fusiontable API for upload is authenticated")
}
  
  
  ########## Window
  
  
  if (Sys.info()["sysname"] == "Windows") {
    
    res_install <- system2("pip", "install GEE2R")
    while (!(exists("res_install"))) {
      Sys.sleep(1)
    }
    path <- system.file("Python/install_scripts/authenticate_windows.bat", package="earthEngineGrabR")
    if (length(grep(" ", path) > 0)) {
      path <-  shQuote(path)
    }
    system2(path)
    while (!(file.exists("~/.config/earthengine/credentials"))) {
      Sys.sleep(1)
    }
  
  # run earthengine authenticate
    command = "python"
    terminal_path = system.file("Python/install_scripts/terminal.py", package="earthEngineGrabR")
    if (length(grep(" ", terminal_path) > 0)) {
      terminal_path <-  shQuote(terminal_path)
    }


    ee_credentials = "earthengine authenticate"
    
    call = paste(command, terminal_path, "--wait", ee_credentials)
    
    # invoce installation
    system(call)
    
    while (!(file.exists("~/.config/earthengine/credentials"))) {
      Sys.sleep(1)
    }
    
  cat("Google earth python api is installed and authenticated \n")
  
  ## authenticate googledrive
  googledrive::drive_auth(cache = "~/.config/earthengine/.httr-oauth", verbose = F)
  while (!(file.exists("~/.config/earthengine/.httr-oauth"))) {
    Sys.sleep(1)
  }
  cat("Googledrive package to communicate with your google drive account is authenticated \n")
  
  
  # fusion table authentication
  path_ft_init <- system.file("Python/install_scripts/gdal_auth_gee2r.py", package="earthEngineGrabR")
  if (length(grep(" ", path_ft_init) > 0)) {
    path_ft_init <-  shQuote(path_ft_init)
  }
  if (Sys.info()["sysname"] %in% c("Linux")) {
    system_call = paste(command, terminal_path, "--wait", "-m gnome-terminal", path_ft_init)
  } else {
    system_call = paste(command, terminal_path, "--wait", path_ft_init)
  } 
  # make gdal_init executable
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
  system(paste("chmod +x", path_ft_init))
  }
  
  # invoce installation
  system(system_call)
  
  while (!(file.exists("~/.config/earthengine/refresh_token.txt"))) {
    Sys.sleep(1)
  }
  cat("Fusiontable API is authenticated \n")
  
  ## fusion table upload
  id <- get_ft_id("test")
  cat("Fusiontable API for upload is authenticated")
}

}

#' Add quotes to paths with spaces
#' @export
clean_spaces <- function(path) {
  if (length(grep(" ", path) > 0)) {
    path <-  shQuote(path)
  }
  return(path)
}


#' Execute command in new terminal window for all operating systems
#' @export
exec_auth_new_window <- function(command, gnome = T, credential_path, credential_name) {
  # write credentials path
  
  # path to open new terminal script
  terminal_path = clean_spaces(system.file("Python/install_scripts/terminal.py", package = "earthEngineGrabR"))
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


#' The function installes additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_init <- function() {

  library(reticulate)
  # setwd("../Test_GEE2R/")
  
  ##############################################################################
  ## install ee_grab_helpers and python dependencies
  ##############################################################################
  
  reticulate::py_available(initialize = T)
  reticulate::py_install("ee_grab_helpers")
  
  
  ##############################################################################
  ## get credentials path
  ##############################################################################
  
  os <- reticulate::import("os")
  
  # credential_path <- os$path$expanduser('~/.config/earthengine/credentials')
  credential_path <- os$path$expanduser('~/.config/earthengine')
  
  delete_credentials(credential_path)
  ##############################################################################
  ## authenticate ee api
  ##############################################################################
  
  # credential_path <- clean_spaces(system.file("data", package="earthEngineGrabR"))
  
  write.table(t(credential_path), file = "./path.csv", sep = ",", row.names = F, col.names = F)
  
  exec_auth_new_window(command = c('earthengine', 'authenticate'), credential_path = credential_path, credential_name = "credentials")
  
  cat("Earth Engine Python API is authenticated \n")
  
  ##############################################################################
  ## authentication fusion table api
  ##############################################################################
  
  path_ft_init <- clean_spaces(system.file("Python/install_scripts/gdal_auth_gee2r.py", package="earthEngineGrabR"))
  
  # make gdal_auth_gee2r executable
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
    system(paste("chmod +x", path_ft_init))
  }
  
  exec_auth_new_window(command = path_ft_init, credential_path = credential_path, credential_name = "refresh_token.json")
  
  cat("Fusion Table API for upload is authenticated \n")
  
  ##############################################################################
  ## authentication google drive api
  ##############################################################################
  
  httr_credential_path = paste0(credential_path, ".httr-oauth")
  
  googledrive::drive_auth(cache = httr_credential_path, verbose = F)
  while (!(file.exists(httr_credential_path))) {
    Sys.sleep(1)
  }
  
  cat("Googledrive API is authenticated \n")
  
  ##############################################################################
  ## authentication fusion table get id api
  ##############################################################################
  
  id <- get_ft_id("test", credential_path = credential_path, credential_name = ".httr-oauth")
  
  cat("Fusiontable API for ID is authenticated")
  
}

#' upload vector data and return fusion table ID
#' @param verbose specifies weather information is about the process is printed to the console
#' @param target path to vector data to be uploaded
#' @return Fusion table ID
#' @export
upload_data <- function(verbose = T, target) {
  target_name <- get_name_from_path(target)
  # test if file is already uploaded
  test <- try(nrow(googledrive::drive_find(target_name, verbose = F)) == 1, silent = T)
  if (!test) {
    if (verbose == T)
      cat("upload:", target_name, "\n")
    upload2ft(target, target_name)
  } else {
    if (verbose == T)
      cat("upload:", target_name, "is already uploaded", "\n")
  }
  credential_path <- get_credential_path()
  table_id <- get_ft_id(
      ft_name = target_name,
      credential_path = credential_path,
      credential_name = ".httr-oauth"
    )
  # if is na delete credentials and re-authenticate before rerunning get_ft_id
  if (is.na(table_id)) {
    file.remove(paste0(credential_path, "/", ".httr-oauth"))
    table_id <- get_ft_id(target_name)
  }
  
  if (is.na(table_id))
    stop("problem with uploading your files")
  table_id$ft_id <- paste0("ft:", table_id$items.tableId)
  
  return(table_id)
  
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


#' delete_if_exist
#' @param path_file path of file to check
#' @export
delete_if_exist <- function(path) {
  file_name <- get_name_from_path(path)
  test <- try(nrow(googledrive::drive_find(file_name, verbose = F)), silent = T)
  if(!(class(test) == "try-error")){
    googledrive::drive_rm(file_name, verbose = F)
  }
}


#' upload as fusion tables !!!!!!!!old version!!!!!!!!!!!!!!
#' @param path_file path of file to upload
#' @return if 0
#' @export
upload_data_ft <- function(path_file) {
  # check if file allready exist and delete it
  # read refresh token from GEE2R folder
  # path <- system.file("Python/install_scripts/refresh_token.txt", package="GEE2R")
  if (file.exists("~/.config/earthengine/refresh_token.txt")) {
    refresh_token = readChar("~/.config/earthengine/refresh_token.txt", nchars = 100000)
  } else {
    stop("Fusion Table API is not authenticated \n
         run ee_grab_init()")
  }
  # creat ogr2ogr system call with refresh token
  ft_refresh <- paste0("GFT:refresh=", refresh_token)
  # upload as fusion table
  if (Sys.info()["sysname"] == "Darwin") {
    call <- paste0("/anaconda3/bin/ogr2ogr -f GFT ", sQuote(ft_refresh), " ", path_file)
  } else {
    call <- paste0("ogr2ogr -f GFT ", sQuote(ft_refresh), " ", path_file)
  }
  result <- system(call)
  return(result)
}


#' validate_shapefile
#' @param ft_id id of fusion table
#' @return if shapefile is not valid, returns error
#' 
validate_shapefile <- function(ft_id) {
  # first command in console
  command = "python"
  # path to python scripts
  path2script <- system.file("Python/GEE2R_python_scripts/validate_ft.py", package="earthEngineGrabR")
  
    # concatenate path and arguments
  AllArgs <- c(path2script, ft_id)
  # test for spaces in path
  if (length(grep(" ", path2script) > 0)) {
    AllArgs <-  shQuote(AllArgs)
  }
  # invoce system call on the command line get url of data
  output = system2(command, args =  AllArgs, stdout = T, wait=T)
  # download data
  return(output)
}




#' download_data
#' @param info Output of the get_data function.
#' @param path The local path where the file should be stored, default is working directory.
#' @param clear If the file should be removed from Google Drive after the download.
#' @return nothing
#' @export
download_data <- function(info, path = getwd(), clear = T){

  filename <- paste0(info$description, ".", info$output)
  path_full <- paste0(path, "/", filename)
  test <- googledrive::drive_find(filename,  verbose = F)
  
  if(!(nrow(test) >= 1)) stop(paste0(filename, " is not yet transferred to your Google Drive, be patient"))
  if(!(nrow(test) >= 1)) stop(paste0("Mutiple files have the same name: ", filename))
  
  googledrive::drive_download(file = filename, path = path_full, overwrite = T)
  if(clear == T){
    # delete file
    googledrive::drive_rm(filename, verbose = F)
    # delete folder
    googledrive::drive_rm("GEE2R_temp", verbose = F)
    
  }
}



#' chirps_precipitation
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description Climate Hazards Group InfraRed Precipitation with Station data (CHIRPS) is a 30+ year quasi-global rainfall dataset. CHIRPS incorporates 0.05° resolution satellite imagery with in-situ station data to create gridded rainfall time series for trend analysis and seasonal drought monitoring.
#' @return depend on output
#' @export
eeProduct_chirps_precipitation <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002), byYear = F) {
  productInfo <- list(
    productName = paste0("chirps_precipitation_mm", "_", yearIntervall[1], "_", yearIntervall[2]),
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2],
    byYear = byYear
  )
  return(productInfo)
}
#' jrc_distanceToWater
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description These data were generated using 3,066,102 scenes from Landsat 5, 7, and 8 acquired between 16 March 1984 and 10 October 2015. Each pixel was individually classified into water / non-water using an expert system and the results were collated into a monthly history for the entire time period and two epochs (1984-1999, 2000-2015) for change detection.This Yearly Seasonality Classification collection contains a year-by-year classification of the seasonality of water based on the occurrence values detected throughout the year.Resolution is 30 METERS. 
#' @return depend on output
#' @export
eeProduct_jrc_distanceToWater <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002), byYear = F) {
  productInfo <- list( 
    productName = paste0("jrc_distanceToWater_km", "_", yearIntervall[1], "_", yearIntervall[2]),
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2],
    byYear = byYear
  )
  return(productInfo)
}
#' modis_treeCover
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description The Terra MODIS Vegetation Continuous Fields (VCF) product is a sub-pixel-level representation of surface vegetation cover estimates globally. Designed to continuously represent Earth's terrestrial surface as a proportion of basic vegetation traits, it provides a gradation of three surface cover components: percent tree cover, percent non-tree cover, and percent bare. VCF products provide a continuous, quantitative portrayal of land surface cover with improved spatial detail, and hence, are widely used in environmental modeling and monitoring applications. Generated yearly, the VCF product is produced using monthly composites of Terra MODIS 250 and 500 meters Land Surface Reflectance data, including all seven bands, and Land Surface Temperature
#' @return depend on output
#' @export
eeProduct_modis_treeCover <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002), byYear = F) {
  productInfo <- list( 
    productName = paste0("modis_treeCover_percent", "_", yearIntervall[1], "_", yearIntervall[2]),
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2],
    byYear = byYear
  )
  return(productInfo)
}
#' modis_nonTreeVegetation
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description The Terra MODIS Vegetation Continuous Fields (VCF) product is a sub-pixel-level representation of surface vegetation cover estimates globally. Designed to continuously represent Earth's terrestrial surface as a proportion of basic vegetation traits, it provides a gradation of three surface cover components: percent tree cover, percent non-tree cover, and percent bare. VCF products provide a continuous, quantitative portrayal of land surface cover with improved spatial detail, and hence, are widely used in environmental modeling and monitoring applications. Generated yearly, the VCF product is produced using monthly composites of Terra MODIS 250 and 500 meters Land Surface Reflectance data, including all seven bands, and Land Surface Temperature
#' @return depend on output
#' @export
eeProduct_modis_nonTreeVegetation <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002), byYear = F) {
  productInfo <- list( 
    productName = paste0("modis_nonTreeVegetation_percent", "_", yearIntervall[1], "_", yearIntervall[2]),
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2],
    byYear = byYear
  )
  return(productInfo)
}
#' modis_nonVegetated
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description The Terra MODIS Vegetation Continuous Fields (VCF) product is a sub-pixel-level representation of surface vegetation cover estimates globally. Designed to continuously represent Earth's terrestrial surface as a proportion of basic vegetation traits, it provides a gradation of three surface cover components: percent tree cover, percent non-tree cover, and percent bare. VCF products provide a continuous, quantitative portrayal of land surface cover with improved spatial detail, and hence, are widely used in environmental modeling and monitoring applications. Generated yearly, the VCF product is produced using monthly composites of Terra MODIS 250 and 500 meters Land Surface Reflectance data, including all seven bands, and Land Surface Temperature
#' @return depend on output
#' @export
eeProduct_modis_nonVegetated <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002), byYear = F) {
  productInfo <- list( 
    productName = paste0("modis_nonVegetated_percent", "_", yearIntervall[1], "_", yearIntervall[2]),
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2],
    byYear = byYear
  )
  return(productInfo)
}

#' srtm_elevation
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @return depend on output
#' @description The Shuttle Radar Topography Mission (SRTM, see Farr et al. 2007) digital elevation data is an international research effort that obtained digital elevation models on a near-global scale. This SRTM V3 product (u201CSRTM Plusu201D) is provided by NASA JPL at a resolution of 1 arc-second (approximately 30m). This dataset has undergone a void-filling process using open-source data (ASTER GDEM2, GMTED2010, and NED), as opposed to other versions that contain voids or have been void-filled with commercial sources. For more information on the different versions see the SRTM Quick Guide .
#' @export
eeProduct_srtm_elevation <- function(spatialReducer = "mean") {
  productInfo <- list(
    productName = "srtm_elevation_m",
    spatialReducer = spatialReducer
  )
  return(productInfo)
}
#' srtm_slope
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @description The Shuttle Radar Topography Mission (SRTM, see Farr et al. 2007) digital elevation data is an international research effort that obtained digital elevation models on a near-global scale. This SRTM V3 product (u201CSRTM Plusu201D) is provided by NASA JPL at a resolution of 1 arc-second (approximately 30m). This dataset has undergone a void-filling process using open-source data (ASTER GDEM2, GMTED2010, and NED), as opposed to other versions that contain voids or have been void-filled with commercial sources. For more information on the different versions see the SRTM Quick Guide .
#' @return depend on output
#' @export
eeProduct_srtm_slope <- function(spatialReducer = "mean") {
  productInfo <- list(
    productName = "srtm_slope_degrees",
    spatialReducer = spatialReducer
  )
  return(productInfo)
}
#' oxford_accessibility
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @return depend on output
#' @description This global accessibility map enumerates land-based travel time to the nearest densely-populated area for all areas between 85 degrees north and 60 degrees south for a nominal year 2015.Densely-populated areas are defined as contiguous areas with 1,500 or more inhabitants per square kilometer or a majority of built-up land cover types coincident with a population centre of at least 50,000 inhabitants. This map was produced through a collaboration between the University of Oxford Malaria Atlas Project (MAP), Google, the European Union Joint Research Centre (JRC), and the University of Twente, Netherlands. The underlying datasets used to produce the map include roads (comprising the first ever global-scale use of Open Street Map and Google roads datasets), railways, rivers, lakes, oceans, topographic conditions (slope and elevation), landcover types, and national borders. These datasets were each allocated a speed or speeds of travel in terms of time to cross each pixel of that type. The datasets were then combined to produce a “friction surface”, a map where every pixel is allocated a nominal overall speed of travel based on the types occurring within that pixel. Least-cost-path algorithms (running in Google Earth Engine and, for high-latitude areas, in R) were used in conjunction with this friction surface to calculate the time of travel from all locations to the nearest city (by travel time). Cities were determined using the high-density-cover product created by the Global Human Settlement Project. Each pixel in the resultant accessibility map thus represents the modeled shortest time from that location to a city.
#' @export
eeProduct_oxford_accessibility <- function(spatialReducer = "mean") {
  productInfo <- list(
    productName = "oxford_accessibility_min",
    spatialReducer = spatialReducer
  )
  return(productInfo)
}

#' oxford_friction
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @description This global friction surface enumerates land-based travel speed for all land pixels between 85 degrees north and 60 degrees south for a nominal year 2015. This map was produced through a collaboration between the University of Oxford Malaria Atlas Project (MAP), Google, the European Union Joint Research Centre (JRC), and the University of Twente, Netherlands. The underlying datasets used to produce the map include roads (comprising the first ever global-scale use of Open Street Map and Google roads datasets), railways, rivers, lakes, oceans, topographic conditions (slope and elevation), landcover types, and national borders. These datasets were each allocated a speed or speeds of travel in terms of time to cross each pixel of that type. The datasets were then combined to produce this “friction surface”, a map where every pixel is allocated a nominal overall speed of travel based on the types occurring within that pixel, with the fastest travel mode intersecting the pixel being used to determine the speed of travel in that pixel (with some exceptions such as national boundaries, which have the effect of imposing a travel time penalty). This map represents the travel speed from this allocation process, expressed in units of minutes required to travel one meter. It forms the underlying dataset behind the global accessibility map described in the referenced paper.
#' @return depend on output
#' @export
eeProduct_oxford_friction <- function(spatialReducer = "mean") {
  productInfo <- list(
    productName = "oxford_friction_min_m",
    spatialReducer = spatialReducer
  )
  return(productInfo)
}


#' get_name_from_path
#' @param path A file path
#' @return basename without extension
#' @export
get_name_from_path <- function(path){
  name =   sub('\\..*$', '', basename(path))
  return(name)
  
}


#' upload vector data as fusion table and parse file to allow large uploads
#' @param path2file Path to vector data
#' @param fileName Name of fusion table in google drive
#' @export
upload2ft <- function(path2file, fileName) {
  
  ogr2ft_path = clean_spaces(system.file("Python/GEE2R_python_scripts/upload.py", package = "earthEngineGrabR"))
  
  # make functions available
  reticulate::source_python(file = ogr2ft_path)
  
  convert(path2file, fileName)
  
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




## parameter testing


#for(i in 1:length(products)) {
#  if(!(products[[i]]$spatialReducer %in% reducers)){
#    stop(paste0("spatialReducer has to be on of: ", reducers))
#  }
#}
# test exclusive params 
#for(i in 1:length(products)) {
#  if (is.character(try(products[[i]]$temporalReducer))) {
#    if (!(products[[i]]$spatialReducer %in% reducers)) {
#      stop(paste0("spatialReducer has to be on of: ", reducers))
#    }
#  }
#}


#' ee_grab
#' @param products List of dataproduct functions starting with eeProduct
#' @param target A path to a local geofile, if file is already uploaded, the upload is skipped. 
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ.
#' @param verbose if true, prints messages about the state of processing
#' @param resolution Resolution of the dataproducts.
#' @return Object of class sf.
#' @export
ee_grab <- function(
  target = NULL, 
  outputFormat = "GeoJSON",
  resolution = 100,
  products = list(
    eeProduct_modis_treeCover()
    ), 
  verbose = T
  )

{

# test data products validation

  # test <- try(as.data.frame(products), silent = T)
  # if(!(class(test) == "data.frame" || nrow(test) == 2)) stop("products has to be a list of vectors as c(dataproduct, timeReducer)")
  # # get products in a more usefull form
  # dataproducts_df <- as.data.frame(do.call(rbind, products)) 
  # names(dataproducts_df) <- c("products", "timeReducer")
  # # list of products an reducers
  # reducers <- c("mean", "median", "mode", "sum", "min", "max")
  # dataproductNames <- c("chirps_precipitation", "jrc_distanceToWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", "modis_quality", "oxford_friction", "oxford_accessibility")
  # 
  
# validate params

  # 
  # if(!(class(timeIntervall[1]) == "numeric" || timeIntervall[1] >= 2000 & timeIntervall[1] < 2016)) stop("yearStart must be an integer between 2000 and 2015")
  # if(!(class(timeIntervall[2]) == "numeric" || timeIntervall[2] >= 2000 & timeIntervall[2] < 2016)) stop("yearEnd must be an integer between 2000 and 2015")
  # if(!(timeIntervall[1] <= timeIntervall[2])) stop("year_start must be before or equal to year_end")
  # if(!(class(dataproducts_df$timeReducer) == "character" || dataproducts_df$timeReducer %in% reducers ||is.na(dataproducts_df$timeReducer))) stop("timeReducer must be of class string, either mean, median mode, sum, min or max")
  # if(!(class(spatialReducer) == "character" || dataproducts_df$spatialReducer %in% c("mean", "median", "mode"))) stop("spatialReducer must be of class string, either mean, median or mode")
  # if(!(class(dataproducts_df$products) == "character" || dataproducts_df$products %in% dataproductNames)) stop(paste0("dataproduct name must be one of: ", dataproductNames))
  # if(!(class(assetPath) == "character")) stop("assetPath must be string consisting of users/username/nameOfPolygons")
  # if(!(class(name) == "character")) stop("must be a string")
  # if(!(class(outputFormat) == "character" || outputFormat %in% c("CSV", "GeoJSON", "KML", "KMZ"))) stop("Output must be a String specifying the output, use CSV, GeoJSON, KML or KMZ")
  # extensions <- c("CSV", "GeoJSON", "KML", "KMZ")
    # validate path to shapefile if no test specified

# validate fusion table and get info about feature collection in earth engine

  ##############################################################################
  ## upload vector data is fusion table
  ##############################################################################
  
  table_id <-  upload_data(target = target)
  

  list = list()
  

# loop over data products

  for(i in seq_along(products)) {
    params <- rbind(cbind(products[[i]]), ft_id = table_id$ft_id, outputFormat, resolution)
     
    #write params to file
    write.table(t(params), file = "./params.csv", sep = ",", row.names = F, col.names = T)
  
  
    command = "python"
  # path to python scripts
    path2script <- system.file("Python/GEE2R_python_scripts/get_data.py", package="earthEngineGrabR")
  # test for spaces in path
    if (length(grep(" ", path2script) > 0)) {
     path2script <-  shQuote(path2script)
   }
  # for information
  # message(paste0("send request to earth engine, answer depends on the number of polygons in your shapefile. \n Your Shapefile in ", assetPath, " consists of ", message, " features."))
  
  # if a file with the same name is present on google drive it is deleted
    filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    googledrive::drive_rm(filename, verbose = F)
    
    list[i] <- filename


  # invoce system call on the commandline 
    drop = system2(command,
                       args =  path2script,
                       stdout = T,
                       wait = T)
  
  json_data <- rjson::fromJSON(file ="./exportInfo.json")
  exportInfo <- rjson::fromJSON(json_data)
  file.remove("./exportInfo.json")
  file.remove("./params.csv")
  #print(paste0("the projection of result is", drop))
  if (exportInfo$state == "READY") {
    if (verbose == T) cat("processing:", products[[i]]$productName,'\n') 
  }
  }

   for(i in seq_along(products)) {
     if (i == 1) {
       if (verbose == T) cat("waiting for Earth Engine", "\n")
     }
     download_data_waiting(filename = list[i], verbose = verbose)
   }
  

  product_list <- unlist(list) 
  downloads <- list.files(getwd())
  downloads_clean <- grep('geojson', downloads, value = T)

  while (sum(product_list %in% downloads_clean) != length(product_list)) {
    if (verbose == T) cat("waiting for Earth Engine", "\n")
    if (verbose == T) cat(".")
    Sys.sleep(2)
    downloads <- list.files(getwd())
    downloads_clean <- grep('geojson', downloads, value = T)
  }
  
    ## import data
  if (verbose == T) cat("import: finished", "\n")
    join <- sf::st_read(downloads_clean[1], quiet = TRUE)
    file.remove(downloads_clean[1])
    if(length(downloads_clean) > 1) {
      for(i in 2:length(downloads_clean)) {
        data <- sf::st_read(downloads_clean[i], quiet = TRUE)
        file.remove(downloads_clean[i])
        data_no_geom <- sf::st_set_geometry(data, NULL)
        join <- suppressMessages(dplyr::left_join(join, data_no_geom))
      }
    }
    #delete_if_exist(target)
    googledrive::drive_rm("GEE2R_temp", verbose = F)
  
   return(join)
}




#' download_data_waiting
#' @param info Output of the get_data function.
#' @param path The local path where the file should be stored, default is working directory.
#' @param clear If the file should be removed from Google Drive after the download.
#' @return nothing
#' @export
download_data_waiting <- function(filename, path = getwd(), clear = T, verbose = T){
  
  filename <- as.character(filename)
  path_full <- paste0(path, "/", filename)
  test <- googledrive::drive_find(filename, verbose = F)
  
  # cat("data products are in progress on the Earth Engine servers")
  while (nrow(test) < 1) {
    Sys.sleep(2)
    if (verbose == T) cat(".")
    test <- googledrive::drive_find(filename, verbose = F)
  }
  if (verbose == T) cat("\n")
  googledrive::drive_download(file = filename, path = path_full, overwrite = T, verbose = F)
  if (verbose == T) cat(paste0('download: ', get_name_from_path(filename), "\n"))
  if(clear == T){
    # delete file
    googledrive::drive_rm(filename, verbose = F)
    # delete folder
    # googledrive::drive_rm("GEE2R_temp")
    
  }
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




#' jsonToShapefile
#' @param json_paht path as String to the json file
#' @param shapefile_path path and name  as String of the wanted shapefile
#' @return ESRI Shapefile
#' 
JsonToShapefile <- function(json_path, shapefile_path) {
  poly <- rgdal::readOGR(dsn = json_path, layer = "OGRGeoJSON")
  rgdal::writeOGR(poly, dsn = shapefile_path, layer = "poly", driver="ESRI Shapefile")
}


#' test sys connection
#' @return sys arguments
#' @export 
#' 
get_sys <- function(month_start = 1, month_end = 5, year_start = 2000, year_end = 2000, asset_path = "users/JesJehle/Strips") {
  arguments = c(month_start, month_end, year_start, year_end, asset_path)
  # first command in console
  command = "python"
  # path to python scripts
  path2script <- "../Python/GEE2R_python_scripts/test.py"
  # concatenate path and arguments
  AllArgs <- c(path2script, arguments)
  # invoce system call on the command line get url of data
  output = system2(command, args =  AllArgs, stdout = T, wait=T)
  # download data
  return(output)
  
}


# 
# products = list(
#   eeProduct_chirps_precipitation(yearIntervall = c(2000, 2005)),
#   eeProduct_oxford_accessibility()
# )
# 
# 
# producs_new = list("first")
# 
# start <- length(producs_new) + 1
# 
# for (i in seq_along(products)) {
#   if (sum(names(products[[i]]) %in% "byYear") > 0) {
#     if (!products[[i]]$byYear) {
#       diff <- products[[i]]$yearEnd - products[[i]]$yearStart
#       start <- length(producs_new)
#       if (length(grep("chirps", products[[i]]$productName)) > 0) {
#         for (d in 0:diff) {
#           year = as.numeric(products[[i]]$yearStart) + d
#           producs_new[[start + d]] <-
#             eeProduct_chirps_precipitation(
#               spatialReducer = products[[i]]$spatialReducer,
#               temporalReducer = products[[i]]$temporalReducer,
#               yearIntervall = c(year, year)
#             )
#         }
#       }
#     }
#   }
# }
#       
# 
# 




