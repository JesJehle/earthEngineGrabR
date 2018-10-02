


#' get_product_info
#' @description Retrives Metadata of data product
#' @param product_id String of the product id
#' @param path String, specifieng the path for the medata
get_product_info <- function(prodct_id, path) {
  activate_environments()
  ee <- import("ee")
  ee$Initialize()
  info <- ee$Image("CGIAR/SRTM90_V4")$getInfo()

}


#product_info <- get_data_info(p$productID)

# if(verbose) {
#   for(pr in seq_along(product_info)) {
#     cat(paste0(names(product_info)[pr], ": ", product_info[pr],"\n"))
#   }
# }
# 
