** Hurricane Research **
** Oct 6, 2023 *********

** Business Dynamics Statistics **
** Cleaning File **

** US by County

*** WORKING DIRECTORY *********

** Home Computer
cd "C:\Users\samue\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

** LMIS Computer
* cd "C:\Users\sneylon\OneDrive - City University of New York\CUNY! (Cloud)\Stata\BDS"

*******************************

**# Import Raw Data

import delimited data\BDS\bds2020_st_cty.csv, stringcols(2 3 4 5 6 7 12 14 16 17 19 21 22 23 24) clear 

** OLD METHOD
* clear
* use data\BDS\bds2020_st_cty.dta, clear
**

**# Missing Data 

destring firms-firmdeath_emp, replace force

**# FIPS

gen FIPS = st + cty
order FIPS, after(cty)

* Numeric FIPS 
destring FIPS, gen(county_fips)
order county_fips, after(FIPS)

**# Save

save data\BDS\wd_bds_byCOUNTY, replace