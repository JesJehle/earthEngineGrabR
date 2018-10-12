
  
# earthEngineGrabR

The Google Earth Engine ([GEE](https://earthengine.google.com/)) is a cloud computing platform, which offers a multi-petabyte catalog of satellite images and manipulated geospatial data products. It also provides extensive computational resources &mdash;	 available for scientists and developers.

The `earthEngineGrabR` is an interface between R and the [GEE](https://earthengine.google.com/), which simplifies the acquisition of remote sensing data. The R package extracts data from the [Earth Engine Data Catalog](https://developers.google.com/earth-engine/datasets/) in a user-defined target area and a user-defined aggregation process. All extractions and manipulations of the data are entirely outsourced to EE. The user obtains an analysis-ready dataset, locally saved and directly imported into R. 
As such, the package makes the massive public data catalog available to R-users with minimal techincal and computational effort.


---------------------------------------------------------------------------------------------------------------------


#### Usage

The example shows how to grab the yearly precipitation sum from the [CHIRPS Daily](https://developers.google.com/earth-engine/datasets/catalog/UCSB-CHG_CHIRPS_DAILY) dataset for a shapefile of spatial polygons, in this case some ecosystems in Africa.
To extract data from the EE Data Catalog the `earthEngineGrabR` uses `ee_grab()`.
The `ee_grab()` function grabs data from the [CHIRPS Daily](https://developers.google.com/earth-engine/datasets/catalog/UCSB-CHG_CHIRPS_DAILY) dataset according to the target area defined by the feature geometries of the territories shapefile and an aggregation process defined by `ee_data_collection()`.
```r
library(earthEngineGrabR)

chirps_data <- ee_grab(data = ee_data_collection(datasetID = "UCSB-CHG/CHIRPS/DAILY",
                                                 spatialReducer = "mean",
                                                 temporalReducer = "sum", 
                                                 timeStart = "2016-01-01",
                                                 timeEnd = "2016-12-31", 
                                                 scale = 200
                                                 ),
                       targetArea = system.file("data/territories.shp", package = "earthEngineGrabR")
                      )

chirps_data

Simple feature collection with 53 features and 3 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: -13.71389 ymin: -25.52952 xmax: 43.10118 ymax: 16.63924
epsg (SRID):    4326
proj4string:    +proj=longlat +datum=WGS84 +no_defs
First 10 features:
   id area_sqkm precipitation_s.mean_t.sum_2016.01.01_to_2016.12.31                       geometry
1  40     32356                                            500.2795 MULTIPOLYGON (((37.76223 0....
2  29     42612                                            914.9900 MULTIPOLYGON (((36.58819 -1...
3  12     47000                                           1321.1984 MULTIPOLYGON (((37.10833 -7...
4   9     19624                                            572.1886 MULTIPOLYGON (((31.87845 -2...
```
The example calculates the yearly precipitation sum for 2016 and aggregates the spatial mean in the polygons of the target area. The calculations are performed on a [`scale`](https://developers.google.com/earth-engine/scale) of 200 meters per pixel.

After a short processing time of approximately 1 -2 minutes, `ee_grab()` returns the data.

--------------------------------------------------------------------

## Requirements

The earthEngineGrabR R package has a few dependencies requirements, which need to be satisfied before the installation can run successfully:

#### Required accounts

* [Google Account](https://accounts.google.com/SignUp?hl=de).
* sign up for [Earth Engine access](https://signup.earthengine.google.com/#!/).

#### Required dependencies

* install [Anaconda](https://www.anaconda.com/download/) (Python => 2.7)
* install [sf](https://github.com/r-spatial/sf)

Install the development version of the `earthEngineGrabR`:

```r
library(devtools)
install_github("JesJehle/earthEngineGrabR")
library(earthEngineGrabR)
```
-----------------------------------------------------------

## Installation

The package has additional Python dependencies and connects to several API’s, which each require an individual, user-specific, authentication procedure.

To simplify the installation and authentication process, the earthEngineGrabR includes a function `ee_grab_install()` that installs Python dependencies and furthermore guides the user through the different authentications. 

Before using the earthEngineGrabR for the first time, run `ee_grab_install()` (**you only have to do this once**)

```r
ee_grab_install()
```

#### Authentication

The earthEngineGrabR connects to 3 Google API's: 

* [Google Fusion Table](https://www.gdal.org/drv_gft.html) API to upload data. 
* [Google Earth Engine](https://developers.google.com/earth-engine/) API for data aquisition and processing.
* [Google Drive}](https://github.com/tidyverse/googledrive) API to download data. 
 
 To authenticate the APIs, log in to your google account and allow the API to access data on googles servers. 
To simplify this procedure the `ee_grab_install()` function successively opens a browser window to log into the Google account.
If the Google account is verified and the permission is granted, you will be directed to an authentification token. Copy this token and paste it into the R console. 
This process will be repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there will be no need for any further authentification.

To test the installation run:

```r
srtm_data <- ee_grab(data = ee_data_image(datasetID = "CGIAR/SRTM90_V4", 
                                          spatialReducer = "mean", 
                                          scale = 100, 
                                          bandSelection = "elevation"
                                          ),
                    targetArea = system.file("data/territories.shp", package = "earthEngineGrabR")
                    )

```
--------------------------------------------------
### The earthEngineGrabR Workflow

* **Search** for dataset in Earth Engine [Data Catalog](https://developers.google.com/earth-engine/datasets/) .

* **Grab** data according to a user defines data reuquest.

#### Search for data

Use Earth Engine's [Data Catalog](https://developers.google.com/earth-engine/datasets/) to browse and find datasets you want to grab using the earthEngineGrabR. Once you have found a dataset, use the snippet section to obtain the **dataset ID** and whether the dataset is an **image** or a **collection of images**. The snippet section consists of one line of code (don't open the link) and shows how Earth Engine loads the dataset. If it is an image, the `ee.Image(dataset-ID)` constructor is used. if it is a collection the `ee.ImageCollection(dataset-id)` constructor is used instead.

#### Grab data

`ee_grab()` requests and imports data from Earth Engine to R. `ee_grab()` takes two arguments, `data` and `targetArea`. `data` takes a single or a list of `ee_data_image()` and `ee_data_collection()` functions, which define the requested data to `ee_grab()`. If the requested data is an image use `ee_data_image()`, if it's a collection use `ee_data_collection()`. `targetArea` takes a path to a local geo-file, which defines the spatial target in which the data sould be aggregated.


