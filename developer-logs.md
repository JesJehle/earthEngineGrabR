# today

finish readme
 * one introduction sentence
 * good example
 * how to install, authenticate
 * describe workflow.

check spelling in documentation and readme


# to Do

+ try to use permanent tokens for the httr package
+ implement parameters checks for ee_grab and create_product
+ catch error from ee servers - no images found an example
+ documentation
* website
* vignettes
+ implement tests
* clean up python files

* implement info option in ee_grab to extract formatted info about the data product if needed. -- not important

* implement export projection control
* add extensibility functionality by separating ee data manipulation and allow the embedding of external scripts
* implement manual use escape in the authorisation process, like in the httr package
* test with a list of product IDs

+ catch error no sf library
+ pass error in tryCatch installation test failed.
* installation test on windows
* build and test on Travis ??

+ refactore ee_grab_install
* adit readme, locally saved
* host package site on githup
* supress warning refresh credentials google drive package
* change dplyr::join to merge, to loose dplyr dependency


# rename functions

* rename create_image_product-> ee_data_image, 
* rename create_collection_product -> ee_data_collection .
* rename productID -> datasetID
* rename products -> data
* rename target -> targetArea

# workflow

* search for data - with earth engine data catalog
* grab data - with ee_grab(data = ee_data_*, targetArea = geo-file, 
  * requested data is defiend by list of ee_data_* functions.
  * targetArea is defiend by a path to a local geo-file
  




# rest


The interface enables the use of Earth Engine (EE) as a backend-service to request datasets from the EE Data Catalog, while providing extensive control over temporal and spatial resolution. The package not only allows to extract specific aspects of the data, like in a regular databank but enables to generate new data by an aggregation process, controlled by the user. 







