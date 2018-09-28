#' process_ee_data
#' @description Starts processing on earth engine retrieves info from data product
#' @param product_info
#' @export
process_ee_data <- function(product_info) {
  activate_environments("earthEngineGrabR")
  ee_helpers = system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  source_python(file = ee_helpers)
  process_data(product_info)
} 
