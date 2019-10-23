### Loab libraries ###
library(shiny)
library(sf)
library(leaflet)

### Load data ###
sites <- st_read('data/EML_Sites.shp')

### Source helper functions ###
source('helpers.R')

### User interface ###
ui <- fluidPage(
  titlePanel("EML Map"),
  
  sidebarLayout(
    sidebarPanel(
      
    ),
    
    mainPanel(
      leafletOutput("map")
    )
  )
)

# Server logic ----
server <- function(input, output) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addMarkers(data = sites,
                 label = sites$Name) %>% 
      addProviderTiles("Esri.WorldImagery")
  })
  
}


### Run app ###
shinyApp(ui, server)