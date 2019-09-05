context("Upload functionalities")
library(earthEngineGrabR)

ft_name <- "test-data"
test_that("test that get_ft_id extracts the id of test-data on google drive", {
  skip_test_if_not_possible()
  test <- get_ft_id_gd(ft_name)
  expect_is(test, "character")
})

# multiple files with same name test To-Do

#wrong_ft_name <- "test-data-error"
#test_that("test that get_ft_id raise error with wrong ft_name argument", {
#  skip_test_if_not_possible()
#  expect_error(get_ft_id_gd(wrong_ft_name))
#})


test_that("test that upload_as_ft uploads shapefile test data to google drive as fusion table", {
  skip_test_if_not_possible()
  # Issue - upload files on travis with os-osx fails, unresolved.
  #skip_on_os("mac")
  name <- paste0("test-upload-", as.character(sample(1:200, 1)))
  earthEngineGrabR:::activate_environments()
  earthEngineGrabR:::upload_as_ft(system.file("data/test-data.shp", package = "earthEngineGrabR"), name)
  test_upload <- googledrive::drive_find(name, verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  on.exit({
    try(googledrive::drive_rm(name, verbose = F), silent = T)
    })
})


test_that("test that upload_as_ft uploads big shapefile data to google drive as fusion table", {
  earthEngineGrabR:::skip_test_if_not_possible()
  # Issue - upload files on travis with os-osx fails, unresolved.
  #skip_on_os("mac")
  #try(googledrive::drive_mv("test-upload", verbose = F), silent = T)
  name <- paste0("test-upload-", as.character(sample(1:200, 1)))
  earthEngineGrabR:::activate_environments()
  # expect_warning(earthEngineGrabR:::upload_as_ft(system.file("data/VG250_KRS.shp", package = "earthEngineGrabR"), name))
  test_upload <- googledrive::drive_find(name, verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  on.exit({
    try(googledrive::drive_rm(name, verbose = F), silent = T)
  })
})


# test_that("test that upload_as_ft uploads huge shapefile data to google drive as fusion table", {
# 
#   file_path_huge <- system.file("data/poly.shp", package = "earthEngineGrabR")
#   if (file.exists(file_path_huge)) {
#     
#   skip_test_if_not_possible()
#   # Issue - upload files on travis with os-osx fails, unresolved.
#   #skip_on_os("mac")
#   #try(googledrive::drive_mv("test-upload", verbose = F), silent = T)
#   name <- paste0("test-upload-", as.character(sample(1:200, 1)))
#   earthEngineGrabR:::activate_environments()
#   earthEngineGrabR:::upload_as_ft(file_path_huge, name)
#   test_upload <- googledrive::drive_find(name, verbose = F)
#   test <- try(nrow(test_upload) == 1, silent = T)
#   expect_true(test)
#   on.exit({
#     try(googledrive::drive_rm(name, verbose = F), silent = T)
#   })
#   } else {
#     skip('File for big shapefile upload test not present')
#   }
# })

test_that("test that upload_as_ft uploads geosjon test data to google drive as fusion table", {
  skip_test_if_not_possible()
  # Issue - upload files on travis with os-osx fails, unresolved.
  name <- paste0("test-upload-", as.character(sample(1:200, 1)))
  earthEngineGrabR:::activate_environments()
  earthEngineGrabR:::upload_as_ft(system.file("data/map.geojson", package = "earthEngineGrabR"), name)
  test_upload <- googledrive::drive_find(name, verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  on.exit({
    try(googledrive::drive_rm(name, verbose = F), silent = T)
  })
})


test_that("test that upload_as_ft uploads kml test data to google drive as fusion table", {
  earthEngineGrabR:::skip_test_if_not_possible()
  # Issue - upload files on travis with os-osx fails, unresolved.
  name <- paste0("test-upload-", as.character(sample(1:200, 1)))
  earthEngineGrabR:::activate_environments()
  expect_warning(earthEngineGrabR:::upload_as_ft(system.file("data/map.kml", package = "earthEngineGrabR"), name))
  test_upload <- googledrive::drive_find(name, verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  on.exit({
    try(googledrive::drive_rm(name, verbose = F), silent = T)
  })
})


test_that("test that upload_as_ft uploads with ~ in path", {
  earthEngineGrabR:::skip_test_if_not_possible()
  # Issue - upload files on travis with os-osx fails, unresolved.
  file_path_tilde <- "~/R/x86_64-pc-linux-gnu-library/3.4/earthEngineGrabR/data/segments_part.geojson"
  if (file.exists(file_path_tilde)) {
    
  skip_on_os("windows")
  skip_on_os("mac")
  
  name <- paste0("test-upload-", as.character(sample(1:200, 1)))
  earthEngineGrabR:::activate_environments()
  earthEngineGrabR:::upload_as_ft(file_path_tilde, name)
  test_upload <- googledrive::drive_find(name, verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  on.exit({
    try(googledrive::drive_rm(name, verbose = F), silent = T)
  })
  
  }
  else {
    skip('File for test was not found')
  }
})


test_that("test that upload_as_ft throws error with non valid file", {
  skip_test_if_not_possible()
  activate_environments()
  expect_error(upload_as_ft(system.file("data/not-valid.shp", package = "earthEngineGrabR"), "test-upload"))
})




test_that("test that upload_data uploads test data to google drive as fusion table and returns ID", {
  skip_test_if_not_possible()
  earthEngineGrabR:::activate_environments()
  try(googledrive::drive_mv("test-data", verbose = F), silent = T)
  test_id <- earthEngineGrabR:::upload_data(targetArea = system.file("data/test-data.shp", package = "earthEngineGrabR"), verbose = F, testCase = 'y')

  # test if file is uploaded
  test_upload <- googledrive::drive_find("test-data", verbose = F)
  test <- try(nrow(test_upload) > 0, silent = T)
  expect_true(test)

  # test if id is returned
  expect_is(test_id, "character")
  on.exit({
    try(googledrive::drive_rm("test-data", verbose = F), silent = T)
  })
})


test_that("test that upload_data reuploads data if needed", {
  earthEngineGrabR:::activate_environments()
  earthEngineGrabR:::skip_test_if_not_possible()
  try(googledrive::drive_rm("map", verbose = F), silent = T)
  
  # Issue - upload files on travis with os-osx fails, unresolved.
  earthEngineGrabR:::upload_data(system.file("data/map.geojson", package = "earthEngineGrabR"))
  test_upload <- googledrive::drive_find("map$", verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  
  earthEngineGrabR:::upload_data(system.file("data/map.geojson", package = "earthEngineGrabR"), testCase = "y")
  test_upload <- googledrive::drive_find("map$", verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  
  earthEngineGrabR:::upload_data(system.file("data/map.geojson", package = "earthEngineGrabR"), testCase = "n")
  test_upload <- googledrive::drive_find("map$", verbose = F)
  test <- try(nrow(test_upload) == 1, silent = T)
  expect_true(test)
  
  try(googledrive::drive_rm("map", verbose = F), silent = T)

})


