-- Create staging tables
CREATE TABLE IF NOT EXISTS staging_energy_data (
    FSA VARCHAR(10),
    DATE DATE,
    HOUR INTEGER,
    CUSTOMER_TYPE VARCHAR(50),
    PRICE_PLAN VARCHAR(50),
    TOTAL_CONSUMPTION NUMERIC,
    PREMISE_COUNT INTEGER
);

CREATE TABLE IF NOT EXISTS staging_outages (
    Company_Name TEXT,
    Year INTEGER,
    Submitted_On DATE,
    Event_Date DATE,
    Prior_Distributor_Warning TEXT,
    Event_Time TIME,
    Prior_Distributor_Warning_Details TEXT,
    Extra_Employees_On_Duty TEXT,
    Staff_Trained_Response_Plan TEXT,
    Media_Announcements TEXT,
    Main_Contributing_Event TEXT,
    Brief_Description TEXT,
    IEEE_Standard_Used TEXT,
    ETR_Issued TEXT,
    ETR_Issued_Details TEXT,
    Number_of_Customers_Interrupted INTEGER,
    Percentage_Customers_Interrupted NUMERIC,
    Hours_to_Restore_Ninety_Percent NUMERIC,
    Outages_Loss_of_Supply TEXT,
    Need_Equipment_or_Materials TEXT,
    Future_Actions TEXT
);

CREATE TABLE IF NOT EXISTS staging_weather_data (
    station VARCHAR(20),
    name TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    elevation NUMERIC,
    date DATE,
    prcp NUMERIC,
    prcp_attributes TEXT,
    snwd NUMERIC,
    snwd_attributes TEXT,
    tavg NUMERIC,
    tavg_attributes TEXT,
    tmax NUMERIC,
    tmax_attributes TEXT,
    tmin NUMERIC,
    tmin_attributes TEXT
);

-- Create final tables with constraints
CREATE TABLE IF NOT EXISTS energy_data (
    FSA VARCHAR(10),
    DATE DATE,
    HOUR INTEGER,
    CUSTOMER_TYPE VARCHAR(50),
    PRICE_PLAN VARCHAR(50),
    TOTAL_CONSUMPTION NUMERIC,
    PREMISE_COUNT INTEGER,
    PRIMARY KEY (FSA, DATE, HOUR, CUSTOMER_TYPE)  -- Ensure uniqueness
);

CREATE TABLE IF NOT EXISTS daily_energy_consumption (
    FSA VARCHAR(10),
    DATE DATE,
    CUSTOMER_TYPE VARCHAR(50),
    daily_consumption NUMERIC,
    daily_premise_count INTEGER,
    PRIMARY KEY (FSA, DATE, CUSTOMER_TYPE)  -- Ensure uniqueness
);

CREATE TABLE IF NOT EXISTS outages (
    Company_Name TEXT,
    Year INTEGER,
    Submitted_On DATE,
    Event_Date DATE,
    Prior_Distributor_Warning TEXT,
    Event_Time TIME,
    Prior_Distributor_Warning_Details TEXT,
    Extra_Employees_On_Duty TEXT,
    Staff_Trained_Response_Plan TEXT,
    Media_Announcements TEXT,
    Main_Contributing_Event TEXT,
    Brief_Description TEXT,
    IEEE_Standard_Used TEXT,
    ETR_Issued TEXT,
    ETR_Issued_Details TEXT,
    Number_of_Customers_Interrupted INTEGER,
    Percentage_Customers_Interrupted NUMERIC,
    Hours_to_Restore_Ninety_Percent NUMERIC,
    Outages_Loss_of_Supply TEXT,
    Need_Equipment_or_Materials TEXT,
    Future_Actions TEXT,
    PRIMARY KEY (Event_Date, Company_Name, Year)  -- Ensure uniqueness
);

CREATE TABLE IF NOT EXISTS weather_data (
    station VARCHAR(20),
    name TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    elevation NUMERIC,
    date DATE,
    prcp NUMERIC,
    prcp_attributes TEXT,
    snwd NUMERIC,
    snwd_attributes TEXT,
    tavg NUMERIC,
    tavg_attributes TEXT,
    tmax NUMERIC,
    tmax_attributes TEXT,
    tmin NUMERIC,
    tmin_attributes TEXT,
    PRIMARY KEY (station, date)  -- Ensure uniqueness
);

-- Create indexes to optimize query performance
CREATE INDEX IF NOT EXISTS idx_energy_data_date_fsa ON energy_data (DATE, FSA);
CREATE INDEX IF NOT EXISTS idx_weather_data_date ON weather_data (date);
CREATE INDEX IF NOT EXISTS idx_outages_event_date ON outages (Event_Date);


-- Check for duplicates in energy_data
SELECT FSA, DATE, HOUR, CUSTOMER_TYPE, COUNT(*)
FROM energy_data
GROUP BY FSA, DATE, HOUR, CUSTOMER_TYPE
HAVING COUNT(*) > 1;

-- Check for duplicates in weather_data
SELECT station, date, COUNT(*)
FROM weather_data
GROUP BY station, date
HAVING COUNT(*) > 1;

-- Check for duplicates in outages
SELECT Event_Date, Company_Name, Year, COUNT(*)
FROM outages
GROUP BY Event_Date, Company_Name, Year
HAVING COUNT(*) > 1;
