
## parameter testing


# for(i in 1:length(products)) {
#  if(!(products[[i]]$spatialReducer %in% reducers)){
#    stop(paste0("spatialReducer has to be on of: ", reducers))
#  }
# }
# test exclusive params
# for(i in 1:length(products)) {
#  if (is.character(try(products[[i]]$temporalReducer))) {
#    if (!(products[[i]]$spatialReducer %in% reducers)) {
#      stop(paste0("spatialReducer has to be on of: ", reducers))
#    }
#  }
# }



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
