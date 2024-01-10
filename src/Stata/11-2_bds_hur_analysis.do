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
 cd "C:\Users\samue\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

** LMIS Computer
* cd "C:\Users\sneylon\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

*******************************

** Load Data

clear

use data\Stata\Final_dataset_processed.dta, clear

** xtset

xtset county_fips year

** Group Variable

	* State
* encode state, gen(state_cat)
	* County
encode fips_text, gen(cty_cat)

**# Diagnostic

xtdescribe

**# Analysis

**# FUNCTION VERSION
* This version of the code will allow me to skip the copy-pasting!

local Xvar estabs_entry
local Xname birth2
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(0) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace



**# Emp Rate for Adults

local Xvar emp_rate_tot_adult
local Xname emp_rate
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace


**# log_curr_trans_ind_gov_pc

local Xvar log_curr_trans_ind_gov_pc
local Xname curr_trans
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace


**# birth1 -- Establishment Birth Rate - estabs_entry_rate

local Xvar estabs_entry_rate
local Xname birth_rate
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace


**# exit1 -- Establishment Exit Rate - estabs_exit_rate

local Xvar estabs_exit_rate
local Xname exit_rate
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace



	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace

**# ln_jd -- Job Destruction Logged

capture drop ln_job_destruction
gen ln_job_destruction = ln(job_destruction + 1)

	* Analysis 
local Xvar ln_job_destruction
local Xname ln_jd
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace



	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace


**# ln_jd_exit -- Job Destruction from exits Logged

capture drop ln_jd_exit
gen ln_jd_exit = ln(job_destruction_deaths + 1)

	* Analysis 
local Xvar ln_jd_exit
local Xname ln_jd_exit
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace



	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace


**# ln_jd_exit -- Job Destruction from continuers Logged

capture drop ln_jd_cont
gen ln_jd_cont = ln(job_destruction_continuers + 1)

	* Analysis 
local Xvar ln_jd_cont
local Xname ln_jd_cont
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace



	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace


**# net_rate - Net job creation rate

local Xvar net_job_creation_rate
local Xname net_rate
local modelNUM _1_

xthdidregress aipw (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\11-2-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(-0.5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace



	* Aggregate by Cohort 

capture graph drop "`Xname'`modelNUM'agg_cohort"
	
estat aggregation, cohort graph(name("`Xname'`modelNUM'agg_cohort") xline(-0.5) xlabel(#5))

graph export output\Stata\11-2-23\\`Xname'`modelNUM'agg_cohort.pdf, as(pdf) name("`Xname'`modelNUM'agg_cohort") replace
