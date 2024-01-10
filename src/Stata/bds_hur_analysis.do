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

* Percent adults employed

	* Two-Way Fixed Effects
	** [TOO MANY ROWS] Only for sample_hurr_valley - 9 hurricane prone states in the south (see Tableau for viz)
	** Only for coastal counties
	
* xthdidregress twfe (emp_rate_tot_adult) (hurr_treat) if coastal==1, group(cty_cat)

	* ra1 -- Trying 'ra' estimation

xthdidregress ra (emp_rate_tot_adult) (hurr_treat) if coastal==1, group(cty_cat) controlgroup(notyet) 

* IT WORKED WITH 'ra' !!!!

capture graph drop ra1_cohorts

estat atetplot, ysc(r(-.25 .4))  name(ra1_cohorts)

graph export output\Stata\testing_10-7-23\ra1_cohorts.pdf, as(pdf) name("ra1_cohorts") replace

	* ra1 -- Plot cohorts without 1988, so that I can zoom in!

capture graph drop ra1_cohorts_no88

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1991 1992 1995 1996 1998 1999, ysc(r(-.1 .1))  name(ra1_cohorts_no88)

graph export output\Stata\testing_10-7-23\ra1_cohorts_no88.pdf, as(pdf) name("ra1_cohorts_no88") replace

	* ra1 -- Dynamic Treatment Effects
	
capture graph drop ra1_dynamic
	
estat aggregation, dynamic(-5(1)10) graph(name(ra1_dynamic) xline(0))

graph export output\Stata\testing_10-7-23\ra1_dynamic.pdf, as(pdf) name("ra1_dynamic") replace


* ra2 -- For sample_hurr_valley states

xthdidregress ra (emp_rate_tot_adult) (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet) 

capture graph drop ra2_cohorts

estat atetplot,  name(ra2_cohorts)

graph export output\Stata\testing_10-7-23\ra2_cohorts.pdf, as(pdf) name("ra2_cohorts") replace

	* ra2 -- Plot cohorts without 1988, so that I can zoom in!

capture graph drop ra2_cohorts_no88

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, ysc(r(-.1 .1))  name(ra2_cohorts_no88)

graph export output\Stata\testing_10-7-23\ra2_cohorts_no88.pdf, as(pdf) name("ra2_cohorts_no88") replace

	* ra2 -- Dynamic Treatment Effects
	
capture graph drop ra2_dynamic
	
estat aggregation, dynamic(-5(1)10) graph(name(ra2_dynamic) xline(0))

graph export output\Stata\testing_10-7-23\ra2_dynamic.pdf, as(pdf) name("ra2_dynamic") replace



**# m3 (model3) -- log_curr_trans_ind_gov_pc 
	* Using sample_hurr_valley states

	* m3_1
xthdidregress ra (log_curr_trans_ind_gov_pc) (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet) 

	* m3_1 -- Cohorts
capture graph drop m3_1_cohorts

estat atetplot, name(m3_1_cohorts)

graph export output\Stata\testing_10-7-23\m3_1_cohorts.pdf, as(pdf) name("m3_1_cohorts") replace

	* m3_1 -- Plot cohorts without 1988

capture graph drop m3_1_cohorts_no88

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name(m3_1_cohorts_no88)

graph export output\Stata\testing_10-7-23\m3_1_cohorts_no88.pdf, as(pdf) name("m3_1_cohorts_no88") replace

	* m3_1 -- Dynamic Treatment Effects
	
capture graph drop m3_1_dynamic
	
estat aggregation, dynamic(-5(1)10) graph(name(m3_1_dynamic) xline(0))

graph export output\Stata\testing_10-7-23\m3_1_dynamic.pdf, as(pdf) name("m3_1_dynamic") replace


**# BDS Analysis 

* birth1 -- Establishment Birth Rate - estabs_entry_rate

