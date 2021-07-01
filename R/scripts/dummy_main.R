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

# Define Program Root Directory
root <- "/home/ziya/Desktop/SATELLITE/Optimization"

# Load Functions
source(paste0(root, "/R/city_dummy_iterator.R"))
source(paste0(root, "/R/prepare_dummy.R"))

# Directories
join_hs <- "/home/ziya/Desktop/BOUNDARY/TURKEY/2020/ADMINISTRATIVE/HGM/ILCE/GROUPED/SHP"
join_hn <- "HGK_Ilce_Poly_Join.shp"

# Set System Locale to Turkish for Turkish characters
Sys.setlocale(locale = "Turkish")

# Get City List
city_list <- "/home/ziya/Desktop/BOUNDARY/TURKEY/2020/AGRICULTURAL/PRODUCTION/PROJECTION_INFO.csv" %>%
  data.table::fread() %>%
  dplyr::pull(City)

# Get Vector List
vector_list <- list.files(paste0(root, "/Parcels/old"), ".csv$")

# Plan Multi-session
future::plan("multisession")

# Specify Corn Raster
furrr::future_map(city_list, ~ city_dummy_iterator(city_name = .x,
                                                   vector_list = vector_list,
                                                   vector_source = paste0(root, "/Parcels/old"),
                                                   vector_dest = paste0(root, "/Parcels/updated/CSV"),
                                                   join_hs = join_hs,
                                                   join_hn = join_hn))
