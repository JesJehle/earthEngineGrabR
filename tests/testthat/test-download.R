library(earthEngineGrabR)

context("Download functionalities")

# test_that("Test that download_data downloads test files to from google drive", {
#   skip_test_if_not_possible()
#   activate_environments()
#   test_file <- "test-download"
# 
#   test_dir <- tempdir()
#   googledrive::drive_find(test_file, verbose = F)
#   
#   download_data(
#     filename = test_file, 
#     path = test_dir)
#   
#   
# })
#   
# 
#   list.files(test_dir)
#   unlink(test_dir, T)
#   