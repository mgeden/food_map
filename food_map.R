
# Maps -------------------------------------------------------------------------
# Resources
        # http://www.shanelynn.ie/massive-geocoding-with-r-and-google-maps/
        # hover: http://leafletjs.com/examples/choropleth.html
        # static text: https://github.com/rstudio/leaflet/blob/master/inst/examples/labels.R
# Notes
        # Sizing may be an issue using shiny widgets, thing about using
        # html + javascript + r cleaned data file instead
# Features
        # Text always present
        # Additional information displayed on hover in corner
        # Location: Select city or current location
        # Categories
# Additional Information
        # Daily hours based posted?
        # Prices
        # Have I been to or not
# Webscraping
        # Professional food critics
                # Restaurant name
                # Webpage
                # Price
                # Stars
        # Restaurant Descriptions
## Temporarily change IP address when playing with this stuff, or I might get
# banned from google....
# - - - - -
# Setup ------------------------------------------------------------------------
# - - - - -
# Mapping
library(leaflet)
# Geocode
library(ggmap)

# Manual df for proof of concept
test1 <- data.frame(
        name = c("Chuck's Burgers",
                 "Bida Manda",
                 "Nofu",
                 "The Pit"),
        address = c(
                "237 S Wilmington St, Raleigh, NC 27601",
                "222 S Blount St, Raleigh, NC 27601",
                "2014 Fairview Rd, Raleigh, NC 27608",
                "328 W Davie St, Raleigh, NC 27601")
)

# - - - - -
# Read Data File ---------------------------------------------------------------
# - - - - -
# Import Data file with restaurant names
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # sets wd
test2 <- read.csv("raw_restaurants.csv", header = TRUE)

# Make new column with name + "restaurant" for the webscaper
test2$search <- paste0(test2$name, " restuarant NC")

# Replace spaces with "+" for the google search
test2$search <- gsub(" ", "+", test2$search)
# Setup Urls
test2$url <- paste0("https://www.google.com/search?q=", test2$search, "&num=10")

# - - - - -
# Webscraper == ----------------------------------------------------------------
# - - - - -

# = = = =
# rvest
# = = = =
# Notes
        # Currently using google, may want to change to whitepages
        # Need to put everything under a function to apply to each row
        # Change ip address after a certain number of searches [complex]
library(rvest)
library(stringr)
# Setup
open_html <- read_html(url, encoding = "ISO-8859-2")
test_scrape <- open_html %>%
        #html_node("#rhs_block") %>%
        html_nodes("span.st") %>%
        html_text()
## Clean Strings
# Addresses
addresses <- gsub(".*·","",test_scrape[3]) # Remove crap in front
addresses <- gsub("\\....*","", addresses) # Remove crap behind
addresses <- gsub("^\\s+|\\s+$", "", addresses) # Remove extra white spaces
# Phone Number
phone_numbers <- substr(test_scrape[3], 1, 15)
phone_numbers <- gsub("^\\s+|\\s+$", "", phone_numbers) # Remove extra white spaces

# Hours of operation [requires a click]
        # Click -> Table -> Parse
library(RSelenium)

# Rating data [elsewhere]

# Menu / Website [this may be tricky, leave for later]

# = = = =
# RCurl
# = = = =
library(RCurl)
library(XML)
# This part worked!
site <- getForm("http://www.google.com/search", hl = "en", lr = "",
                q = "bida manda restaurant", btnG = "Search")
htmlTreeParse(site)

# - - - - -
# Geocode: ggmap ---------------------------------------------------------------
# - - - - -

# WORKING
dff$address <- as.character(dff$address)
geotest <- geocode(dff$address)

# - - - - -
# Geocode: rydn ----------------------------------------------------------------
# - - - - -
#$ NOT CURRENTLY WORKING, BUT USES YAHOO
library(rydn)
geotest2 <- lapply(test1$address, function(x){
        tmp <- find_place(x, commercial = FALSE,
                        key = "GET A KEY",
                        secret = "GET SECRET CODE")
        # this is the lazy way to do this, in a few cases more than one result is
        # provided and I have not looked into the details so I'm picking the first
        tmp <- tmp[1 ,c("latitude", "longitude")]

})
geocodes <- do.call("rbind", geotest2) %>%
        rename(lat = latitude, lon = longitude) %>%
        mutate(address = test1$address)
# - - - - -
# Acquire User Geolocation -----------------------------------------------------
# - - - - -
# Requires shiny app, needs to be in ui.R script....it might be time to learn
        # some java script....
    # https://github.com/AugustT/shiny_geolocation



# - - - - -
# leaflet ----------------------------------------------------------------------
# - - - - -
# Set up for the Url's, use for popup name
content <- paste(sep = "<br/>",
                 "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>")
# Map
map_leaf <- leaflet(data = geotest) %>%
    addTiles() %>% # Map visualization
    setView(lat = 35.7796, lng = -78.6382, zoom = 14) %>% # Starting place
    addMarkers(~lon, ~lat, popup = dff$name) # Adding in lon/lat for markers, and their content
map_leaf



