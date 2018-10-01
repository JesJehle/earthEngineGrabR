

#' request_data
#' @description Starts processing on earth engine retrieves info from data product
#' @param product_info list object created by ee_product functions
#' @param target_id String of fusion table id created by upload_data()
#' @return ee_responses for each correctly exported data product
#' @export
request_data <- function(product_info, target_id, verbose = T) {
  activate_environments("earthEngineGrabR")
  ee_helpers = system.file("Python/ee_get_data.py", package = "earthEngineGrabR")
  source_python(file = ee_helpers)
  
  ee_responses = c()
  
  # loop over data products
  
  for (i in seq_along(product_info)) {
    p = product_info[[i]]
    p$ft_id = target_id
    
    #filename <- paste0(products[[i]]$productName,".", casefold(outputFormat))
    #googledrive::drive_rm(filename, verbose = F)
    
    # make functions available
    

    # get data
    status <- get_data(p)
    
    # filename <- paste0(status$description, ".", casefold(p$outputFormat))
    
    
    #print(paste0("the projection of result is", drop))
    if (status$state == "READY") {
      if (verbose) cat("processing:", product_info[[i]]$productName, '\n')
      ee_responses[i] <- p$productNameFull
    } else {
      if (verbose) cat("Processing error on earth engine servers for: ", product_info[[i]]$productName, '\n')
    }
  }
  
  
  
return(ee_responses)
  
  } 
