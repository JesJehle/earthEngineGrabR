library(earthEngineGrabR)
context("Test create_image_product and create_collection_product")


test_that("Test that create_image_product and create_collection_product return correct output if input is valid", {
  output_image <- create_image_product(productID = "Test_xyz", productName = "test", spatialReducer = "mean", resolution = 200)
  names(output_image)
  expect_named(output_image, c("productID","productName","spatialReducer","resolution" ,"productNameFull", "data_type", "outputFormat" ))
  
  output_image <- create_collection_product(productID = "Test_xyz", productName = "test", spatialReducer = "mean", resolution = 200, temporalReducer = "sum", timeStart = "12-02-01", timeEnd = "12-03-31")
  names(output_image)
  expect_named(output_image, c("productID","productName","spatialReducer","resolution" ,"productNameFull", "data_type", "outputFormat", "temporalReducer", "timeStart", "timeEnd"), ignore.order = T)
  })


test_that("Test that create_image_product and create_collection_product raise appropriate errors if input is not valid", {
  
  expect_error(create_image_product(productID = "Test_xyz", productName = "test", spatialReducer = "wrong"))
  expect_error(create_image_product(productID = "Test_xyz", productName = 1234))
  expect_error(create_image_product(productID = NULL))
  expect_error(create_image_product(productID = 2345))
  expect_error(create_image_product(resolution = "wrong"))
  
  expect_error(create_collection_product(productID = "Test_xyz", productName = "test", spatialReducer = "wrong"))
  expect_error(create_collection_product(productID = "Test_xyz", productName = 1234))
  expect_error(create_collection_product(productID = NULL))
  expect_error(create_collection_product(productID = 2345))
  expect_error(create_collection_product(resolution = "wrong"))
  expect_error(create_collection_product(spatialReducer = "sum"))
  expect_error(create_collection_product(timeStart = 1234))
  expect_error(create_collection_product(timeEnd = as.Date(1234)))
  expect_warning(expect_error(create_collection_product(timeEnd = "2007-56-12")))
  expect_warning(expect_error(create_collection_product(timeEnd = "dfg-ff-12")))
  
  

  })