library(sf)
library(leaflet)
library(tidyverse)
library(schoolmath)

data <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/Shiny/EML_map/data/EML_Sites.shp")
# data <- data %>%
#   st_transform(4326)

# plots <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/GPS/All_Points/Site_Summary_Shapefiles/plot_coordinates_from_2017.shp")
ww <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/GPS/All_Points/Site_Summary_Shapefiles/water_wells.shp")
sites <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/GPS/All_Points/Site_Summary_Shapefiles/Sites.shp")
plots <- st_read("C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/GPS/All_Points/All_Points_2017_SPCSAK4.shp")

# compile data
# most plot information
plots_format <- plots %>%
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
         block = ifelse(fence <= 2,
                        'A',
                        ifelse(fence <= 4,
                               'B',
                               'C')),
         site = ifelse(as.character(Type) == 'grad',
                      'Gradient',
                      ifelse(!is.na(as.numeric(plot)),
                             'CiPEHR',
                             'DryPEHR')),
         treatment = ifelse(site == 'CiPEHR' & Type != 'ww',
                            ifelse(plot == '2' | plot == '4',
                                   'Control',
                                   ifelse(plot == '1' | plot == '3',
                                          'Air Warming',
                                          ifelse(plot == '6' | plot == '8',
                                                 'Soil Warming',
                                                 'Air & Soil Warming'))),
                            ifelse(site == 'DryPEHR' & Type != 'ww',
                                   ifelse(plot == 'a',
                                          'Control',
                                          ifelse(plot == 'b',
                                                 'Drying',
                                                 ifelse(plot == 'c',
                                                        'Warming',
                                                        'Drying & Warming'))),
                                   ifelse(site == 'Gradient',
                                          ifelse(as.numeric(plot) <= 12,
                                                 'Extensive',
                                                 ifelse(as.numeric(plot) <= 24,
                                                        'Moderate',
                                                        'Minimal')),
                                          ifelse(plot == '1' | plot == '2' | plot == '2.5',
                                                 'Control',
                                                 ifelse(plot == 'bn' | plot == 'bs',
                                                        'Drying',
                                                        ifelse(plot == '3' | plot == '4' | plot == '4.5',
                                                               'Soil Warming',
                                                               'Drying & Soil Warming')))))),
label = ifelse(site == 'Gradient',
               paste(site, '/n', 'Plot: ', plot),
                        paste(site, Type, '/n', 'Fence: ', fence, ', Plot: ', plot)),
type = as.character(Type)) %>%
  select(site, type, block, fence, plot, treatment, label)

# 2017 water wells
ww_format <- ww %>%
  st_zm() %>%
  st_transform(4326) %>%
  filter(str_detect(Name, pattern = '17')) %>%
  separate(Name, c('fence', 'plot1', 'plot2')) %>%
  mutate(fence = as.numeric(str_sub(fence, start = 3)),
         plot = as.numeric(paste(plot1, plot2, sep = '.')),
         block = ifelse(fence <= 2,
                        'A',
                        ifelse(fence <= 4,
                               'B',
                               'C')),
         site = 'CiPEHR',
         type = 'ww',
         label = paste(site, type, '/n', 'Fence: ', fence, ', Plot: ', plot),
         treatment = ifelse(plot < 5,
                            'Control',
                            'Soil Warming')) %>%
  select(site, type, block, fence, plot, treatment, label)

# general site locations
sites_format <- sites %>%
  st_zm() %>%
  st_transform(4326) %>%
  rbind.data.frame(filter(., Exp == 'CiPEHR') %>% mutate(Exp = 'DryPEHR')) %>%
  mutate(fence = NA,
         plot = NA,
         label = ifelse(Exp == 'Gradient',
                        paste(Exp, Block, sep = ' '),
                        paste(Exp, 'Block ', Block)),
         type = 'site',
         treatment = NA) %>%
  select(site = Exp, type, block = Block, fence, plot, treatment, label)

data <- plots_format %>%
  rbind.data.frame(ww_format, sites_format)
  
# st_write(data, 'C:/Users/Heidi Rodenhizer/Documents/School/NAU/Schuur Lab/Shiny/EML_map/data/data.shp')

leaflet(data) %>%
  addTiles() %>%
  addMarkers() #%>%
 # addPopups()


# example
shiny::runGitHub("rstudio/shiny-examples", subdir="063-superzip-example", display.mode = 'showcase')
