from pulp import *
import numpy as np
import pandas as pd
import re
import os
import sys
from optimization_func import *
from preprocessing_func import *
import glob
import concurrent.futures
import time
from functools import partial
import time

# starting time
start = time.time()
# File paths
main_path = "/home/ziya/Desktop/PROCESS/Optimization/scenarios"
base_path = './variable-coefficients/base/'
input_path = './variable-coefficients/input/'
price_path = './variable-coefficients/price/'
yield_path = './variable-coefficients/yield/'
cost_path = './variable-coefficients/cost/'
cons_path = './constraints/'
result_single_path = "./results/single/"
result_merge_path = "./results/merged/"

scenario_name = 'scenario-1'

# Scenario Specification
scenario_path = main_path + "/" + scenario_name

# Set scenario path
os.chdir(scenario_path)

# Detect Constraint Files
min_cons_file = cons_path + "DoktarDistrictMinAreaCons_" + scenario_name + ".csv"
max_cons_file = cons_path + "DoktarDistrictMaxAreaCons_" + scenario_name + ".csv"

# Read Constraint Files
min_area_cons = pd.read_csv(min_cons_file, encoding = 'utf-8')
max_area_cons = pd.read_csv(max_cons_file, encoding = 'utf-8')  

# Run the program
city_data = run_optimization(city_id = 42, city_file = input_path + "DoktarVariableInput_42.csv", min_area_cons = min_area_cons, max_area_cons = max_area_cons, result_single_path = result_single_path, scenario_name = scenario_name)

# ending time
end = time.time()

# Print total time taken
print(f"Runtime of the program is {(end - start) / 60} mins")