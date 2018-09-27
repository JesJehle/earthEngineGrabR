
library(earthEngineGrabR)
library(testthat)


test_that("test that run_ee_oauth creates credentials in credentials root dir", {
  
  activate_environments()
  delete_credentials("credentials")
  run_ee_oauth()
  credentials_test <- test_credentials("credentials")
  expect_true(credentials_test)
})

test_that("test that run_gd_oauth creates credentials in credentials root dir", {
  
  activate_environments()
  delete_credentials("gd-credentials.rds")
  run_gd_oauth()
  credentials_test <- test_credentials("gd-credentials.rds")
  expect_true(credentials_test)
})


test_that("test that run_ft_oauth creates credentials in credentials root dir", {
  
  activate_environments()
  delete_credentials("ft_credentials.json")
  run_ft_oauth()
  credentials_test <- test_credentials("ft_credentials.json")
  expect_true(credentials_test)
})


