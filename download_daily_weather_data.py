import os
import time
from selenium import webdriver
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support import expected_conditions as EC
from shutil import move

# Define the path to the geckodriver
firefox_service = FirefoxService(executable_path='/usr/local/bin/geckodriver')

# Set up Firefox options
firefox_options = FirefoxOptions()
download_dir = os.path.abspath("data/weather/toronto_daily_weather_with_prcp")  # Set your desired download path
if not os.path.exists(download_dir):
    os.makedirs(download_dir)  # Create the directory if it doesn't exist
firefox_profile = webdriver.FirefoxProfile()

# Set Firefox preferences for automatic downloads
firefox_profile.set_preference("browser.download.folderList", 2)  # Custom download directory
firefox_profile.set_preference("browser.download.dir", download_dir)
firefox_profile.set_preference("browser.helperApps.neverAsk.saveToDisk", "application/octet-stream,text/csv")
firefox_options.profile = firefox_profile

# Initialize the Firefox WebDriver
driver = webdriver.Firefox(service=firefox_service, options=firefox_options)

# Function to rename downloaded files based on year and month
def rename_downloaded_file(download_dir, year, month):
    base_name = f"en_climate_daily_ON_615S001_{year}_P1D.csv"
    downloaded_file = os.path.join(download_dir, base_name)

    # Handle duplicates (e.g., (1), (2) files)
    for attempt in range(5):  # Check up to 5 versions
        if attempt == 0 and os.path.exists(downloaded_file):
            break
        temp_file = os.path.join(download_dir, f"en_climate_daily_ON_615S001_{year}_P1D({attempt}).csv")
        if os.path.exists(temp_file):
            downloaded_file = temp_file
            break

    # Rename the file to include the year and month
    new_file_name = os.path.join(download_dir, f"daily_weather_{year}_{month:02d}.csv")
    if os.path.exists(downloaded_file):
        move(downloaded_file, new_file_name)
        print(f"File renamed to {new_file_name}.")
    else:
        print(f"File not found for {year}-{month}: {downloaded_file}")

# Function to select the year, month, and download the weather data
def download_daily_weather_data(year, month):
    try:
        # Open the URL for daily weather data for the station
        driver.get('https://climate.weather.gc.ca/climate_data/daily_data_e.html?hlyRange=%7C&dlyRange=1994-11-01%7C2024-11-17&mlyRange=1994-01-01%7C2006-12-01&StationID=26953&Prov=ON&urlExtension=_e.html&searchType=stnName&optLimit=specDate&StartYear=2018&EndYear=2024&selRowPerPage=25&Line=3&searchMethod=contains&Month=7&Day=8&txtStationName=toronto&timeframe=2&Year=2024')

        # Select the year from the dropdown menu
        WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.ID, "Year1")))
        Select(driver.find_element(By.ID, "Year1")).select_by_value(str(year))

        # Select the month from the dropdown menu
        WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.ID, "Month1")))
        Select(driver.find_element(By.ID, "Month1")).select_by_value(str(month))

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

        # Rename the file with a structured name
        rename_downloaded_file(download_dir, year, month)

    except Exception as e:
        print(f"Error occurred while downloading data for {year}-{month}: {e}")

# Loop through each month of each year and download data
for year in range(2018, 2025):  # Loop through years from 2018 to 2024
    for month in range(1, 13):  # Loop through all 12 months
        # Stop the loop at August 2024
        if year == 2024 and month > 8:
            break
        download_daily_weather_data(year, month)

# Close the browser when done
driver.quit()
