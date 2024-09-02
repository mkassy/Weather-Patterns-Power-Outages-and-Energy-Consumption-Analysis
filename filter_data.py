import pandas as pd

# Read the CSV file into a DataFrame
df = pd.read_csv('data/outages/major_response_reporting_data.csv')

# Filter the DataFrame for rows related to Toronto
toronto_data = df[df['Brief_Description'].str.contains('Toronto', case=False, na=False)]

# Save the filtered data to a new CSV file
toronto_data.to_csv('toronto_specific_data.csv', index=False)

print('Filtered data saved to toronto_specific_data.csv')
