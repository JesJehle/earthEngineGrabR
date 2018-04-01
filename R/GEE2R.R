
#' initialize gee2r package by installing the ee python library with all dependencies and creat earth engine credetiales.
#' @export
initialize_gee2r <- function() {
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
    path <- system.file("Python/install_scripts/authenticate_linux.sh", package="GEE2R")
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
    path <- system.file("Python/install_scripts/authenticate_windows.bat", package="GEE2R")

    system2(path)
    while (!(file.exists("~/.config/earthengine/credentials"))) {
      Sys.sleep(1)
    }
    #print("I am sorry, no implementation on windows yet")
    #path = "~/Documents/Ms_Arbeit/test/authenticate_windows.sh"
    #command = "bash"
    #system2(command, args = path)
    }
    message("Google earth python api is installed and authenticated")
  
    ## authenticate googledrive
    #try(test <- googledrive::drive_find(), silent = T)
    googledrive::drive_auth(cache = "~/.config/earthengine/.httr-oauth")
   # while (!(file.exists("./.httr-oauth"))) {
      Sys.sleep(2)
   # }

  message("Googledrive package to communicate with your google drive account is authenticated")
  
  
    # path to authentification script
    path <- system.file("Python/install_scripts/gdal_auth_gee2r.py", package="GEE2R")
    call <- paste0("python ", path)
    system(paste0("gnome-terminal -x sh -c ", "\"", call, "\""))
    
    while (!(file.exists("~/.config/earthengine/refresh_token.txt"))) {
      Sys.sleep(1)
    }
    
    message("Fusiontable API is authenticated")
    
    ## fusion table upload
    id <- get_ft_id("test")
    message("Fusiontable API for upload is authenticated")
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
    googledrive::drive_rm(file_name)
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
  if (file.exists("refresh_token.txt")) {
    refresh_token = readChar("refresh_token.txt", nchars = 100000)
  } else {
    stop("Fusion Table API is not authenticated \n
         run gee2r_initialize()")
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
  path2script <- system.file("Python/GEE2R_python_scripts/validate_ft.py", package="GEE2R")
  
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
    googledrive::drive_rm(filename)
    # delete folder
    googledrive::drive_rm("GEE2R_temp")
    
  }
}



