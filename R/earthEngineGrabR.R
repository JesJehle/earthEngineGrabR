
#' The function installes additionally required dependencies and guides the user through the authentication processes to activate the different API's
#' @description To authenticate to the API the user has to log in with his google account and allow the API to access data on googles servers on the user's behalf. If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into a running command line script, which stores the token as persistent credentials. Later, the credentials are used to authenticate a request to the API. To simplify this procedure the ee_grab_init function successively opens a browser window to log into the Google account and a corresponding command line window to enter the token. This process is repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there should be no need for further authentification.
#' @export
ee_grab_init <- function() {
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
    #print("I am sorry, no implementation on windows yet")
    #path = "~/Documents/Ms_Arbeit/test/authenticate_windows.sh"
    #command = "bash"
    #system2(command, args = path)
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

#' deletes credentials to re initialize
#' @export
delete_credentials = function() {
  # httr oauth2, googledrive and fusiontable api
  if(file.exists("~/.config/earthengine/.httr-oauth")) {
    file.remove("~/.config/earthengine/.httr-oauth")
  }
  # earth engine credentials
  if(file.exists("~/.config/earthengine/credentials")) {
    file.remove("~/.config/earthengine/credentials")
  }
  # GDAL API refresh token
  #path <- system.file("Python/install_scripts/refresh_token.txt", package="GEE2R")
  
  if(file.exists("~/.config/earthengine/refresh_token.txt")) {
    file.remove("~/.config/earthengine/refresh_token.txt")
  }
}



#' delete_if_exist
#' @param path_file path of file to check
#' @export
delete_if_exist <- function(path) {
  file_name <- get_name_from_path(path)
  test <- try(nrow(googledrive::drive_find(file_name)), silent = T)
  if(!(class(test) == "try-error")){
    googledrive::drive_rm(file_name, verbose = F)
  }
}


#' upload as fusion tables
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
  call <- paste0("ogr2ogr -f GFT ", sQuote(ft_refresh), " ", path_file)
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
  test <- googledrive::drive_find(filename)
  
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
#' @return depend on output
#' @export
eeProduct_chirps_precipitation <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
  productInfo <- list(
    productName = "chirps_precipitation_mm",
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2]
  )
  return(productInfo)
}
#' jrc_distanceToWater
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @return depend on output
#' @export
eeProduct_jrc_distanceToWater <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
  productInfo <- list(
    productName = "jrc_distanceToWater_km",
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2]
  )
  return(productInfo)
}
#' modis_treeCover
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @return depend on output
#' @export
eeProduct_modis_treeCover <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
  productInfo <- list(
    productName = "modis_treeCover_percent",
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2]
  )
  return(productInfo)
}
#' modis_nonTreeVegetation
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @return depend on output
#' @export
eeProduct_modis_nonTreeVegetation <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
  productInfo <- list(
    productName = "modis_nonTreeVegetation_percent",
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2]
  )
  return(productInfo)
}
#' modis_nonVegetated
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @return depend on output
#' @export
eeProduct_modis_nonVegetated <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
  productInfo <- list(
    productName = "modis_nonVegetated_percent",
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    yearStart = yearIntervall[1],
    yearEnd = yearIntervall[2]
  )
  return(productInfo)
}
#' srtm_elevation
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @return depend on output
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

  # decide if target is fusion table name or local file
  
  #upload data
  #delete_if_exist(target)
  #Sys.sleep(1)
  
  target_name =   get_name_from_path(target)
  test <- try(nrow(googledrive::drive_find(target_name)) == 1, silent = T)
  
  if (!test) {
    if (verbose == T) cat("upload:", target_name, "\n")
    response_ft_upload <- upload_data_ft(target)
    # cat("upload:", target_name, "is uploaded", "\n")
  } else {
    if (verbose == T) cat("upload:", target_name, "is already uploaded", "\n")
  }
  

  #extension_full <- paste0(".",tolower(extensions))
  #grep(extension_full %in% target)
  #gsub(extension_full[1]," ",target)
  #gsub("^.*\\.",".",x)
  
  
  table_id <- get_ft_id(target_name)
  if(is.na(table_id)) {
    file.remove("~/.config/earthengine/.httr-oauth")
    table_id <- get_ft_id(target_name)
  }
  
  if(is.na(table_id)) stop("problem with uploading your files")
  table_id$ft_id <- paste0("ft:",table_id$items.tableId)

  
  #message <- validate_shapefile(table_id$ft_id)
  #test <- try(suppressWarnings(as.numeric(message)), silent = T) 
  #if(!(class(test) == "numeric")) stop(paste0(message, " Parameter target must be string pointing to a local file to upload or a name of a file, that is already uploaded"))
  
  

# write params to file

  
  # cat to data frame
  #dataproducts_df <- as.data.frame(do.call(cbind, products)) 
  #names(dataproducts_df) <- as.character(unlist(dataproducts_df[1,]))
  #dataproducts_df <- dataproducts_df[2,]
  # list for all filnames exported
  list = list()
  

# loop over data products

  
  for(i in seq_along(products)) {
    #products[[i]]$productName <- paste0(groupname, "_", products[[i]]$productName)
    params <- rbind(cbind(products[[i]]), ft_id = table_id$ft_id, outputFormat, resolution)
    
    write.table(t(params), file = "./params.csv", sep = ",", row.names = F, col.names = T)
  
    #params_json <- jsonlite::toJSON(as.data.frame(t(params)))
    #jsonlite::write_json(x = params_json,
    #                     path = "./params.json")
    #cat("request for", paste(products[[i]]$productName, "is send to Earth Engine", '\n'))

# creat system call

  
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
  test <- googledrive::drive_find(filename)
  
  # cat("data products are in progress on the Earth Engine servers")
  while (nrow(test) < 1) {
    Sys.sleep(2)
    if (verbose == T) cat(".")
    test <- googledrive::drive_find(filename)
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
get_ft_id <- function(ft_name) {
  
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
    cache = "~/.config/earthengine/.httr-oauth")
  
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



