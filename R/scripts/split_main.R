library(dplyr)
library(magrittr)
library(stringr)
setwd("/home/ziya/Desktop/PROCESS/Optimization/scenarios/scenario-1/variable-coefficients/base")

city_list <- list.files(".", "*.csv$")

# It takes all files and split them according to their DistrictId -- PROBLEMATIC
split_district <- function(city_file){
  
  city_data <- readr::read_csv(city_file)
  city_idc <- stringr::str_split(city_file, pattern = "_")[[1]][[2]]
  city_id <- stringr::str_split(city_idc, pattern = "\\.")[[1]][[1]] %>% as.numeric()
  city_data %<>% dplyr::filter(CityId == city_id)
  district_id_list <- city_data$DistrictId %>% unique()
  city_file_name <- stringr::str_split(city_file, pattern = "\\.")[[1]][[1]]
  
  for (district_id in district_id_list){
    
    district_data <- city_data %>% dplyr::filter(DistrictId == district_id)
    data.table::fwrite(district_data, paste0("../district/", city_file_name, "_", district_id, ".csv"), bom = TRUE)
    
  }
}

future::plan("multisession")
furrr::future_map(city_list, split_district)
# It takes all files and split them according to their DistrictId -- PROBLEMATIC

# Bind all rows of all base files
read_all <- purrr::map(city_list, ~ readr::read_csv(.x))
all_base <- dplyr::bind_rows(read_all)

# Split Function for City Separator
split_city <- function(city_id, data){
  # Subset data
  subset_data <- data %>% dplyr::filter(CityId == city_id)
  # Write data
  data.table::fwrite(subset_data, paste0("./updated/DoktarVariableBase_", city_id, ".csv"), bom = TRUE)
  
}


all_base %<>% na.omit()
city_id_list <- unique(all_base$CityId)

for (city_id in city_id_list){
  
  split_city(city_id, all_base)
  
}