#' chirps_precipitation
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @return depend on output
#' @export
data_chirps_precipitation <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
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
data_jrc_distanceToWater <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
  productInfo <- list(
    productName = "jrc_distanceToWater_m",
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
data_modis_treeCover <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
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
data_modis_nonTreeVegetation <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
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
data_modis_nonVegetated <- function(spatialReducer = "mean", temporalReducer = "mean", yearIntervall = c(2000, 2002)) {
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
data_srtm_elevation <- function(spatialReducer = "mean") {
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
data_srtm_slope <- function(spatialReducer = "mean") {
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
data_oxford_accessibility <- function(spatialReducer = "mean") {
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
data_oxford_friction <- function(spatialReducer = "mean") {
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




################################
## parameter testing
################################

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


#' get_data_one_by_one
#' @param products list of vectors as list(c(dataproduct, timeReducer)...) 
#' @param timeReducer Reducer to aggregate data over time, can be: mean, median or mode, sum, min, max 
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param timeIntervall Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param target A path to a local file or a name of a already uploaded to earth engine
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ
#' @param resolution Resolution of the dataproducts. modis = 250
#' @return depend on output
#' @export
get_data_one_by_one <- function(
  target = NULL, 
  outputFormat = "GeoJSON",
  resolution = 100,
  products = list(
    data_jrc_distanceToWater()
    )
  )

{
  ##############################################################
  # test data products validation
  ##############################################################
  
  # test <- try(as.data.frame(products), silent = T)
  # if(!(class(test) == "data.frame" || nrow(test) == 2)) stop("products has to be a list of vectors as c(dataproduct, timeReducer)")
  # # get products in a more usefull form
  # dataproducts_df <- as.data.frame(do.call(rbind, products)) 
  # names(dataproducts_df) <- c("products", "timeReducer")
  # # list of products an reducers
  # reducers <- c("mean", "median", "mode", "sum", "min", "max")
  # dataproductNames <- c("chirps_precipitation", "jrc_distanceToWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", "modis_quality", "oxford_friction", "oxford_accessibility")
  # 
  # ##############################################################
  # # validate params
  # ##############################################################
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
  ##############################################################
  # validate fusion table and get info about feature collection in earth engine
  ##############################################################
  # decide if target is fusion table name or local file
  
  #upload data
  #delete_if_exist(target)
  #Sys.sleep(1)
  
  target_name =   get_name_from_path(target)
  test <- try(nrow(googledrive::drive_find(target_name)) == 1, silent = T)
  if (!test) {
    response_ft_upload <- upload_data_ft(target)
    message("file upload finished")
  } else {
    message("file alredy uploaded")
  }
  

  #extension_full <- paste0(".",tolower(extensions))
  #grep(extension_full %in% target)
  #gsub(extension_full[1]," ",target)
  #gsub("^.*\\.",".",x)
  
  
  table_id <- get_ft_id(target_name)
  if(is.na(table_id)) stop("problem with uploading your files")
  table_id$ft_id <- paste0("ft:",table_id$items.tableId)

  
  #message <- validate_shapefile(table_id$ft_id)
  #test <- try(suppressWarnings(as.numeric(message)), silent = T) 
  #if(!(class(test) == "numeric")) stop(paste0(message, " Parameter target must be string pointing to a local file to upload or a name of a file, that is already uploaded"))
  
  
  ##############################################################
  # write params to file
  ##############################################################
  
  # cat to data frame
  #dataproducts_df <- as.data.frame(do.call(cbind, products)) 
  #names(dataproducts_df) <- as.character(unlist(dataproducts_df[1,]))
  #dataproducts_df <- dataproducts_df[2,]
  # list for all filnames exported
  list = list()
  
  ###########
  # loop over data products
  ###########
  
  for(i in seq_along(products)) {
    #products[[i]]$productName <- paste0(groupname, "_", products[[i]]$productName)
    params <- rbind(cbind(products[[i]]), ft_id = table_id$ft_id, outputFormat, resolution)
    
    write.table(t(params), file = "./params.csv", sep = ",", row.names = F, col.names = T)
  
    #params_json <- jsonlite::toJSON(as.data.frame(t(params)))
    #jsonlite::write_json(x = params_json,
    #                     path = "./params.json")

    ##############################################################
  # creat system call
  ##############################################################
  
    command = "python"
  # path to python scripts
    path2script <- system.file("Python/GEE2R_python_scripts/get_data.py", package="GEE2R")
  # test for spaces in path
    if (length(grep(" ", path2script) > 0)) {
     path2script <-  shQuote(path2script)
   }
  # for information
  # message(paste0("send request to earth engine, answer depends on the number of polygons in your shapefile. \n Your Shapefile in ", assetPath, " consists of ", message, " features."))
  
  # if a file with the same name is present on google drive it is deleted
    filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    googledrive::drive_rm(filename)
    
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
  print(paste0("Earth Engine export status of ",  exportInfo$description, " is: ", exportInfo$state))  
  
  }

  
   for(i in seq_along(products)) {
     download_data_waiting(filename = list[i])
   }
  

  #lig <- unlist(l) %in% unlist(v)
  
  product_list <- unlist(list) 
  
  
  downloads <- list.files(getwd())
  downloads_clean <- grep('geojson', downloads, value = T)
  

  while (sum(product_list %in% downloads_clean) != length(product_list)) {
    
    Sys.sleep(1)
    downloads <- list.files(getwd())
    downloads_clean <- grep('geojson', downloads, value = T)
  }
  
    ## import data
    join <- sf::st_read(downloads_clean[1], quiet = TRUE)
    file.remove(downloads_clean[1])
    if(length(downloads_clean) > 1) {
      for(i in 2:length(downloads_clean)) {
        data <- sf::st_read(downloads_clean[i], quiet = TRUE)
        file.remove(downloads_clean[i])
        data_no_geom <- sf::st_set_geometry(data, NULL)
        join <- dplyr::left_join(join, data_no_geom)
      }
    }
    #delete_if_exist(target)
    googledrive::drive_rm("GEE2R_temp")
  
   return(join)
}






#' download_data_waiting
#' @param info Output of the get_data function.
#' @param path The local path where the file should be stored, default is working directory.
#' @param clear If the file should be removed from Google Drive after the download.
#' @return nothing
#' @export
download_data_waiting <- function(filename, path = getwd(), clear = T){
  
  filename <- as.character(filename)
  path_full <- paste0(path, "/", filename)
  test <- googledrive::drive_find(filename)
  
  while (nrow(test) < 1) {
    Sys.sleep(1)
    test <- googledrive::drive_find(filename)
  }
  
  googledrive::drive_download(file = filename, path = path_full, overwrite = T)
  message(paste0('download: ', filename))
  if(clear == T){
    # delete file
    googledrive::drive_rm(filename)
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

















































#' get_data
#' @param products list of vectors as list(c(dataproduct, timeReducer)...) 
#' @param timeReducer Reducer to aggregate data over time, can be: mean, median or mode, sum, min, max 
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param timeIntervall Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param assetPath  A string path to earth engine asset
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ
#' @param resolution Resolution of the dataproducts. modis = 250
#' @return depend on output
#' @export
get_data<- function(
  timeIntervall = c(2000, 2000),
  assetPath = NULL, 
  spatialReducer = "mean",
  outputFormat = "GeoJSON",
  resolution = 100,
  name = "example",
  products = list(
    c("chirps_precipitation", "mean"),
    c("jrc_distanceToWater", "mode"),
    c("modis_treeCover","mean"),
    c("modis_nonTreeVegetation","mean"),
    c("modis_nonVegetated","mean"),
    c("srtm_elevation", NA),
    c("srtm_slope", NA),
    c("modis_quality", "mean"),
    c("oxford_friction", NA),
    c("oxford_accessibility", NA)
    
  ))

{
  ##############################################################
  # test data products validation
  ##############################################################
  
  test <- try(as.data.frame(products), silent = T)
  if(!(class(test) == "data.frame" || nrow(test) == 2)) stop("products has to be a list of vectors as c(dataproduct, timeReducer)")
  # get products in a more usefull form
  dataproducts_df <- as.data.frame(do.call(rbind, products)) 
  names(dataproducts_df) <- c("products", "timeReducer")
  # list of products an reducers
  reducers <- c("mean", "median", "mode", "sum", "min", "max")
  dataproductNames <- c("chirps_precipitation", "jrc_distanceToWater", "modis_treeCover", "modis_nonTreeVegetation", "modis_nonVegetated", "srtm_elevation", "srtm_slope", "modis_quality", "oxford_friction", "oxford_accessibility")
  
  ##############################################################
  # validate params
  ##############################################################
  
  if(!(class(timeIntervall[1]) == "numeric" || timeIntervall[1] >= 2000 & timeIntervall[1] < 2016)) stop("yearStart must be an integer between 2000 and 2015")
  if(!(class(timeIntervall[2]) == "numeric" || timeIntervall[2] >= 2000 & timeIntervall[2] < 2016)) stop("yearEnd must be an integer between 2000 and 2015")
  if(!(timeIntervall[1] <= timeIntervall[2])) stop("year_start must be before or equal to year_end")
  if(!(class(dataproducts_df$timeReducer) == "character" || dataproducts_df$timeReducer %in% reducers ||is.na(dataproducts_df$timeReducer))) stop("timeReducer must be of class string, either mean, median mode, sum, min or max")
  if(!(class(spatialReducer) == "character" || dataproducts_df$spatialReducer %in% c("mean", "median", "mode"))) stop("spatialReducer must be of class string, either mean, median or mode")
  if(!(class(dataproducts_df$products) == "character" || dataproducts_df$products %in% dataproductNames)) stop(paste0("dataproduct name must be one of: ", dataproductNames))
  if(!(class(assetPath) == "character")) stop("assetPath must be string consisting of users/username/nameOfPolygons")
  if(!(class(name) == "character")) stop("must be a string")
  if(!(class(outputFormat) == "character" || outputFormat %in% c("CSV", "GeoJSON", "KML", "KMZ"))) stop("Output must be a String specifying the output, use CSV, GeoJSON, KML or KMZ")
  
  # validate path to shapefile if no test specified
  message <- validate_shapefile(assetPath)
  test <- try(suppressWarnings(as.numeric(message)), silent = T) 
  if(!(class(test) == "numeric")) stop(paste0(message, " Parameter assetPath must be string pointing to an earth engine asset: users/username/name_of_shapefile"))
  
  
  ##############################################################
  # write params to file
  ##############################################################
  
  # cat to data frame
  dataproducts_df <- as.data.frame(do.call(cbind, products)) 
  names(dataproducts_df) <- as.character(unlist(dataproducts_df[1,]))
  dataproducts_df <- dataproducts_df[2,]
  params <- cbind(dataproducts_df, assetPath, spatialReducer, outputFormat, resolution, name, year_start = timeIntervall[1], year_end = timeIntervall[2])
  
  write.table(params, file = "./params.csv", sep = ",", row.names = F)
  
  ##############################################################
  # creat system call
  ##############################################################
  
  command = "python"
  # path to python scripts
  path2script <- system.file("Python/GEE2R_python_scripts/get_data.py", package="GEE2R")
  # test for spaces in path
  if (length(grep(" ", path2script) > 0)) {
    path2script <-  shQuote(path2script)
  }
  # for information
  message(paste0("send request to earth engine, answer depends on the number of polygons in your shapefile. \n Your Shapefile in ", assetPath, " consists of ", message, " features."))
  
  # if a file with the same name is present on google drive it is deleted
  filename <- paste0(name,".", casefold(outputFormat))
  googledrive::drive_rm(filename)
  

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
  print(paste0("Earth Engine export status is: ", exportInfo$state))  
  
  return(exportInfo)
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



#' get_data_profile_version
#' @param products list of vectors as list(c(dataproduct, timeReducer)...) 
#' @param timeReducer Reducer to aggregate data over time, can be: mean, median or mode, sum, min, max 
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param timeIntervall Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param assetPath  A string path to earth engine asset
#' @param outputFormat A string specifying the output format: CSV, GeoJSON, KML or KMZ
#' @param resolution Resolution of the dataproducts. modis = 250
#' @return depend on output
#' @export
get_data_profile <- function(
  timeIntervall = c(2000, 2000),
  assetPath = NULL, 
  spatialReducer = "mean",
  outputFormat = "GeoJSON",
  resolution = 100,
  numPolygons = 10000,
  name = "example",
  products = list(
    c("chirps_precipitation", "mean"),
    c("jrc_distanceToWater", "mode"),
    c("modis_treeCover","mean"),
    c("modis_nonTreeVegetation","mean"),
    c("modis_nonVegetated","mean"),
    c("srtm_elevation", NA),
    c("srtm_slope", NA),
    c("modis_quality", "mean"),
    c("oxford_friction", NA),
    c("oxford_accessibility", NA)
    
  ))

{
  
  ##############################################################
  # write params to file
  ##############################################################
  
  # cat to data frame
  dataproducts_df <- as.data.frame(do.call(cbind, products)) 
  names(dataproducts_df) <- as.character(unlist(dataproducts_df[1,]))
  dataproducts_df <- dataproducts_df[2,]
  params <- cbind(dataproducts_df, assetPath, spatialReducer, outputFormat, resolution, name, year_start = timeIntervall[1], year_end = timeIntervall[2], numPolygons)
  
  write.table(params, file = "./params.csv", sep = ",", row.names = F)
  
  ##############################################################
  # creat system call
  ##############################################################
  
  command = "python"
  # path to python scripts
  path2script <- system.file("Python/GEE2R_python_scripts/get_data_profile.py", package="GEE2R")
  # test for spaces in path
  if (length(grep(" ", path2script) > 0)) {
    path2script <-  shQuote(path2script)
  }
  # for information
  #message(paste0("send request to earth engine, answer depends on the number of polygons in your shapefile. \n Your Shapefile in ", assetPath, " consists of ", message, " features."))
  
  # if a file with the same name is present on google drive it is deleted
  filename <- paste0(name,".", casefold(outputFormat))
  googledrive::drive_rm(filename)
  
  
  # invoce system call on the commandline 
  drop = system2(command,
                 args =  path2script,
                 stdout = T,
                 wait = T)
  
  json_data <- rjson::fromJSON(file="./exportInfo.json")
  exportInfo <- rjson::fromJSON(json_data)
  file.remove("./exportInfo.json")
  file.remove("./params.csv")
  #print(paste0("the projection of result is", drop))
  print(paste0("Earth Engine export status is: ", exportInfo$state))  
  
  return(exportInfo)
}





#' get_data_test
#' @param products list("chirps_precipitation","jrc_permanentWater","modis_treeCover","modis_nonTreeVegetation","modis_nonVegetated","srtm_elevation",srtm_slope", "modis_quality")
#' @param year_start asd
#' @param year_end  asd
#' @param time_reducer asd
#' @param asset_path  
#' @param output A String specifying the output format: CSV, GeoJSON, KML or KMZ
#' @param spatial_reducer as
#' @param scale as
#' @param test what test to perform, "size_test"
#' @param numPolygons if test is "size_test", numPolygons sets number of polygons to test
#' @param raster perPolygon = list(raster = T, asset_id), raster = list(raster = T, extend, resolution), rasterAsDataFrame = list(rasterAsDataFrame = T, extand, resolution)
#' @return depends on target
get_data_test <- function(
                     year_start = 2000,
                     year_end = 2000,
                     time_reducer = "mean",
                     asset_path = "users/JesJehle/Strips", 
                     output = "GeoJSON",
                     spatial_reducer = "mean", 
                     scale = 100,
                     test = "no_size_test",
                     numPolygons = 10000,
                     name = "example",
                     export = F,
                     products = list(
                                    "chirps_precipitation",
                                    "jrc_permanentWater",
                                    "modis_treeCover",
                                    "modis_nonTreeVegetation",
                                    "modis_nonVegetated",
                                    "srtm_elevation",
                                    "srtm_slope", 
                                    "modis_quality")
)

{
  # generate arguments for chirps data
  month_start = 1
  month_end = 12
  
  ##############################################################
  # validate params
  ##############################################################
  
  assertthat::assert_that(assertthat::is.number(month_start), month_start > 0 & month_start < 13, msg = "month_start must be an integer between 1 and 12") 
  assertthat::assert_that(assertthat::is.number(month_end), month_end > 0 & month_end < 13, msg = "month_end must be an integer between 1 and 12") 
  assertthat::assert_that(assertthat::is.number(year_start), year_start >= 2000 & year_start < 2016, msg = "year_start must be an integer between 2000 and 2015") 
  assertthat::assert_that(assertthat::is.number(year_end), year_end >= 2000 & year_end < 2016, msg = "year_end must be an integer between 2000 and 2015") 
  assertthat::assert_that(year_start <= year_end, msg = "year_start must be before or equal to year_end") 
  assertthat::assert_that(assertthat::is.string(time_reducer), time_reducer == "mean" | time_reducer == "median" | time_reducer == "mode", msg = "time_reducer must be of class string, either mean, median or mode") 
  assertthat::assert_that(assertthat::is.string(asset_path), msg = "asset_path must be string consisting of users/username/nameOfPolygons") 
  assertthat::assert_that(assertthat::is.string(name), msg = "name of file") 
  assertthat::assert_that(assertthat::is.string(output), output %in% c("CSV", "GeoJSON", "KML", "KMZ"),  msg = "Output must be a String specifying the output, use CSV, GeoJSON, KML or KMZ") 
    # validate path to shapefile if no test specified
  if(test == "no_size_test") {
  message <- validate_shapefile(asset_path = asset_path)
  assertthat::assert_that(assertthat::is.number(as.numeric(message)), msg = cat(message, "Parameter asset_id must be string consisting of users/username/name_of_shapefile")) 
  }
  
  ##############################################################
  # creat system call
  ##############################################################
  
  # concatenate arguments
  arguments = c(month_start, month_end, year_start, year_end, time_reducer, asset_path, spatial_reducer, scale, test, format(numPolygons, scientific=F), output, name, export, products)
  # first command in console
  command = "python"
  # path to python scripts
  path2script <- "./scripts/get_data_test.py"
  # concatenate path and arguments
  AllArgs <- c(path2script, arguments)
  # for information
  message(paste0("send request to earth engine, answer depends on the number of polygons in your shapefile. \n Your Shapefile in", asset_path, " consists of ", message, " features."))
  
  # invoce system call on the commandline 
  output_gee = system2(command,
                   args =  AllArgs,
                   stdout = T,
                   wait = T)
  if(export == T){
    
  # clean gee output
  file_clean <- gsub("'", "\"", output_gee)
  file_clean <- gsub("u", "", file_clean)
  file_json <- rjson::fromJSON(file_clean)
  file_json$output <- casefold(output)
  file <- file_json
  # print export status
  print(paste0("Earth Engine export status is: ", file_json$state))  
  } else {
    file <- "test"
  }
  return(file)
}




# When? Timeperiode of interest to reduce over
# year start-end, month start-end

# Where? Region of interest
# polygon, multipolygon, extend, bounding box, asset_path

# What? Data products
# list of products with specified reducers

# How? Output
# as raster or data.frame
# raster - resolution, projection


# iteration example

'  file_list = list()
  if (length(output) > 1){
    for(i in 1:length(output)) {
      file_list[[i]] <- data.table::fread(output[i])
    }
     file <-  data.table::rbindlist(file_list)
  } else {
    file <- data.table::fread(output)
  }'



