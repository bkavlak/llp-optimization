library(readr)
library(magrittr)
library(sf)
library(tidyverse)
library(dplyr)

# Define Program Root Directory
root <- "/home/ziya/Desktop/PROCESS/Optimization/scenarios"

# Set program to root
setwd(root)

# Load Functions
source("../../../gitHub/doktar-opt/ExampleLPPProgram/R/functions/coordinate_result.R")
source("../../../gitHub/doktar-opt/ExampleLPPProgram/R/functions/detect_city.R")
source("../../../gitHub/doktar-opt/ExampleLPPProgram/R/functions/detect_city_files.R")
source("../../../gitHub/doktar-opt/ExampleLPPProgram/R/iterators/city_coordinate_iterator.R")

scenario_list <- c("scenario-4", "scenario-5")

# Set System Locale to Turkish for Turkish characters
Sys.setlocale(locale = "Turkish")

# Loop Over Scenarios
  for (sc in scenario_list) {
    
    # Files
    result_source = paste0("./", sc, "/results/single")
    base_source = paste0("./", sc, "/variable-coefficients/base")
    output_dest = paste0("./", sc, "/results/single_coordinated")
    
    # Get City List
    city_id_list <- 1:81
    
    # Plan Multi-session
    future::plan("multisession")
    
    # Specify Corn Raster
    furrr::future_map(city_id_list, ~ city_coordinate_iterator(city_id = .x,
                                                               result_source = result_source,
                                                               base_source = base_source,
                                                               output_dest = output_dest,
                                                               scenario_name = sc))
  }
