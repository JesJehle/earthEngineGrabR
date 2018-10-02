
library(earthEngineGrabR)
context("Requirements for the test to run")
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
  test <- googledrive::drive_find("test-download_mean.geojson", verbose = F)
  environment_test <- try(nrow(test) == 1, silent = T)
  expect_true(environment_test)
})

googledrive::drive_rm("test-upload")
