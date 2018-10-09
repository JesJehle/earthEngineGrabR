# earthEngineGrabR


The earthEngineGrabR simplifies the acquisition of remote sensing data by building an interface between R and the Google Earth Engine. 

The interface enables the use of Earth Engine (EE) as a backend-service to request datasets from the EE Data Catalog, while providing extensive control over temporal and spatial resolution. The package not only allows to extract specific aspects of the data, like in a regular databank but enables to generate new data by an aggregation process, controlled by the user. 

Any acquiring and processing of the remote sensing data is entirely outsourced to EE with only the derived datasets, being exported and imported into R. 

This way, the package uses both, the massive public Data Catalog of available data and the processing resources supplied by EE, to request data in a strongly user-specified approach.


# Dependencies of the earthEngineGrabR

The earthEngineGrabR R package has some dependencies that need to be satisfied before the installation can run sucessfully:

## required Accounts

* [you need a Google Account](https://accounts.google.com/SignUp?hl=de)
* [sign up for Earth Engine access](https://signup.earthengine.google.com/#!/)

## required dependencies

* [install Anaconda](https://www.anaconda.com/download/)

* [install sf](https://github.com/r-spatial/sf)


Next, you can install the developmenet version of the earthEngineGrabR with:

```r
library(devtools)
install_github("JesJehle/earthEngineGrabR")
library(earthEngineGrabR)
```

# install and authentication of the earthEngineGrabR

The earthEngineGrabR has additional Python dependencies and connects to several API’s, which each require an individual, user-specific, authentication procedure.

To simplify the installation and authentication process, the earthEngineGrabR includes a function `ee_grab_install()` that installs Python dependencies and furthermore guides the user through the different authentications. Before using the earthEngineGrabR, the user has to call `ee_grab_install()`

```r
ee_grab_install()
```
After the succesfull installation the user has to log in to log in to his Google account and allow the API to access data on googles servers on the user's behalf. 
To simplify this procedure, the `ee_grab_install()`  function successively opens a browser window to log into the Google account.

If the Google account is verified and the permission is granted, the user is directed to an authentification token. This token is manually copied and pasted into the R console, which creates persistent credentials. 


## Test 

To test the earthEngineGrabR run:
```r
srtm_data <- ee_grab(data = ee_data_image(datasetID = "CGIAR/SRTM90_V4", 
                                          spatialReducer = "mean", 
                                          scale = 100, 
                                          bandSelection = "elevation"
                                          ),
                    targetArea = system.file("data/territories.shp", package = "earthEngineGrabR")
                    )

```






