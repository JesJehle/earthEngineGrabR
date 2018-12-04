library(earthEngineGrabR)
context("Test ee_data_image and ee_data_collection")


test_that("Test that ee_data_image and ee_data_collection return correct output if input is valid", {
  # skip_test_if_not_possible()
  
  output_image <- ee_data_image(datasetID = "Test_xyz", spatialReducer = "mean", resolution = 200)
  expect_named(output_image, c("datasetID", "productName", "spatialReducer", "resolution", "productNameFull", "data_type", "outputFormat", "bandSelection"))

  output_collection <- ee_data_collection(datasetID = "Test_xyz", spatialReducer = "mean", resolution = 200, temporalReducer = "sum", timeStart = "12-02-01", timeEnd = "12-03-31")
  expect_named(output_collection, c("datasetID", "productName", "spatialReducer", "resolution", "productNameFull", "data_type", "outputFormat", "temporalReducer", "timeStart", "timeEnd", "bandSelection"), ignore.order = T)

  output_collection_1 <- ee_data_collection(timeStart = "12-02-01", timeEnd = "12-03-31")
  output_collection_2 <- ee_data_collection(timeStart = "12-2-1", timeEnd = "12-3-31")
  expect_true(identical(output_collection_1, output_collection_2))
})


test_that("Test that ee_data_image and ee_data_collection raise appropriate errors if input is not valid", {
  # skip_test_if_not_possible()
  
  expect_error(ee_data_image(datasetID = "Test_xyz", spatialReducer = "wrong"))
  expect_error(ee_data_image(datasetID = NULL))
  expect_error(ee_data_image(datasetID = 2345))
  expect_error(ee_data_image(resolution = "wrong"))
  expect_silent(ee_data_image(resolution = NULL))
  expect_error(ee_data_image(bandSelection = list("string", 1)))
  expect_error(ee_data_image(bandSelection = 1))
  expect_error(ee_data_image(bandSelection = c(1, 4)))
  expect_error(ee_data_collection(datasetID = "Test_xyz", spatialReducer = "wrong"))
  expect_error(ee_data_collection(datasetID = NULL))
  expect_error(ee_data_collection(datasetID = 2345))
  expect_error(ee_data_collection(resolution = "wrong"))
  expect_silent(ee_data_collection(resolution = NULL))
  expect_error(ee_data_collection(spatialReducer = "sum"))
  expect_error(ee_data_collection(timeStart = 1234))
  expect_error(ee_data_collection(timeEnd = as.Date(1234)))
  expect_error(ee_data_collection(timeStart = "12/02/01", timeEnd = "12/03/31"))
  expect_error(ee_data_collection(timeStart = "2015-01-01", timeEnd = "2015-01-01"))
  expect_error(ee_data_collection(timeEnd = "dfg-ff-12"))
  expect_error(ee_data_collection(bandSelection = list("string", 1)))
  expect_error(ee_data_collection(bandSelection = 1))
  expect_error(ee_data_collection(bandSelection = c(T, F)))
})
