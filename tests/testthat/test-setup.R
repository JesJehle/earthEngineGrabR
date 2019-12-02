
library(earthEngineGrabR)
context("Requirements for the test to run")

test_that("Test that required credentials exist", {
  skip_test_if_not_possible()
  activate_environments()
  
  credentials_test <- try(test_credentials(), silent = T)
  expect_true(credentials_test)
})

test_that("Test that required python modules can be loaded", {
  skip_test_if_not_possible()
  activate_environments()
  
  test_ee <- py_module_available("ee")

  expect_true(test_ee)
})

