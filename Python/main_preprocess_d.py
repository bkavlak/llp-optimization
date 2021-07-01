from pulp import *
import numpy as np
import pandas as pd
import re 
import os
import sys
from preprocessing_func_d import *
import glob
import concurrent.futures
import time
from functools import partial
import time
from itertools import repeat

# starting time
start = time.time()

# Set Concurrency
with concurrent.futures.ProcessPoolExecutor(max_workers=19) as executor:
    # File paths
    main_path = "/home/ziya/Desktop/PROCESS/Optimization/scenarios"
    base_path = './variable-coefficients/base/'
    input_c_path = './variable-coefficients/input/city/'
    input_d_path = './variable-coefficients/input/district/'
    price_path = './variable-coefficients/price/'
    yield_path = './variable-coefficients/yield/'
    cost_path = './variable-coefficients/cost/'
    cons_path = './constraints/'
    result_single_path = "./results/single/"
    result_merge_path = "./results/merged/"

    # Scenario List
    #scenario_list = ['scenario-1','scenario-2','scenario-3','scenario-4','scenario-5']
    #coef_list = ['Profit', 'Profit', 'Physical', 'Profit', 'Profit']
    scenario_list = ['scenario-3']
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
        do_preprocess_p = partial(do_preprocess, yield_path = yield_path,
        cost_path = cost_path, price_path = price_path,
        scenario_name = scenario_name, target = sc_dict.get(scenario_name),
        input_c_path = input_c_path, input_d_path = input_d_path)

        # Iterate all operations
        list(executor.map(do_preprocess_p, base_list, city_id_list))


# ending time
end = time.time()

# Print total time taken
print(f"Runtime of the program is {(end - start) / 60} mins")