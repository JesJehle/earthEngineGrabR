# earthEngineGrabR

The earthEngineGrabR package is supposed to provide an interface of R and the Google Earth Engine to acquire geodata for environmental system modelling. This Interface is supposed to extract data from the Earth Engine data catalogue while providing extensive control over temporal and spatial resolution. The package not only allows to extract specific aspects of the data, like in a regular databank but enables to generate new data by an aggregation process, controlled by the user. This way, the package uses both, the massive public data catalogue of available data products and the processing resources supplied by the Google Earth Engine, to extract data in a strongly user-specified approach.


## Dependencies and installation of the earthEngineGrabR


The earthEngineGrabR R package has some dependencies that need to be satisfied before the installation can run sucessfully:

* [you need a Google Account](https://accounts.google.com/SignUp?hl=de)
* [sign up for Earth Engine access](https://signup.earthengine.google.com/#!/)
* [you need a Python version > 2.7, with PYTHONPATH set](https://www.python.org/downloads/)

Next, you can install the earthEngineGrabR with:

```r
library(devtools)
install_github("earthEngineGrabR")
library(earthEngineGrabR)
```
