# Author: Bryan Carlson
# Contact: bryan.carlson@ars.usda.gov
# Purpose: Create JSON document for Cosmos DB DocumentDB

# Setup project
library(jqr) #https://cran.r-project.org/web/packages/jqr/vignettes/jqr_vignette.html
library(jsonlite)

setwd("C:\\Dev\\Projects\\CookEastGeospatialBoundary\\R")

# Load geojson file as text
geoJsonString <- readLines("Export/CookEastBoundary.geojson")

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
write(j, "Export/CookEastBoundaryDocument.json")