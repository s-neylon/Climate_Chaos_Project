** Deryugina Hurricane Data **
	* MERGE WITH *
** Business Dynamics Statistics by County **

/*

NOTES:
* Dataset created by Dery_DataProc_justClean.do (Deryugina's code, set to only run the cleaning, and I added a hurr_treat variable which switches to 1 the year the hurricane hits).

WORK NOTES: Are kept in OneNote: 'Dissertation/Causal Final/10-7-23 Work Notes'


*/


*** WORKING DIRECTORY *********

** Home Computer
* cd "C:\Users\samue\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

** LMIS Computer
 cd "C:\Users\sneylon\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

*******************************

** Load Data

clear

use data\Stata\Final_dataset_processed.dta, clear

**# IFEct Analysis

fect log_curr_trans_ind_gov_pc, treat(hurr_treat) unit(county_fips) time(year) cov() method("ife") force("two-way") r(5)

mat list e(ATT)

mat list e(ATTs)

