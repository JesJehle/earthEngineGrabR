#install.packages("sf")
#library("tidyverse")
#library(plyr)
#library(jsonlite)
#library(data.table)
library(GEE2R)
library(testthat)
library(googledrive)
#install_github("r-spatial/sf")
library(sf)
library(ggplot2)
library(jsonlite)



info <- get_data()



download_data(info, path = "./example")

data <- st_read("./example")

drive_find()
drive_rm("exampleFile.geojson")




names(spdf_fortified)
ggplot() +
  geom_polygon(data = spdf_fortified, aes(fill = piece, x = long, y = lat, group = group)) +
  theme_void() +
  coord_map()



