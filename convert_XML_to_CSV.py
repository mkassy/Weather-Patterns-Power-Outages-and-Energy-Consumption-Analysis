import requests
import xml.etree.ElementTree as ET
import csv

# URL of the XML file
url = 'https://www.oeb.ca/documents/opendata/rrr/2023/2.1.4.2.10%20Major%20Response%20Reporting.xml'

# Fetch the XML content
response = requests.get(url)
response.raise_for_status()  # Check if the request was successful

# Parse the XML content
root = ET.fromstring(response.content)

# Define the header mapping (XML tag to CSV header)
header_mapping = {
    'Company_Name': 'Company_Name',
    'Year': 'Year',
    'Submitted_On': 'Submitted_On',
    'Event_Date': 'Event_Date',
    'Prior_to_the_Major_Event_Prior_Distributor_Warning_': 'Prior_Distributor_Warning',
    'Event_Time': 'Event_Time',
    'Prior_to_the_Major_Event_Prior_Distributor_Warning_Details': 'Prior_Distributor_Warning_Details',
    'Prior_to_the_Major_Event_Did_Distributor_Have_Extra_Employees_on_Duty_and_Standby': 'Extra_Employees_On_Duty',
    'Prior_to_the_Major_Event_Was_the_Staff_Trained_on_the_Response_Plan': 'Staff_Trained_Response_Plan',
    'Prior_to_the_Major_Event_Media_Announcements_To_Public_Warning_of_Possible_Outages': 'Media_Announcements',
    'During_the_Major_Event_Main_Contributing_Event_As_Per_RRR_Section_2.1.4.2.5': 'Main_Contributing_Event',
    'During_the_Major_Event_Brief_Description': 'Brief_Description',
    'During_the_Major_Event_Was_IEEE_Standard_Use_to_Derive_Any_Threshold': 'IEEE_Standard_Used',
    'During_the_Major_Event_Any_Information_Regarding_Estimated_Time_of_Restoration_Issued_to_Public': 'ETR_Issued',
    'During_the_Major_Event_Any_Information_Regarding_Estimated_Time_of_Restoration_Issued_to_Public_Details': 'ETR_Issued_Details',
    'During_the_Major_Event_Number_of_Customers_Interrupted': 'Number_of_Customers_Interrupted',
    'During_the_Major_Event_Percentage_of_Total_Customers_Base_Interrupted': 'Percentage_Customers_Interrupted',
    'During_the_Major_Event_How_Many_Hours_Did_it_Take_to_Restore_Ninety_Percentage_of_the_Customers': 'Hours_to_Restore_Ninety_Percent',
    'During_the_Major_Event_How_Many_Hours_Did_it_Take_to_Restore_Ninety_Percentage_of_the_Customers_Comments': 'Hours_to_Restore_Ninety_Percent_Comments',
    'During_the_Major_Event_Any_Outages_Associated_with_Loss_of_Supply': 'Outages_Loss_of_Supply',
    'During_the_Major_Event_Assistance_Through_Third_Party_Mutual_Assistance_with_Other_Utilities_Details': 'Third_Party_Assistance_Details',
    'During_the_Major_Event_Need_Equipment_or_Materials': 'Need_Equipment_or_Materials',
    'After_Mitigation_FutureActions': 'Future_Actions',
    'Prior_to_the_Major_Event_If_No_Arrangements_or_Extra_Employees_or_Employees_Were_Not_Arranged': 'No_Arrangements_Extra_Employees',
    'During_the_Major_Event_Assistance_Through_Third_Party_Mutual_Assistance_with_Other_Utilities': 'Third_Party_Assistance',
}

# Extract the headers in the correct order for CSV
# Extracted Headers (to be used in CSV):
csv_headers = list(header_mapping.values())

# Open a CSV file for writing
with open('data/outages/major_response_reporting_data.csv', 'w', newline='', encoding='utf-8') as csv_file:
    writer = csv.writer(csv_file)

    # Write the header row
    writer.writerow(csv_headers)

    # Iterate through XML elements and write to CSV
    for record in root.findall('.//record'):
        # Extract the data based on the header mapping
        data = [
            record.findtext(xml_tag, default='') for xml_tag in header_mapping.keys()
        ]
        writer.writerow(data)  # Write the row to CSV
        print(f"Written row: {data}")

print("Conversion completed. Check 'major_response_reporting_data.csv' for results.")
