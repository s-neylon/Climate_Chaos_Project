** Import and Clean Label Files **

*** WORKING DIRECTORY *********

** Home Computer
cd "C:\Users\samue\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

** LMIS Computer
* cd "C:\Users\sneylon\OneDrive - City University of New York\CUNY! (Cloud)\Stata\BDS"

*******************************


**# County and MSA FIPS File 

clear

import delimited data\Labels\FIPS_all_counties.csv, stringcols(2 3 4 11) numericcols(1)

	* Make FIPS variable, to match Deryugina data format
	gen FIPS = fips_text
	
	* Rename state_fips because of conflict with Deryugina
	rename state_fips ST_FIPS
	rename county_fips CTY_FIPS
	
** Save

save data\Labels\FIPS_all_counties.dta, replace
