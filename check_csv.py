import pandas as pd

# Replace with the path to your CSV file
# csv_file = 'cleaned-data/weather/toronto_hourly_weather_cleaned/en_climate_hourly_ON_6158355_01-2019_P1H_cleaned.csv'
csv_file = 'data/weather/toronto_hourly_weather_with_wind/en_climate_hourly_ON_6158731_01-2018_P1H.csv'
# Load the CSV into a pandas DataFrame
df = pd.read_csv(csv_file)

# Print the column names and data types
print(df.dtypes)
