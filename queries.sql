-- Create staging tables
CREATE TABLE IF NOT EXISTS staging_hourly_energy_data (
    fsa VARCHAR(10),
    date DATE,
    hour INTEGER,
    customer_type VARCHAR(50),
    price_plan VARCHAR(50),
    total_consumption NUMERIC,
    premise_count INTEGER
);

-- CREATE TABLE IF NOT EXISTS staging_outage_data (
--     "Company_Name" TEXT,
--     "Year" INTEGER,
--     "Submitted_On" DATE,
--     "Event_Date" DATE,
--     "Prior_Distributor_Warning" TEXT,
--     "Event_Time" TIME,
--     "Prior_Distributor_Warning_Details" TEXT,
--     "Extra_Employees_On_Duty" TEXT,
--     "Staff_Trained_Response_Plan" TEXT,
--     "Media_Announcements" TEXT,
--     "Main_Contributing_Event" TEXT,
--     "Brief_Description" TEXT,
--     "IEEE_Standard_Used" TEXT,
--     "ETR_Issued" TEXT,
--     "ETR_Issued_Details" TEXT,
--     "Number_of_Customers_Interrupted" INTEGER,
--     "Percentage_Customers_Interrupted" NUMERIC,
--     "Hours_to_Restore_Ninety_Percent" NUMERIC,
--     "Hours_to_Restore_Ninety_Percent_Comments" TEXT,
--     "Outages_Loss_of_Supply" TEXT,
--     "Third_Party_Assistance_Details" TEXT, 
--     "Need_Equipment_or_Materials" TEXT,
--     "Future_Actions" TEXT,
--     "No_Arrangements_Extra_Employees" TEXT,  
--     "Third_Party_Assistance" TEXT
-- );

CREATE TABLE IF NOT EXISTS staging_hourly_outage_data (
    "UtilityName" VARCHAR(100),
    "StateName" VARCHAR(50),
    "CountyName" VARCHAR(100),
    "CityName" VARCHAR(100),
    "CustomersTracked" INTEGER,
    "CustomersOut" INTEGER,
    "RecordDateTime" TIMESTAMP
);

-- CREATE TABLE IF NOT EXISTS staging_weather_data (
--     station VARCHAR(20),
--     name TEXT,
--     latitude NUMERIC,
--     longitude NUMERIC,
--     elevation NUMERIC,
--     date DATE,
--     prcp NUMERIC,
--     prcp_attributes TEXT,
--     snwd NUMERIC,
--     snwd_attributes TEXT,
--     tavg NUMERIC,
--     tavg_attributes TEXT,
--     tmax NUMERIC,
--     tmax_attributes TEXT,
--     tmin NUMERIC,
--     tmin_attributes TEXT
-- );


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


-- Create daily energy data table if it doesn't exist
-- CREATE TABLE IF NOT EXISTS toronto_energy_data AS
-- SELECT 
--     fsa,
--     date,
--     price_plan,
--     customer_type,
--     SUM(total_consumption) AS daily_total_consumption_kWh,
--     SUM(premise_count) AS total_premises
-- FROM 
--     staging_energy_data
-- WHERE 
--     fsa LIKE 'M%'  -- Filter for Toronto FSAs (those starting with 'M')
-- GROUP BY 
--     fsa, date, price_plan, customer_type 
-- ORDER BY 
--     date;


-- city level table (aggregate data)

CREATE TABLE IF NOT EXISTS toronto_city_energy_data AS
SELECT 
    date,
    hour,
    price_plan,
    customer_type,
    SUM(total_consumption) AS hourly_total_consumption_kWh,
    SUM(premise_count) AS total_premises
FROM 
    staging_hourly_energy_data
WHERE 
    fsa LIKE 'M%'  -- Filter for Toronto FSAs (those starting with 'M')
GROUP BY 
    date, hour, price_plan, customer_type
ORDER BY 
    date, hour;


