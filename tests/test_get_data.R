target <- system.file("data/territories.shp", package="earthEngineGrabR")
table_id <-  upload_data(target = target)

try_data <- ee_grab_dev()

response <- get_data_image(
  productID = "CGIAR/SRTM90_V4",
  productName = "SRTM",
  resolution = 50,
  spatialReducer = "mean",
  ft_id = table_id$ft_id,
  outputFormat = "GeoJSON"
)



response <- get_data_collection(
  productID = "GLCF/GLS_TCC",
  productName = "TreeCover",
  spatialReducer = "mean",
  temporalReducer = "mean",
  timeStart = "2000-3-20",
  timeEnd = "2005-2-20",
  ft_id = table_id$ft_id,
  outputFormat = "GeoJSON",
  resolution = 500
)

