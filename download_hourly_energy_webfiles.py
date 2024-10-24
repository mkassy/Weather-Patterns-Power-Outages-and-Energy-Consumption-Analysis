import os
import time
import requests
import zipfile
from selenium import webdriver
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.common.by import By

# URL of the webpage with the files
url = 'http://reports.ieso.ca/public/HourlyConsumptionByFSA/'  # Replace with your actual URL

# Define the path to the geckodriver
firefox_service = FirefoxService(executable_path='/usr/local/bin/geckodriver')

# Set up Firefox options (if needed)
firefox_options = FirefoxOptions()

# Initialize the Firefox WebDriver
driver = webdriver.Firefox(service=firefox_service, options=firefox_options)

def unzip_file(zip_path, extract_to):
    """Unzip the file to the specified directory."""
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)

def delete_empty_folders(directory):
    """Delete empty folders in the specified directory."""
    for root, dirs, files in os.walk(directory, topdown=False):
        for dir_ in dirs:
            dir_path = os.path.join(root, dir_)
            if not os.listdir(dir_path):
                os.rmdir(dir_path)
                print(f'Deleted empty directory: {dir_path}')

try:
    # Open the webpage
    driver.get(url)
    
    # Wait for the page to load
    time.sleep(5)  # Adjust the sleep time if needed

    # Find all the ZIP file links
    links = driver.find_elements(By.XPATH, '//a[contains(@href, ".zip")]')

    for link in links:
        href = link.get_attribute('href')
        filename = href.split('/')[-1]
        zip_path = os.path.join('data/energy', filename)

        # Download the ZIP file
        response = requests.get(href, stream=True)
        with open(zip_path, 'wb') as file:
            file.write(response.content)

        print(f'Downloaded: {filename}')
        
        # Unzip the file
        extract_to = os.path.join('data/energy', filename.replace('.zip', ''))
        unzip_file(zip_path, extract_to)
        
        # Delete the ZIP file after extraction
        os.remove(zip_path)
        print(f'Unzipped and deleted ZIP file: {filename}')

finally:
    driver.quit()
    # Delete any empty folders that might have been left behind
    delete_empty_folders('data/energy')
