
library(googledrive)


#   credential_name_to_test = "gd-credentials.rds"
#   delete_credentials(credentials_root, credential_name_to_test)
#   run_gd_auth(credential_path = credentials_root)
#   
# test_that("test that run_gd_oauth creates credentials in credentials root dir", {
#   skip_test_if_not_possible()
#   credentials_test <- test_credentials(credentials = credential_name_to_test)
#   expect_true(credentials_test)
# })

# run_ee_oauth and run_ft_oauth cause errors during test run cause of readline function that canot be evalueted without a evaluation stop.


test_that("test that test_credentials work as expacted",  {
  skip_test_if_not_possible()
  
  activate_environments()
  credentials_root <- get_credential_root()

  # expect true if all credentials exists
  credentials_test <- test_credentials()
  expect_true(credentials_test)
  # expect true if one exists
  credentials_test <- test_credentials(credentials = "credentials")
  expect_true(credentials_test)
  # expect false if name not exist
  credentials_test <- test_credentials(credentials = "test")
  expect_false(credentials_test)
  # expect error if with_error argument true and name not exists
  expect_error(test_credentials(credentials = "test", with_error = T, silent_match = T))

})




