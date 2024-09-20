import os

def count_energy_rows():
    # Define paths
    energy_base_dir = 'cleaned-data/energy/'
    
    # Initialize total row count for energy data
    total_rows_energy = 0
    
    # Loop through each year's FSA directory
    for year_dir in os.listdir(energy_base_dir):
        year_dir_path = os.path.join(energy_base_dir, year_dir)
        if os.path.isdir(year_dir_path):
            # Loop through CSV files in each year's directory
            for filename in os.listdir(year_dir_path):
                if filename.endswith('.csv'):
                    file_path = os.path.join(year_dir_path, filename)
                    try:
                        with open(file_path, 'r') as file:
                            lines = file.readlines()

                        # Detect the first line with the correct number of columns (i.e., the header)
                        header_line = None
                        for i, line in enumerate(lines):
                            if line.count(',') >= 6:  # Assuming a valid CSV line has at least 7 fields (adjust based on data)
                                header_line = i
                                break

                        if header_line is not None:
                            # Filter out metadata and error lines before the detected header
                            valid_lines = lines[header_line + 1:]  # Skip the header line

                            # Strip out empty lines or rows that contain only whitespace
                            valid_lines = [line for line in valid_lines if line.strip() and line.count(',') >= 6]

                            # Count the number of valid rows (excluding header and empty lines)
                            total_rows_energy += len(valid_lines)
                    except Exception as e:
                        print(f"Error processing {file_path}: {e}")
    
    print(f"Total number of energy data rows (excluding headers): {total_rows_energy}")
    return total_rows_energy


def count_outage_rows():
    # Define the path for outages data
    outage_data_path = 'cleaned-data/outages/major_response_reporting_data_cleaned.csv'
    
    # Initialize row count for outages
    total_rows_outage = 0
    
    try:
        with open(outage_data_path, 'r') as file:
            lines = file.readlines()

        # Detect the header line (assuming valid CSV line has at least 6 fields, adjust based on data)
        header_line = None
        for i, line in enumerate(lines):
            if line.count(',') >= 5:
                header_line = i
                break
        
        if header_line is not None:
            # Filter out lines after header and remove empty lines
            valid_lines = lines[header_line + 1:]
            valid_lines = [line for line in valid_lines if line.strip() and line.count(',') >= 5]
            
            # Count the rows
            total_rows_outage += len(valid_lines)
    
    except Exception as e:
        print(f"Error processing {outage_data_path}: {e}")
    
    print(f"Total number of outage data rows (excluding headers): {total_rows_outage}")
    return total_rows_outage


def count_weather_rows():
    # Define the path for weather data
    weather_data_path = 'cleaned-data/weather/toronto_weather_cleaned.csv'
    
    # Initialize row count for weather
    total_rows_weather = 0
    
    try:
        with open(weather_data_path, 'r') as file:
            lines = file.readlines()

        # Detect the header line (assuming valid CSV line has at least 6 fields, adjust based on data)
        header_line = None
        for i, line in enumerate(lines):
            if line.count(',') >= 5:
                header_line = i
                break
        
        if header_line is not None:
            # Filter out lines after header and remove empty lines
            valid_lines = lines[header_line + 1:]
            valid_lines = [line for line in valid_lines if line.strip() and line.count(',') >= 5]
            
            # Count the rows
            total_rows_weather += len(valid_lines)
    
    except Exception as e:
        print(f"Error processing {weather_data_path}: {e}")
    
    print(f"Total number of weather data rows (excluding headers): {total_rows_weather}")
    return total_rows_weather


def main():
    # Count energy, outage, and weather rows
    count_energy_rows()
    count_outage_rows()
    count_weather_rows()


if __name__ == "__main__":
    main()
