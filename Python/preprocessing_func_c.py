import pandas as pd
import os
from functools import partial

def add_columns(base_name, yield_path, price_path, cost_path, scenario_name):
    
    # Read Base Data
    base_data = pd.read_csv(base_name)
    
    # Add Yield Columns
    yield_data = pd.read_csv(yield_path + "DoktarVariableYield_" + scenario_name + ".csv", encoding="latin-1")
    base_data = pd.merge(base_data, yield_data, on = 'DistrictId', how = 'left', suffixes = ('', '_extra'))
    base_data = base_data[base_data.columns.drop(list(base_data.filter(regex='_extra')))]
    
    # Add Price Columns
    price_data = pd.read_csv(price_path + "DoktarVariablePrice_" + scenario_name + ".csv", encoding = "latin-1")
    base_data = pd.merge(base_data, price_data, on = 'DistrictId', how = 'left', suffixes = ('', '_extra'))
    base_data = base_data[base_data.columns.drop(list(base_data.filter(regex='_extra')))]

    # Add Cost Columns
    cost_data = pd.read_csv(cost_path + "DoktarVariableCost_" + scenario_name + ".csv", encoding = "latin-1")
    base_data = pd.merge(base_data, cost_data, on = ['DistrictId', 'IrrigationId'], how = 'left', suffixes = ('', '_extra'))
    base_data= base_data[base_data.columns.drop(list(base_data.filter(regex='_extra')))]
    
    return base_data


def wide_to_long(crop_name, base_data):
    main_columns = ['CityId', 'DistrictId', 'FieldId', "IrrigationId", 'CityName', 'DistrictName', 'FieldArea', 'geometry']
    crop_columns = list(base_data.filter(regex=(crop_name)).columns)
    base_data = base_data.filter(main_columns + crop_columns)
    base_data = base_data.rename(columns={crop_name + 'Percent': 'Percent', crop_name + 'Yield': 'Yield', crop_name + 'Price': 'Price', crop_name + 'Cost': 'Cost'})
    base_data['CropName'] = crop_name

    return base_data


def wtl_map(base_data):
    crop_list = ['Wheat', 'Barley', 'Oat',
    'Cotton', 'Soybean', 'Tomato',
    'Canola', 'Potato', 'Sugarbeet',
    'Onion', 'Bean', 'Lentil', 'Chickpea',
    'Peanut', 'Rice', 'Corn', 'Sunflower']

    # Partial wide_to_long Function
    wide_func = partial(wide_to_long, base_data = base_data)
    # Map to each Crop
    long_list = list(map(wide_func, crop_list))
    long_data = pd.concat(long_list)

    return long_data


def add_coef(base_data, target = "Profit"):
    if target == "Profit":
        base_data['Coef'] = base_data.eval('FieldArea*10*Percent*Yield*Price-FieldArea*10*Cost')
        return(base_data)
    elif target == "Physical":
        base_data['Coef'] = base_data.eval('Percent*Yield')
        return(base_data)
    else:
        print("Hayat kısa, kuşlar uçuyor...")


def write_input(city_id, city_data, input_path):
    city_data.to_csv(input_path + "DoktarVariableInput_" + str(city_id) + ".csv",
    encoding = "utf-8-sig",
    index = False)
