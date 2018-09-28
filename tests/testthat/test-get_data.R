library(earthEngineGrabR)

context("Get data and info from earth engine")

test_that("test that get_data processes data on earth engine and exports it to drive while returning status of process", {
  
  skip_test_if_not_possible()
  activate_environments()
  
  df <- create_image_product(
        productID = "CGIAR/SRTM90_V4",
        productName = "test_SRTM"
        )

      df$ft_id = get_ft_id_gd("test-data")$ft_id
      delete_on_drive(df$productNameFull)

  status <- get_data(df)
  test <- wait_for_file_on_drive(df$productNameFull, verbose = F)
  expect_true(test)
})


