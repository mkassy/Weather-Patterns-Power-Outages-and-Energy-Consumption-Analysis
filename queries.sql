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

-- merged hourly weather data (intl and city)

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
    ROUND(
        CAST(
            CASE 
                WHEN shwd.temp_c IS NOT NULL AND shww.temp_c IS NOT NULL 
                    THEN (shwd.temp_c + shww.temp_c) / 2  -- Average if both values are present
                ELSE COALESCE(shwd.temp_c, shww.temp_c)  -- Use whichever is available
            END AS NUMERIC
        ), 1
    ) AS avg_temp_celsius,  -- Rounded to nearest tenth

    -- Dew point and relative humidity: Average or keep both
    ROUND(
        CAST(
            CASE 
                WHEN shwd.dew_point_temp_c IS NOT NULL AND shww.dew_point_temp_c IS NOT NULL 
                    THEN (shwd.dew_point_temp_c + shww.dew_point_temp_c) / 2
                ELSE COALESCE(shwd.dew_point_temp_c, shww.dew_point_temp_c)
            END AS NUMERIC
        ), 1
    ) AS avg_dew_point_celsius,  -- Rounded to nearest tenth
    shwd.rel_hum_percent AS rel_hum_percent_city,
    shww.rel_hum_percent AS rel_hum_percent_intl,
    ROUND(
        CAST(
            CASE 
                WHEN shwd.rel_hum_percent IS NOT NULL AND shww.rel_hum_percent IS NOT NULL 
                    THEN (shwd.rel_hum_percent + shww.rel_hum_percent) / 2
                ELSE COALESCE(shwd.rel_hum_percent, shww.rel_hum_percent)
            END AS NUMERIC
        ), 1
    ) AS avg_rel_hum_percent,  -- Rounded to nearest tenth
    
    -- Wind data: Only from Toronto Intl A
    shww.wind_dir_10s_deg AS wind_dir_10s_deg,
    shww.wind_spd_kmh AS wind_spd_kmh,
    
    -- Additional fields
    shww.visibility_km AS visibility_km,  -- Visibility only from Toronto Intl A
    shwd.precip_amount_mm AS precip_amount_mm,  -- Precipitation only from Toronto City
    ROUND(COALESCE(CAST(shwd.stn_press_kpa AS NUMERIC), CAST(shww.stn_press_kpa AS NUMERIC)), 1) AS avg_station_pressure_kpa,  -- Rounded to nearest tenth
    ROUND(COALESCE(CAST(shwd.hmdx AS NUMERIC), CAST(shww.hmdx AS NUMERIC)), 1) AS hmdx,  -- Rounded to nearest tenth
    ROUND(COALESCE(CAST(shwd.wind_chill AS NUMERIC), CAST(shww.wind_chill AS NUMERIC)), 1) AS wind_chill,  -- Rounded to nearest tenth
    
    -- Weather description: Use only from Toronto Intl A dataset
    shww.weather AS weather  -- Use weather data only from Toronto Intl A

FROM 
    staging_hourly_weather_data shwd
FULL OUTER JOIN 
    staging_hourly_weather_data_with_wind shww
ON 
    shwd.date_time_lst = shww.date_time_lst;  -- Join on timestamp for hourly data alignment


