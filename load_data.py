import psycopg2
import os
import csv

# Database connection parameters
conn = psycopg2.connect(
    dbname='your_database_name',
    user='your_username',
    host='localhost',
    password='your_password'
)

def preprocess_csv(file_path):
    temp_file_path = file_path + '.tmp'
    
    with open(file_path, 'r', newline='') as infile, open(temp_file_path, 'w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        
        for row in reader:
            # Replace "NULL" with an empty string
            row = ['' if cell == 'NULL' else cell for cell in row]
            writer.writerow(row)
    
    return temp_file_path

def load_csv_to_postgres(table_name, file_path):
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return
    
    temp_file_path = preprocess_csv(file_path)
    
    with conn.cursor() as cur:
        with open(temp_file_path, 'r') as f:
            try:
                cur.copy_expert(sql=f"COPY {table_name} FROM STDIN WITH CSV HEADER NULL AS ''", file=f)
                print(f"Loaded {file_path} into {table_name} table.")
            except Exception as e:
                print(f"Error loading {file_path} into {table_name}: {e}")
            conn.commit()
    
    os.remove(temp_file_path)  # Remove the temporary file after loading

def check_row_counts(table_name):
    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cur.fetchone()[0]
        print(f"Row count in {table_name}: {count}")

def load_weather_data():
    csv_file_path = 'data/weather_data/weather_data.csv'
    load_csv_to_postgres('staging_weather_data', csv_file_path)
    check_row_counts('staging_weather_data')

def load_energy_data():
    base_dir = 'data/energy/'
    for folder in os.listdir(base_dir):
        folder_path = os.path.join(base_dir, folder)
        if os.path.isdir(folder_path):
            for file_name in os.listdir(folder_path):
                if file_name.endswith('.csv'):
                    file_path = os.path.join(folder_path, file_name)
                    print(f"Loading {file_path} into staging_energy_data table...")
                    load_csv_to_postgres('staging_energy_data', file_path)
    check_row_counts('staging_energy_data')

def load_outages_data():
    csv_file_path = 'data/outages/major_response_reporting_data_cleaned_int.csv'
    load_csv_to_postgres('staging_outages', csv_file_path)
    check_row_counts('staging_outages')


    # Close the database connection
    conn.close()
