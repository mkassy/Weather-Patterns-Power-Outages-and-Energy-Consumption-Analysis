-- Create tables

-- Create the energy_data table
CREATE TABLE IF NOT EXISTS energy_data (
    FSA VARCHAR(10),
    DATE DATE,
    HOUR INTEGER,
    CUSTOMER_TYPE VARCHAR(50),
    PRICE_PLAN VARCHAR(50),
    TOTAL_CONSUMPTION NUMERIC,
    PREMISE_COUNT INTEGER
);

-- Create daily consumption summary table for Toronto FSAs
CREATE TABLE IF NOT EXISTS daily_energy_consumption (
    FSA VARCHAR(10),
    DATE DATE,
    CUSTOMER_TYPE VARCHAR(50),
    daily_consumption NUMERIC
);

-- Insert aggregated data
INSERT INTO daily_energy_consumption (FSA, DATE, CUSTOMER_TYPE, daily_consumption)
SELECT 
    FSA, 
    DATE, 
    CUSTOMER_TYPE, 
    SUM(TOTAL_CONSUMPTION) AS daily_consumption
FROM 
    energy_data
WHERE 
    FSA LIKE 'M%'  -- Toronto FSAs
GROUP BY 
    FSA, DATE, CUSTOMER_TYPE
ORDER BY 
    FSA, DATE, CUSTOMER_TYPE;


-- Create the outages table
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
    Future_Actions TEXT
);


-- Create the weather_data table
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
    tmin_attributes TEXT
);

-- Copy data

-- Query data
-- Outage Events and Their Causes
SELECT Event_Date, Main_Contributing_Event, Number_of_Customers_Interrupted, Hours_to_Restore_Ninety_Percent
FROM outages
WHERE Event_Date BETWEEN '2018-01-01' AND '2024-01-01';

-- Weather Extremes and Energy Consumption
SELECT weather_data.DATE, TMAX, TMIN, SUM(energy_data.TOTAL_CONSUMPTION) AS total_energy
FROM weather_data
JOIN energy_data ON weather_data.DATE = energy_data.DATE
WHERE weather_data.TMAX > 30 OR weather_data.TMIN < -10  -- Extreme temperatures
GROUP BY weather_data.DATE, weather_data.TMAX, weather_data.TMIN;

-- Linking Weather, Power Outages, and Energy Consumption
SELECT weather_data.DATE, TMAX, TMIN, outages.Number_of_Customers_Interrupted, SUM(energy_data.TOTAL_CONSUMPTION) AS total_energy
FROM weather_data
JOIN outages ON weather_data.DATE = outages.Event_Date
JOIN energy_data ON weather_data.DATE = energy_data.DATE
WHERE weather_data.TMAX > 35 OR weather_data.TMIN < -15  -- Hot and cold extremes
GROUP BY weather_data.DATE, TMAX, TMIN, outages.Number_of_Customers_Interrupted;

-- List tables
\dt;
