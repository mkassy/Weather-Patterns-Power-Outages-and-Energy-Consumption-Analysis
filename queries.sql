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

CREATE TABLE IF NOT EXISTS staging_hourly_outage_data (
    "UtilityName" VARCHAR(100),
    "StateName" VARCHAR(50),
    "CountyName" VARCHAR(100),
    "CityName" VARCHAR(100),
    "CustomersTracked" INTEGER,
    "CustomersOut" INTEGER,
    "RecordDateTime" TIMESTAMP
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


CREATE TABLE IF NOT EXISTS staging_hourly_weather_data (
    longitude_x FLOAT,  
    latitude_y FLOAT,  
    station_name TEXT,  
    climate_id BIGINT,  
    date_time_lst TIMESTAMP,  
    year INT,  
    month INT,  
    day INT,  
    time_lst TEXT,  
    temp_c FLOAT,  
    temp_flag TEXT,  
    dew_point_temp_c FLOAT,  
    dew_point_temp_flag TEXT,  
    rel_hum_percent FLOAT,  -- Change to FLOAT to handle values like 79.0
    rel_hum_flag TEXT,  
    precip_amount_mm FLOAT,  
    precip_amount_flag TEXT,  
    wind_dir_10s_deg FLOAT,  
    wind_dir_flag TEXT,  
    wind_spd_kmh FLOAT,  
    wind_spd_flag TEXT,  
    visibility_km FLOAT,  
    visibility_flag TEXT,  
    stn_press_kpa FLOAT,  
    stn_press_flag TEXT,  
    hmdx FLOAT,  
    hmdx_flag TEXT,  
    wind_chill FLOAT,  
    wind_chill_flag TEXT,  
    weather TEXT  
);

CREATE TABLE IF NOT EXISTS staging_hourly_weather_data_with_wind (
    longitude_x FLOAT,  
    latitude_y FLOAT,  
    station_name TEXT,  
    climate_id BIGINT,  
    date_time_lst TIMESTAMP,  
    year INT,  
    month INT,  
    day INT,  
    time_lst TEXT,  
    temp_c FLOAT,  
    temp_flag TEXT,  
    dew_point_temp_c FLOAT,  
    dew_point_temp_flag TEXT,  
    rel_hum_percent FLOAT,  -- Change to FLOAT to handle values like 79.0
    rel_hum_flag TEXT,  
    precip_amount_mm FLOAT,  
    precip_amount_flag TEXT,  
    wind_dir_10s_deg FLOAT,  
    wind_dir_flag TEXT,  
    wind_spd_kmh FLOAT,  
    wind_spd_flag TEXT,  
    visibility_km FLOAT,  
    visibility_flag TEXT,  
    stn_press_kpa FLOAT,  
    stn_press_flag TEXT,  
    hmdx FLOAT,  
    hmdx_flag TEXT,  
    wind_chill FLOAT,  
    wind_chill_flag TEXT,  
    weather TEXT  
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


-- Create toronto_outage_data table by combining data from staging_outage_data and aggregated staging_hourly_outage_data
CREATE TABLE IF NOT EXISTS toronto_outage_data AS
-- Manually reported outages from staging_outage_data
SELECT 
    "Company_Name" AS "Company_Name",  -- Explicitly select "Company_Name" for clarity
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
FROM 
    staging_outage_data
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
    OR "Third_Party_Assistance" ILIKE '%GTA%'

UNION ALL

-- Aggregated hourly outages from staging_hourly_outage_data
SELECT 
    "UtilityName" AS "Company_Name",  -- Map "UtilityName" from hourly data to "Company_Name"
    EXTRACT(YEAR FROM "RecordDateTime") AS "Year", 
    NULL AS "Submitted_On", 
    DATE("RecordDateTime") AS "Event_Date", 
    NULL AS "Event_Time", 
    NULL AS "Prior_Distributor_Warning", 
    NULL AS "Main_Contributing_Event", 
    NULL AS "Brief_Description", 
    NULL AS "ETR_Issued", 
    NULL AS "ETR_Issued_Details", 
    SUM("CustomersOut") AS "Number_of_Customers_Interrupted", 
    NULL AS "Percentage_Customers_Interrupted", 
    NULL AS "Hours_to_Restore_Ninety_Percent", 
    NULL AS "Outages_Loss_of_Supply"
FROM 
    staging_hourly_outage_data
GROUP BY 
    "UtilityName", EXTRACT(YEAR FROM "RecordDateTime"), DATE("RecordDateTime")
ORDER BY 
    "Event_Date";


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
-- CREATE TABLE IF NOT EXISTS toronto_weather_energy_outages_data AS
-- SELECT 
--     COALESCE(to_data."Event_Date", te.date) AS date,  -- Combine the two date columns
--     te.fsa, 
--     te.customer_type,
--     te.price_plan, 
--     te.daily_total_consumption_kWh, 
--     te.total_premises,
--     tw.latitude,
--     tw.longitude,
--     tw.precipitation_mm, 
--     tw.snow_depth_mm, 
--     tw.avg_temperature_celsius, 
--     tw.max_temperature_celsius, 
--     tw.min_temperature_celsius,
--     COALESCE(to_data."Company_Name", 'No Outage') AS "Company_Name",  -- Fallback for non-outage days
--     COALESCE(to_data."Number_of_Customers_Interrupted", 0) AS "Number_of_Customers_Interrupted",  -- Default to 0 if no outage
--     COALESCE(to_data."Percentage_Customers_Interrupted", 0) AS "Percentage_Customers_Interrupted",  -- Default to 0
--     COALESCE(to_data."Hours_to_Restore_Ninety_Percent", 0) AS "Hours_to_Restore_Ninety_Percent"  -- Default to 0
-- FROM 
--     toronto_energy_data te
-- JOIN 
--     toronto_weather_data tw
-- ON 
--     te.date = tw.date
-- LEFT JOIN 
--     toronto_outage_data to_data
-- ON 
--     te.date = to_data."Event_Date"  -- Keep all rows from energy and weather data, include outages where they exist
-- ORDER BY 
--     te.date;



-- MASTER TABLE with HOURLY data for TORONTO

-- Create toronto_hourly_weather_energy_outages_data with hourly data at the city level
-- CREATE TABLE IF NOT EXISTS toronto_hourly_weather_energy_outages_data AS
-- SELECT 
--     COALESCE(sho."RecordDateTime", she.date + she.hour * INTERVAL '1 hour') AS date_hour,  -- Combine dates to retain hourly data
--     she.customer_type,
--     she.price_plan,
--     SUM(she.total_consumption) AS hourly_total_consumption_kWh, 
--     SUM(she.premise_count) AS total_premises,
--     shw.latitude_y AS latitude,
--     shw.longitude_x AS longitude,
--     AVG(shw.temp_c) AS avg_temperature_celsius,
--     AVG(shw.dew_point_temp_c) AS avg_dew_point_celsius,
--     AVG(shw.rel_hum_percent) AS avg_relative_humidity_percent,
--     SUM(shw.precip_amount_mm) AS hourly_precipitation_mm,
--     AVG(shw.wind_spd_kmh) AS avg_wind_speed_kmh,
--     AVG(shw.stn_press_kpa) AS avg_station_pressure_kpa,
--     COALESCE(sho."UtilityName", 'No Outage') AS "UtilityName",
--     COALESCE(SUM(sho."CustomersOut"), 0) AS "CustomersOut"  -- Total number of customers affected by outages hourly
-- FROM 
--     staging_energy_data she
-- JOIN 
--     staging_hourly_weather_data shw 
-- ON 
--     she.date = DATE(shw.date_time_lst) AND she.hour = EXTRACT(HOUR FROM shw.date_time_lst)  -- Matching by date and hour
-- LEFT JOIN 
--     staging_hourly_outage_data sho 
-- ON 
--     she.date = DATE(sho."RecordDateTime") AND she.hour = EXTRACT(HOUR FROM sho."RecordDateTime")  -- Matching outages by date and hour
-- WHERE 
--     she.fsa LIKE 'M%'  -- Only Toronto FSAs
-- GROUP BY 
--     date_hour, she.customer_type, she.price_plan, shw.latitude_y, shw.longitude_x, sho."UtilityName"
-- ORDER BY 
--     date_hour;


CREATE TABLE IF NOT EXISTS merged_hourly_weather_data AS
SELECT 
    -- Date and time for hourly data
    COALESCE(shwd.date_time_lst, shww.date_time_lst) AS date_time_lst,  -- Use COALESCE to merge date_time
    
    -- Location and station identifiers
    shwd.latitude_y AS latitude_city,
    shwd.longitude_x AS longitude_city,
    shww.latitude_y AS latitude_intl,
    shww.longitude_x AS longitude_intl,
    shwd.station_name AS station_name_city,
    shww.station_name AS station_name_intl,
    shwd.climate_id AS climate_id_city,
    shww.climate_id AS climate_id_intl,

    -- Temperature columns: Separate for each dataset, plus an average
    shwd.temp_c AS temp_c_city,  -- Temperature from City dataset
    shww.temp_c AS temp_c_intl,  -- Temperature from Toronto Intl A dataset
    CASE 
        WHEN shwd.temp_c IS NOT NULL AND shww.temp_c IS NOT NULL 
            THEN (shwd.temp_c + shww.temp_c) / 2  -- Average if both values are present
        ELSE COALESCE(shwd.temp_c, shww.temp_c)  -- Use whichever is available
    END AS avg_temp_celsius,
    
    -- Dew point and relative humidity: Average or keep both
    CASE 
        WHEN shwd.dew_point_temp_c IS NOT NULL AND shww.dew_point_temp_c IS NOT NULL 
            THEN (shwd.dew_point_temp_c + shww.dew_point_temp_c) / 2
        ELSE COALESCE(shwd.dew_point_temp_c, shww.dew_point_temp_c)
    END AS avg_dew_point_celsius,
    shwd.rel_hum_percent AS rel_hum_percent_city,
    shww.rel_hum_percent AS rel_hum_percent_intl,
    
    -- Wind data: Only from Toronto Intl A
    shww.wind_dir_10s_deg AS wind_dir_10s_deg,
    shww.wind_spd_kmh AS wind_spd_kmh,
    
    -- Additional fields
    shww.visibility_km AS visibility_km,  -- Visibility only from Toronto Intl A
    shwd.precip_amount_mm AS precip_amount_mm,  -- Precipitation only from Toronto City
    COALESCE(shwd.stn_press_kpa, shww.stn_press_kpa) AS avg_station_pressure_kpa,
    COALESCE(shwd.hmdx, shww.hmdx) AS hmdx,
    COALESCE(shwd.wind_chill, shww.wind_chill) AS wind_chill,
    
    -- Weather description: Use only from Toronto Intl A dataset
    shww.weather AS weather  -- Use weather data only from Toronto Intl A

FROM 
    staging_hourly_weather_data shwd
FULL OUTER JOIN 
    staging_hourly_weather_data_with_wind shww
ON 
    shwd.date_time_lst = shww.date_time_lst;  -- Join on timestamp for hourly data alignment
