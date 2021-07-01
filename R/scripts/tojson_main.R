library(jsonlite)
library(dplyr)
library(tidyverse)

setwd("C:/Users/batuh/Documents/GitHub/doktar-opt/ExampleLPPProgram/final_data")

# Read Data
data <- readr::read_csv("Turkey_Optimization_L2_dummy.csv")

# 
default <- data %>% dplyr::select(contains("Default"))
scenario_1 <- data %>% dplyr::select(contains("SC1"))
scenario_2 <- data %>% dplyr::select(contains("SC2"))
scenario_3 <- data %>% dplyr::select(contains("SC3"))
scenario_4 <- data %>% dplyr::select(contains("SC4"))
scenario_5 <- data %>% dplyr::select(contains("SC5"))


toJSON(data)
