
library(earthEngineGrabR)
context("Requirements for the test to run")
activate_environments()

test_that("Test that required credentials exist", {
  skip_test_if_not_possible()
  
  credentials_test <- try(test_credentials(), silent = T)
  expect_true(credentials_test)
})

test_that("Test that required python modules can be loaded", {
  skip_test_if_not_possible()
  
  module_test_conda <- test_import_ee_gdal_conda()
  module_test_virtual <- test_import_ee_gdal_virtual()
  module_test <- module_test_conda[[1]] | module_test_virtual[[1]]
  expect_true(module_test)
})

