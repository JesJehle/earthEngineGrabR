library(earthEngineGrabR)

context("Test EE request functionality")
#if (!identical(Sys.getenv("NOT_CRAN"), "false")) {
targetArea <- "users/JesJehle/eeg_min_test"

activate_environments()
#}

test_that(
  "test that get_data processes data on earth engine and exports it to drive while returning status of process",
  {
    skip_test_if_not_possible()
    
    df <- ee_data_image(
      datasetID = "CGIAR/SRTM90_V4",
      spatialReducer = "min",
      resolution = 3000,
      bandSelection = NULL
    )
    
    df$ftID <- targetArea
    earthEngineGrabR:::delete_on_drive(df$productNameFull)
    
    status <- earthEngineGrabR:::get_data(df)
    expect_named(
      status,
      c(
        "creation_timestamp_ms",
        "start_timestamp_ms",
        "name",
        "state",
        "task_type",
        "description",
        "id",
        "update_timestamp_ms"
      ),
      ignore.order = TRUE
    )
    test <-
      earthEngineGrabR:::wait_for_file_on_drive(df$productNameFull, verbose = F)
    expect_true(test)
  }
)


test_that("test that bug: OverflowError: Python int too large to convert to C long, is fixed",
          {
            skip_test_if_not_possible()
            
            df <- ee_data_image(
              datasetID = "CGIAR/SRTM90_V4",
              spatialReducer = "max",
              resolution = 3000,
              bandSelection = NULL
            )
            
            target_id <- targetArea
            
            status <- earthEngineGrabR:::request_data(df, target_id)
            expect_is(status, "character")
            
            new_df <- df
            new_df$ftID <- target_id
            
            status <- earthEngineGrabR:::get_data(new_df)
            
            expect_match(status$state, "READY")
            
            
          })





test_that("test that get_data raises a meaninfull message without crashing",
          {
            skip_test_if_not_possible()
            
            
            # wrong product ID
            df <- ee_data_image(datasetID = "CGIAR/wrong")
            df$ftID <- targetArea
            
            status <- get_data(df)
            expect_match(status, "Error")
            expect_match(status, "Image asset 'CGIAR/wrong' not found")
            
            # wrong product ID
            df <- ee_data_collection(
              datasetID = "UCSB-CHG/CHIRPS/DAILY",
              timeStart = "1950-01-01",
              timeEnd = "1955-01-01",
              spatialReducer = "mean",
              temporalReducer = "mean",
              resolution = 4000
            )
            
            df$ftID <- targetArea
            
            status <- get_data(df)
            expect_match(status, "Error")
            expect_match(status, "No images found with the given daterange")
          })



test_that("test that check_processing raises error if task failed and no valid requests left",
          {
            skip_test_if_not_possible()
            
            df <- ee_data_image(
              datasetID = "CGIAR/SRTM90_V4",
              spatialReducer = "mode",
              resolution = 0,
              bandSelection = NULL
            )
            
            ft_id <- targetArea
            
            ee_respones <-
              expect_error(expect_warning(earthEngineGrabR:::request_data(df, ft_id)))
            
          })


test_that("test that check_scale raises an error with Bands of different resolutions",
          {
            earthEngineGrabR:::skip_test_if_not_possible()
            different_res <- 'COPERNICUS/S2'
            expect_error(earthEngineGrabR:::check_scale(different_res))
          })

test_that("test that check_scale returns resolutions with bands of same resolution",
          {
            earthEngineGrabR:::skip_test_if_not_possible()
            same_res <- 'COPERNICUS/S5P/OFFL/L3_AER_AI'
            res <- earthEngineGrabR:::check_scale(same_res)
            expect_is(res, "integer")
          })

test_that("test that check_scale raises an error with non valid id", {
  earthEngineGrabR:::skip_test_if_not_possible()
  fail <- 'wrong_name'
  expect_error(earthEngineGrabR:::check_scale(fail))
})


#if (!identical(Sys.getenv("NOT_CRAN"), "false")) {

#googledrive::drive_rm("earthEngineGrabR-tmp", verbose = F)

#}
