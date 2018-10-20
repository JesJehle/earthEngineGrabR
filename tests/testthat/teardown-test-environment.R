


# delete uploaded file
test_that("delete tmp files", {
  skip_test_if_not_possible()
  try(googledrive::drive_rm("test-upload", verbose = F), silent = T)
  
  temp_path <- get_temp_path(F)
  if (dir.exists(temp_path))
    unlink(temp_path, recursive = T)
})

