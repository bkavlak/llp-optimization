# Function that matches city_name with Raster & Vector Files
# in a list. It expects the final version of Raster & Vector
# Files and do not check for any duplicates.

# ABBREVIATIONS
# RS  -> Raster Source
# RSC -> Raster Scope
# RD  -> Raster Destination
# RPD -> Report Destination
# UD  -> Update Destination
# VD  -> Vector Destination
# CD  -> CSV Destination
# KD  -> KML Destination
# RN  -> Raster Name
# ON  -> Output Name
# RL  -> Raster List
# VL  -> Vector List
# SN  -> Sort Number
# TS  -> TKGM Source
# HS  -> HGM Source
# TN  -> TKGM Name
# HN  -> HGM Name

# Improvement List:
#

city_dummy_iterator <- function(city_name = "AGRI",
                                  vector_list = c("AGRI_v04.csv",
                                                  "BOLU_v04.csv"),
                                  vector_source = getwd(),
                                  vector_dest = getwd(),
                                  join_hs = getwd(),
                                  join_hn = "polygon.gpkg") {
  
  # Buggy File Notifier
  print(paste0("I am here: city_extract_iterator ", city_name))
  
  # Find Raster that match with city_name
  vector_scope <- vector_list %>% as.data.frame() %>%
    dplyr::filter(stringr::str_detect(., paste0(city_name, "_"))) %>%
    dplyr::pull(.) %>%
    as.character()
  
  # Stop function if there are problems with expected inputs
  if (length(vector_scope) == 0) { print(paste0("I do not have any raster for ", city_name)) } else {
    
    # Prepare Output Name
    output_name <- paste0(city_name, "_parcel_v02.csv")
    
    # Extract Result
    prepare_dummy(city_name = city_name,
                  vector_name = vector_scope,
                  vector_source = vector_source,
                  vector_dest   = vector_dest,
                  output_name = output_name,
                  join_hs = join_hs,
                  join_hn = join_hn)
  }
}
