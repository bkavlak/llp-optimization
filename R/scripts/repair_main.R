setwd("/home/ziya/Desktop/PROCESS/Optimization/scenarios/scenario-1/results/single")
csv_list <- list.files(".", "*.csv$")

repair_yield <- function(data_name){
  
  data <- readr::read_csv(data_name,
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
                            Profit = col_double()
                          ))
  data$Yield <- data$Yield * data$Percent * data$FieldArea
  data$Revenue <- data$Yield * data$FieldArea
  data$Cost <- data$Cost * data$FieldArea
  
  data.table::fwrite(data, paste0("../single_coordinated/", data_name))
  
}

for (data_name in csv_list){
  
  print(paste0("HERE: ", data_name))
  repair_yield(data_name)
  
}
