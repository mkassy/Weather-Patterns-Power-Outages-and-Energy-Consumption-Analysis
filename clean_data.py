import os
import pandas as pd
from io import StringIO

def create_cleaned_data_directory():
    # Create the base cleaned-data directory if it doesn't exist
    if not os.path.exists('cleaned-data'):
        os.makedirs('cleaned-data')


def clean_energy_data():
    # Define paths
    energy_base_dir = 'data/energy/'
    cleaned_energy_base_dir = 'cleaned-data/energy/'
    
    # Loop through each year's FSA directory
    for year_dir in os.listdir(energy_base_dir):
        year_dir_path = os.path.join(energy_base_dir, year_dir)
        if os.path.isdir(year_dir_path):
            # Create corresponding cleaned directory
            cleaned_year_dir = os.path.join(cleaned_energy_base_dir, f"{year_dir}_cleaned")
            if not os.path.exists(cleaned_year_dir):
                os.makedirs(cleaned_year_dir)
            
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
                            valid_lines = lines[header_line:]
                            
                            # Convert valid lines into a dataframe
                            cleaned_data = StringIO(''.join(valid_lines))
                            
                            # Read the cleaned data
                            energy_df = pd.read_csv(cleaned_data, low_memory=False)

                            # Handle missing values separately for numeric and string columns
                            str_cols = energy_df.select_dtypes(include=['object']).columns
                            num_cols = energy_df.select_dtypes(include=['float64', 'int64']).columns

                            energy_df[str_cols] = energy_df[str_cols].fillna('')  # Fill string columns with empty string
                            energy_df[num_cols] = energy_df[num_cols].fillna(0)   # Fill numeric columns with 0
                            
                            # Strip whitespaces for string columns (only leading/trailing whitespace)
                            energy_df[str_cols] = energy_df[str_cols].apply(lambda col: col.str.strip() if col.dtype == "object" else col)
                            
                            # Drop any rows where all columns are NaN (in case of additional metadata)
                            energy_df.dropna(how='all', inplace=True)

                            # Save cleaned file
                            cleaned_file_path = os.path.join(cleaned_year_dir, filename.replace('.csv', '_cleaned.csv'))
                            energy_df.to_csv(cleaned_file_path, index=False)
                            print(f"Cleaned energy data saved to {cleaned_file_path}")
                        else:
                            print(f"No valid header found in {file_path}. Skipping file.")
                            
                    except pd.errors.ParserError as e:
                        print(f"Error parsing {file_path}: {e}")


def clean_outage_data():
    # Define paths
    outage_data_path = 'data/outages/major_response_reporting_data.csv'
    cleaned_outage_dir = 'cleaned-data/outages/'
    
    # Create directory for cleaned outages if it doesn't exist
    if not os.path.exists(cleaned_outage_dir):
        os.makedirs(cleaned_outage_dir)
    
    # Load the CSV file
    outage_df = pd.read_csv(outage_data_path, encoding='utf-8')

    # Parse Date Fields
    outage_df['Submitted_On'] = pd.to_datetime(outage_df['Submitted_On'], errors='coerce')
    outage_df['Event_Date'] = pd.to_datetime(outage_df['Event_Date'], errors='coerce')

    # Normalize Time Format or fill with default '00:00:00'
    # Clean the time column, strip extra spaces, and convert to 24-hour format
    def clean_time(time_str):
        if pd.isna(time_str) or not isinstance(time_str, str):
            # If it's NaN or not a string, return the default time '00:00:00'
            return pd.to_datetime('00:00:00').time()
        
        try:
            # Strip extra spaces and convert to a valid time
            return pd.to_datetime(time_str.strip(), format='%I:%M %p').time()
        except (ValueError, TypeError):
            # If the time string is invalid, default to '00:00:00'
            return pd.to_datetime('00:00:00').time()

    outage_df['Event_Time'] = outage_df['Event_Time'].apply(clean_time)

    # Fill missing values in string columns
    str_cols = outage_df.select_dtypes(include=['object']).columns
    outage_df[str_cols] = outage_df[str_cols].fillna('')

    # Normalize specific columns (like 'No_Arrangements_Extra_Employees')
    outage_df['No_Arrangements_Extra_Employees'] = outage_df['No_Arrangements_Extra_Employees'].replace({
        'n/a': '', 'Not Applicable (N/A)': '', 'N/A': ''
    }).fillna('')

    # Fill missing numeric values with 0
    num_cols = outage_df.select_dtypes(include=['float64', 'int64']).columns
    outage_df[num_cols] = outage_df[num_cols].fillna(0)

    # Drop Columns with too many missing values if needed
    columns_to_drop = ['Third_Party_Assistance_Details', 'Hours_to_Restore_Ninety_Percent_Comments']
    outage_df.drop(columns=columns_to_drop, inplace=True)

    # Save the cleaned data
    cleaned_outage_path = os.path.join(cleaned_outage_dir, 'major_response_reporting_data_cleaned.csv')
    outage_df.to_csv(cleaned_outage_path, index=False)
    print(f"Outage data cleaned and saved to {cleaned_outage_path}")