-- create daily weather data
CREATE TABLE IF NOT EXISTS toronto_daily_weather_data AS
SELECT 
    -- Extract date for daily aggregation
    CAST(DATE_TRUNC('day', date_time_lst) AS DATE) AS date,

    -- Temperature: Average, Max, and Min across both stations
    ROUND(AVG(avg_temp_celsius), 1) AS daily_avg_temp_celsius,
    ROUND(MAX(GREATEST(temp_c_city::numeric, temp_c_intl::numeric)), 1) AS daily_max_temp_c,  -- Max temp of both stations
    ROUND(MIN(LEAST(temp_c_city::numeric, temp_c_intl::numeric)), 1) AS daily_min_temp_c,     -- Min temp of both stations

    -- Dew Point
    ROUND(AVG(avg_dew_point_celsius), 1) AS daily_avg_dew_point_celsius,

    -- Relative Humidity
    ROUND(AVG(avg_rel_hum_percent), 1) AS avg_daily_relative_humidity,

    -- Precipitation
    ROUND(SUM(precip_amount_mm::numeric), 1) AS total_daily_precipitation_mm,

    -- Wind data: Average speed and predominant direction
    ROUND(AVG(wind_spd_kmh::numeric), 1) AS avg_daily_wind_speed_kmh,
    MODE() WITHIN GROUP (ORDER BY wind_dir_10s_deg) AS predominant_wind_direction,  -- Most common wind direction

    -- Visibility
    ROUND(AVG(visibility_km::numeric), 1) AS avg_daily_visibility_km,

    -- Station Pressure
    ROUND(AVG(avg_station_pressure_kpa::numeric), 1) AS avg_daily_station_pressure_kpa,

    -- Heat index and wind chill (daily max and min)
    ROUND(MAX(hmdx::numeric), 1) AS max_daily_heat_index,  
    ROUND(MIN(wind_chill::numeric), 1) AS min_daily_wind_chill,

    -- Overall weather condition: Use the most frequently occurring condition of the day
    MODE() WITHIN GROUP (ORDER BY weather) AS daily_weather_condition

FROM 
    merged_hourly_weather_data
GROUP BY 
    DATE_TRUNC('day', date_time_lst)
ORDER BY 
    date;



-- toronto specific hourly energy data
CREATE TABLE IF NOT EXISTS toronto_hourly_energy_data AS
SELECT 
    fsa,
    date,
    hour,
    customer_type,
    price_plan,
    total_consumption,
    premise_count
FROM 
    staging_hourly_energy_data
WHERE 
    fsa LIKE 'M%'  -- Filter for Toronto FSAs (those starting with 'M')
ORDER BY 
    date, hour, customer_type, price_plan;


-- city level table (hourly data)
CREATE TABLE IF NOT EXISTS toronto_city_hourly_energy_data AS
SELECT 
    -- Combine date and hour to create a timestamp without time zone
    (date + interval '1 hour' * hour) AS date_time,  -- Converts to timestamp without time zone
    customer_type,
    price_plan,
    SUM(total_consumption) AS hourly_total_consumption_kWh,  -- Aggregate total consumption for the city
    SUM(premise_count) AS total_premises  -- Aggregate premise count for the city
FROM 
    toronto_hourly_energy_data
GROUP BY 
    date_time, customer_type, price_plan
ORDER BY 
    date_time, customer_type, price_plan;


-- city level table (daily data)
CREATE TABLE IF NOT EXISTS toronto_city_daily_energy_data AS
SELECT 
    DATE_TRUNC('day', date_time) AS date,  -- Extract date from date_time timestamp
    customer_type,
    price_plan,
    SUM(hourly_total_consumption_kWh) AS daily_total_consumption_kWh,  -- Sum for daily energy use
    MAX(total_premises) AS daily_total_premises  -- Avoid over-counting by taking the maximum
FROM 
    toronto_city_hourly_energy_data
GROUP BY 
    DATE_TRUNC('day', date_time), customer_type, price_plan
ORDER BY 
    date, customer_type, price_plan;


-- create daily outage data
CREATE TABLE IF NOT EXISTS toronto_daily_outage_data AS
SELECT 
    -- Truncate timestamp to date for daily aggregation
    CAST(DATE_TRUNC('day', "RecordDateTime") AS DATE) AS date,

    -- Utility and location information
    "UtilityName",
    "StateName",
    "CountyName",
    "CityName",

    -- Maximum number of customers tracked in a day (assuming it’s the peak count)
    MAX("CustomersTracked") AS max_customers_tracked,

    -- Total customers out across the day
    SUM("CustomersOut") AS daily_total_customers_out

FROM 
    staging_hourly_outage_data
GROUP BY 
    CAST(DATE_TRUNC('day', "RecordDateTime") AS DATE),
    "UtilityName",
    "StateName",
    "CountyName",
    "CityName"
ORDER BY 
    date, "UtilityName";



