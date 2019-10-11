### Loab libraries ###
library(shiny)
library(sf)
library(mapview)

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
  output$map <- renderPlot({
    build_map(sites)
  })
}

### Run app ###
shinyApp(ui, server)