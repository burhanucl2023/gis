install.packages(c("sf", "tmap", "tmaptools", "RSQLite", "tidyverse"), 
                     repos = "https://www.stats.bris.ac.uk/R/")

library(sf)
library(tmap) 
library(tmaptools)
library(RSQLite)
library(tidyverse)
#read in the shapefile
shape_lon <- st_read("GIS_TERM1_UCL/week_1/statistical-gis-boundaries-london/statistical-gis-boundaries-london/ESRI/London_Borough_Excluding_MHW.shp")

# read in the csv
mycsv_lon <- read_csv("GIS_TERM1_UCL/week_1/fly-tipping-borough_edit.csv", 
                                     skip = 1)


shape_lon %>% 
  st_geometry() %>%
  plot()

# merge csv and shapefile
shape_lon <- shape_lon%>%
  merge(.,
        mycsv_lon,
        by.x="GSS_CODE", 
        by.y="Row Labels")

plot(shape_lon)

# set tmap to plot
tmap_mode("plot")

# have a look at the map
qtm(shape_lon, fill = "2011-12")

# write to a .gpkg
shape_lon %>%
  st_write(.,"GIS_TERM1_UCL/week_1/output_R.gpkg",
           "london_boroughs_fly_tipping",
           delete_layer=TRUE)

# connect to the .gpkg
con <- dbConnect(SQLite(),dbname="GIS_TERM1_UCL/week_1/output_R.gpkg")

# list what is in it
con %>%
  dbListTables()

# add the original .csv
con %>%
  dbWriteTable(.,
               "original_csv",
               mycsv_lon,
               overwrite=TRUE)

# disconnect from it
con %>% 
  dbDisconnect()