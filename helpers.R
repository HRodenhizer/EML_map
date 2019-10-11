library(mapview)

build_map <- function(data) {leaflet(data) %>%
    addTiles() %>%
    addMarkers() %>%
    addPopups()
} 
