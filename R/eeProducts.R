
#' create product
#' @param productID Strong of the Image/ImageCollection ID found in Earth Engine Data Explorer
#' @param productName A name for the data product specified by the user.
#' @param spatialReducer Reducer to spatially aggregate all dataproducts in each geometry of the feature, can be: mean, median or mode)
#' @param temporalReducer Integers to spedify the beginning and end of timeperiod to reduce over as c(yearStart, yearEnd).
#' @param yearIntervall A path to a local file or a name of a already uploaded to earth engine
#' @description Climate Hazards Group InfraRed Precipitation with Station data (CHIRPS) is a 30+ year quasi-global rainfall dataset. CHIRPS incorporates 0.05° resolution satellite imagery with in-situ station data to create gridded rainfall time series for trend analysis and seasonal drought monitoring.
#' @return depend on output
#' @export
create_product <- function(productID = "UCSB-CHG/CHIRPS/DAILY",
                          productName = "chirps",
                          spatialReducer = "mean",
                          temporalReducer = "sum",
                          timeStart = "2017-1-1",
                          timeEnd = "2017-12-31") {
  productInfo <- list(
    productID = productID,
    
    productName = productName,
    #   paste0(
    #   productName,
    #   "_",
    #   spatialReducer,
    #   "_",
    #   timeStart,
    #   "_",
    #   timeEnd,
    #   "_",
    #   temporalReducer
    # )
    spatialReducer = spatialReducer,
    temporalReducer = temporalReducer,
    timeStart = timeStart,
    timeEnd = timeEnd
  )
  return(productInfo)
  
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
    spatialReducer = spatialReducer,
    temporalReducer = NULL,
    yearStart = NULL,
    yearEnd = NULL
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
    spatialReducer = spatialReducer,
    temporalReducer = NULL,
    yearStart = NULL,
    yearEnd = NULL
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
    spatialReducer = spatialReducer,
    temporalReducer = NULL,
    yearStart = NULL,
    yearEnd = NULL
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
    spatialReducer = spatialReducer,
    temporalReducer = NULL,
    yearStart = NULL,
    yearEnd = NULL
  )
  return(productInfo)
}
