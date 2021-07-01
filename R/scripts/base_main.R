# TS  -> TKGM Source
# HS  -> HGM Source
# TN  -> TKGM Name
# HN  -> HGM Name

# Improvement List:
# Produce a report of operations:
#  - file names
#  - parameters
#  - specific notes
# Check Here: https://easystats.github.io/report/

library(dplyr)
library(magrittr)
library(sf)
library(qgisprocess)

# Define Program Root Directory
root <- "/home/ziya/Desktop"

# Load Functions
source(paste0(root, "/gitHub/doktar-opt/ExampleLPPProgram/R/iterators/city_base_iterator.R"))
source(paste0(root, "/gitHub/doktar-opt/ExampleLPPProgram/R/functions/prepare_base.R"))

# Directories
join_hs <- "/home/ziya/Desktop/gitHub/common-files/Administrative/Turkey/SHP"
join_hn <- "Turkey_Administrative_L2.shp"

# Set System Locale to Turkish for Turkish characters
Sys.setlocale(locale = "Turkish")

# Get City List
city_list <- "/home/ziya/Desktop/BOUNDARY/TURKEY/2020/AGRICULTURAL/PRODUCTION/PROJECTION_INFO.csv" %>%
  data.table::fread() %>%
  dplyr::pull(City)

# Get Vector List
vector_list <- list.files(paste0(root, "/DoktarVolume/optimizasyon/yield_calculation"), ".csv$")

# Plan Multi-session
future::plan("multisession")

# Specify Corn Raster
furrr::future_map(city_list, ~ city_base_iterator(city_name = .x,
                                                   vector_list = vector_list,
                                                   vector_source = paste0(root, "/DoktarVolume/optimizasyon/yield_calculation"),
                                                   vector_dest = "/media/ziya/disk2/SATELLITE/Optimization/Parcels/base",
                                                   join_hs = join_hs,
                                                   join_hn = join_hn))
