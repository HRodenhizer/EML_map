library(leaflet)

build_map <- function(data) {
  leaflet(data) %>%
    addTiles() %>%
    addMarkers()
} 
