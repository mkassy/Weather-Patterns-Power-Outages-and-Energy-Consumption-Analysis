import os
import shutil

# Define the base directory where the CSV files are located
base_dir = 'data/energy'

# Define the year folders you want to create
years = ['2018', '2019', '2020', '2021', '2022', '2023', '2024']

# Create year-specific folders if they don't exist
for year in years:
    year_folder = os.path.join(base_dir, f'FSA_{year}')
    if not os.path.exists(year_folder):
        os.makedirs(year_folder)

# Walk through the directory structure
for root, dirs, files in os.walk(base_dir):
    # Skip the year-specific folders to avoid moving files from them
    if os.path.basename(root).startswith('FSA_'):
        continue
    
    for file in files:
        if file.endswith('.csv'):
            # Extract the year from the file name
            year = file.split('_')[2][:4]  # Extract the year part from the filename
            
            if year in years:
                # Define the target folder
                target_folder = os.path.join(base_dir, f'FSA_{year}')
                
                # Define source and target file paths
                source_file = os.path.join(root, file)
                target_file = os.path.join(target_folder, file)
                
                # Move the file
                shutil.move(source_file, target_file)
                print(f'Moved: {source_file} to {target_file}')
    
    # After moving all files, remove empty PUB_HourlyConsumptionByFSA directories
    if os.path.basename(root).startswith('PUB_HourlyConsumptionByFSA'):
        if not os.listdir(root):  # Check if the directory is empty
            os.rmdir(root)
            print(f'Deleted empty directory: {root}')
