# print header rows of a csv file

import csv

# data/energy/FSA_2018/PUB_HourlyConsumptionByFSA_201801_v1.csv
# file_path = 'data/weather/toronto_2014-2024.csv'
file_path = 'data/outages/major_response_reporting_data_cleaned.csv'


# print header rows

with open(file_path, 'r') as file:
    reader = csv.reader(file)
    for i in range(5):
        print(next(reader))
