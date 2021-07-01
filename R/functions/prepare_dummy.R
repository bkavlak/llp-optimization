prepare_dummy <- function(city_name = "ADANA",
                          vector_name = "ADANA_parcel.csv",
                          vector_source = getwd(),
                          vector_dest = getwd(),
                          output_name = "ADANA_parcel_v02.csv",
                          join_hs,
                          join_hn){
  
  # Read Parcel Data
  city_data <- sf::read_sf(paste0(vector_source, "/", vector_name)) %>% sf::st_as_sf(wkt = "geometry")
  sf::st_crs(city_data) <- 4326
  
  # Run Spatial Join with QGIS
  qgis_result <- qgisprocess::qgis_run_algorithm("native:joinattributesbylocation",
                                                 INPUT = city_data,
                                                 JOIN = paste0(join_hs, "/", join_hn),
                                                 PREDICATE = c(0, 1, 2, 3, 4, 5, 6),
                                                 JOIN_FIELDS = c("Il_Adi", "Ilce_Adi"),
                                                 METHOD = 1,
                                                 .quiet = TRUE)
  
  # Transfer result to sf object
  sf_output <- qgisprocess::qgis_output(qgis_result, "OUTPUT") %>% sf::read_sf()
  
  # Crop List
  crop_list <- c("Corn", "Wheat", "Barley", "Sunflower", "Rice",
                 "Lentil", "Chickpea", "Sugarbeet", "Soybean",
                 "Potato", "Oat", "Canola", "Onion", "Tomato",
                 "Cotton", "Bean", "Peanut")
  
  # Initialize Columns
  sf_output$CropNameSc1 <- sample(crop_list, 1) %>% unlist()
  sf_output$CropNameSc2 <- sample(crop_list, 1) %>% unlist()
  sf_output$CropNameSc3 <- sample(crop_list, 1) %>% unlist()
  
  # Select a crop randomly
  sf_output$CropNameSc1 %<>% purrr::map(~ sample(crop_list, 1)) %>% unlist()
  sf_output$CropNameSc2 %<>% purrr::map(~ sample(crop_list, 1)) %>% unlist()
  sf_output$CropNameSc3 %<>% purrr::map(~ sample(crop_list, 1)) %>% unlist()
  
  # Write Result
  sf::write_sf(sf_output, paste0(vector_dest, "/", output_name), layer_options = "GEOMETRY=AS_WKT")
  
}