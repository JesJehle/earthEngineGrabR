



#' Grab data from Earth Engine
#' 
#' The ee_grab() function uses a target and the specified products to request and acquire the data from the Earth Engine servers. 
#' The ee_grab() processing runs in 4 steps. 
#' * 1. Upload - The target is uploaded to Google Drive.
#' * 2. Request - The data products are requested from Google Earth Engine and exported to Google Drive.
#' * 3. Download -  The data products are downloaded from Drive
#' * 4. Import - The data is finally imported to R
#' @param products List of create_image_product() or create_collection_product() functions which specify the requested data products. Multiple functions are passed as a object of class list, while a single function can be passed directly.
#' @param target A path of class character to a local geo-file that should be used as a target. If the file is already uploaded, the upload is skipped.
#' @param verbose Logical, whether to inform the user about the processing state of the requested data products.
#'@examples
#' \dontrun{
#' # Request a srtm image data product to get topographic data.
#' # Grab the spatial mean of the elevation band in the polygons of your target. The calculation are based on a 100 meter scale, which means that the original SRTM data product is resampled to 100 * 100 meter Pixel size.
#'
#'srtm_data <- ee_grab(target = system.file("data/territories.shp", package = "earthEngineGrabR"),
#'                     products = create_image_product(productID = "CGIAR/SRTM90_V4", 
#'                                                     spatialReducer = "mean", 
#'                                                     scale = 100, 
#'                                                     bands = "elevation"
#'                                                     )
#'                    )
#'                                                     
#' # Request a chirps collection data product to get precipitation data.
#' # Grab the yearly precipitation sum for 2016 and get the spatial mean in the polygons of your target.
#'
#'chirps_data <- ee_grab(target = system.file("data/territories.shp", package = "earthEngineGrabR"),
#'                       products = create_collection_product(productID = "UCSB-CHG/CHIRPS/DAILY",
#'                                                            spatialReducer = "mean",
#'                                                            temporalReducer = "sum", 
#'                                                            timeStart = "2016-01-01",
#'                                                            timeEnd = "2016-12-31", 
#'                                                            scale = 200
#'                                                            )
#'                      )                                                    
#'                                                     
#'                                                                                                                                                                                                                                                               
#' }
#' 
#' @return Object of class sf.
#' @export
ee_grab <- function(target = NULL,
                    products = NULL,
                    verbose = T) {
  # test required dependencies and activates environment for reticulate
  
  if (is.null(target)) stop("No target specified. \nPlease specify a target with a path to a local geo-file of class character.", call. = F)
  is_type(target, "character")
  
  if (is.null(products)) stop("No products specified. \nPlease specify your requested products with a single or a list of create_image_product() and create_collection_product() functions.", call. = F)
  is_type(target, "character")
  
  activate_environments("earthEngineGrabR")
  googledrive::drive_rm("earthEngineGrabR-tmp", verbose = F)

  # upload vector data is fusion table --------------------
  target_id <- upload_data(target = target, verbose = verbose)

  # request data products form google earth engine servers
  ee_response <- request_data(products, target_id)
  # create temp dir
  temp_path <- get_temp_path()
  # download data products form google drive
  download_data(ee_response = ee_response, verbose = verbose, temp_path = temp_path)
  # import data to R
  product_data <- import_data(ee_response, verbose = verbose, temp_path = temp_path)

  return(product_data)
  
  # remove tmp files local and from drive
  on.exit({
    googledrive::drive_rm("earthEngineGrabR-tmp", verbose = F)
    unlink(temp_path, recursive = T)
    })
}
