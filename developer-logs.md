# today

* use testing only on travis for linux
* change cat to message

# implement features

* implement export projection control
* implement info option in ee_grab to extract formatted info about the data product if needed. -- not important
* add extensibility functionality by separating ee data manipulation and allow the embedding of external scripts
* implement manual use escape in the authorisation process, like in the httr package
* implement byYear and byMonth feature


# stabalise

* get test on Travis for osx and appveyor for windows to run.
* make tmp folder on google drive independent with unique naming - to enable parallel test runs with matrix builds
* test with a list of product IDs
* clean up python files
* refactore request data

# bugs to fix

* refresh credentials message

# documentation

* explain naming
* website with getting started section
* vignettes/tutorials
* polish project - licence, sticker, DOI

# workflow

* search for data - with earth engine data catalog
* grab data - with ee_grab(data = ee_data_*, targetArea = geo-file, 
  * requested data is defiend by list of ee_data_* functions.
  * targetArea is defiend by a path to a local geo-file
  

# issues

* If earthEngineGrabR is installed before sf, sf will use the dependencies from the conda environment and crash.
* sf::st_read() error unable to load shared object '/home/jesjehle/R/x86_64-pc-linux-gnu-library/3.4/sf/libs/sf.so':
* Jussi bug report : my working directory in a local temporary drive "\\\\ATKK/home/j/juzmakin/Documents", Anaconda does not find the compiler information: Error: Could not find a valid conda environment. 

* Error in py_run_file_impl(file, local, convert) : OverflowError: Python int too large to convert to C long

# rest

The interface enables the use of Earth Engine (EE) as a backend-service to request datasets from the EE Data Catalog, while providing extensive control over temporal and spatial resolution. The package not only allows to extract specific aspects of the data, like in a regular databank but enables to generate new data by an aggregation process, controlled by the user. 







