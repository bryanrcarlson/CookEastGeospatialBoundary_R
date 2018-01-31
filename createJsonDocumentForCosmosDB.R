# Author: Bryan Carlson
# Contact: bryan.carlson@ars.usda.gov
# Purpose: Remove projection from shapefile and output as geojson

# Setup project
library(rgdal)
library(geojsonio)
library(jqr)
library(jsonlite)

setwd("C:\\Dev\\Projects\\CookEastGeospatialBoundary\\R")

# Load shapefile and check projection
cookeastarea <- readOGR("Input/cookeastarea", "CafCookEastArea")
proj4string(cookeastarea)

# Remove projection
WGS84 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
cookeastarea.wgs84 <- spTransform(cookeastarea, WGS84)

# -- new method

drops <- c("Area", "Perimeter", "Acres", "Hectares")
cookeastarea.wgs84.clean <- cookeastarea.wgs84[,!(names(cookeastarea.wgs84) %in% drops)]

# Write the file
date.today <- format(Sys.Date(), "%Y%m%d")
write.path.geojson <- paste("Output/CookEastBoundary_", date.today, ".geojson", sep = "")
geojson_write(cookeastarea.wgs84.clean, file = write.path.geojson, precision = 6)

# Test written file
geojson.test <- readOGR(dsn = write.path.geojson)
plot(geojson.test)

# ---- Create json doc for cosmos db
# Load geojson file as text
geoJsonString <- readLines(write.path.geojson)

jstring <- paste('{
                 "partitionKey": "CookEast_Boundary_Boundary",
                 "id":           "CookEast_Boundary_20171106",
                 "type":         "Boundary",
                 "name":         "Boundary",
                 "schemaVersion":"1.0.0",
                 "metadataId":   "CookEastGeospatialFieldBoundary",
                 "fieldId":      "CookEast",
                 "location":     ',geoJsonString,'
                 }')

j <- jq(jstring, ".")
validate(j)

# Write the file
write.path.json <- paste("Output/CookEastBoundaryDocument_", date.today, ".json", sep = "")
write(j, write.path.json)