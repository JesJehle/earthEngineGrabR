
# Sys.setenv("NOT_CRAN" = "false")
# if (!identical(Sys.getenv("NOT_CRAN"), "false")) {

context("Set up test environment")

activate_environments()
#googledrive::drive_rm("earthEngineGrabR-tmp", verbose = F)

# test_that("activate test environment",{
#   skip_on_cran()
#   # skip_if_not_installed("sf")
# })

#test_that("Test that required credentials exist", {
  credentials_test <- try(earthEngineGrabR:::test_credentials(), silent = T)
  expect_true(credentials_test)
#})



#test_that("Test that required python modules can be loaded", {
  #skip_on_cran()
  earthEngineGrabR:::activate_environments()
  
  module_test_ee <- py_module_available("ee")
  module_test_gdal <- py_module_available("gdal")
  expect_true(module_test_ee)
  expect_true(module_test_gdal)
  
#})

#test_that("Test that required testing files on google drive exist", {
  #skip_on_cran()
  #earthEngineGrabR:::activate_environments()
  
  # if test-download data not on google drive upload it.
  if (nrow(googledrive::drive_find("test-data", verbose = F)) == 0) {
    upload_as_ft(system.file("data/test-data.shp", package = "earthEngineGrabR"), "test-data")
  }
  test <- googledrive::drive_find("test-data", verbose = F)
  environment_test <- try(nrow(test) == 1, silent = T)
  expect_true(environment_test)
#})



#test_that("upload files", {
  #skip_on_cran()
  #earthEngineGrabR:::activate_environments()
  
# build environment
# remove upload files if still present
#googledrive::drive_rm("test-upload", verbose = F)

# upload test data for download test

df <- ee_data_image(datasetID = "CGIAR/SRTM90_V4", 
                           spatialReducer = "mean", 
                           scale = 3000)

if (nrow(googledrive::drive_find(df$productNameFull, verbose = F)) == 0) {
  df$ftID <- earthEngineGrabR:::get_ft_id_gd("test-data")

  status <- earthEngineGrabR:::get_data(df, test = T)
  test <- earthEngineGrabR:::wait_for_file_on_drive(df$productNameFull, verbose = F)
  expect_true(test)
}

# if tmp dir exists delete it
#})

temp_path <- get_temp_path(F)
if (dir.exists(temp_path)) unlink(temp_path, recursive = T)

#}
