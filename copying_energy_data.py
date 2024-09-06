import os
import subprocess

# Define the base path to your CSV files
base_path = 'data/energy'

# Loop through each year directory
for year in range(2018, 2025):
    year_path = os.path.join(base_path, f'FSA_{year}')
    
    # Loop through each month CSV file in the directory
    for file_name in os.listdir(year_path):
        if file_name.endswith('.csv'):
            file_path = os.path.join(year_path, file_name)
            
            # Load the data into PostgreSQL
            cmd = f"psql -d weather_energy_power_analysis -c \"\\copy energy_data(FSA, DATE, HOUR, CUSTOMER_TYPE, PRICE_PLAN, TOTAL_CONSUMPTION, PREMISE_COUNT) FROM '{file_path}' DELIMITER ',' CSV HEADER;\""
            
            try:
                subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
                print(f'Loaded {file_path} into the database')
            except subprocess.CalledProcessError as e:
                print(f'Error processing {file_path}: {e.stderr}')
