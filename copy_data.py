import os
import psycopg2

# Database connection details
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")  # Default to 5432 if not specified
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Headers for each dataset
energy_headers = [
    'fsa', 'date', 'hour', 'customer_type', 'price_plan', 'total_consumption', 'premise_count'
]

outage_headers = [
    '"Company_Name"', '"Year"', '"Submitted_On"', '"Event_Date"', '"Prior_Distributor_Warning"', '"Event_Time"',
    '"Prior_Distributor_Warning_Details"', '"Extra_Employees_On_Duty"', '"Staff_Trained_Response_Plan"',
    '"Media_Announcements"', '"Main_Contributing_Event"', '"Brief_Description"', '"IEEE_Standard_Used"',
    '"ETR_Issued"', '"ETR_Issued_Details"', '"Number_of_Customers_Interrupted"', 
    '"Percentage_Customers_Interrupted"', '"Hours_to_Restore_Ninety_Percent"', '"Outages_Loss_of_Supply"', 
    '"Need_Equipment_or_Materials"', '"Future_Actions"', '"No_Arrangements_Extra_Employees"', 
    '"Third_Party_Assistance"'
]

hourly_outage_data_headers = [
    '"UtilityName"', '"StateName"', '"CountyName"', '"CityName"', 
    '"CustomersTracked"', '"CustomersOut"', '"RecordDateTime"'
]


weather_headers = [
    'station', 'name', 'latitude', 'longitude', 'elevation', 'date', 'prcp', 'prcp_attributes', 
    'snwd', 'snwd_attributes', 'tavg', 'tavg_attributes', 'tmax', 'tmax_attributes', 'tmin', 
    'tmin_attributes'
]

# Headers for hourly weather data
hourly_weather_data_headers = [
    'longitude_x', 'latitude_y', 'station_name', 'climate_id', 'date_time_lst',
    'year', 'month', 'day', 'time_lst', 'temp_c', 'temp_flag', 'dew_point_temp_c',
    'dew_point_temp_flag', 'rel_hum_percent', 'rel_hum_flag', 'precip_amount_mm',
    'precip_amount_flag', 'wind_dir_10s_deg', 'wind_dir_flag', 'wind_spd_kmh',
    'wind_spd_flag', 'visibility_km', 'visibility_flag', 'stn_press_kpa',
    'stn_press_flag', 'hmdx', 'hmdx_flag', 'wind_chill', 'wind_chill_flag', 'weather'
]

# Function to copy CSV data to the PostgreSQL table with explicit headers
def copy_csv_to_table(conn, file_path, table_name, headers, encoding='UTF-8'):
    cursor = conn.cursor()
    try:
        # Convert headers list to a string of comma-separated column names
        columns = ', '.join(headers)
        with open(file_path, 'r', encoding=encoding) as f:
            copy_query = f"COPY {table_name} ({columns}) FROM STDIN WITH CSV HEADER NULL AS ''"
            cursor.copy_expert(copy_query, f)
        print(f"Data from {file_path} loaded into {table_name} successfully.")
    except Exception as e:
        print(f"Error loading {file_path} into {table_name}: {str(e)}")
    finally:
        cursor.close()

# Load energy data from all FSA files
def load_energy_data(conn):
    energy_dir = 'cleaned-data/energy'
    for root, _, files in os.walk(energy_dir):
        for file in files:
            if file.endswith('.csv'):
                file_path = os.path.join(root, file)
                print(f"Loading {file_path} into staging_energy_data")
                copy_csv_to_table(conn, file_path, 'staging_energy_data', energy_headers)
    conn.commit()

# Load outage data
def load_outage_data(conn):
    outage_file = 'cleaned-data/outages/major_response_reporting_data_cleaned.csv'
    print(f"Loading {outage_file} into staging_outage_data")
    copy_csv_to_table(conn, outage_file, 'staging_outage_data', outage_headers)
    conn.commit()


# Load hourly outage data 
def load_hourly_outage_data(conn):
    hourly_outage_data_file = 'data/outages/POUS_Export_City_Hourly_Toronto.csv'
    print(f"Loading {hourly_outage_data_file} into staging_hourly_outage_data")
    # Pass 'UTF-16' as the encoding argument for this dataset
    copy_csv_to_table(conn, hourly_outage_data_file, 'staging_hourly_outage_data', hourly_outage_data_headers, encoding='UTF-16')
    conn.commit()


# Load weather data
def load_weather_data(conn):
    weather_file = 'cleaned-data/weather/toronto_weather_cleaned.csv'
    print(f"Loading {weather_file} into staging_weather_data")
    copy_csv_to_table(conn, weather_file, 'staging_weather_data', weather_headers)
    conn.commit()

# Load hourly weather data from all CSV files in the directory
def load_hourly_weather_data(conn):
    weather_dir = 'cleaned-data/weather/toronto_hourly_weather_cleaned'
    for root, _, files in os.walk(weather_dir):
        for file in files:
            if file.endswith('.csv'):
                file_path = os.path.join(root, file)
                print(f"Loading {file_path} into staging_hourly_weather_data")
                # Use 'UTF-8-SIG' for the weather data
                copy_csv_to_table(conn, file_path, 'staging_hourly_weather_data', hourly_weather_data_headers, encoding='UTF-8-SIG')
    conn.commit()

# Load hourly weather data with wind from all CSV files in the directory
def load_hourly_weather_data_with_wind(conn):
    weather_dir = 'cleaned-data/weather/toronto_hourly_weather_with_wind_cleaned'
    for root, _, files in os.walk(weather_dir):
        for file in files:
            if file.endswith('.csv'):
                file_path = os.path.join(root, file)
                print(f"Loading {file_path} into staging_hourly_weather_data_with_wind")
                # Use 'UTF-8-SIG' for the weather data
                copy_csv_to_table(conn, file_path, 'staging_hourly_weather_data_with_wind', hourly_weather_data_headers, encoding='UTF-8-SIG')
    conn.commit()

# Main function to establish connection and load data
def main():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD
        )
        print("Database connection successful")

        # Load energy data, outage data, and weather data
        # load_energy_data(conn)
        # load_outage_data(conn)
        # load_hourly_outage_data(conn)
        # load_weather_data(conn)
        # load_hourly_weather_data(conn)
        load_hourly_weather_data_with_wind(conn)

        # Close the connection
        conn.close()
        print("Data loading complete.")
    except Exception as e:
        print(f"Error connecting to the database: {str(e)}")

if __name__ == "__main__":
    main()
