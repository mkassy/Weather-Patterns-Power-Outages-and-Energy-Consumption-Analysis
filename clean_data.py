# import pandas as pd
# import os


# CLEANING DATA FOR OUTAGES
# # Load the CSV file with proper encoding
# file_path = 'data/outages/major_response_reporting_data.csv'
# df = pd.read_csv(file_path, encoding='utf-8')

# # 1. Parse Date Fields - Ensure dates are in 'YYYY-MM-DD' format
# df['Submitted_On'] = pd.to_datetime(df['Submitted_On'], errors='coerce')
# df['Event_Date'] = pd.to_datetime(df['Event_Date'], errors='coerce')

# # 2. Normalize Time Formats to 24-hour time or parse if 12-hour
# def normalize_time(time_str):
#     try:
#         # First, try to parse as 12-hour format
#         return pd.to_datetime(time_str, format='%I:%M %p').time()
#     except:
#         try:
#             # If it fails, try to parse as 24-hour format
#             return pd.to_datetime(time_str, format='%H:%M').time()
#         except:
#             return pd.NaT

# df['Event_Time'] = df['Event_Time'].apply(normalize_time)

# # 3. Remove Leading/Trailing Whitespaces from all object columns (use apply instead of applymap)
# for col in df.select_dtypes(include=['object']).columns:
#     df[col] = df[col].apply(lambda x: x.strip() if isinstance(x, str) else x)

# # 4. Normalize Categorical Data
# # Standardizing the 'No' responses
# df['Prior_Distributor_Warning'] = df['Prior_Distributor_Warning'].replace({'No.': 'No', 'no': 'No'})
# df['Need_Equipment_or_Materials'] = df['Need_Equipment_or_Materials'].replace({'No.': 'No', 'no': 'No'})

# # 5. Handle Missing Times (replace inplace=True with direct assignment)
# df['Event_Time'] = df['Event_Time'].fillna(pd.Timestamp('00:00:00').time())

# # 6. Remove Incomplete Rows (Optional: Depends on your use case)
# df.dropna(subset=['Submitted_On', 'Event_Date'], inplace=True)

# # 7. Drop Empty Columns with Too Many Missing Values
# columns_to_drop = ['Hours_to_Restore_Ninety_Percent_Comments', 'Third_Party_Assistance_Details']
# df.drop(columns=columns_to_drop, inplace=True)

# # 8. Ensure Date Columns Are Saved in 'YYYY-MM-DD' Format
# df['Submitted_On'] = df['Submitted_On'].dt.strftime('%Y-%m-%d')
# df['Event_Date'] = df['Event_Date'].dt.strftime('%Y-%m-%d')

# # Save the cleaned data
# cleaned_file_path = 'data/outages/major_response_reporting_data_cleaned.csv'
# df.to_csv(cleaned_file_path, index=False)

# print("Data cleaning complete. Cleaned data saved to", cleaned_file_path)




# # Load the CSV file
# df = pd.read_csv('data/outages/major_response_reporting_data_cleaned.csv')

# # Convert the column to integers (or handle as needed)
# df['Number_of_Customers_Interrupted'] = df['Number_of_Customers_Interrupted'].fillna(0).astype(int)

# # Save the cleaned CSV
# df.to_csv('data/outages/major_response_reporting_data_cleaned_int.csv', index=False)



# CLEANING DATA FOR ENERGY
# # Define the base path to your CSV files
# base_path = 'data/energy'

# # Loop through each year directory
# for year in range(2018, 2025):
#     year_path = os.path.join(base_path, f'FSA_{year}')
    
#     # Loop through each month CSV file in the directory
#     for file_name in os.listdir(year_path):
#         if file_name.endswith('.csv'):
#             file_path = os.path.join(year_path, file_name)
            
#             # Create a temporary file to store the cleaned data
#             temp_file_path = file_path + '.tmp'
            
#             with open(file_path, 'r') as infile, open(temp_file_path, 'w') as outfile:
#                 # Skip the first 3 lines
#                 for i, line in enumerate(infile):
#                     if i >= 3:
#                         outfile.write(line)
            
#             # Replace the original file with the cleaned file
#             os.replace(temp_file_path, file_path)
#             print(f'Removed first 3 lines from {file_path}')
