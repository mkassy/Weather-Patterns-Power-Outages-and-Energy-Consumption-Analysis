import requests
import xml.etree.ElementTree as ET

# URL of the XML file (updated URL as provided)
url = 'https://www.oeb.ca/documents/opendata/rrr/2023/2.1.4.2.10%20Major%20Response%20Reporting.xml'

# Fetch the XML content
response = requests.get(url)
response.raise_for_status()  # Ensure we got a successful response
root = ET.fromstring(response.content)

# Function to print the XML structure recursively
def print_xml_structure(element, indent=""):
    print(f"{indent}{element.tag}: {element.attrib if element.attrib else ''}")
    for child in element:
        print_xml_structure(child, indent + "  ")

# Print the entire XML structure
print("XML Structure:")
print_xml_structure(root)

# Set to store all unique headers
headers_set = set()

# Iterate through all 'record' elements
for record in root.findall('.//record'):
    # Check each child of the 'record' for field names
    for child in record:
        headers_set.add(child.tag)

# Convert the set to a list for ordered processing (if needed)
headers_list = list(headers_set)

# Print the extracted headers
print("\nExtracted Headers (to be used in CSV):")
print(headers_list)
