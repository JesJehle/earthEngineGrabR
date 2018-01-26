
#' initialize gee2r package by installing the ee python library with all dependencies and creat earth engine credetiales.
#' @export
initalize_gee2r <- function(){
  
  system2("pip", "install GEE2R")
  if (Sys.info()["sysname"] == "Linux") {
    
    path <- system.file("Python/install_scripts/authenticate_linux.sh", package="GEE2R")
    # path = "../Python/install_scripts/authenticate_linux.sh"
    command = "bash"
    system2(command, args = path)
  } 
  
  if (Sys.info()["sysname"] == "Windows") {
    print("I am sorry, no implementation on windows yet")
    #path = "~/Documents/Ms_Arbeit/test/authenticate_windows.sh"
    #command = "bash"
    #system2(command, args = path)
  }
}


#' validate_shapefile
#' @param asset_path path of asset in GEE
#' @return if shapefile is not valid, returns error
#' 
validate_shapefile <- function(asset_path) {
  # first command in console
  command = "python"
  # path to python scripts
  path2script <- system.file("Python/GEE2R_python_scripts/validate_params.py", package="GEE2R")
  
    # concatenate path and arguments
  AllArgs <- c(path2script, asset_path)
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
  assertthat::assert_that(nrow(test) == 1, msg = paste0(filename, " is not yet on your Google Drive, be patient!")) 
  
  googledrive::drive_download(file = filename, path = path_full)
  if(clear == T){
    googledrive::drive_rm(filename)
  }
}



#' get_data
#' @param products list("chirps_precipitation","jrc_permanentWater","modis_treeCover","modis_nonTreeVegetation","modis_nonVegetated","srtm_elevation",srtm_slope", "modis_quality")
#' @param year_start Integer to spedify the beginning of timeperiod to reduce over.
#' @param year_end Integer to spedify the end of timeperiod to reduce over.
#' @param time_reducer Reducer to aggregate data over time, can be: mean, median or mode
#' @param asset_path  A string path to earth engine asset
#' @param spatial_reducer Reducer to spatially aggregate data, can be: mean, median or mode
#' @param output A string specifying the output format: CSV, GeoJSON, KML or KMZ
#' @param scale A scale spedifying the basis of analysis
#' @return depend on output
#' @export
get_data <- function(
  year_start = 2000,
  year_end = 2000,
  time_reducer = "mean",
  asset_path = F, 
  output = "GeoJSON",
  spatial_reducer = "mean", 
  scale = 100,
  name = "example",
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
  
  ##############################################################
  # validate params
  ##############################################################
  
  assertthat::assert_that(assertthat::is.number(year_start), year_start >= 2000 & year_start < 2016, msg = "year_start must be an integer between 2000 and 2015") 
  assertthat::assert_that(assertthat::is.number(year_end), year_end >= 2000 & year_end < 2016, msg = "year_end must be an integer between 2000 and 2015") 
  assertthat::assert_that(year_start <= year_end, msg = "year_start must be before or equal to year_end") 
  assertthat::assert_that(assertthat::is.string(time_reducer), time_reducer == "mean" | time_reducer == "median" | time_reducer == "mode", msg = "time_reducer must be of class string, either mean, median or mode") 
  assertthat::assert_that(assertthat::is.string(asset_path), msg = "asset_path must be string consisting of users/username/nameOfPolygons") 
  assertthat::assert_that(assertthat::is.string(name), msg = "must be a string") 
  assertthat::assert_that(assertthat::is.string(output), output %in% c("CSV", "GeoJSON", "KML", "KMZ"),  msg = "Output must be a String specifying the output, use CSV, GeoJSON, KML or KMZ") 
  # validate path to shapefile if no test specified
  message <- validate_shapefile(asset_path = asset_path)
  assertthat::assert_that(assertthat::is.number(as.numeric(message)), msg = cat(message, "Parameter asset_id must be string consisting of users/username/name_of_shapefile")) 
  
  
  ##############################################################
  # creat system call
  ##############################################################
  
  # concatenate arguments
  arguments = c(year_start, year_end, time_reducer, asset_path, spatial_reducer, scale, output, name, products)
  # first command in console
  command = "python"
  # path to python scripts
  path2script <- system.file("Python/GEE2R_python_scripts/get_data.py", package="GEE2R")
  # concatenate path and arguments
  AllArgs <- c(path2script, arguments)
  # for information
  message(paste0("send request to earth engine, answer depends on the number of polygons in your shapefile. \n Your Shapefile in", asset_path, " consists of ", message, " features."))
  
  # invoce system call on the commandline 
  output_gee = system2(command,
                       args =  AllArgs,
                       stdout = T,
                       wait = T)
  
  # clean gee output
  file_clean <- gsub("'", "\"", output_gee)
  file_clean <- gsub("u", "", file_clean)
  file_json <- rjson::fromJSON(file_clean)
  file_json$output <- casefold(output)
  file <- file_json
  # print export status
  print(paste0("Earth Engine export status is: ", file_json$state))  
  
  return(file)
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



