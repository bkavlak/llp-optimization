from pulp import *
import numpy as np
import pandas as pd
import re 
import os
import sys
from preprocessing_func_c import *
import glob
import concurrent.futures
import time
from functools import partial
import time
from itertools import repeat

# starting time
start = time.time()

# Set Concurrency
with concurrent.futures.ProcessPoolExecutor(max_workers=15) as executor:
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

    # Scenario List
    #scenario_list = ['scenario-1','scenario-2','scenario-3','scenario-4','scenario-5']
    #coef_list = ['Profit', 'Profit', 'Physical', 'Profit', 'Profit']
    scenario_list = ['scenario-1']
    coef_list = ['Profit']

    # Scenario Dict
    sc_dict = {scenario_list[i]: coef_list[i] for i in range(len(scenario_list))} 

    # Preprocess
    for scenario_name in scenario_list:

        # Scenario Specification
        scenario_path = main_path + "/" + scenario_name

        # Set scenario path
        os.chdir(scenario_path)

        # base list prepreation
        base_list = glob.glob(base_path + '*.csv')
        base_name_list = list(map(lambda name: name.split("/")[-1], base_list))
        id_list = list(map(lambda file_name: re.findall(r'(\d+)', file_name), base_name_list))
        flat_id_list = [item for sublist in id_list for item in sublist]

        # Get iteration lists
        city_id_list = list(map(int, flat_id_list))

        # Partial function
        add_columns_p = partial(add_columns, yield_path = yield_path, cost_path = cost_path, price_path = price_path, scenario_name = scenario_name)
        add_coef_p = partial(add_coef, target = sc_dict.get(scenario_name))

        # Iterate all operations
        city_data_list = list(executor.map(add_columns_p, base_list))

        # Convert to Long Format
        city_data_list = list(executor.map(wtl_map, city_data_list))

        # Add Coefficient
        city_data_list = list(executor.map(add_coef_p, city_data_list))

        # Write results
        write_input_p = partial(write_input, input_path = input_path)
        list(map(write_input_p, city_id_list, city_data_list))


# ending time
end = time.time()

# Print total time taken
print(f"Runtime of the program is {(end - start) / 60} mins")