library(dplyr)
library(magrittr)
library(purrrlyr)
library(tidyr)
library(purrr)

setwd("/home/ziya/Desktop/PROCESS/Optimization/scenarios/scenario-1/variable-coefficients/input")

input_list <- list.files(".", ".csv$")

check_na <- function(data_name){
  print(data_name)
  data <- readr::read_csv(data_name)
  data %>% na.omit() %>% nrow == nrow(data) %>% print
}

na_list <- purrr::map(input_list, check_na)

adana <- readr::read_csv("DoktarVariableInput_1.csv")

adana_sum %<>%
  dplyr::select(FieldId, CropName, Coef) %>%
  tidyr::pivot_wider(names_from = CropName, values_from = Coef) %>%
  dplyr::group_by(FieldId) %>%
  dplyr::summarise_each(funs(sum(., na.rm = TRUE)))

adana %>% na.omit() %>% nrow == nrow(adana)
