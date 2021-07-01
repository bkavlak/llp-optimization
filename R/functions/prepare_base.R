prepare_base <- function(city_name = "AFYONKARAHISAR",
                          vector_name = "AFYONKARAHISAR_parsel.csv",
                          vector_source = getwd(),
                          vector_dest = getwd(),
                          output_name = "ADANA_parcel_v02.csv",
                          join_hs,
                          join_hn){
  
  # Read Parcel Data
  city_data <- sf::read_sf(paste0(vector_source, "/", vector_name)) %>% sf::st_as_sf(wkt = "geometry")
  sf::st_crs(city_data) <- 4326
  
  # Column List
  columns_old <- c("Field_Id", "area", "nonirrigated", "irrigated", "Bugday_yield", "Arpa_yield", "Aycicegi_yield",
                   "celtik_yield", "Mercimek_yield", "Nohut_yield", "Pamuk_yield", "sekerpancari_yield",
                   "SoyaFasulyesi_yield", "Yerfistigi_yield", "Yulaf_yield",
                   "Patates_yield", "Misir_yield", "Kanola_yield", "Sogan_yield",
                   "Fasulye_yield", "Domates_yield", "geometry")
  
  # Filter City
  city_data %<>% dplyr::select(all_of(columns_old))
  
  # Create Irrigation Id
  city_data$IrrigationId <- 1
  city_data %<>% dplyr::mutate(IrrigationId = dplyr::if_else(nonirrigated == "True", 0, 1))
  
  # Drop Irrigation Columns
  city_data %<>% dplyr::select(-c(irrigated, nonirrigated)) 
  
  # Renamed Column List
  column_new <- c("FieldId", "FieldArea", "WheatPercent", "BarleyPercent", "SunflowerPercent",
                  "RicePercent", "LentilPercent", "ChickpeaPercent", "CottonPercent", "SugarbeetPercent",
                  "SoybeanPercent", "PeanutPercent", "OatPercent",
                  "PotatoPercent", "CornPercent", "CanolaPercent", "OnionPercent",
                  "BeanPercent", "TomatoPercent", "geometry", "IrrigationId")
  
  # Rename Columns
  colnames(city_data) <- column_new
  
  # Convert Id to integer
  city_data$FieldId <- as.integer(city_data$FieldId)
  
  # Convert data type
  city_data %<>%
    dplyr::mutate(dplyr::across(where(is.character), as.double))
  
  # Convert Percentage
  convert_percent <- function(column){(column + 100) / 100}
  percent_columns <- city_data %>%
    dplyr::select(contains("Percent")) %>%
    colnames() # detect Percent columns
  percent_columns <- percent_columns[-length(percent_columns)] # drop geometry
  city_data %<>%
    dplyr::mutate_at(dplyr::all_of(percent_columns), convert_percent) # apply function
  
  # Change Lentil - Chickpea - Canola
  city_data %<>% dplyr::mutate(LentilPercent = dplyr::if_else(IrrigationId == 1, LentilPercent + 0.15, LentilPercent + 0.75))
  city_data %<>% dplyr::mutate(ChickpeaPercent = dplyr::if_else(IrrigationId == 1, ChickpeaPercent + 0.15, ChickpeaPercent + 0.8))
  city_data %<>% dplyr::mutate(CanolaPercent = dplyr::if_else(IrrigationId == 1, CanolaPercent, CanolaPercent + 0.6))
  
  
  # Run Spatial Join with QGIS
  qgis_result <- qgisprocess::qgis_run_algorithm("native:joinattributesbylocation",
                                                 INPUT = city_data,
                                                 JOIN = paste0(join_hs, "/", join_hn),
                                                 PREDICATE = c(0, 1, 2, 3, 4, 5, 6),
                                                 JOIN_FIELDS = c("CityId", "DistrictId",
                                                                 "CityNameTr", "DistrictNa"),
                                                 METHOD = 1,
                                                 .quiet = TRUE)
  
  # Transfer result to sf object
  sf_output <- qgisprocess::qgis_output(qgis_result, "OUTPUT") %>% sf::read_sf()
  
  # Old Column List
  column_old2 <- c("CityId", "DistrictId",
                  "CityNameTr", "DistrictNa",
                  "FieldId", "IrrigationId", "FieldArea", "WheatPercent",
                  "BarleyPercent", "SunflowerPercent",
                  "RicePercent", "LentilPercent", "ChickpeaPercent",
                  "CottonPercent", "SugarbeetPercent",
                  "SoybeanPercent", "PeanutPercent", "OatPercent",
                  "PotatoPercent", "CornPercent", "CanolaPercent", "OnionPercent",
                  "BeanPercent", "TomatoPercent", "geom")
  # Select Columns
  sf_output %<>% dplyr::select(column_old2)
  
  # New Column List
  column_new2 <- c("CityId", "DistrictId",
                  "CityName", "DistrictName",
                  "FieldId", "IrrigationId", "FieldArea", "WheatPercent",
                  "BarleyPercent", "SunflowerPercent",
                  "RicePercent", "LentilPercent", "ChickpeaPercent",
                  "CottonPercent", "SugarbeetPercent",
                  "SoybeanPercent", "PeanutPercent", "OatPercent",
                  "PotatoPercent", "CornPercent", "CanolaPercent", "OnionPercent",
                  "BeanPercent", "TomatoPercent", "geom")
  
  # Rename Columns
  colnames(sf_output) <- column_new2
  
  # Write Result
  sf::write_sf(sf_output, paste0(vector_dest, "/", output_name), layer_options = c("GEOMETRY=AS_WKT", "ENCODING=UTF-8"))
  
}