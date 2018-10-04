library(earthEngineGrabR)
context("Test create_image_product and create_collection_product")


test_that("Test that create_image_product and create_collection_product return correct output if input is valid", {
  output_image <- create_image_product(productID = "Test_xyz", spatialReducer = "mean", scale = 200)
  expect_named(output_image, c("productID", "productName", "spatialReducer", "scale", "productNameFull", "data_type", "outputFormat", "bands"))

  output_collection <- create_collection_product(productID = "Test_xyz", spatialReducer = "mean", scale = 200, temporalReducer = "sum", timeStart = "12-02-01", timeEnd = "12-03-31")
  expect_named(output_collection, c("productID", "productName", "spatialReducer", "scale", "productNameFull", "data_type", "outputFormat", "temporalReducer", "timeStart", "timeEnd", "bands"), ignore.order = T)

  output_collection_1 <- create_collection_product(timeStart = "12-02-01", timeEnd = "12-03-31")
  output_collection_2 <- create_collection_product(timeStart = "12-2-1", timeEnd = "12-3-31")
  expect_true(identical(output_collection_1, output_collection_2))
})


test_that("Test that create_image_product and create_collection_product raise appropriate errors if input is not valid", {
  expect_error(create_image_product(productID = "Test_xyz", spatialReducer = "wrong"))
  expect_error(create_image_product(productID = NULL))
  expect_error(create_image_product(productID = 2345))
  expect_error(create_image_product(scale = "wrong"))

  expect_error(create_collection_product(productID = "Test_xyz", spatialReducer = "wrong"))
  expect_error(create_collection_product(productID = NULL))
  expect_error(create_collection_product(productID = 2345))
  expect_error(create_collection_product(scale = "wrong"))
  expect_error(create_collection_product(spatialReducer = "sum"))
  expect_error(create_collection_product(timeStart = 1234))
  expect_error(create_collection_product(timeEnd = as.Date(1234)))
  expect_error(create_collection_product(timeStart = "12/02/01", timeEnd = "12/03/31"))
  expect_error(create_collection_product(timeEnd = "dfg-ff-12"))
})
