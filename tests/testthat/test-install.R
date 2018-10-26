library(earthEngineGrabR)

context("Installation and Environment tests")

test_that("Test that ee_grab_install passes without installation, if specified and dependencies allready installed", {
  # cannot open connection error while testing ?

  skip_test_if_not_possible()
  activate_environments()
  expect_output(ee_grab_install(clean_credentials = F, clean_environment = F))
  
})
