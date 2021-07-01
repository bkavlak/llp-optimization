import pandas as pd
import pulp
import os
import time
from itertools import repeat
from functools import partial
import sys
import gc
import concurrent.futures


def write_result(city_id, city_data, result_single_path, scenario_name):
    city_data.to_csv(result_single_path + scenario_name + "_optimization_result_" + str(city_id) + ".csv",
    encoding = "utf-8-sig",
    index = False)


def register_var(rownum = 0):
    variable = str('x' + str(rownum))
    variable = pulp.LpVariable(str(variable), lowBound = 0, upBound = 1, cat= 'Integer') #make variables binary
    return variable


def add_field_constraint(field_id, prob, city_data):
    prob += pulp.lpSum(city_data[city_data['FieldId']==field_id]['VarName'].tolist()) <= 1


def add_area_constraint(district_id, crop_name, prob, city_data, min_area_cons, max_area_cons):
        sub_min_data = min_area_cons[min_area_cons['DistrictId'] == district_id]
        sub_max_data = max_area_cons[max_area_cons['DistrictId'] == district_id]
        sub_crop_data = city_data[city_data['CropName'] == crop_name]
        min_area = sub_min_data[str('Min' + crop_name + 'Area')]
        max_area = sub_max_data[str('Max' + crop_name + 'Area')]
        prob += pulp.lpSum(sub_crop_data['VarName'] * sub_crop_data['FieldArea'] * 10) >= min_area
        prob += pulp.lpSum(sub_crop_data['VarName'] * sub_crop_data['FieldArea'] * 10) <= max_area


def run_optimization(city_id, city_file, min_area_cons, max_area_cons, result_single_path, scenario_name):
    """
    This function takes csv files and follow optimization
    framework with pulp. It does the process without returning
    anything back to the system.
    """
    # Define Program Name
    program_name = 'optimization' + str(city_id)

    ## Create the LP object, set up as a maximization problem
    prob = pulp.LpProblem(program_name, pulp.LpMaximize)

    ## Read csv
    city_data = pd.read_csv(city_file, usecols=["CityId", "DistrictId", "FieldId",
    "IrrigationId", "Yield", "Cost", "Price", "Percent", "Coef", "FieldArea", "CropName"],
    dtype={"CityId": "uint8", "DistrictId": "uint16", "FieldId": "uint64",
    "IrrigationId": "uint8", "Yield": "uint16", "Cost": "uint16",
    "Percent": "float16", "Coef": "float32", "Price": "float16", "FieldArea": "float16"})

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "w") as f:
        print("Frame size is " + str(sys.getsizeof(city_data)/1024/1024), file=f)

    # Create decision - sown or not?
    row_list = list(city_data.index)
    decision_variables = list(map(register_var, row_list))

    ## Add variable names to main csv
    city_data['VarName'] = decision_variables

    ## Delete Decision Variable
    del(decision_variables)

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Frame size after Registration " + str(sys.getsizeof(city_data)/1024/1024), file=f)

    # Define Optimization Formula
    prob += pulp.lpSum(city_data['Coef'] * city_data['VarName'])

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Prob size after Formula " + str(sys.getsizeof(prob)/1024/1024), file=f)

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Frame size after Formula " + str(sys.getsizeof(city_data)/1024/1024), file=f)

    # Unique FieldId List
    id_unqiue = city_data.FieldId.unique()

    # starting time
    start = time.time()

    # Set Field Constraint
    for i in id_unqiue:
        prob += pulp.lpSum(city_data[city_data['FieldId']==i]['VarName'].tolist()) <= 1

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Prob size after Field Constraint " + str(sys.getsizeof(prob)/1024/1024), file=f)
    
    # ending time
    end = time.time()

    # Report Execution Time
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print(f"Runtime of the field constraint registration is {(end - start) / 60} mins", file=f)

    # starting time
    start = time.time()

    # Get District & Crop Name List
    district_list = list(city_data.DistrictId.unique())
    crop_list = list(city_data.CropName.unique())

    # Set constraints for each district at Min & Max
    for district in district_list:
        sub_min_data = min_area_cons[(min_area_cons['CityId'] == city_id) & (min_area_cons['DistrictId'] == district)]
        sub_max_data = max_area_cons[(max_area_cons['CityId'] == city_id) & (max_area_cons['DistrictId'] == district)]
        for crop in crop_list:
            sub_crop_data = city_data[city_data['CropName'] == crop]
            min_area = sub_min_data[str('Min' + crop + 'Area')]
            max_area = sub_max_data[str('Max' + crop + 'Area')]
            prob += pulp.lpSum(sub_crop_data['VarName'] * sub_crop_data['FieldArea'] * 10) >= min_area
            prob += pulp.lpSum(sub_crop_data['VarName'] * sub_crop_data['FieldArea'] * 10) <= max_area
            del(sub_crop_data)
            del(min_area)
            del(max_area)
        del(sub_max_data)
        del(sub_min_data)

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Prob size after Formula" + str(sys.getsizeof(prob)/1024/1024), file=f)
    
    # ending time
    end = time.time()

    # Report Execution Time
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print(f"Runtime of the district area constraint registration is {(end - start) / 60} mins", file=f)

    # starting time
    start = time.time()

    # Solve optimization
    prob.solve()
    
    # ending time
    end = time.time()

    # Report Execution Time
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print(f"Runtime of the district solving time is {(end - start) / 60} mins", file=f)

    # Add Values to Frame
    city_data['VarValue'] = city_data['VarName'].apply(lambda x: x.varValue)

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Frame size after Solution " + str(sys.getsizeof(city_data)/1024/1024), file=f)

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Prob size after Solution " + str(sys.getsizeof(prob)/1024/1024), file=f)
    
    # Remove 0's
    city_data = city_data[city_data['VarValue'] == 1]

    # Add Values to Frame
    city_data['Profit'] = city_data.eval('FieldArea*10*Percent*Yield*Price-FieldArea*10*Cost')

    # Write Result
    city_data.to_csv(result_single_path + scenario_name + "_optimization_result_" + str(city_id) + ".csv",
    encoding = "utf-8-sig",
    index = False)

    # Report Memory Size
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Frame size after Solution " + str(sys.getsizeof(city_data)/1024/1024), file=f)

    # Summarize results
    with open("./results/report/Optimization_Report_" + str(city_id) + ".txt", "a") as f:
        print("Status:" + str(pulp.LpStatus[prob.status]), file=f)
        print("Optimal Solution to the problem: " + str(pulp.value(prob.objective)), file=f)

    del(city_data)
    del(prob)