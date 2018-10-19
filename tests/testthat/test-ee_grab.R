
#   This test tests the entire function evaluation with all dependencies. It can be used as a final test for full functionality.

context("test full ee_grab() function evaluation")
library(earthEngineGrabR)

verbose <- F

targetArea <- system.file("data/test-data.shp", package = "earthEngineGrabR")
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

  product_image <- ee_data_image(
    datasetID = "CGIAR/SRTM90_V4", 
    spatialReducer = "max", 
    scale = 3000
  )

  image_test <- ee_grab(
    targetArea = targetArea,
    data = product_image,
    verbose = verbose
  )
  expect_is(image_test, "sf")
})

test_that("test that ee_grab() works with image collections by returning the final sf object", {
  skip_test_if_not_possible()
  activate_environments()

  product_image_collection <- ee_data_collection(datasetID = "UCSB-CHG/CHIRPS/DAILY",
                                                        spatialReducer = "mean",
                                                        temporalReducer = "mean", 
                                                        timeStart = "2017-01-01",
                                                        timeEnd = "2017-02-01", 
                                                        scale = 3000, 
                                                        bandSelection = NULL)

  image_collection_test <- ee_grab(
    targetArea = targetArea,
    data = product_image_collection,
    verbose = verbose
  )
  expect_is(image_collection_test, "sf")
})

test_that("Test that ee_grab() raises an error if targetArea is not specified", {
  expect_error(ee_grab(targetArea = 123))
})


test_that("Test that band selection and naming behaves like expected", {
  
  skip_test_if_not_possible()
  activate_environments()
  
  # test band selection and naming 
  product_image <- ee_data_image(datasetID = "ESA/GLOBCOVER_L4_200901_200912_V2_3",
                                        bandSelection = "landcover", 
                                        spatialReducer = "mean",
                                        scale = 3000
                                        )
  
  image_test <- ee_grab(data = product_image,
                           targetArea = targetArea)
  
  expect_true(sum(names(image_test) %in% "landcover_s.mean") == 1)
  expect_true(sum(names(image_test) %in% "qa_s.mean") == 0)
  
  # test with no band selection
  
  product_image <- ee_data_image(datasetID =   "ESA/GLOBCOVER_L4_200901_200912_V2_3",
                                        spatialReducer = "mean",
                                        scale = 3000
  )
  
  image_test <- ee_grab(data = product_image,
                        targetArea = targetArea)
  
  expect_true(sum(names(image_test) %in% "landcover_s.mean") == 1)
  expect_true(sum(names(image_test) %in% "qa_s.mean") == 1)
  
  # test with image collections, get all bands
  product_collection <- ee_data_collection(datasetID =   "IDAHO_EPSCOR/TERRACLIMATE",
                                                  spatialReducer = "mean",
                                                  timeStart = "2000-01-01",
                                                  timeEnd = "2001-01-01",
                                                  temporalReducer = "mean", 
                                                  scale = 3000)
  
  image_test <- ee_grab(data = product_collection,
                        targetArea = targetArea)
  expect_length(names(image_test), 17)

  # select bands
  product_collection <- ee_data_collection(datasetID =   "IDAHO_EPSCOR/TERRACLIMATE",
                                                  spatialReducer = "mean",
                                                  timeStart = "2000-01-01",
                                                  timeEnd = "2001-01-01",
                                                  temporalReducer = "mean",
                                                  bandSelection = c("pdsi", "vap", "soil"),
                                                  scale = 3000
                                                  )
  
  image_test <- ee_grab(data = product_collection,
                        targetArea = targetArea)

  expect_length(charmatch(c("pdsi", "vap", "soil"), names(image_test)), 3)
  expect_length(grep(c("t.mean"), names(image_test)[2]), 1)
  expect_length(grep(c("s.mean"), names(image_test)[2]), 1)
  
  # test_wrong bandname
product_collection <- ee_data_collection(datasetID = "IDAHO_EPSCOR/TERRACLIMATE",
                                                spatialReducer = "mean",
                                                timeStart = "2000-01-01",
                                                timeEnd = "2001-01-01",
                                                temporalReducer = "mean",
                                                bandSelection = "wrong",
                                                scale = 3000
                                                )
  
  expect_warning(expect_error(ee_grab(data = product_collection,
                        targetArea = targetArea)))
  
  # one band selected
  product_collection <- ee_data_collection(datasetID =   "IDAHO_EPSCOR/TERRACLIMATE",
                                                  spatialReducer = "mean",
                                                  timeStart = "2000-01-01",
                                                  timeEnd = "2001-01-01",
                                                  temporalReducer = "mean",
                                                  bandSelection = "soil", 
                                                  scale = 3000
  )
  
  test_collection <- ee_grab(data = product_collection,
                       targetArea = targetArea)
  
  expect_length(charmatch(c("soil"), names(test_collection)), 1)
  
})























