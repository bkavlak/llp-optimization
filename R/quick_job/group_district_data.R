library(tidyverse)
library(dplyr)

setwd("C:/Users/batuh/Documents/GitHub/doktar-opt/ExampleLPPProgram/final/turkey_districts")
district_data <- readr::read_csv("Turkey_Optimization_L2_v04.csv")

city_data <- district_data %>%
  dplyr::select(-c("DistrictId", "DistrictName")) %>%
  dplyr::group_by(CountryId, CountryName, CityId, CityName) %>%
  dplyr::summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))

turkey_data <- city_data %>%
  dplyr::group_by(CountryId, CountryName) %>%
  dplyr::summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))

data.table::fwrite(city_data, "../turkey_cities/Turkey_Optimization_L1_v04.csv", bom = TRUE)
data.table::fwrite(turkey_data, "../turkey/Turkey_Optimization_L0_v04.csv", bom = TRUE)
