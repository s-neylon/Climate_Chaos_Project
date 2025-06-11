** Deryugina Hurricane Data **
	* MERGE WITH *
** Business Dynamics Statistics by County **

*** WORKING DIRECTORY *********

** Home Computer
* cd "C:\Users\samue\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes_R"

** LMIS Computer
cd "C:\Users\sneylon\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes_R"

*******************************

clear

use data\Deryugina_replication\data\Final_dataset.dta, clear

** String FIPS

tostring county_fips, gen(FIPS)
order FIPS, after(county_fips)

	* Add Zeroes
	replace FIPS = "0" + FIPS if length(FIPS) == 4

** Merge

merge 1:1 year FIPS using data\BDS\wd_bds_byCOUNTY.dta

**# Save (All Rows)

* save data\Stata\bds_hurricane_merge_ALL.dta, replace


**# Filter For Matched Rows

keep if _merge == 3

**# Save (Matched Rows)

* save data\Stata\bds_hurricane_merge_MATCH.dta, replace

* Clean

drop _merge 


**# Merge with Geo Names

merge m:1 FIPS using data\Labels\FIPS_all_counties.dta

**# Save (Matched + Labels)

save data\Stata\bds_hurricane.dta, replace

