# It add WKT column from base files
coordinate_result <- function(district_result = "scenario-1_optimization_result_1_51.csv",
                              result_source = "./scenario-1/results/single",
                              base_source = "./scenario-1/variable-coefficients/base",
                              base_name = "DoktarVariableBase_1.csv",
                              output_dest = "./scenario-1/results/single_coordinated",
                              city_id = 1,
                              scenario_name = "scenario-1"){
  
  # Get District Id
  district_id <-  stringr::str_split(district_result, "_")[[1]][[5]]
  district_id <-  stringr::str_split(district_id, "\\.")[[1]][[1]] %>% as.integer()
  
  # Read base data
  base_data <- readr::read_csv(paste0(base_source, "/", base_name),
                               col_types = cols_only(
                                 WKT = col_character(),
                                 FieldId = col_integer(),
                                 DistrictId = col_integer()
                               )) %>%
    dplyr::filter(DistrictId == district_id)
  
  # Read District Result
  district_data <- readr::read_csv(paste0(result_source, "/", district_result),
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
                                     Revenue = col_double()
                                   ))
  
  # Add WKT to district_data
  district_data %<>% dplyr::left_join(base_data, by = c("DistrictId", "FieldId"))
  
  # Create an outputname
  output_name <- paste0(scenario_name, "_op_", city_id, "_", district_id, ".csv")
  
  # Write Result
  sf::write_sf(district_data,
               paste0(output_dest, "/", output_name),
               layer_options = c("GEOMETRY=AS_WKT", "ENCODING=UTF-8"),
               quiet = TRUE)
  
}