-- Lookup view example..
Let's create a lookup view that provides a lsit of country names and theor estimated population from the 
access to basic services table.

USE united_nations;

CREATE VIEW Country_Lookup AS 
SELECT 
	Country_name,
    Est_population_in_millions,
    Time_period
FROM
	access_to_basic_services;

SELECT * 
FROM Country_Lookup;