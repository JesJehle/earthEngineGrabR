context("Upload functionalities")
library(earthEngineGrabR)

ft_name <- "test-data"
test_that("test that get_ft_id extracts the id of test-data on google drive", {
  skip_test_if_not_possible()
  test <- get_ft_id_gd(ft_name)
  expect_is(test, "character")
})

wrong_ft_name <- "test-data-error"
test_that("test that get_ft_id raise error with wrong ft_name argument", {
  skip_test_if_not_possible()
  expect_error(get_ft_id_gd(wrong_ft_name))
})

test_that("test that upload_as_ft uploads test data to google drive as fusion table", {
  skip_test_if_not_possible()
  
  try(googledrive::drive_mv("test-upload", verbose = F), silent = T)
  
  earthEngineGrabR:::activate_environments()
  earthEngineGrabR:::upload_as_ft(system.file("data/test-data.shp", package = "earthEngineGrabR"), "test-upload")
  test_upload <- googledrive::drive_find("test-upload", verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  googledrive::drive_rm("test-upload", verbose = F)
})

test_that("test that upload_as_ft throws error with non valid file", {
  skip_test_if_not_possible()
  activate_environments()
  expect_error(upload_as_ft(system.file("data/not-valid.shp", package = "earthEngineGrabR"), "test-upload"))
})







test_that("test that upload_data uploads test data to google drive as fusion table and returns ID", {
  skip_test_if_not_possible()
  earthEngineGrabR:::activate_environments()
  googledrive::drive_mv("test-data", verbose = F)
  test_id <- earthEngineGrabR:::upload_data(targetArea = system.file("data/test-data.shp", package = "earthEngineGrabR"), verbose = F)

  # test if file is uploaded
  test_upload <- googledrive::drive_find("test-data", verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)

  # test if id is returned
  expect_is(test_id, "character")
  googledrive::drive_rm("test-upload")
})


