### Loab libraries ###
library(shiny)
library(sf)
library(leaflet)

### Load data ###
# need to change to read in one data file that contains all of the necessary data
sites <- st_read('data/EML_Sites.shp')
plots <- st_read('data/plot_coords.shp')

### Source helper functions ###
source('helpers.R')

### User interface ###
# need to add in tabs for map and data visualization
# need to create pickerInput() options rather than checkboxInput
# pickerInput() allows the user to select any, none, or all options, while checkboxInput only has one option to turn on or off
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
# need to change map update to look more like Gerardo's
# (creating the background map outside(?) of the reactive expression and using clearMarkers())
server <- function(input, output) {
  
  icon.glyphicon <- makeAwesomeIcon(icon= 'map-marker-alt', library = 'fa', markerColor = 'lightgray', iconColor = 'black')
  pal <- colorFactor(palette = c("black", "red", 'yellow'), domain = plots$exp)
  
  output$map <- renderLeaflet({
    
    sitedata <- switch(
      input$site,
      'Sites' = sites
    )
    
    l <- leaflet() %>%
      addTiles() %>%
      addCircles(data = plots,
                 color = ~pal(plots$exp),
                 radius = 0.5,
                 label = plots$label) %>%
      addProviderTiles("Esri.WorldImagery")
    
    if (input$site) {
      l %>% addAwesomeMarkers(data = sitedata,
                              label = sites$Name,
                              icon = icon.glyphicon,
                              group = 'sitegroup')
    } else {
      l
    }
  })
  
}


### Run app ###
shinyApp(ui, server)