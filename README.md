
# earthEngineGrabR <img src='man/sticker/ee sticker_cropped.jpg' align="right" width="130" /></a>

<!-- badges: start -->

<!--[![Build Status](https://travis-ci.org/JesJehle/earthEngineGrabR.svg?branch=master)](https://travis-ci.org/JesJehle/earthEngineGrabR) --> 

[![Coverage status](https://codecov.io/gh/JesJehle/earthEngineGrabR/branch/master/graph/badge.svg)](https://codecov.io/github/JesJehle/earthEngineGrabR?branch=master) 
<!-- badges: end -->


# !!!Change in the Package due to the shut down of the Fusion Table service!!!
On December 3, Google, unfortunately, shot down the [Fusion Table service](https://support.google.com/fusiontables/answer/9551050?visit_id=637115143730978855-1704825216&rd=1), which was used by the earthEngineGrabR to upload vector data from R to GEE. Since, there is no free alternative service, a major change in package workflow was required. I used the issue to further simplify the package.

The changes are:

* Target area file needs to be uploaded manually 
* `ee_grab()` now requests only a single data product during a function call 
* The downloaded data is no longer important into R but instead saved on a user-defined location.

Although these changes are more tedious for the application, they allow a simplified and hopefully more stable installation and usage. I tried to reduce the package to its core functionalities - grab data from google earth engine in a user-defined aggregation process.

### The new earthEngineGrabR Workflow

* **Search** for dataset in Earth Engine [Data Catalog](https://developers.google.com/earth-engine/datasets/).

* **Upload** your target area to GEE with the [Asset Manager](https://developers.google.com/earth-engine/importing) of the [EE code editor](https://code.earthengine.google.com/)

* **Grab** data according to a user-defined data request from within R.

#### Search for data

Use Earth Engine's [Data Catalog](https://developers.google.com/earth-engine/datasets/) to browse and find datasets you want to grab using the earthEngineGrabR. Once you have found a dataset, use the snippet section to obtain the **dataset ID** and whether the dataset is an **image** or a **collection of images**. The snippet section consists of one line of code (don't open the link) and shows how Earth Engine loads the dataset. If it is an image, the `ee.Image(dataset-ID)` constructor is used. if it is a collection the `ee.ImageCollection(dataset-id)` constructor is used instead.

#### Upload

Use the [Asset Manager](https://developers.google.com/earth-engine/importing) of the [EE code editor](https://code.earthengine.google.com/) to manually upload your target area.
After a successful upload copy the **Asset ID**, which is simply the asset path on EE

#### Grab data

`ee_grab()` requests data from Earth Engine to your local machine. `ee_grab()` takes three arguments, `data`, `targetAreaAssetPath` and `download_path`. `data` takes a either a `ee_data_image()` or a `ee_data_collection()` functions, which define the requested data to `ee_grab()`. If the requested data is an image use `ee_data_image()`, if it's a collection use `ee_data_collection()`. `targetAreaAssetPath` takes the **Asset ID** of the uploaded target area, which defines the spatial target in which the data sould be aggregated. `download_path` specifies a path on your maschine where the requested data from EE is downloaded.


The Google Earth Engine ([GEE](https://earthengine.google.com/)) is a cloud computing platform, which offers a multi-petabyte catalog of satellite images and manipulated geospatial data products. It also provides extensive computational resources &mdash; available for scientists and developers.

The `earthEngineGrabR` is an interface between R and the [GEE](https://earthengine.google.com/), which simplifies the acquisition of remote sensing data. The R package extracts data from the [Earth Engine Data Catalog](https://developers.google.com/earth-engine/datasets/) in a user-defined target area and a user-defined aggregation process. All extractions and manipulations of the data are entirely outsourced to EE. 
As such, the package makes the massive public data catalog available to R-users with minimal technical and computational effort.

---------------------------------------------------------------------------------------------------------------------


#### Usage

The example shows how to grab the yearly precipitation sum from the [CHIRPS Daily](https://developers.google.com/earth-engine/datasets/catalog/UCSB-CHG_CHIRPS_DAILY) dataset for a shapefile of spatial polygons, in this case, some ecosystems in Africa.
To extract data from the EE Data Catalog the `earthEngineGrabR` uses `ee_grab()`.
The `ee_grab()` function grabs data from the [CHIRPS Daily](https://developers.google.com/earth-engine/datasets/catalog/UCSB-CHG_CHIRPS_DAILY) dataset according to the target area defined by the feature geometries of the territories shapefile and an aggregation process defined by `ee_data_collection()`.

First, upload the territories to EE by using the [Asset Manager](https://developers.google.com/earth-engine/importing) of the [EE code editor](https://code.earthengine.google.com/).
The path to the territories can be found by running `system.file("data/territories.shp", package = "earthEngineGrabR")` in R.
Next, request the dataset with the earthEngineGrabR

```r
library(earthEngineGrabR)
library(sf)

ee_grab(data = ee_data_collection(datasetID = "UCSB-CHG/CHIRPS/DAILY",
 spatialReducer = "mean",
 temporalReducer = "sum", 
 timeStart = "2016-01-01",
 timeEnd = "2016-12-31", 
 resolution = 200
 ),
 targetAreaAssetPath = "users/JesJehle/territories", # Use your username instead
 download_path = getwd()
 )

# read in the downloaded data with your favorit geo library 
chirps_data <- st_read('territories.geojson')
chirps_data

Simple feature collection with 53 features and 3 fields
geometry type: MULTIPOLYGON
dimension: XY
bbox: xmin: -13.71389 ymin: -25.52952 xmax: 43.10118 ymax: 16.63924
epsg (SRID): 4326
proj4string: +proj=longlat +datum=WGS84 +no_defs
First 10 features:
 id area_sqkm precipitation_s.mean_t.sum_2016.01.01_to_2016.12.31 geometry
1 40 32356 500.2795 MULTIPOLYGON (((37.76223 0....
2 29 42612 914.9900 MULTIPOLYGON (((36.58819 -1...
3 12 47000 1321.1984 MULTIPOLYGON (((37.10833 -7...
4 9 19624 572.1886 MULTIPOLYGON (((31.87845 -2...
```
The example calculates the yearly precipitation sum for 2016 and aggregates the spatial mean in the polygons of the target area. The calculations are performed on a [`resolution`](https://developers.google.com/earth-engine/scale) of 200 meters per pixel.

After a short processing time of approximately 1 -2 minutes, `ee_grab()` returns the data.

--------------------------------------------------------------------

## Requirements

The earthEngineGrabR R package has a few dependencies and requirements, which need to be satisfied before the installation can run successfully:

#### Required accounts

* [Google Account](https://accounts.google.com/SignUp?hl=de).
* [Earth Engine access](https://signup.earthengine.google.com/#!/).

#### Required dependencies

* install [Anaconda](https://www.anaconda.com/download/) (Python => 3.3)

Install the development version of the `earthEngineGrabR`:

```r
library(devtools)
install_github("JesJehle/earthEngineGrabR")
library(earthEngineGrabR)
```
-----------------------------------------------------------

## Installation

The package has additional Python dependencies and connects to several API’s, which each require an individual, user-specific, authentication procedure.

To simplify the installation and authentication process, the earthEngineGrabR includes a function `ee_grab_install()` that installs Python dependencies and guides the user through the different authentications. 

Before using the earthEngineGrabR for the first time, run `ee_grab_install()` (**you only have to do this once**)

```r
ee_grab_install()
```

#### Authentication

The earthEngineGrabR connects to 3 Google API's: 

* [Google Earth Engine](https://developers.google.com/earth-engine/) API for data acquisition and processing.
* [Google Drive](https://github.com/tidyverse/googledrive) API to download data. 
 
 To authenticate the APIs, log in to your Google account and allow the API to access data on Google servers. 
To simplify this procedure the `ee_grab_install()` function successively opens a browser window to log into the Google account.
If the Google account is verified and the permission is granted, you will be directed to an authentification token. Copy this token and paste it into the R console. 
This process will be repeated for each API. If the function runs successfully, all needed credentials are stored for further sessions and there will be no need for any further authentification.


-----------------------------------------------------------------------------------------------------------------------

## Changelog

2019-12-09

* Major changes due to the shut down of the Fusion table service


2019-09-05

* Updated Google Drive integration due to changes in the googledrive R package. 
* Fixed - Error in googledrive::drive_auth(reset = T, cache = F, verbose = F) : 
 unused arguments (reset = T, verbose = F)




