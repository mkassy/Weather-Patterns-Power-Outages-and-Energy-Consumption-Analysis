# Data Preparation Guide

## Overview

This guide provides instructions for downloading, organizing, cleaning, and loading data required for the Weather Patterns, Power Outages, and Energy Consumption Analysis project.

## Data Preparation Steps

### 1. Downloading Data

To download the hourly energy consumption data, use the script download_webfiles.py:

```bash
python download_webfiles.py
```
This script will automatically download all the necessary files from the specified URLs and place them into the appropriate directories.

### 2. Organizing Data

After downloading, organize the CSV files into their respective year folders using organize_csv.py.

```bash
python organize_csv.py
```
This script will create folders for each year and move the corresponding CSV files into the appropriate folders.

### 3. Converting XML Data to CSV

The outage data is initially in XML format. Convert it to CSV using the following steps:

1. (Optional) Print XML Structure: If needed, print the XML structure to ensure that the convert_xml_to_csv.py script will handle the data correctly:

```bash
python print_xml_structure.py
```

2. Convert XML to CSV: Use the convert_xml_to_csv.py script to convert the XML data to CSV format:

```bash
python convert_xml_to_csv.py
```
This script will create a CSV file with the necessary headers for the outage data.

___

# Data Cleaning

Once the data is downloaded and put into its respective folders, we can clean the data and prepare it for analysis.

To perform the data cleaning, run the clean_data.py script:

```bash
python clean_data.py
```
This script will:

### 1. Clean the Energy Data:

     - Remove metadata and error lines, and detect the correct header row dynamically for each CSV file.
    
    - Handle missing values for both string and numeric columns.
    
    - Strip whitespaces from string columns and ensure no critical data is lost.
    
    - Save the cleaned data in the cleaned-data/energy/ directory with a consistent folder structure.

### 2. Clean the Outage Data:

    - Parse and normalize date fields (Submitted_On, Event_Date) into the YYYY-MM-DD format.
    
    - Normalize time fields to 24-hour time format or parse them as 12-hour time where applicable.

    - Remove leading/trailing whitespaces from all string columns.

    - Standardize categorical data (e.g., replacing different variations of No).

    - Handle missing values by filling in defaults or removing incomplete rows.
    
    - Drop unnecessary columns with excessive missing values.

### 3. Process Weather Data:

    - Handle missing values for both string and numeric columns.

    - Clean up the dataset by removing unnecessary whitespace and saving the cleaned weather data to a dedicated folder.


The cleaned data will be saved in the cleaned-data directory, following the same folder structure as the original data.

___

# Data Loading

### 1. Start PostgreSQL
Ensure the PostgreSQL service is running. You can also type this into the command line:

```bash
psql -U postgres

```

### 2. Create Database
Create a database using either pgAdmin or the command line:

```sql
CREATE DATABASE mydatabase;

```

### 3. Exit PostgreSQL
Type \q to exit the PostgreSQL command-line interface.

### 4. Load Data into Database
Use the load_data.py script to load the cleaned data into the PostgreSQL database:

```bash
python load_data.py
```

This script load all the cleaned data into the PostgreSQL database, ready for analysis.