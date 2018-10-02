library(earthEngineGrabR)

context("Get data and info from earth engine")


test_that("test that get_data processes data on earth engine and exports it to drive while returning status of process", {
  skip_test_if_not_possible()
  activate_environments()
  
  df <- create_image_product(
        productID = "CGIAR/SRTM90_V4",
        productName = "test_SRTM"
        )

      df$ft_id = get_ft_id_gd("test-data")
      delete_on_drive(df$productNameFull)

  status <- get_data(df)
  test <- wait_for_file_on_drive(df$productNameFull, verbose = F)
  expect_true(test)
})


test_that("test that reguest_data processes multiple data products on earth engine and exports it to drive while returning status of process", {
  skip_test_if_not_possible()
  activate_environments()

  df <- list(
    create_image_product(
      productID = "CGIAR/SRTM90_V4",
      productName = "test_SRTM"),
    create_collection_product(
      timeStart = "2017-01-01", 
      timeEnd = "2017-01-20")
  )
  
  ft_id = get_ft_id_gd("test-data")

  status <- request_data(df, ft_id)
  test_1 <- wait_for_file_on_drive(df[[1]]$productNameFull, verbose = F)
  test_2 <- wait_for_file_on_drive(df[[2]]$productNameFull, verbose = F)
  
  expect_true(test_1 & test_2)
  expect_length(status, 2)
})




