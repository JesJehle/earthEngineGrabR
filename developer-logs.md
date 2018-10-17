# today


# to Do

## Features

* implement export projection control

* implement info option in ee_grab to extract formatted info about the data product if needed. -- not important
* add extensibility functionality by separating ee data manipulation and allow the embedding of external scripts
* implement manual use escape in the authorisation process, like in the httr package

## stabilise 

* implement status request for large tasks
* clean up python files
* test with a list of product IDs
* installation test on windows
* build and test on Travis ??

## docs

* add new example data
* website
* vignettes/ tutorials
* getting started section
* explain naming


# bugs

if earthEngineGrabR is already installed and the conda environment is created an instllation of sf crashes



# workflow

* search for data - with earth engine data catalog
* grab data - with ee_grab(data = ee_data_*, targetArea = geo-file, 
  * requested data is defiend by list of ee_data_* functions.
  * targetArea is defiend by a path to a local geo-file
  




# rest


The interface enables the use of Earth Engine (EE) as a backend-service to request datasets from the EE Data Catalog, while providing extensive control over temporal and spatial resolution. The package not only allows to extract specific aspects of the data, like in a regular databank but enables to generate new data by an aggregation process, controlled by the user. 







