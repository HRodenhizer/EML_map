library(sf)
library(leaflet)
library(tidyverse)

data <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/Shiny/EML_map/data/EML_Sites.shp")
# data <- data %>%
#   st_transform(4326)

data <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/GPS/All_Points/All_Points_2017_SPCSAK4.shp")

data <- data %>%
  st_transform(4326) %>%
  filter(as.character(Type) == 'grad' | as.character(Type) == 'flux' | as.character(Type) == 'gw' | as.character(Type) == 'ww') %>%
  select(Name, Type) %>%
  st_zm() %>%
  mutate(Name = as.character(Name),
         Name = ifelse(str_detect(Name, pattern = '^grad'),
                       paste(str_sub(Name, 1, 4), str_sub(Name, 5), sep = '.'),
                       Name)) %>%
  separate(Name, c('fence', 'plot'), extra = 'merge') %>%
  mutate(fence = as.numeric(ifelse(as.character(Type) == 'ww',
                        str_sub(fence, 3),
                        fence)),
         plot = ifelse(as.character(Type) == 'flux' | as.character(Type) == 'gw',
                       str_sub(plot, 1, 1),
                       as.character(plot)),
         exp = ifelse(as.character(Type) == 'grad',
                      'Gradient',
                      ifelse(!is.na(as.numeric(plot)),
                             'CiPEHR',
                             'DryPEHR')),
         label = ifelse(exp == 'Gradient',
                        paste(exp, '/n', 'Plot: ', plot),
                        paste(exp, Type, '/n', 'Fence: ', fence, ', Plot: ', plot)))
# st_write(data, 'C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/Shiny/EML_map/data/plot_coords.shp')

leaflet(data) %>%
  addTiles() %>%
  addMarkers() #%>%
 # addPopups()


# example
shiny::runGitHub("rstudio/shiny-examples", subdir="063-superzip-example", display.mode = 'showcase')