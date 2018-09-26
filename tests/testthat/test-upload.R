context("Upload functionalities")
library(earthEngineGrabR)

ft_name <- "test-data"
test_that("test that get_ft_id extracts the id of test-data on google drive", {
  skip_test_if_not_possible()
  test <- get_ft_id_gd(ft_name)
  expect_equal(nrow(test), 1)
  expect_named(test, c("name", "id", "drive_resource"), ignore.order = T)
  })

wrong_ft_name <- "test-data-error"
test_that("test that get_ft_id raise error with wrong ft_name argument", {
  skip_test_if_not_possible()
  expect_error(get_ft_id_gd(wrong_ft_name))
})

test_that("test that upload_as_ft uploads test data to google drive as fusion table", {
  skip_test_if_not_possible()
  activate_environments()
  upload_as_ft(system.file("data/test-data.shp", package = "earthEngineGrabR"), "test-upload")
  test_upload <- googledrive::drive_find("test-upload")
})
