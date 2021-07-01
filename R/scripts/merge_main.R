library(readr)
library(dplyr)
library(tidyverse)
library(sf)
library(magrittr)
library(janitor)

# Define Program Root Directory
root <- "/home/ziya/Desktop/PROCESS/Optimization/scenarios"

# Source functions
source("/home/ziya/Desktop/gitHub/doktar-opt/ExampleLPPProgram/R/functions/prepare_fields.R")
source("/home/ziya/Desktop/gitHub/doktar-opt/ExampleLPPProgram/R/functions/prepare_scenario.R")

# Set program to root
setwd(root)

scenario_list <- c("scenario-1", "scenario-2", "scenario-3",
                   "scenario-4", "scenario-5")

# Set System Locale to Turkish for Turkish characters
Sys.setlocale(locale = "Turkish")

# Loop Over Scenarios to merge them within
for (sc in scenario_list) {
  
  # detect scenario number
  scenario_number <- stringr::str_split(sc, "-")[[1]][2]
  
  # Define Paths for the scenario
  single_path <- paste0("./", sc, "/results/single_coordinated")
  merge_path <- paste0("./", sc, "/results/merged")
  
  # Border Geometries
  district_borders <- sf::read_sf("/home/ziya/Desktop/gitHub/common-files/Administrative/Turkey/GPKG/Turkey_Administrative_L2.gpkg")
  city_borders <- sf::read_sf("/home/ziya/Desktop/gitHub/common-files/Administrative/Turkey/GPKG/Turkey_Administrative_L1.gpkg")
  
  # Files
  single_results <- list.files(single_path, "*.csv$")
  
  # Read Files
  single_all <- purrr::map(single_results, ~ readr::read_csv(paste0(single_path, "/", .x),
                                                             col_types = cols(
                                                               CityId = col_integer(),
                                                               DistrictId = col_integer(),
                                                               FieldId = col_integer(),
                                                               IrrigationId = col_integer(),
                                                               FieldArea = col_double(),
                                                               Percent = col_double(),
                                                               Yield = col_double(),
                                                               Price = col_double(),
                                                               Cost = col_double(),
                                                               CropName = col_character(),
                                                               Coef = col_double(),
                                                               VarName = col_character(),
                                                               VarValue = col_double(),
                                                               Profit = col_double(),
                                                               Revenue = col_double(),
                                                               WKT = col_character()
                                                             )))
  
  # Bind All Data
  merged_all <- dplyr::bind_rows(single_all)
  
  # Write Results
  data.table::fwrite(merged_all, paste0(merge_path, "/", sc, "_Fields.csv"), bom = TRUE)
  
  # Get CropNames
  crop_names <- merged_all$CropName %>% unique()
  
  # Spread Data - Profit
  spread_data_profit <- merged_all %>%
    dplyr::select(CityId, DistrictId, CropName, FieldArea, Profit, Yield) %>%
    dplyr::group_by(CityId, DistrictId, CropName) %>%
    dplyr::summarise(Yield = sum(Yield),
                     Profit = sum(Profit),
                     Area = sum(FieldArea)) %>%
    tidyr::pivot_wider(names_from = CropName, values_from = Profit) %>%
    dplyr::group_by(CityId, DistrictId) %>%
    dplyr::summarise(across(dplyr::all_of(crop_names), ~ sum(.x, na.rm = TRUE)))
  colnames(spread_data_profit)[3:length(spread_data_profit)] <- purrr::map_chr(crop_names, ~ paste0(.x, "ProfitSC", scenario_number))
  
  # Spread Data - Yield
  spread_data_yield <- merged_all %>%
    dplyr::select(CityId, DistrictId, CropName, FieldArea, Profit, Yield) %>%
    dplyr::group_by(CityId, DistrictId, CropName) %>%
    dplyr::summarise(Yield = sum(Yield),
                     Profit = sum(Profit),
                     Area = sum(FieldArea)) %>%
    tidyr::pivot_wider(names_from = CropName, values_from = Yield) %>%
    dplyr::group_by(CityId, DistrictId) %>%
    dplyr::summarise(across(dplyr::all_of(crop_names), ~ sum(.x, na.rm = TRUE)))
  colnames(spread_data_yield)[3:length(spread_data_profit)] <- purrr::map_chr(crop_names, ~ paste0(.x, "YieldSC", scenario_number))
  
  # Spread Data - Area
  spread_data_area <- merged_all %>%
    dplyr::select(CityId, DistrictId, CropName, FieldArea, Profit, Yield) %>%
    dplyr::group_by(CityId, DistrictId, CropName) %>%
    dplyr::summarise(Yield = sum(Yield),
                     Profit = sum(Profit),
                     Area = sum(FieldArea)) %>%
    tidyr::pivot_wider(names_from = CropName, values_from = Area) %>%
    dplyr::group_by(CityId, DistrictId) %>%
    dplyr::summarise(across(dplyr::all_of(crop_names), ~ sum(.x, na.rm = TRUE)))
  colnames(spread_data_area)[3:length(spread_data_profit)] <- purrr::map_chr(crop_names, ~ paste0(.x, "AreaSC", scenario_number))
  
  # Join Data
  district_join <- district_borders %>%
    dplyr::left_join(spread_data_area) %>%
    dplyr::left_join(spread_data_yield) %>%
    dplyr::left_join(spread_data_profit) %>%
    dplyr::select(-c(RegionNameTr, PartNameTr, CityNameEng, DistrictNameEng,
                     RegionNameEng, PartNameEng, TuikNameTr, TuikNameEng,
                     indxTr, indxEng))
  colnames(district_join)[3:4] <- c("CityName", "DistrictName")
  
  # Write Result on District Level
  sf::write_sf(district_join,
               paste0(merge_path, "/", sc, "_Districts.csv"),
               layer_options = c("GEOMETRY=AS_WKT", "ENCODING=UTF-8"))
  
  # Write Result on District Level
  sf::write_sf(district_join,
               paste0(merge_path, "/", sc, "_Districts_nogeom.csv"),
               layer_options = c("ENCODING=UTF-8"))
  
  # Spread Data - Profit
  spread_data_profit <- merged_all %>%
    dplyr::select(CityId, DistrictId, CropName, FieldArea, Profit, Yield) %>%
    dplyr::group_by(CityId, DistrictId, CropName) %>%
    dplyr::summarise(Yield = sum(Yield),
                     Profit = sum(Profit),
                     Area = sum(FieldArea)) %>%
    tidyr::pivot_wider(names_from = CropName, values_from = Profit) %>%
    dplyr::group_by(CityId) %>%
    dplyr::summarise(across(dplyr::all_of(crop_names), ~ sum(.x, na.rm = TRUE)))
  colnames(spread_data_profit)[2:length(spread_data_profit)] <- purrr::map_chr(crop_names, ~ paste0(.x, "ProfitSC", scenario_number))
  
  # Spread Data - Yield
  spread_data_yield <- merged_all %>%
    dplyr::select(CityId, DistrictId, CropName, FieldArea, Profit, Yield) %>%
    dplyr::group_by(CityId, DistrictId, CropName) %>%
    dplyr::summarise(Yield = sum(Yield),
                     Profit = sum(Profit),
                     Area = sum(FieldArea)) %>%
    tidyr::pivot_wider(names_from = CropName, values_from = Yield) %>%
    dplyr::group_by(CityId) %>%
    dplyr::summarise(across(dplyr::all_of(crop_names), ~ sum(.x, na.rm = TRUE)))
  colnames(spread_data_yield)[2:length(spread_data_profit)] <- purrr::map_chr(crop_names, ~ paste0(.x, "YieldSC", scenario_number))
  
  # Spread Data - Area
  spread_data_area <- merged_all %>%
    dplyr::select(CityId, DistrictId, CropName, FieldArea, Profit, Yield) %>%
    dplyr::group_by(CityId, DistrictId, CropName) %>%
    dplyr::summarise(Yield = sum(Yield),
                     Profit = sum(Profit),
                     Area = sum(FieldArea)) %>%
    tidyr::pivot_wider(names_from = CropName, values_from = Area) %>%
    dplyr::group_by(CityId) %>%
    dplyr::summarise(across(dplyr::all_of(crop_names), ~ sum(.x, na.rm = TRUE)))
  colnames(spread_data_area)[2:length(spread_data_profit)] <- purrr::map_chr(crop_names, ~ paste0(.x, "AreaSC", scenario_number))
  
  # Join Data
  city_join <- city_borders %>%
    dplyr::left_join(spread_data_area) %>%
    dplyr::left_join(spread_data_yield) %>%
    dplyr::left_join(spread_data_profit) %>%
    dplyr::select(-c(DistrictId, DistrictNameTr, RegionNameTr, PartNameTr, CityNameEng, DistrictNameEng,
                     RegionNameEng, PartNameEng, TuikNameTr, TuikNameEng,
                     indxTr, indxEng))
  colnames(city_join)[2] <- c("CityName")
  
  # Write Result on District Level
  sf::write_sf(city_join,
               paste0(merge_path, "/", sc, "_Cities.csv"),
               layer_options = c("GEOMETRY=AS_WKT", "ENCODING=UTF-8"))
  
  # Write Result on District Level
  sf::write_sf(city_join,
               paste0(merge_path, "/", sc, "_Cities_nogeom.csv"),
               layer_options = c("ENCODING=UTF-8"))
  
  
}


