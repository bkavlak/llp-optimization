city_coordinate_iterator <- function(city_id = 1,
                                     result_source = "./scenario-1/results/single",
                                     base_source = "./scenario-1/variable-coefficients/base",
                                     output_dest = "./scenario-1/results/single_coordinated",
                                     scenario_name = "scenario-1") {
  
  # List files in Base Source & Result Source
  base_files <- list.files(base_source, "*.csv$")
  res_files <- list.files(result_source, "*.csv$")
  
  # Detect Base & Result Files in Scope
  base_scope <- detect_city(base_files, city_id = city_id)
  res_scope_list <- detect_city_files(res_files, city_id = city_id)
  
  if (length(base_scope) == 0) { print(paste0("We don't have a file for ", city_id)) } else {
    # Map coordinate_result
    purrr::map(res_scope_list, ~ coordinate_result(.x,
                                                   result_source = result_source,
                                                   base_source = base_source,
                                                   base_name = base_scope,
                                                   output_dest = output_dest,
                                                   city_id = city_id,
                                                   scenario_name = scenario_name))
  }
}