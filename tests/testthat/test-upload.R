context("Upload functionalities")
library(earthEngineGrabR)

ft_name <- "test-data"
test_that("get_ft_id extracts the id of test-data on google drive", {
  test <- get_ft_id_gd(ft_name)
  expect_equal(nrow(test), 1)
  expect_named(test, c("name", "id", "drive_resource"), ignore.order = T)
  })


wrong_ft_name <- "test-data-error"
test_that("get_ft_id raise error with wrong ft_name argument", {
  expect_error(get_ft_id_gd(wrong_ft_name))
})