# Prepare Scenarios
field_frames <- purrr::map(scenario_list, ~ prepare_fields(.x))
field_frames %<>% purrr::reduce(dplyr::left_join, by = "FieldId")
field_frames %<>%
  dplyr::select(CityId.x, DistrictId.x, FieldId,
                CropNameSc1, CropNameSc2, CropNameSc3,
                CropNameSc4, CropNameSc5,
                WKT.x) %>%
  dplyr::rename(CityId = CityId.x,
                DistrictId = DistrictId.x,
                WKT = WKT.x)

# Omit NAs in the table
field_frames %<>% na.omit()
# Convert to SF and add CRS
field_frames %<>%
  sf::st_as_sf(wkt = "WKT")
sf::st_crs(field_frames) <- 4326
# Add CityName & DistrictName
field_frames %<>%
  dplyr::left_join(city_names, by = "CityId", "DistrictId") %>%
  dplyr::select(CityId, CityName, DistrictId, DistrictName,
                FieldId, CropNameSc1, CropNameSc2, CropNameSc3,
                CropNameSc4, CropNameSc5)

# Write results to GEOJSON
sf::write_sf(field_frames, "Turkey_Optimization_L3_v03.geojson")

# Read Default CSV
default_frame <- readr::read_csv("./default/TuikDefault_District.csv")

# Prepare Scenarios
scenario_frames <- purrr::map(scenario_list, ~ prepare_scenario(.x, level = "Districts"))
scenario_frames %<>% purrr::reduce(dplyr::left_join, by = c("CityId", "CityName", "DistrictId", "DistrictName"))

# Join with default
default_frame %<>%
  dplyr::left_join(scenario_frames)

data.table::fwrite(default_frame, "Turkey_Optimization_L2.csv", bom = TRUE)

# Default Data Preparation
default_frame %<>%
  dplyr::select(-c(DistrictId, DistrictName)) %>%
  dplyr::group_by(CityId, CityName) %>%
  dplyr::summarise_all(sum, na.rm = TRUE)

data.table::fwrite(default_frame, "Turkey_Optimization_L1.csv", bom = TRUE)

default_frame %<>%
  adorn_totals("row") %>%
  dplyr::filter(CityId=="Total") %>%
  dplyr::rename(CountryId = CityId,
                CountryName = CityName) %>%
  dplyr::mutate(CountryName := "Turkey",
                CountryId := 1)

data.table::fwrite(default_frame, "Turkey_Optimization_L0.csv", bom = TRUE)
