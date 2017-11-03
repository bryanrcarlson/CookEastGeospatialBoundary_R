# Author: Bryan Carlson
# Contact: bryan.carlson@ars.usda.gov
# Purpose: Remove projection from shapefile and output as geojson

# Setup project
library(rgdal)
library(geojsonio)
library(jqr)

setwd("C:\\Dev\\Projects\\CookEastGeospatialBoundary\\R")

# Load shapefile and check projection
cookeastarea <- readOGR("Input/cookeastarea", "CafCookEastArea")
proj4string(cookeastarea)

# Remove projection
WGS84 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
cookeastarea.wgs84 <- spTransform(cookeastarea, WGS84)

# Write json file
#writeOGR(cookeastarea.wgs84, "Export/CookEastBoundary.geojson", layer="boundary", driver="GeoJSON")

# Test written file
#geojson.test <- readOGR(dsn = "Export/CookEastBoundary.geojson", layer = "boundary")
#plot(geojson.test)

# Convert to json, then make it a single feature instead of feature collection
fc <- geojson_json(cookeastarea.wgs84)
f <- jq(unclass(fc), ".features[]")

# Clean up unwanted attributes
# Using jdr package: https://cran.r-project.org/web/packages/jqr/vignettes/jqr_vignette.html
f <- f %>% del(id)
f <- f %>% del(properties.Id)
f <- f %>% del(properties.Acres)
f <- f %>% del(properties.Area)
f <- f %>% del(properties.Perimeter)
f <- f %>% del(properties.Hectares)

# Write the file
write(f, "Export/CookEastBoundary.geojson")

# Test written file
geojson.test <- readOGR(dsn = "Export/CookEastBoundary.geojson")
plot(geojson.test)