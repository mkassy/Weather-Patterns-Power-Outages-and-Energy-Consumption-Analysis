DROP TABLE IF EXISTS staging_energy_data;
DROP TABLE IF EXISTS staging_outage_data;
DROP TABLE IF EXISTS staging_weather_data;

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
    "Number_of_Customers_Interrupted" FLOAT,
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
