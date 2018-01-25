#Load library
#install.packages("raster")
#install.packages("rgdal", dependencies = T)
#install.packages("geojsonio", dependencies = T)
#library(raster)
#library(rgdal)
# library(geojsonio)

#Load shapefile
#setwd("~/Documents/Ms_Arbeit/Data/")
#shp <- shapefile("Strips_shapefiles/RR16StripsAlignedForFig.shp")
#print(shp)
#writeOGR(shp, dsn = 'Stripes','shp', driver='GeoJSON')
#"GeoJSON" %in% ogrDrivers()$name


library(raster)
library(rgdal)
angola <- getData(country = "CONGO", level = 0)
angola <- spTransform(angola, CRSobj = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
cs <- c(1, 1)*4000
grdpts <- makegrid(angola, cellsize = cs)
spgrd <- SpatialPoints(grdpts, proj4string = CRS(proj4string(angola)))
spgrdWithin <- SpatialPixels(spgrd)

spatialGrid_fuck <- as(spgrdWithin, "SpatialGrid")
plot(spgrdWithin)
SpatialPolygonsDataFrame(polygons)
write.asciigrid(fname = "spatial_grid", x = spatialGrid_fuck)




