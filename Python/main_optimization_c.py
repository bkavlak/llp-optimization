from pulp import *
import numpy as np
import pandas as pd
import re 
#import matplotlib.pyplot as plt
#from IPython.display import Image
import os
import sys
from optimization_func_c import *
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

    # Calculate Optimization
    for scenario_name in scenario_list:

        # Scenario Specification
        scenario_path = main_path + "/" + scenario_name

        # Set scenario path
        os.chdir(scenario_path)

        # input list prepreation
        input_list = glob.glob(input_path + '*.csv')
        input_list = np.array(input_list)
        input_list = np.array_split(input_list, 38)
        input_list = [l.tolist() for l in input_list]

        # Loop over Cities Chunks
        for input_list_chunk in input_list:
            input_name_list = list(map(lambda name: name.split("/")[-1], input_list_chunk))
            id_list = list(map(lambda file_name: re.findall(r'(\d+)', file_name), input_name_list))
            flat_id_list = [item for sublist in id_list for item in sublist]

            # Get iteration lists
            city_id_list = list(map(int, flat_id_list))

            # Detect Constraint Files
            min_cons_file = cons_path + "DoktarDistrictMinAreaCons_" + scenario_name + ".csv"
            max_cons_file = cons_path + "DoktarDistrictMaxAreaCons_" + scenario_name + ".csv"

            # Read Constraint Files
            min_area_cons = pd.read_csv(min_cons_file, encoding = 'utf-8')
            max_area_cons = pd.read_csv(max_cons_file, encoding = 'utf-8')  

            # Run the program on parallel
            optim_func = partial(run_optimization, min_area_cons = min_area_cons, max_area_cons = max_area_cons, result_single_path = result_single_path, scenario_name = scenario_name)
            list(executor.map(optim_func, city_id_list, input_list_chunk))


# ending time
end = time.time()

# Print total time taken
print(f"Runtime of the program is {(end - start) / 60} mins")