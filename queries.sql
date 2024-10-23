-- Create staging tables
CREATE TABLE IF NOT EXISTS staging_energy_data (
    fsa VARCHAR(10),
    date DATE,
    hour INTEGER,
    customer_type VARCHAR(50),
    price_plan VARCHAR(50),
    total_consumption NUMERIC,
    premise_count INTEGER
);

CREATE TABLE IF NOT EXISTS staging_outage_data (
    "Company_Name" TEXT,
    "Year" INTEGER,
    "Submitted_On" DATE,
    "Event_Date" DATE,
    "Prior_Distributor_Warning" TEXT,
    "Event_Time" TIME,
    "Prior_Distributor_Warning_Details" TEXT,
    "Extra_Employees_On_Duty" TEXT,
    "Staff_Trained_Response_Plan" TEXT,
    "Media_Announcements" TEXT,
    "Main_Contributing_Event" TEXT,
    "Brief_Description" TEXT,
    "IEEE_Standard_Used" TEXT,
    "ETR_Issued" TEXT,
    "ETR_Issued_Details" TEXT,
    "Number_of_Customers_Interrupted" INTEGER,
    "Percentage_Customers_Interrupted" NUMERIC,
    "Hours_to_Restore_Ninety_Percent" NUMERIC,
    "Hours_to_Restore_Ninety_Percent_Comments" TEXT,
    "Outages_Loss_of_Supply" TEXT,
    "Third_Party_Assistance_Details" TEXT, 
    "Need_Equipment_or_Materials" TEXT,
    "Future_Actions" TEXT,
    "No_Arrangements_Extra_Employees" TEXT,  
    "Third_Party_Assistance" TEXT
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


CREATE TABLE IF NOT EXISTS staging_hourly_outage_data (
    UtilityName VARCHAR(100),
    StateName VARCHAR(50),
    CountyName VARCHAR(100),
    CityName VARCHAR(100),
    CustomersTracked INTEGER,
    CustomersOut INTEGER,
    RecordDateTime TIMESTAMP
);


-- Create daily energy data table if it doesn't exist
CREATE TABLE IF NOT EXISTS toronto_energy_data AS
SELECT 
    fsa,
    date,
    price_plan,
    customer_type,
    SUM(total_consumption) AS daily_total_consumption_kWh,
    SUM(premise_count) AS total_premises
FROM 
    staging_energy_data
WHERE 
    fsa LIKE 'M%'  -- Filter for Toronto FSAs (those starting with 'M')
GROUP BY 
    fsa, date, price_plan, customer_type 
ORDER BY 
    date;


-- Create toronto outage data table if it doesn't exist
-- Create toronto outage data table with relevant fields for analysis
CREATE TABLE IF NOT EXISTS toronto_outage_data AS
SELECT 
    "Company_Name", 
    "Year", 
    "Submitted_On", 
    "Event_Date", 
    "Event_Time", 
    "Prior_Distributor_Warning", 
    "Main_Contributing_Event", 
    "Brief_Description", 
    "ETR_Issued", 
    "ETR_Issued_Details", 
    "Number_of_Customers_Interrupted", 
    "Percentage_Customers_Interrupted", 
    "Hours_to_Restore_Ninety_Percent", 
    "Outages_Loss_of_Supply"
FROM staging_outage_data
WHERE 
    "Company_Name" ILIKE '%Toronto%' 
    OR "Company_Name" ILIKE '%GTA%'
    OR "Brief_Description" ILIKE '%Toronto%'
    OR "Brief_Description" ILIKE '%GTA%'
    OR "Prior_Distributor_Warning_Details" ILIKE '%Toronto%'
    OR "Prior_Distributor_Warning_Details" ILIKE '%GTA%'
    OR "ETR_Issued_Details" ILIKE '%Toronto%'
    OR "ETR_Issued_Details" ILIKE '%GTA%'
    OR "No_Arrangements_Extra_Employees" ILIKE '%Toronto%'
    OR "No_Arrangements_Extra_Employees" ILIKE '%GTA%'
    OR "Third_Party_Assistance" ILIKE '%Toronto%'
    OR "Third_Party_Assistance" ILIKE '%GTA%';


-- Create toronto weather data table if it doesn't exist
CREATE TABLE IF NOT EXISTS toronto_weather_data AS
SELECT 
    station,
    latitude,
    longitude,
    date, 
    prcp AS precipitation_mm, 
    snwd AS snow_depth_mm, 
    tavg AS avg_temperature_celsius, 
    tmax AS max_temperature_celsius, 
    tmin AS min_temperature_celsius
FROM staging_weather_data
WHERE name ILIKE '%Toronto%';


-- Create a combined table with energy, weather, and outage data (including non-outage days)
CREATE TABLE IF NOT EXISTS toronto_weather_energy_outages_data AS
SELECT 
    COALESCE(to_data."Event_Date", te.date) AS date,  -- Combine the two date columns
    te.fsa, 
    te.customer_type,
    te.price_plan, 
    te.daily_total_consumption_kWh, 
    te.total_premises,
    tw.latitude,
    tw.longitude,
    tw.precipitation_mm, 
    tw.snow_depth_mm, 
    tw.avg_temperature_celsius, 
    tw.max_temperature_celsius, 
    tw.min_temperature_celsius,
    to_data."Company_Name",  -- Will be NULL on non-outage days
    to_data."Number_of_Customers_Interrupted",  -- Will be NULL on non-outage days
    to_data."Percentage_Customers_Interrupted",  -- Will be NULL on non-outage days
    to_data."Hours_to_Restore_Ninety_Percent"  -- Will be NULL on non-outage days
FROM 
    toronto_energy_data te
JOIN 
    toronto_weather_data tw
ON 
    te.date = tw.date
LEFT JOIN 
    toronto_outage_data to_data
ON 
    te.date = to_data."Event_Date";  -- Keep all rows from energy and weather data, include outages where they exist
