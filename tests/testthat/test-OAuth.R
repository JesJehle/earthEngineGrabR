library(earthEngineGrabR)
context("OAuth functionality")


# run_ee_oauth and run_ft_oauth cause errors during test run cause of readline function that canot be evalueted without a evaluation stop.

test_that("test that test_credentials work as expacted", {
  skip_test_if_not_possible()
  # expect true if all credentials exists
  credentials_test <- test_credentials()
  expect_true(credentials_test)
  # expect true if one exists
  credentials_test <- test_credentials(credentials = "credentials")
  expect_true(credentials_test)
  # expect error if with_error argument true and name not exists
  expect_error(test_credentials(
    credentials = "test",
    with_error = T,
    silent_match = T
  ))
})


test_that("test that activate_environment behaves like expacted", {
  skip_test_if_not_possible()
  expect_error(earthEngineGrabR:::activate_environments("wrong_name"))
  
})

test_that("test that get_credentials_root behaves like expected", {
  skip_test_if_not_possible()
  
  path <- get_credential_root()
  expect_true(dir.exists(path))
  
})
