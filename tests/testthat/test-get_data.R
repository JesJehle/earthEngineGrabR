library(earthEngineGrabR)

context("Get data and info from earth engine")

test_that("test that get_data processes data on earth engine and exports it to drive while returning status of process", {
  
  skip_test_if_not_possible()
  activate_environments()
  data_type <- "Image"
  df <- list()
  df$productID = "CGIAR/SRTM90_V4"
  df$productName = "test_SRTM"
  df$spatialReducer = "mean"
  df$ft_id = get_ft_id_gd("test-data")$ft_id
  df$outputFormat = "GeoJSON"
  df$resolution = 3000
  df$productNameExtension = paste0(df$productName, ".", casefold(df$outputFormat))
  
  delete_on_drive(df$productNameExtension)
  status <- get_data(df, data_type)
  test <- wait_for_file_on_drive(df$productNameExtension, verbose = F)
  expect_true(test)
  
  # 
  # temporalReducer,
  # timeStart,
  # timeEnd
  # 
  
  
})

