# dependencies

* sf needs gdal to be installed for the own installation, putting sf in the description file, requires gdal to be installed on the system
* reticulate bug - To use a spedific virtual or conda environment, the environment has to be acrivated as first reticulate function. A later change is not possible ans requires a manual restart of R. 

# to Do

+ try to use permanent tokens for the httr package
* implement parameters checks for ee_grab and create_product
* dokumentation
* website
* vigniettes
* implement tests

* implement info option in ee_grab to extreact formated info about the dataproduct of needed. -- not important

* implement export projection control
* add extensibility functionality by seperating ee data manipulation and allow the embadding of external scripts
* implement manual use escape in authorisation process, like in httr package
* test with list of product IDs
