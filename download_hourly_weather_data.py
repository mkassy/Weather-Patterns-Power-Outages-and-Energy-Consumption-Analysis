import os
import time
from selenium import webdriver
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support import expected_conditions as EC

# Define the path to the geckodriver
firefox_service = FirefoxService(executable_path='/usr/local/bin/geckodriver')

# Set up Firefox options (if needed)
firefox_options = FirefoxOptions()

# Initialize the Firefox WebDriver
driver = webdriver.Firefox(service=firefox_service, options=firefox_options)

# Function to select the year, month, and day, and download the weather data
def download_weather_data(year, month):
    try:
        # Open the URL for hourly weather data for the station
        # For Toroto City Station:
        # driver.get('https://climate.weather.gc.ca/climate_data/hourly_data_e.html?StationID=31688&Prov=ON')

        # For Toronto International Airport:
        driver.get('https://climate.weather.gc.ca/climate_data/hourly_data_e.html?StationID=51459&Prov=ON')


        # Select the year from the dropdown menu (assuming it's in a dropdown with name "Year1")
        WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.ID, "Year1")))
        Select(driver.find_element(By.ID, "Year1")).select_by_value(str(year))

        # Select the month from the dropdown menu
        Select(driver.find_element(By.ID, "Month1")).select_by_value(str(month))

        # Select the first day (Day 1) to load the month (can change this to select a specific day if needed)
        Select(driver.find_element(By.ID, "Day1")).select_by_value("1")

        # Click the "Go" button to load the data for the selected year and month
        go_button = WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.XPATH, '//input[@value="Go"]')))
        go_button.click()
        print(f"Go button clicked for {year}-{month}.")

        # Wait for the "Download Data" button to be clickable and click it
        download_button = WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.XPATH, '//input[@value="Download Data"]')))
        download_button.click()
        print(f"Download Data button clicked for {year}-{month}.")
        
        # Wait for the file to download (adjust based on your system's download speed)
        time.sleep(5)

    except Exception as e:
        print(f"Error occurred while downloading data for {year}-{month}: {e}")

# Loop through each month of each year and download data
for year in range(2018, 2025):  # Loop through years from 2018 to 2024
    for month in range(1, 13):  # Loop through all 12 months
        download_weather_data(year, month)

# Close the browser when done
driver.quit()
