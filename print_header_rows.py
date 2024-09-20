# print only the header row of a csv file

import csv

# Specify the file path (modify as needed)
# file_path = 'cleaned-data/energy/FSA_2018_cleaned/PUB_HourlyConsumptionByFSA_201801_v1_cleaned.csv'
# file_path = 'cleaned-data/outages/major_response_reporting_data_cleaned.csv'
file_path = 'cleaned-data/weather/toronto_weather_cleaned.csv'

# Open and print the header row
with open(file_path, 'r') as file:
    reader = csv.reader(file)
    # Print only the first row, which is the header
    header = next(reader)
    print(header)
