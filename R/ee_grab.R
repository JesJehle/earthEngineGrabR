



#' Request and import data from Earth Engine
#' 
#' 
#' The \code{ee_grab()} function Request and imports data from Earth Engine according to a user defined data request.
#' 
#' To define the data request:
#'  
#' use \code{ee_data_image()} and \code{ee_data_collection()} to define the data. 
#' 
#' use \code{targetArea} to define the spatial target, in which the data sould be aggregated.
#'  
#' @section \code{earthEngineGrabR} Workflow:
#' 
#' Search for dataset in Earth Engine \href{https://developers.google.com/earth-engine/datasets/}{Data Catalog}.
#' 
#' Grab data according to a user defines data reuquest.
#' 
#' @section Search for data:
#' Use Earth Engine's \href{https://developers.google.com/earth-engine/datasets/}{Data Catalog} to browse and find datasets you want to grab using the earthEngineGrabR. Once you have found a dataset, use the \href{link to tutorial }{snippet section} to obtain the dataset ID and whether the dataset is an image or a collection of images. The snippet section consists of one line of code (don't open the link) and shows how Earth Engine loads the dataset. If it is an image, the  ee.Image(dataset-ID) constructor is used. if it is a collection the ee.ImageCollection(dataset-id) constructor is used instead.
#' 
#' @section Grab data:
#' 
#' \code{ee_grab()} requests and imports data from Earth Engine to R.
#' \code{ee_grab()} takes two arguments, \code{data} and \code{targetArea}. 
#' \code{data} takes a single or a \code{list} of \code{ee_data_image()} and \code{ee_data_collection()} functions, which define the requested data to \code{ee_grab()}.
#' If the requested data is an image use \code{ee_data_image()}, if it's a collection use \code{ee_data_collection()}.
#' \code{targetAreo} takes a path to a local geo-file, which defines the spatial target in which the data sould be aggregated.
#' 
#' 
#' 
#' @section Internal processing:
#' 
#'   The \code{ee_grab()} processing runs in 4 steps:
#' 
#'   1. Upload - The targetArea is uploaded to Google Drive.
#' 
#'   2. Request - The data is requested from Google Earth Engine and exported to Google Drive.
#' 
#'   3. Download -  The data is downloaded from Drive.
#' 
#'   4. Import - The data is imported to R and merged.

#' @param data \code{list} of \code{ee_data_image()} or \code{ee_data_collection()} functions which define the requested data. Multiple functions are passed inside a \code{list}, while a single function can be passed directly.
#' @param targetArea \code{character} path to a local geo-file that should be used as a targetArea (.shp, .geojson, .kml). If the file is already uploaded, the upload is skipped.
#' @param verbose \code{logical}, whether to inform the user about the processing state of the data. Default is set to \code{True}.
#' @param testCase \code{character}, simulates user input. For development only. Default is set to \code{NULL}.
#' @return Object of class \code{sf}. \code{ee_grab()} returns the targetArea file with the bands of the requested data added as columns.
#'@examples
#' \dontrun{
#' # Request a srtm image data product to get topographic data.
#' # Grab the spatial mean of the elevation band in the polygons of your targetArea. The calculation are based on a 100 meter scale, which means that the original SRTM data product is resampled to 100 * 100 meter Pixel size.
#'
#'srtm_data <- ee_grab(data = ee_data_image(datasetID = "CGIAR/SRTM90_V4", 
#'                                          spatialReducer = "mean", 
#'                                          resolution = 100, 
#'                                          bandSelection = "elevation"
#'                                          ),
#'                    targetArea = system.file("data/territories.shp", package = "earthEngineGrabR")
#'                    )
#'                                                     
#' # Request a chirps collection data product to get precipitation data.
#' # Grab the yearly precipitation sum for 2016 and get the spatial mean in the polygons of your targetArea.
#'
#'chirps_data <- ee_grab(data = ee_data_collection(datasetID = "UCSB-CHG/CHIRPS/DAILY",
#'                                                 spatialReducer = "mean",
#'                                                 temporalReducer = "sum", 
#'                                                 timeStart = "2016-01-01",
#'                                                 timeEnd = "2016-12-31", 
#'                                                 resolution = 200
#'                                                 ),
#'                       targetArea = system.file("data/territories.shp", package = "earthEngineGrabR")
#'                      )                                                    
#'                                                     
#'                                                                                                                                                                                                                                                               
#' }
#' 
#' @export
ee_grab <- function(data = NULL,
                    targetAreaAssetPath = NULL,
                    verbose = T,
                    testCase = NULL,
                    download_path =  getwd()) {
  # test required dependencies and activates environment for reticulate
  
  if (is.null(targetAreaAssetPath) | targetAreaAssetPath == "") stop("No targetArea specified. \nPlease specify a targetArea with a path to a asset on GEE of class character.", call. = F)
  is_type(targetAreaAssetPath, "character")
  
  if (is.null(data) | !is.list(data[1])) stop("No data specified. \nPlease specify your requested data with a single ee_data_image() or ee_data_collection() functions.", call. = F)

  earthEngineGrabR:::activate_environments("earthEngineGrabR")
  try(googledrive::drive_rm("earthEngineGrabR-tmp", verbose = F), silent = T)
  
  # check for equal resolutions of Bands and get native resolution if resolution argument is NULL
  data <- set_resolution(data)
  # upload vector data as fusion table --------------------
  targetArea_id <- targetAreaAssetPath

  # request data data form google earth engine servers
  ee_response <- request_data(data, targetArea_id)

  # create temp dir
  # download data data form google drive
  download_data(ee_response = ee_response, verbose = verbose, temp_path = download_path)
  # import data to R

  return(NULL)
  
  # remove tmp files local and from drive
  #try(googledrive::drive_rm("earthEngineGrabR-tmp", verbose = F), silent = T)
  on.exit({
    try(googledrive::drive_rm("earthEngineGrabR-tmp", verbose = F), silent = T)
    unlink(temp_path, recursive = T)
    })
}
