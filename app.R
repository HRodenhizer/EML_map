### Loab libraries ###
library(shiny)
library(sf)
library(leaflet)

### Load data ###
sites <- st_read('data/EML_Sites.shp')
plots <- st_read('data/plot_coords.shp')

### Source helper functions ###
source('helpers.R')

### User interface ###
ui <- fluidPage(
  titlePanel("EML Map"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxInput("site", label = "Sites", value = TRUE)
       
    ),
    
    mainPanel(
      leafletOutput("map")
    )
  )
)

# Server logic ----
server <- function(input, output) {
  
  icon.glyphicon <- makeAwesomeIcon(icon= 'map-marker-alt', library = 'fa', markerColor = 'lightgray', iconColor = 'black')
  pal <- colorFactor(palette = c("black", "red", 'yellow'), domain = plots$exp)
  
  output$map <- renderLeaflet({
    sitedata <- switch(
      input$site,
      'Sites' = sites
    )
    if (input$site) {
    leaflet() %>%
      addTiles() %>%
      addAwesomeMarkers(data = sitedata,
                 label = sitedata$Name,
                 icon = icon.glyphicon) %>%
      addCircles(data = plots, color = ~pal(plots$exp), radius = 0.5, label = plots$label) %>%
      addProviderTiles("Esri.WorldImagery")
    } else {
      leaflet() %>%
        addTiles() %>%
        addCircles(data = plots, color = ~pal(plots$exp), radius = 0.5, label = plots$label) %>%
        addProviderTiles("Esri.WorldImagery")
    }
  })
  
}


### Run app ###
shinyApp(ui, server)