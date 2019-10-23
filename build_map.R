library(sf)
library(leaflet)

data <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/Shiny/EML_map/data/EML_Sites.shp")
# data <- data %>%
#   st_transform(4326)

# st_write(data, 'C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/Shiny/EML_map/data/EML_Sites.shp')

leaflet(data) %>%
  addTiles() %>%
  addMarkers() #%>%
 # addPopups()
