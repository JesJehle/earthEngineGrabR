
#   This test tests the entire function evaluation with all dependencies. It can be used as a final test for full functionality.

context("test full ee_grab() function evaluation")
library(earthEngineGrabR)

target <- system.file("data/test-data.shp", package="earthEngineGrabR")
test_that("test that ee_grab() works with images by returning the final sf object", {
  skip_test_if_not_possible()
  activate_environments()

product_image <- create_product(
  productID = "CGIAR/SRTM90_V4",
  productName = "test_SRTM"
  )

image_test <- ee_grab(
  target = target,
  resolution = 1000,
  products = product_image,
  verbose = F
  )
  expect_is(image_test, "sf")
})

test_that("test that ee_grab() works with image collections by returning the final sf object", {
  skip_test_if_not_possible()
  activate_environments()

product_image_collection <- create_product(
  productID = "GLCF/GLS_TCC",
  productName = "test_TreeCover",
  timeStart = "2000-3-20",
  timeEnd = "2005-2-20"
  )

image_collection_test <- ee_grab(
  target = target,
  resolution = 1000,
  products = product_image_collection,
  verbose = F
)
  expect_is(image_collection_test, "sf")
})
