library(earthEngineGrabR)

context("Set up test environment")
activate_environments()

test_that("Test that required credentials exist", {
  credentials_test <- try(test_credentials(), silent = T)
  expect_true(credentials_test)
})

test_that("Test that required python modules can be loaded", {
  
  module_test_conda <- test_import_ee_gdal_conda()
  module_test_virtual <- test_import_ee_gdal_virtual()
  module_test <- module_test_conda[[1]] | module_test_virtual[[1]]
  expect_true(module_test)
})

test_that("Test that required testing files on google drive exist", {
  
# if test-download data not on google drive upload it.
if(nrow(googledrive::drive_find("test-data", verbose = F)) == 0) {
  upload_as_ft(system.file("data/test-data.shp", package = "earthEngineGrabR"), "test-data")
}
  test <- googledrive::drive_find("test-data", verbose = F)
  environment_test <- try(nrow(test) == 1, silent = T)
  expect_true(environment_test)
  
})

# build environment
# remove upload files if still present
googledrive::drive_rm("test-upload", verbose = F)


# upload test data for download test
if(nrow(googledrive::drive_find("test-download", verbose = F)) == 0) {
  data_type <- "Image"
  df <- list()
  df$productID = "CGIAR/SRTM90_V4"
  df$productName = "test-download"
  df$spatialReducer = "mean"
  df$ft_id = get_ft_id_gd("test-data")$ft_id
  df$outputFormat = "GeoJSON"
  df$resolution = 3000
  df$productNameExtension = paste0(df$productName, ".", casefold(df$outputFormat))
  status <- get_data(df, data_type)
  test <- wait_for_file_on_drive(df$productNameExtension, verbose = F)
  expect_true(test)
  

}






