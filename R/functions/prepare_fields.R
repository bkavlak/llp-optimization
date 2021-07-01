# It merges all scenarios
prepare_fields <- function(sc = "scenario-1",
                           level = "Fields"){
  
  # Detect Scenario Path
  merge_path <- paste0("./", sc, "/results/merged")
  file_name <- paste0(sc, "_", level, ".csv")
  
  # Detect Scenario Number
  sc_number <- stringr::str_split(sc, "-")[[1]][2]
  
  # Read Parcel Data
  scenario_fields <- readr::read_csv(paste0(merge_path, "/", file_name),
                                     col_types = cols_only(
                                       CityId = col_integer(),
                                       DistrictId = col_integer(),
                                       FieldId = col_integer(),
                                       FieldArea = col_double(),
                                       CropName = col_character(),
                                       WKT = col_character()
                                     ))
  
  # Subset and Change Crop Name column
  scenario_fields %<>%
    dplyr::select(c(CityId, DistrictId, FieldId, FieldArea, CropName, WKT)) %>%
    dplyr::rename(!!dplyr::sym(paste0("CropNameSc", sc_number)) := CropName)
  
  return(scenario_fields)
  
}