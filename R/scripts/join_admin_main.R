library(sf)
library(tidyverse)
library(dplyr)
library(magrittr)

# Set working directory
setwd("C:/Users/batuh/Documents/GitHub/doktar-opt/Data")

# Read Data
polies <- sf::read_sf("HGM_Ilce_Poly.gpkg")
level_id <- data.table::fread("level_names_tr_eng.csv", encoding = "UTF-8")

# Join Table
polies_id <- dplyr::left_join(polies, level_id,
                              by = "TARGET_FID",
                              copy = FALSE,
                              keep = FALSE)
# Get Column names
colnames(polies_id)

#

# Change order
polies_id %<>% dplyr::select(CityId, TARGET_FID, CityNameTr,
                             DistrictNameTr, RegionNameTr, PartNameTr,
                             CityNameEng, DistrictNameEng,
                             RegionNameEng, PartNameEng, TuikNameTr, TuikNameEng,
                             indxTr, indxEng, geom)

# Change district column name
polies_id %<>% dplyr::rename(DistrictId = TARGET_FID)

# Write Data
sf::write_sf(polies_id, "Turkey_Administrative_L2.gpkg")
