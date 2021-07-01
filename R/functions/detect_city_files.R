# It detects files given a city_id on this type of string:
# scenario-1_optimization_result_1_51.csv -> city id is at the end of the string
detect_city_files <- function(file_list, city_id){
  
  # Get all city ids in files
  city_id_list <- purrr::map_chr(file_list, ~ stringr::str_split(.x, "_")[[1]][[4]])
  
  # Create a DataFrame
  scope_frame <- data.frame(city_id_list, file_list)
  
  # Detect City File
  city_list <- scope_frame %>%
    dplyr::filter(city_id_list == as.character(city_id)) %>%
    dplyr::pull(file_list) %>%
    as.character()
  
  return(city_list)
  
}