-- Define weather extremes in Toronto
CREATE TABLE IF NOT EXISTS toronto_weather_extremes AS
SELECT 
    date_time_lst,
    latitude_city,
    longitude_city,
    latitude_intl,
    longitude_intl,
    station_name_city,
    station_name_intl,
    climate_id_city,
    climate_id_intl,
    
    -- Include temperature from both sources and the calculated average rounded to two decimal places
    temp_c_city,
    temp_c_intl,
    ROUND(CAST(avg_temp_celsius AS NUMERIC), 1) AS avg_temp_celsius,
    
    -- Dew point, humidity, and precipitation
    ROUND(CAST(avg_dew_point_celsius AS NUMERIC), 1) AS avg_dew_point_celsius,
    rel_hum_percent_city,
    rel_hum_percent_intl,
    precip_amount_mm,
    
    -- Wind speed, direction, and visibility
    wind_dir_10s_deg,
    wind_spd_kmh,
    visibility_km,
    
    -- Pressure, heat index, wind chill, and weather description
    ROUND(CAST(avg_station_pressure_kpa AS NUMERIC), 1) AS avg_station_pressure_kpa,
    hmdx,
    wind_chill,
    weather
    
FROM 
    merged_hourly_weather_data
WHERE 
    -- Temperature extremes
    temp_c_city <= -15 OR temp_c_intl <= -15 OR temp_c_city >= 30 OR temp_c_intl >= 30
    
    -- High wind speed
    OR wind_spd_kmh >= 50
    
    -- Low visibility
    OR visibility_km < 1
    
    -- High precipitation
    OR precip_amount_mm >= 10
    
    -- High or low humidity
    OR rel_hum_percent_city >= 90 OR rel_hum_percent_intl >= 90 
    OR rel_hum_percent_city <= 20 OR rel_hum_percent_intl <= 20
    
    -- Weather description indicating snow, fog, or extreme weather
    OR weather ILIKE '%Snow%' 
    OR weather ILIKE '%Fog%' 
    OR weather ILIKE '%Rain%' 
    OR weather ILIKE '%Thunderstorm%'
ORDER BY 
    date_time_lst;



-- MASTER TABLE WITH WEATHER EXTREMES AND ENERGY, OUTAGES DATA

CREATE TABLE IF NOT EXISTS toronto_combined_hourly_data AS
SELECT
    -- Date and time for hourly data
    COALESCE(mhwd.date_time_lst, tce.date + tce.hour * INTERVAL '1 hour', sho."RecordDateTime") AS date_time_lst,

    -- Weather data from merged_hourly_weather_data
    mhwd.latitude_city AS latitude_weather,
    mhwd.longitude_city AS longitude_weather,
    mhwd.station_name_city AS station_name_weather,
    mhwd.temp_c_city AS temp_c_weather_city,
    mhwd.temp_c_intl AS temp_c_weather_intl,
    ROUND(CAST(mhwd.avg_temp_celsius AS NUMERIC), 1) AS avg_temp_celsius,
    ROUND(CAST(mhwd.avg_dew_point_celsius AS NUMERIC), 1) AS avg_dew_point_celsius,
    mhwd.rel_hum_percent_city AS rel_humidity_weather_city,
    mhwd.rel_hum_percent_intl AS rel_humidity_weather_intl,
    ROUND(CAST(mhwd.precip_amount_mm AS NUMERIC), 1) AS precipitation_mm,
    mhwd.wind_dir_10s_deg AS wind_direction,
    ROUND(CAST(mhwd.wind_spd_kmh AS NUMERIC), 1) AS wind_speed_kmh,
    ROUND(CAST(mhwd.visibility_km AS NUMERIC), 1) AS visibility_km,
    ROUND(CAST(mhwd.avg_station_pressure_kpa AS NUMERIC), 1) AS avg_station_pressure_kpa,
    ROUND(CAST(mhwd.hmdx AS NUMERIC), 1) AS heat_index,
    ROUND(CAST(mhwd.wind_chill AS NUMERIC), 1) AS wind_chill,
    mhwd.weather AS weather_description,

    -- Energy data from toronto_city_energy_data
    tce.price_plan,
    tce.customer_type,
    tce.hourly_total_consumption_kWh,
    tce.total_premises,

    -- Outage data from staging_hourly_outage_data
    sho."UtilityName" AS outage_utility_name,
    sho."CustomersTracked" AS customers_tracked,
    sho."CustomersOut" AS customers_out

FROM 
    merged_hourly_weather_data mhwd
FULL OUTER JOIN 
    toronto_city_energy_data tce
ON 
    mhwd.date_time_lst = tce.date + tce.hour * INTERVAL '1 hour'
FULL OUTER JOIN 
    staging_hourly_outage_data sho
ON 
    mhwd.date_time_lst = sho."RecordDateTime"
ORDER BY 
    date_time_lst;
