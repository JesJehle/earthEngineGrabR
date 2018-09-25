library(testthat)
library(earthEngineGrabR)
# check requirements for the earthEngineGrabR and set a test environment

# test environment
## check test data on google drive and upload if neccessary

# googledrive::drive_mkdir("test-earthEngineGrabR")
# target = system.file("data/test-data.shp", package = "earthEngineGrabR")
# 
# googledrive::drive_rm("test-earthEngineGrabR")
# 
# upload_data(target = target)
#
# upload2ft(path2file = target, fileName = "test-earthEngineGrabR/test-data")

test_check("earthEngineGrabR")

#googledrive::drive_ls()
