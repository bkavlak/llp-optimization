# It merges all scenarios
prepare_scenario <- function(sc = "scenario-1",
                             level = "Districts"){
  
  # Detect Scenario Path
  merge_path <- paste0("./", sc, "/results/merged")
  file_name <- paste0(sc, "_", level, "_nogeom.csv")
  
  # Detect Scenario Number
  sc_number <- stringr::str_split(sc, "-")[[1]][2]
  
  # Crop names
  crop_names <- c('Wheat', 'Barley', 'Oat',
                  'Cotton', 'Soybean', 'Tomato',
                  'Canola', 'Potato', 'Sugarbeet',
                  'Onion', 'Bean', 'Lentil', 'Chickpea',
                  'Peanut', 'Rice', 'Corn', 'Sunflower')
  area_cols <- crop_names %>% purrr::map_chr(~ paste0(.x, "AreaSC", sc_number))
  yield_cols <- crop_names %>% purrr::map_chr(~ paste0(.x, "YieldSC", sc_number))
  profit_cols <- crop_names %>% purrr::map_chr(~ paste0(.x, "ProfitSC", sc_number))
  crop_cols <- c(area_cols, yield_cols, profit_cols)
  
  # Read Data
  scenario_data <- readr::read_csv(paste0(merge_path, "/", file_name))
  
  # Prepare a table outline
  outline <- setNames(data.frame(matrix(ncol = length(crop_cols), nrow = 0)), crop_cols)
  
  # Set missing column names
  scenario_data[setdiff(names(outline), names(scenario_data))] <- 0
  
  return(scenario_data)

}