import requests
import xml.etree.ElementTree as ET

# URL of the XML file
url = 'https://www.oeb.ca/documents/opendata/rrr/2023/2.1.4.2.10%20Major%20Response%20Reporting.xml'

# Fetch the XML content
response = requests.get(url)
response.raise_for_status()  # Check if the request was successful

# Parse the XML content
root = ET.fromstring(response.content)

# Print the XML structure
def print_xml_element(element, indent=0):
    print('  ' * indent + f'{element.tag}: {element.attrib}')
    for child in element:
        print_xml_element(child, indent + 1)

print_xml_element(root)
