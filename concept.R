
# Maps -------------------------------------------------------------------------
    # Resources
        # http://www.shanelynn.ie/massive-geocoding-with-r-and-google-maps/
        # https://github.com/rCarto/photon

# - - - - -
# Setup ------------------------------------------------------------------------
# - - - - -
# Mapping
library(leaflet)
library(rMaps)
# Geocode
library(photon)
library(ggmap)
library(httr)
# Json files
library(rjson)

# - - - - -
# Input ------------------------------------------------------------------------
# - - - - -


# - - - - -
# Input ------------------------------------------------------------------------
# - - - - -
# Example
dff <- data.frame(
    address = c("237 S. WILMINGTON ST., RALEIGH, North Carolina, 27601",
         "Chuck's Burgers, Raleigh, North Carolina",
         "Bida Manda, Raeligh, North Carolina",
         "Tir Na Nog, Raleigh, North Carolina"),
    nonsense = c(0, 0 ,0 ,0)
)

# - - - - -
# Geocode ----------------------------------------------------------------------
# - - - - -

# Method 1 = photon

geotest <- geocode(dff$address, limit = 4, key = "place")

# Method 2 = Datascience kit

data <- paste0("[",paste(paste0("\"",dff$address,"\""),collapse = ","),"]")
url  <- "http://www.datasciencetoolkit.org/street2coordinates"
response <- POST(url,body = data)
json     <- fromJSON(content(response,type = "text"))
geotest2  <- do.call(rbind,sapply(json,
                                 function(x) c(long = x$longitude,lat = x$latitude)))
geotest2

# Method 3 = ggmap

# WORKING
dff$address <- as.character(dff$address)
geotest3 <- geocode(dff$address)

# - - - - -
# rMaps ------------------------------------------------------------------------
# - - - - -

# Open new map
map <- Leaflet$new()
# Center on Raleigh
map$setView(c(35.7796, -78.6382), zoom = 14)
# Set appearanec
map$tileLayer(provider = 'Acetate.terrain')
# Markers
        # Only getting these to work one at a time at the moment.....
map$marker(c(geotest2[1,"long"], geotest2[2,"lat"]))
map

# - - - - -
# leaflet ----------------------------------------------------------------------
# - - - - -
# Set up for the Url's
content <- paste(sep = "<br/>",
                 "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>")
# Map
map_leaf <- leaflet(data = geotest3) %>%
    addTiles() %>% # Map visualization
    setView(lat = 35.7796, lng = -78.6382, zoom = 14) %>% # Starting place
    addMarkers(~lon, ~lat, popup = content) # Adding in lon/lat for markers, and their content
map_leaf



