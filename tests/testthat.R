library(testthat)
library(earthEngineGrabR)

# check requirements for the earthEngineGrabR and set a test environment

# test the existance of all needed credentials

credentials_test <- try(test_credentials(), silent = T)
# test the installation of required python modules

module_test_conda <- test_import_ee_gdal_conda()
module_test_virtual <- test_import_ee_gdal_virtual()

module_test <- module_test_conda[[1]] | module_test_virtual[[1]]

# test environment
## check test data on google drive and upload if neccessary
  
gd_auth()
test <- googledrive::drive_find("test-earthEngineGrabR", verbose = F)
environment_test <- try(nrow(test) == 1, silent = T)

if(credentials_test & module_test & environment_test) {
 test_check("earthEngineGrabR")
} else {
  stop(paste("Testing is not possible", paste(c("credentials", "modules", "environment"), c(credentials_test, module_test, environment_test), collapse = " ")))
}
  




# googledrive::drive_mkdir("test-earthEngineGrabR")
# target = system.file("data/test-data.shp", package = "earthEngineGrabR")
# 
# googledrive::drive_rm("test-earthEngineGrabR")
# 
# upload_data(target = target)
#
# upload2ft(path2file = target, fileName = "test-earthEngineGrabR/test-data")


#googledrive::drive_ls()
