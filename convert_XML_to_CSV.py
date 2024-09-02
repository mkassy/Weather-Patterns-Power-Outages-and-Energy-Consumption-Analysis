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

# Open a CSV file for writing
with open('data/outages/major_response_reporting_data.csv', 'w', newline='', encoding='utf-8') as csv_file:
    writer = csv.writer(csv_file)

    # Write the header row
    headers = [
        'Company_Name', 'Year', 'Submitted_On', 'Event_Date', 'Prior_Distributor_Warning',
        'Event_Time', 'Prior_Distributor_Warning_Details', 'Extra_Employees_On_Duty', 
        'Staff_Trained_Response_Plan', 'Media_Announcements', 'Main_Contributing_Event',
        'Brief_Description', 'IEEE_Standard_Used', 'ETR_Issued', 'ETR_Issued_Details',
        'Number_of_Customers_Interrupted', 'Percentage_Customers_Interrupted',
        'Hours_to_Restore_Ninety_Percent', 'Hours_to_Restore_Ninety_Percent_Comments',
        'Outages_Loss_of_Supply', 'Third_Party_Assistance_Details', 'Need_Equipment_or_Materials',
        'Future_Actions'
    ]
    writer.writerow(headers)

    # Iterate through XML elements and write to CSV
    for record in root.findall('.//record'):
        data = [
            record.findtext('Company_Name', default=''),
            record.findtext('Year', default=''),
            record.findtext('Submitted_On', default=''),
            record.findtext('Event_Date', default=''),
            record.findtext('Prior_to_the_Major_Event_Prior_Distributor_Warning_', default=''),
            record.findtext('Event_Time', default=''),
            record.findtext('Prior_to_the_Major_Event_Prior_Distributor_Warning_Details', default=''),
            record.findtext('Prior_to_the_Major_Event_Did_Distributor_Have_Extra_Employees_on_Duty_and_Standby', default=''),
            record.findtext('Prior_to_the_Major_Event_Was_the_Staff_Trained_on_the_Response_Plan', default=''),
            record.findtext('Prior_to_the_Major_Event_Media_Announcements_To_Public_Warning_of_Possible_Outages', default=''),
            record.findtext('During_the_Major_Event_Main_Contributing_Event_As_Per_RRR_Section_2.1.4.2.5', default=''),
            record.findtext('During_the_Major_Event_Brief_Description', default=''),
            record.findtext('During_the_Major_Event_Was_IEEE_Standard_Use_to_Derive_Any_Threshold', default=''),
            record.findtext('During_the_Major_Event_Any_Information_Regarding_Estimated_Time_of_Restoration_Issued_to_Public', default=''),
            record.findtext('During_the_Major_Event_Any_Information_Regarding_Estimated_Time_of_Restoration_Issued_to_Public_Details', default=''),
            record.findtext('During_the_Major_Event_Number_of_Customers_Interrupted', default=''),
            record.findtext('During_the_Major_Event_Percentage_of_Total_Customers_Base_Interrupted', default=''),
            record.findtext('During_the_Major_Event_How_Many_Hours_Did_it_Take_to_Restore_Ninety_Percentage_of_the_Customers', default=''),
            record.findtext('During_the_Major_Event_How_Many_Hours_Did_it_Take_to_Restore_Ninety_Percentage_of_the_Customers_Comments', default=''),
            record.findtext('During_the_Major_Event_Any_Outages_Associated_with_Loss_of_Supply', default=''),
            record.findtext('During_the_Major_Event_Assistance_Through_Third_Party_Mutual_Assistance_with_Other_Utilities_Details', default=''),
            record.findtext('During_the_Major_Event_Need_Equipment_or_Materials', default=''),
            record.findtext('After_Mitigation_FutureActions', default='')
        ]
        writer.writerow(data)
        print(f"Written row: {data}")

print("Conversion completed. Check 'data.csv' for results.")
