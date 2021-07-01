# It detects files given a city_id on this type of string:
# DoktarVariable_1.csv -> city id is at the end of the string
detect_city <- function(file_list, city_id){
  
  # Get all city ids in files
  city_id_list <- purrr::map_chr(file_list, ~ stringr::str_split(.x, "_")[[1]][[2]])
  city_id_list <- purrr::map_chr(city_id_list, ~ stringr::str_split(.x, "\\.")[[1]][[1]])
  
  # Create a DataFrame
  scope_frame <- data.frame(city_id_list, file_list)
  
  # Detect City File
  city_file <- scope_frame %>%
    dplyr::filter(city_id_list == as.character(city_id)) %>%
    dplyr::select(file_list) %>%
    dplyr::pull(.) %>%
    as.character()
  
  return(city_file)
  
}