def clean_weather_data():
    # Define paths
    weather_data_path = 'data/weather/toronto_weather.csv'
    cleaned_weather_dir = 'cleaned-data/weather/'
    
    # Create directory for cleaned weather data if it doesn't exist
    if not os.path.exists(cleaned_weather_dir):
        os.makedirs(cleaned_weather_dir)
    
    # Load and clean the weather data
    weather_df = pd.read_csv(weather_data_path)
    
    # Separate columns by type to handle missing values appropriately
    str_cols = weather_df.select_dtypes(include=['object']).columns
    num_cols = weather_df.select_dtypes(include=['float64', 'int64']).columns

    # Fill missing values
    weather_df[str_cols] = weather_df[str_cols].fillna('')  # Fill string columns with empty string
    weather_df[num_cols] = weather_df[num_cols].fillna(0)   # Fill numeric columns with 0
    
    # Save cleaned data
    cleaned_weather_path = os.path.join(cleaned_weather_dir, 'toronto_weather_cleaned.csv')
    weather_df.to_csv(cleaned_weather_path, index=False)
    print(f"Weather data cleaned and saved to {cleaned_weather_path}")

# def clean_hourly_weather_data():
#     # Define paths
#     weather_base_dir = 'data/weather/toronto_hourly_weather'
#     cleaned_weather_dir = 'cleaned-data/weather/toronto_hourly_weather_cleaned'
    
#     # Create directory for cleaned weather data if it doesn't exist
#     if not os.path.exists(cleaned_weather_dir):
#         os.makedirs(cleaned_weather_dir)
    
#     # Loop through all files in the hourly weather directory
#     for filename in os.listdir(weather_base_dir):
#         if filename.endswith('.csv'):
#             file_path = os.path.join(weather_base_dir, filename)
#             try:
#                 # Load the weather data CSV file
#                 weather_df = pd.read_csv(file_path)
                
#                 # Fill missing values
#                 str_cols = weather_df.select_dtypes(include=['object']).columns
#                 num_cols = weather_df.select_dtypes(include=['float64', 'int64']).columns

#                 weather_df[str_cols] = weather_df[str_cols].fillna('')  # Fill string columns with empty string
#                 weather_df[num_cols] = weather_df[num_cols].fillna(0)   # Fill numeric columns with 0
                
#                 # Convert the 'Date/Time (LST)' column to datetime
#                 weather_df['Date/Time (LST)'] = pd.to_datetime(weather_df['Date/Time (LST)'], errors='coerce')
                
#                 # Save cleaned data
#                 cleaned_file_path = os.path.join(cleaned_weather_dir, filename.replace('.csv', '_cleaned.csv'))
#                 weather_df.to_csv(cleaned_file_path, index=False)
#                 print(f"Cleaned hourly weather data saved to {cleaned_file_path}")
#             except Exception as e:
#                 print(f"Error processing file {file_path}: {e}")

def clean_hourly_weather_data(weather_base_dir, cleaned_weather_dir):
    # Create directory for cleaned weather data if it doesn't exist
    if not os.path.exists(cleaned_weather_dir):
        os.makedirs(cleaned_weather_dir)
    
    # Loop through all files in the hourly weather directory
    for filename in os.listdir(weather_base_dir):
        if filename.endswith('.csv'):
            file_path = os.path.join(weather_base_dir, filename)
            try:
                # Load the weather data CSV file
                weather_df = pd.read_csv(file_path)
                
                # Replace 'M' (missing values) with NaN for numeric columns if needed
                weather_df.replace('M', pd.NA, inplace=True)

                # Fill missing values for object and numeric columns
                str_cols = weather_df.select_dtypes(include=['object']).columns
                num_cols = weather_df.select_dtypes(include=['float64', 'int64']).columns

                weather_df[str_cols] = weather_df[str_cols].fillna('')  # Fill string columns with empty string
                weather_df[num_cols] = weather_df[num_cols].fillna(0)   # Fill numeric columns with 0
                
                # Convert the 'Date/Time (LST)' column to datetime
                weather_df['Date/Time (LST)'] = pd.to_datetime(weather_df['Date/Time (LST)'], errors='coerce')
                
                # Save cleaned data
                cleaned_file_path = os.path.join(cleaned_weather_dir, filename.replace('.csv', '_cleaned.csv'))
                weather_df.to_csv(cleaned_file_path, index=False)
                print(f"Cleaned hourly weather data saved to {cleaned_file_path}")
                
            except Exception as e:
                print(f"Error processing file {file_path}: {e}")

# Define paths for Toronto City and Toronto Intl A data
toronto_hourly_weather_dir = 'data/weather/toronto_hourly_weather'
toronto_hourly_weather_cleaned_dir = 'cleaned-data/weather/toronto_hourly_weather_cleaned'
toronto_hourly_weather_with_wind_dir = 'data/weather/toronto_hourly_weather_with_wind'
toronto_hourly_weather_with_wind_cleaned_dir = 'cleaned-data/weather/toronto_hourly_weather_with_wind_cleaned'


def main():
    # Create the cleaned-data directory structure
    create_cleaned_data_directory()
    
    # Clean each dataset
    # clean_energy_data()
    # clean_outage_data()
    # clean_weather_data()
    # Run the cleaning function for both directories
    # clean_hourly_weather_data(toronto_hourly_weather_dir, toronto_hourly_weather_cleaned_dir)
    clean_hourly_weather_data(toronto_hourly_weather_with_wind_dir, toronto_hourly_weather_with_wind_cleaned_dir)

if __name__ == "__main__":
    main()
