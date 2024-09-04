# Weather-Patterns-Power-Outages-and-Energy-Consumption-Analysis

This project analyzes the relationship between weather patterns, residential energy consumption, and power outages from 2004 to 2024. It aims to uncover how weather extremes impact energy use and power reliability.

## Table of Contents

1. [Introduction](#introduction)
2. [Datasets](#datasets)
   - [Weather Data](#weather-data)
   - [Energy Consumption Data](#energy-consumption-data)
   - [Power Outage Data](#power-outage-data)
3. [Setup](#setup)
   - [Requirements](#requirements)
   - [Installation](#installation)
4. [Usage](#usage)
   - [Running the Analysis](#running-the-analysis)
   - [Data Files](#data-files)
5. [Analysis](#analysis)
   - [Methods](#methods)
   - [Scripts](#scripts)
6. [Results](#results)
   - [Findings](#findings)
7. [Contributing](#contributing)
   - [How to Contribute](#how-to-contribute)
8. [License](#license)
9. [Contact](#contact)

## Introduction

The goal of this project is to explore how extreme weather conditions affect energy consumption in residential areas and the occurrence of power outages. The analysis will cover:

- The correlation between extreme weather events and power outages.
- The impact of weather extremes on energy consumption, particularly for heating and cooling.
- The effect of power outages on energy consumption patterns and infrastructure resilience.

## Datasets

### Weather Data

- **Source:** [NCEI](https://www.ncei.noaa.gov/cdo-web/search)
- **Coverage:** 2014-01-01 to 2024-08-25
- **Types of Data:** Temperature highs/lows, precipitation, storm frequency, etc.
- **Format:** CSV

### Energy Consumption Data

- **Source:** [IESO](http://reports.ieso.ca/public/HourlyConsumptionByFSA/)
- **Coverage:** 2018-01-01 to 2024-04-23
- **Types of Data:** Residential energy usage, segmented by time and weather conditions

### Power Outage Data

- **Source:** [OEB](https://www.oeb.ca/open-data/electricity-reporting-record-keeping-requirements-rrr-section-214210-major-event-response)
- **Coverage:** 2016-01-01 to 2023-01-01
- **Types of Data:** Frequency, duration, and causes of power outages

## Setup

### Requirements

- Python 3.x
- Required libraries: pandas, numpy, matplotlib, sqlite3 or SQLAlchemy (for SQL integration)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/weather-energy-power-analysis.git

2. Navigate to the project directory:
   ```bash
   cd weather-energy-power-analysis

3. Install dependencies:
   ```bash
   pip install -r requirements.txt

## Usage

### Running the Analysis

1. Place the weather data CSV files in the data/weather directory.

2. Place the energy consumption data files in the data/energy directory.

3. Place the power outage data files in the data/outages directory.

4. Run the analysis script:
   ```bash
   python analyze.py

### Data Files

- data/weather/ - Directory containing weather data CSV files.
- data/energy/ - Directory containing energy consumption data files.
- data/outages/ - Directory containing power outage data files.

## Analysis

### Methods

The analysis will involve the following steps:

1. Data Cleaning and Preprocessing: Handle missing values and ensure consistency across datasets.

2. Exploratory Data Analysis:  Initial analysis to understand data distribution and trends.

3. Correlation and Regression Analysis: Analyze relationships between weather patterns, energy consumption, and power outages.

4. Time Series Analysis: Examine trends and seasonal variations.

### Scripts

- `analyze.py`: Main script to run the analysis.
- `data_cleaning.py`: Functions for cleaning and preprocessing data.

## Results

### Findings

- Correlations between weather extremes and energy usage.
- Insights into how weather conditions affect power outage frequency and duration.
- Recommendations for improving energy infrastructure resilience.


## Contributing

### How to Contribute

1. Fork the repository and make changes in a separate branch.
2. Submit a pull request explaining the changes made.
3. Ensure your code follows the project's coding standards and includes appropriate tests.


## License
This project is licensed under the MIT License. See the LICENSE file for details.


## Contact

For any questions or collaboration inquiries, please contact:

    Name: Maha Haj-Kasem
    Email: maha.kasem@protonmail.com
    GitHub: https://github.com/mkassy






