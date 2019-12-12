### Load libraries ###
library(shiny)
library(sf)
library(leaflet)
library(shinyWidgets)

### Load data ###
data <- st_read('data/data.shp')

# find the geographical center of the sites (more or less) to set the view of the map
center <- data %>%
  filter(type == 'site' & (site == 'CiPEHR' | site == 'Gradient')) %>%
  st_coordinates() %>%
  as.data.frame() %>%
  summarise(X = mean(X),
            Y = mean(Y))

### Source helper functions ###
# source('helpers.R')

### User interface ###
# need to add in tabs for map and data visualization
# need to create pickerInput() options rather than checkboxInput
# pickerInput() allows the user to select any, none, or all options, while checkboxInput only has one option to turn on or off
ui <- fluidPage(
  titlePanel("EML Map"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("type",
                         label = "Plot Type",
                         choices = c('Flux Plots' = 'flux', 'Gas Well Plots' = 'gw', 'Water Wells' = 'ww', 'Gradient' = 'grad', 'Sites' = 'site'),
                         selected = c('site'))
      
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
  
  # select correct data
  plot_data <- reactive({
    
    data <- data %>%
      filter(type %in% input$type) %>%
      mutate(radius = ifelse(type == 'site',
                             10,
                             5))
    
    # Conditional so that app does not crash with empty data.frame
    if(nrow(data) == 0)
      return()
    else
      return(data)
    
    })
  
  # icon.glyphicon <- makeAwesomeIcon(icon= 'map-marker-alt', library = 'fa', markerColor = 'lightgray', iconColor = 'black')
  pal <- colorFactor(palette = c("yellow", "red", 'green', 'black', 'blue'), domain = unique(data$type))
  
  output$map <- renderLeaflet({
    
    leaflet() %>%
      setView(center[1, 1], center[1, 2], zoom = 14) %>%
      addTiles() %>%
      addProviderTiles("Esri.WorldImagery")
    
  })
  
  observe({

    if (is.null(plot_data())) return(leafletProxy("map") %>%
                                           clearMarkers())
    leafletProxy("map") %>%
      clearMarkers() %>%
      addCircleMarkers(data = plot_data(),
                       lng = ~st_coordinates(plot_data())[,1],
                       lat = ~st_coordinates(plot_data())[,2],
                       color = '#000000',
                       fillColor = ~pal(plot_data()$type),
                       radius = ~plot_data()$radius,
                       weight = 2)
  })
  
}


### Run app ###
shinyApp(ui, server)