
#   This test tests the entire function evaluation with all dependencies. It can be used as a final test for full functionality.

context("test full ee_grab() function evaluation")
library(earthEngineGrabR)

verbose <- F

target <- system.file("data/test-data.shp", package = "earthEngineGrabR")
test_that("Test that get_data_info retrieves info of given Product ID", {
  skip_test_if_not_possible()

  # test images
  productID_image <- "CGIAR/SRTM90_V4"
  info_image <- get_data_info(productID_image)
  expect_named(info_image, c("tile", "bands", "data_type", "epsg"))

  # test image collections
  productID_collection <- "GLCF/GLS_TCC"
  info_collection <- get_data_info(productID_collection)
  expect_named(info_collection, c("range", "data_type", "epsg", "tile", "bands", "number_of_images"))
})



test_that("test that ee_grab() works with images by returning the final sf object", {
  skip_test_if_not_possible()
  activate_environments()

  product_image <- create_image_product(
    productID = "CGIAR/SRTM90_V4",
    productName = "test_SRTM"
  )

  image_test <- ee_grab(
    target = target,
    products = product_image,
    verbose = verbose
  )
  expect_is(image_test, "sf")
})

test_that("test that ee_grab() works with image collections by returning the final sf object", {
  skip_test_if_not_possible()
  activate_environments()

  product_image_collection <- create_collection_product(productName = "test_chirps")

  image_collection_test <- ee_grab(
    target = target,
    products = product_image_collection,
    verbose = verbose
  )
  expect_is(image_collection_test, "sf")
})

test_that("Test that ee_grab() raises an error if target is not spedified", {
  expect_error(ee_grab(target = 123))
})


test_that("Test that band selection and naming behaves like expected", {
  
  skip_test_if_not_possible()
  earthEngineGrabR:::activate_environments()
  
  # test band selection and naming 
  product_image <- create_image_product(
    productID =   "ESA/GLOBCOVER_L4_200901_200912_V2_3",
    productName = "test_GLOBCOVER",
    bands = "landcover", 
    spatialReducer = "mean"
  )
  
  image_test <- ee_grab(products = product_image,
                           target = target)
  
  expect_true(sum(names(image_test) %in% "landcover_mean") == 1)
  expect_true(sum(names(image_test) %in% "qa_mean") == 0)
  
  # test with no band selection
  
  product_image <- create_image_product(
    productID =   "ESA/GLOBCOVER_L4_200901_200912_V2_3",
    productName = "test_GLOBCOVER",
    spatialReducer = "mean"
  )
  
  image_test <- ee_grab(products = product_image,
                        target = target)
  
  expect_true(sum(names(image_test) %in% "landcover_mean") == 1)
  expect_true(sum(names(image_test) %in% "qa_mean") == 1)
  
  # test with image collections, get all bands
  product_collection <- create_collection_product(
    productID =   "IDAHO_EPSCOR/TERRACLIMATE",
    productName = "test_climate",
    spatialReducer = "mean",
    timeStart = "2000-01-01",
    timeEnd = "2001-01-01",
    temporalReducer = "mean"
  )
  
  image_test <- ee_grab(products = product_collection,
                        target = target)
  expect_length(names(image_test), 27)

  # select bands

  product_collection <- create_collection_product(
    productID =   "IDAHO_EPSCOR/TERRACLIMATE",
    productName = "test_climate",
    spatialReducer = "mean",
    timeStart = "2000-01-01",
    timeEnd = "2001-01-01",
    temporalReducer = "mean",
    bands = c("pdsi", "vap", "soil")
  )
  
  image_test <- ee_grab(products = product_collection,
                        target = target)

  expect_length(charmatch(c("pdsi", "vap", "soil"), names(image_test)), 3)
  
  # test_woring bandname
  
  product_collection <- create_collection_product(
    productID =   "IDAHO_EPSCOR/TERRACLIMATE",
    productName = "test_climate",
    spatialReducer = "mean",
    timeStart = "2000-01-01",
    timeEnd = "2001-01-01",
    temporalReducer = "mean",
    bands = "wrong"
  )
  
  expect_warning(expect_error(ee_grab(products = product_collection,
                        target = target)))
  
  # one band selected
  product_collection <- create_collection_product(
    productID =   "IDAHO_EPSCOR/TERRACLIMATE",
    productName = "test_climate",
    spatialReducer = "mean",
    timeStart = "2000-01-01",
    timeEnd = "2001-01-01",
    temporalReducer = "mean",
    bands = "soil"
  )
  
  test_collection <- ee_grab(products = product_collection,
                       target = target)
  
  expect_length(charmatch(c("soil"), names(test_collection)), 1)
  
})























