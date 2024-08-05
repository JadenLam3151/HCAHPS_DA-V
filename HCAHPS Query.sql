-- Final: create table for Tableau
create table "postgres"."Hospital_Data".Tableau_File as 
	
-- Common Table Expression
WITH hospital_beds_prep AS
(
	-- Re-Add Leading 0s to provider_ccn (pad left side) and format dates correctly
SELECT lpad(CAST(provider_ccn AS text), 6, '0') AS provider_ccn
	,hospital_name
	,to_date(fiscal_year_begin_date,'MM/DD/YYYY') AS fiscal_year_begin_date
	,to_date(fiscal_year_end_date,'MM/DD/YYYY') AS fiscal_year_end_date
	,number_of_beds
	,ROW_NUMBER() OVER (PARTITION BY provider_ccn ORDER BY to_date(fiscal_year_end_date,'MM/DD/YYYY') DESC) AS nth_row
FROM "postgres"."Hospital_Data".hospital_beds
)
	
-- -- Ensure no duplicate hospitals if only looking at nth_row = 1
-- SELECT provider_ccn, COUNT(*) AS count_of_rows
-- FROM hospital_beds_prep
-- WHERE nth_row = 1
-- GROUP BY provider_ccn
-- ORDER BY COUNT(*) DESC

-- Re-Add Leading 0s to provider_ccn (pad left side) and format dates correctly
SELECT lpad(CAST(facility_id AS text), 6, '0') AS provider_ccn
	,to_date(start_date,'MM/DD/YYYY') AS start_date_converted
	,to_date(end_date,'MM/DD/YYYY') AS end_date_converted
	,hcahps.*
	,beds.number_of_beds
	,beds.fiscal_year_begin_date AS beds_start_report_period
	,beds.fiscal_year_end_date AS beds_end_report_period
FROM "postgres"."Hospital_Data".hcahps_data AS hcahps
-- Join two tables on provider_ccn and nth_row = 1
LEFT JOIN hospital_beds_prep as beds
ON lpad(CAST(facility_id AS text), 6, '0') = beds.provider_ccn
AND beds.nth_row = 1
