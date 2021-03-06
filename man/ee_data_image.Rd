% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ee_products.R
\name{ee_data_image}
\alias{ee_data_image}
\title{Defines request for image data}
\usage{
ee_data_image(datasetID = "CGIAR/SRTM90_V4", spatialReducer = "mean",
  resolution = NULL, bandSelection = NULL)
}
\arguments{
\item{datasetID}{\code{string} that specifies the dataset in Earth Engine. The dataset ID can be found in the \href{link to tutorial }{snippet section} of the dataset in the Earth Engine \href{https://developers.google.com/earth-engine/datasets/}{Data Catalog}.}

\item{spatialReducer}{\code{string} that specifies the spatial aggregation of the data within the polygons of the targetArea. The spatial reducer can be one of \code{"mean", "median", "min", "max", "mode"}}

\item{resolution}{\code{integer} that controls the \href{https://developers.google.com/earth-engine/scale}{scale of analysis} in Earth Engine. The resolution controls the resolution of the data in which the computations are performed. In Earth Engine data is ingested at multiple resolutions, in an image pyramid. When you use an image, Earth Engine chooses a level of the pyramid with the closest resolution less than or equal to the resolution specified by your resolution argument and resamples (using nearest neighbour by default) as necessary. If resolution is left to NULL, the native resolution of the data is used.}

\item{bandSelection}{\code{string} or a \code{vector} of \code{strings} of bands names to select from the requested dataset. By default bandSelection is set to \code{NULL} and all bands of the dataset are used.}
}
\value{
object of class \code{list} that defines the data request for \code{ee_grab()}.
}
\description{
\code{ee_data_image()} and \code{ee_data_collection()} are used to define the requested earth enigne data for the \code{ee_grab()} function.
}
\section{Image and Image Collections in Earth Engine}{


In Earth Engine raster data is stored as an \code{Image} object. 
Images are composed of one or more bands and each band has its own name, data type, resolution, mask and projection. A time series or stack of Images is stored as an Image Collection.
To request data from an Image use \code{ee_data_image()} to define the request. 
To request data from a time series of Images stored in an Image Collection use \code{ee_data_collection()} instead.
}

