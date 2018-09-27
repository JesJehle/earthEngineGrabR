library(earthEngineGrabR)

context("Installation and Environment tests")

test_that("Test that test_anaconda() test_python() ", {
  skip_test_if_not_possible()
  
  expect_silent(test_anaconda())
  expect_silent(test_python())

})