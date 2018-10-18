library(earthEngineGrabR)

context("Download functionalities")


try(earthEngineGrabR:::gd_auth(), silent = T)
test <- googledrive::drive_find("CGIAR-SRTM90_V4_s-mean.geojson", verbose = F)
environment_test <- try(nrow(test) == 1, silent = T)
if (!environment_test) skip(paste("Testing is not possible. \n", "files on google drive: ", environment_test))


test_file <- "CGIAR-SRTM90_V4_s-mean.geojson"
# test_file <- "test_SRTM.geojson"
temp_dir <- earthEngineGrabR:::get_temp_path()


# googledrive::drive_download("test_SRTM.geojson", path = file.path(test_dir, "test_SRTM.geojson"), overwrite = T)


test_that("Test that download_data downloads test file from google drive", {
  skip_test_if_not_possible()
  earthEngineGrabR:::activate_environments()

  # googledrive::drive_find(test_file, verbose = F)

  earthEngineGrabR:::download_data(test_file,
    clear = F,
    temp_path = temp_dir
  )

  test <- grep(test_file, list.files(temp_dir))
  expect_is(test, "integer")
  # unlink(test_dir, recursive = T)
})


test_that("Test that import_data import data to R", {
  earthEngineGrabR:::skip_test_if_not_possible()
  earthEngineGrabR:::activate_environments()

  data <- earthEngineGrabR:::import_data(
    product_list = test_file,
    temp_path = temp_dir
  )

  expect_is(data, "data.frame")
  # googledrive::drive_find(test_file, verbose = F)
  # unlink(test_dir, recursive = T)
})








#
#
#   list.files(test_dir)
#   unlink(test_dir, T)
#