xthdidregress ra (estabs_entry_rate) (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* birth1_1 -- Cohorts
capture graph drop birth1_1_cohorts

estat atetplot, name(birth1_1_cohorts)

graph export output\Stata\testing_10-7-23\birth1_1_cohorts.pdf, as(pdf) name("birth1_1_cohorts") replace

	* birth1_1 -- Plot cohorts without 1988

capture graph drop birth1_1_cohorts_no88

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name(birth1_1_cohorts_no88)

graph export output\Stata\testing_10-7-23\birth1_1_cohorts_no88.pdf, as(pdf) name("birth1_1_cohorts_no88") replace

	* birth1_1 -- Dynamic Treatment Effects
	
capture graph drop birth1_1_dynamic
	
estat aggregation, dynamic(-5(1)10) graph(name(birth1_1_dynamic) xline(0))

graph export output\Stata\testing_10-7-23\birth1_1_dynamic.pdf, as(pdf) name("birth1_1_dynamic") replace


* exit1 -- Establishment Exit Rate - estabs_exit_rate

xthdidregress ra (estabs_exit_rate) (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* exit1_1 -- Cohorts
capture graph drop exit1_1_cohorts

estat atetplot, name(exit1_1_cohorts)

graph export output\Stata\testing_10-7-23\exit1_1_cohorts.pdf, as(pdf) name("exit1_1_cohorts") replace

	* exit1_1 -- Plot cohorts without 1988

capture graph drop exit1_1_cohorts_no88

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name(exit1_1_cohorts_no88)

graph export output\Stata\testing_10-7-23\exit1_1_cohorts_no88.pdf, as(pdf) name("exit1_1_cohorts_no88") replace

	* exit1_1 -- Dynamic Treatment Effects
	
capture graph drop exit1_1_dynamic
	
estat aggregation, dynamic(-5(1)10) graph(name(exit1_1_dynamic) xline(0))

graph export output\Stata\testing_10-7-23\exit1_1_dynamic.pdf, as(pdf) name("exit1_1_dynamic") replace


**# Job Creation from Estab Births

* Log it (add 1 to get rid of zeroes)
gen ln_job_creation_births = ln(job_creation_births + 1)

* jc_birth1 -- Job Creation from Estab Births (logged value)

xthdidregress ra (ln_job_creation_births) (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* jc_birth1_1 -- Cohorts
capture graph drop jc_birth1_1_cohorts

estat atetplot, name(jc_birth1_1_cohorts)

graph export output\Stata\testing_10-7-23\jc_birth1_1_cohorts.pdf, as(pdf) name("jc_birth1_1_cohorts") replace

	* jc_birth1_1 -- Plot cohorts without 1988

capture graph drop jc_birth1_1_cohorts_no88

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name(jc_birth1_1_cohorts_no88)

graph export output\Stata\testing_10-7-23\jc_birth1_1_cohorts_no88.pdf, as(pdf) name("jc_birth1_1_cohorts_no88") replace

	* jc_birth1_1 -- Dynamic Treatment Effects
	
capture graph drop jc_birth1_1_dynamic
	
estat aggregation, dynamic(-5(1)10) graph(name(jc_birth1_1_dynamic) xline(0))

graph export output\Stata\testing_10-7-23\jc_birth1_1_dynamic.pdf, as(pdf) name("jc_birth1_1_dynamic") replace

** birth_pct1 -- JC Births as % of total JC
	
	* New Variable
gen births_pctJC = job_creation_births / job_creation

* birth_pct1 -- Job Creation from Estab Births (logged value)

xthdidregress ra (births_pctJC) (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* birth_pct1_1 -- Cohorts
capture graph drop birth_pct1_1_cohorts

estat atetplot, name(birth_pct1_1_cohorts)

graph export output\Stata\testing_10-7-23\birth_pct1_1_cohorts.pdf, as(pdf) name("birth_pct1_1_cohorts") replace

	* birth_pct1_1 -- Plot cohorts without 1988

capture graph drop birth_pct1_1_cohorts_no88

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name(birth_pct1_1_cohorts_no88)

graph export output\Stata\testing_10-7-23\birth_pct1_1_cohorts_no88.pdf, as(pdf) name("birth_pct1_1_cohorts_no88") replace

	* birth_pct1_1 -- Dynamic Treatment Effects
	
capture graph drop birth_pct1_1_dynamic
	
estat aggregation, dynamic(-5(1)10) graph(name(birth_pct1_1_dynamic) xline(0))

graph export output\Stata\testing_10-7-23\birth_pct1_1_dynamic.pdf, as(pdf) name("birth_pct1_1_dynamic") replace

**# FUNCTION VERSION
* This version of the code will allow me to skip the copy-pasting!

local Xvar estabs_entry
local Xname birth2
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace

**# Estab entry and exit, only as levels this time, instead of rates.
	* I could also try logs, but I think that counties with more employment *should* be weighted more! It is a question of functional form, though, which I need to think through.
	
* birth2 -- Estab entry raw level

local Xvar estabs_entry
local Xname birth2
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace


* exit2 - Estab exit raw level

local Xvar estabs_exit
local Xname exit2
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace

* jc_birth2 -- Job Creation from Estab Births (NON logged value)

local Xvar job_creation_births
local Xname jc_birth2
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace

* jc_cont1 -- Job Creation from Continuing Establishments (NON logged value)

local Xvar job_creation_continuers
local Xname jc_cont1
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace

* bds_emp1 -- Total employment, from the BDS (logged)

** NEW VARIABLE

* Log it (add 1 to get rid of zeroes)
gen ln_emp = ln(emp + 1)

**

local Xvar ln_emp
local Xname bds_emp1
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace

* jc_birth3 -- JC RATE from births 

local Xvar job_creation_rate_births
local Xname jc_birth3
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace

* net1 -- Net Job Creation Rate

local Xvar net_job_creation_rate
local Xname net1
local modelNUM _1_

xthdidregress ra (`Xvar') (hurr_treat) if sample_hurr_valley==1, group(cty_cat) controlgroup(notyet)

	* Cohorts
capture graph drop "`Xname'`modelNUM'cohorts"

estat atetplot, name("`Xname'`modelNUM'cohorts")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts.pdf, as(pdf) name("`Xname'`modelNUM'cohorts") replace

	* Plot cohorts without 1988

capture graph drop "`Xname'`modelNUM'cohorts_no88"

estat atetplot 1979 1980 1983 1984 1985 1986 1987 1989 1992 1995 1996 1998 1999, name("`Xname'`modelNUM'cohorts_no88")

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'cohorts_no88.pdf, as(pdf) name("`Xname'`modelNUM'cohorts_no88") replace

	* Dynamic Treatment Effects
	
capture graph drop "`Xname'`modelNUM'dynamic"
	
estat aggregation, dynamic(-5(1)10) graph(name("`Xname'`modelNUM'dynamic") xline(0))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic.pdf, as(pdf) name("`Xname'`modelNUM'dynamic") replace

	* Dynamic Treatment Effects (All Years)

capture graph drop "`Xname'`modelNUM'dynamic_all"
	
estat aggregation, dynamic graph(name("`Xname'`modelNUM'dynamic_all") xline(0) xlabel(#5))

graph export output\Stata\testing_10-7-23\\`Xname'`modelNUM'dynamic_all.pdf, as(pdf) name("`Xname'`modelNUM'dynamic_all") replace






**# Descriptive

hist job_creation_continuers
summarize job_creation_continuers if job_creation_continuers < 1
list job_creation_continuers if job_creation_continuers < 5

summarize job_creation_births if job_creation_births < 1

hist 
