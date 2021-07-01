import pandas as pd
import os
from functools import partial

def add_columns(base_name, yield_path, price_path, cost_path, scenario_name):
    
    # Read Base Data
    base_data = pd.read_csv(base_name, usecols=["CityId", "DistrictId", "FieldId",
    "IrrigationId", "FieldArea", "WheatPercent", "BarleyPercent", "SunflowerPercent",
    "RicePercent", "LentilPercent", "ChickpeaPercent", "CottonPercent", "SugarbeetPercent",
    "SoybeanPercent", "PeanutPercent", "OatPercent", "PotatoPercent", "CornPercent",
    "CanolaPercent", "OnionPercent", "BeanPercent", "TomatoPercent"],
    dtype={"CityId": "uint8", "DistrictId": "uint16", "FieldId": "uint64",
    "IrrigationId": "uint8", "FieldArea": "float32"})
    
    # Add Yield Columns
    yield_data = pd.read_csv(yield_path + "DoktarVariableYield_" + scenario_name + ".csv", encoding="latin-1",
    dtype={"CityId": "uint8", "DistrictId": "uint16"})
    base_data = pd.merge(base_data, yield_data, on = 'DistrictId', how = 'left', suffixes = ('', '_extra'))
    base_data = base_data[base_data.columns.drop(list(base_data.filter(regex='_extra')))]
    
    # Add Price Columns
    price_data = pd.read_csv(price_path + "DoktarVariablePrice_" + scenario_name + ".csv", encoding = "latin-1",
    dtype={"CityId": "uint8", "DistrictId": "uint16"})
    base_data = pd.merge(base_data, price_data, on = 'DistrictId', how = 'left', suffixes = ('', '_extra'))
    base_data = base_data[base_data.columns.drop(list(base_data.filter(regex='_extra')))]

    # Add Cost Columns
    cost_data = pd.read_csv(cost_path + "DoktarVariableCost_" + scenario_name + ".csv", encoding = "latin-1",
    dtype={"CityId": "uint8", "DistrictId": "uint16", "IrrigationId": "uint8"})
    base_data = pd.merge(base_data, cost_data, on = ['DistrictId', 'IrrigationId'], how = 'left', suffixes = ('', '_extra'))
    base_data= base_data[base_data.columns.drop(list(base_data.filter(regex='_extra')))]
    
    return base_data


def wide_to_long(crop_name, base_data):
    main_columns = ['CityId', 'DistrictId', 'FieldId', "IrrigationId", 'FieldArea']
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
        base_data['Yield'] = base_data['Yield'].astype(float)
        base_data['FieldArea'] = base_data['FieldArea'].astype(float)
        base_data['Percent'] = base_data['Percent'].astype(float)
        base_data['Price'] = base_data['Price'].astype(float)
        base_data['Cost'] = base_data['Cost'].astype(float)
        base_data['Coef'] = base_data['FieldArea'] * float(10) * base_data['Percent'] * base_data['Yield'] * base_data['Price'] - base_data['FieldArea'] * float(10) * base_data['Cost']
        return(base_data)
    elif target == "Physical":
        base_data['Coef'] = base_data.eval('Percent')
        return(base_data)
    else:
        print("Hayat kısa, kuşlar uçuyor...")


def write_input_d(city_id, city_data, input_path):
    for district_id in city_data.DistrictId.unique():
        district_data = city_data[city_data['DistrictId'] == district_id]
        district_data.to_csv(input_path + "DoktarVariableInput_" + str(city_id) + "_" + str(district_id) + ".csv",
        encoding = "utf-8-sig",
        index = False)


def write_input_c(city_id, city_data, input_path):
    city_data.to_csv(input_path + "DoktarVariableInput_" + str(city_id) + ".csv",
    encoding = "utf-8-sig",
    index = False)


def do_preprocess(base_name, city_id, yield_path, price_path, cost_path, scenario_name, target, input_c_path, input_d_path):
    
    # Create base_data add columns
    base_data = add_columns(base_name = base_name, yield_path = yield_path, price_path = price_path, cost_path = cost_path, scenario_name = scenario_name)
    # Wide to Long
    base_data = wtl_map(base_data = base_data)
    # Add Coefs
    base_data = add_coef(base_data = base_data, target = target)
    # Write Cities
    write_input_c(city_id = city_id, city_data = base_data, input_path = input_c_path)
    write_input_d(city_id = city_id, city_data = base_data, input_path = input_d_path)

    del(base_data)




