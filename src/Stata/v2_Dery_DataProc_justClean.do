

***** NOTE *****
/*
This .do file is copied from Deryugina's 'DataProcessingAnalysis.do', but this copy only prepares the data and xtsets it, but doesn't run the analysis.

v2: In this version, I start treatment in 1988 (happy birthday!)

*/

*** WORKING DIRECTORY *********

** Home Computer
* cd "C:\Users\samue\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

** LMIS Computer
 cd "C:\Users\sneylon\OneDrive - City University of New York\CUNY! (Cloud)\R\Hurricanes"

*******************************

* reghdfe is used below to generate the sample results 
* ssc install reghdfe, replace

* Set "path" to wherever the data are located
local path "data\Stata\"

local create_final_data		= 1				// This loop creates final dataset; set = 1 to run
local run_analysis			= 0				// This loop runs the main analysis in the paper; set = 1 to run

********************************************
* Create final dataset
if `create_final_data' {
use "`path'bds_hurricane.dta", clear
keep if sample_hurr_state
drop sample_hurr_state

* Restricting sample of hurricanes to first hurricane hit between 1988 and 2002
gen temp=year if hurricane==1 & year>=1988 & year<=2002	
bys county_fips: egen hurr_year=min(temp)
drop temp

foreach var in hurricane wind_speed cat1_hurr cat2_hurr {
replace `var'=0 if year!=hurr_year
}

replace central_hurr=0 if hurricane==0

*** ADDED BY SN ***

gen hurr_treat = hurricane
replace hurr_treat = 1 if year >= hurr_year

*******************

gen time=year-hurr_year
drop hurr_year

gen temp=(central_hurr==0 & hurricane==1)
bys county_fips: egen non_centr_wms=max(temp)
drop temp

gen temp=hurricane if year>=1988 & year<=2002	
bys county_fips: egen tot_hurr=total(temp)
drop temp

gen temp=year if hurricane==1 & year>=1988 & year<=2002	
bys county_fips: egen hurr_year=min(temp)
drop temp time

gen time=year-hurr_year
drop hurr_year

xtset county_fips year

* Hurricane leads and lags
gen hurr_p=0
gen hurr_m=0

quietly forvalues i=11/60 {
replace hurr_p=1 if F`i'.hurricane==1
replace hurr_m=1 if L`i'.hurricane==1
}

quietly forvalues i=1/10 {
gen F`i'hurr=F`i'.hurricane
gen L`i'hurr=L`i'.hurricane
}

quietly forvalues i=1(2)9 {
local j=`i'+1
egen hurr_`i'_`j'=rowmax(L`i'hurr L`j'hurr)
replace hurr_`i'_`j'=0 if hurr_`i'_`j'==.
egen hurr_f`i'_`j'=rowmax(F`i'hurr F`j'hurr)
replace hurr_f`i'_`j'=0 if hurr_f`i'_`j'==.
}

egen hurr0_4=rowmax(hurricane hurr_1_2 hurr_3_4)
egen hurr5_9=rowmax(hurr_5_6 hurr_7_8 hurr_9_10)

* Different categories of wind speed
gen cat1=(wind_speed>=74 & wind_speed<=95) 
gen cat2=(wind_speed>95 & wind_speed<=110)
gen cat3=(wind_speed>110 & wind_speed<.)

xtset county_fips year

quietly forvalues j=1/3 {
gen cat`j'_p=0
gen cat`j'_m=0
	forvalues i=11/60 {
	replace cat`j'_p=1 if F`i'.cat`j'==1
	replace cat`j'_m=1 if L`i'.cat`j'==1
	}
}

quietly forvalues j=1/3 {
	forvalues i=1/10 {
	gen F`i'cat`j'=F`i'.cat`j'
	gen L`i'cat`j'=L`i'.cat`j'
	}
}

quietly forvalues k=1/3 {
	forvalues i=1(2)9 {
	local j=`i'+1
	egen cat`k'_`i'_`j'=rowmax(L`i'cat`k' L`j'cat`k')
	replace cat`k'_`i'_`j'=0 if cat`k'_`i'_`j'==.
	egen cat`k'_f`i'_`j'=rowmax(F`i'cat`k' F`j'cat`k')
	replace cat`k'_f`i'_`j'=0 if cat`k'_f`i'_`j'==.
	}
}


forvalues i=1/3 {
egen ccat`i'_0_4=rowmax(cat`i' cat`i'_1_2 cat`i'_3_4)
egen ccat`i'_5_10=rowmax(cat`i'_5_6 cat`i'_7_8 cat`i'_9_10)
}

gen f1_2hurr=hurr_f1_2

gen time_lin=year-1979

drop F* L* hurr_f1_2 wind_speed cat*_f1_2 

keep if year<=2012 & year>=1979

gen trend_pre=0
replace trend_pre=time if time>=-10 & time<=10 

gen trend_post=0
replace trend_post=time if time>=0 & time<=10 

gen post_ind=(time>=0 & time<=10)

forvalues i=1/3 {
gen temp=year if cat`i'==1
bys county_fips: egen cat`i'_year=min(temp)
gen time`i'=year-cat`i'_year

gen tcat`i'_trend_pre=0
replace tcat`i'_trend_pre=time`i' if time`i'>=-10 & time`i'<=10

gen tcat`i'_trend_post=0
replace tcat`i'_trend_post=time`i' if time`i'>=0 & time`i'<=10

gen tcat`i'_post_ind=(time`i'>=0 & time`i'<=10)
drop temp time`i' cat`i'_year
}

bys state_fips: egen state_w_hurr=max(hurricane)
bys county_fips: egen county_w_hurr=max(hurricane)
keep if consistent_sample==1

save "`path'Final_dataset_processed", replace
}
******************************************************************************
* Key analysis in paper
/*
Outcomes used in the paper: 
log_curr_trans_ind_gov_pc 
log_curr_trans_ind_bus_pc 
emp_rate_tot_adult 
log_avg_wage_sal_disb 

log_pop 
frac_young 
frac_old 
frac_black 

log_unemp_pc 
log_public_med_benefits_pc 
log_inc_maint_pc 
log_medicare_pc 
log_food_stamps_pc
log_ssi_benefits_pc
log_ret_dis_ins_pc 
log_educ_train_assistance_pc 
log_family_assistance_pc
*/
* To add/change the variables, add or remove variables from outcomelist below:
local outcomelist "log_curr_trans_ind_gov_pc"

* Interest rate used = 3%
local r=0.03
local R=1/(1+`r')

if `run_analysis' {

local treat_v_control 	= 0								// Comparing counties that do and do not experience hurricanes
local main_regs 		= 1								// Main regressions (those making up the tables and figures in the paper)

* ********************************************************************************
* Comparing counties that do and do not experience hurricanes
* ********************************************************************************
if `treat_v_control'==1 {
use "`path'Final_dataset", clear

quietly gen temp=hurricane if year>=1979 & year<=2002
quietly bys county_fips: egen hurr_county=max(temp)
drop temp
replace hurr_county=0 if hurr_county==. 

xtset county_fips year

gen pop_pm=population/land_area1970
gen log_pop = log(population)

* List 1969 characteristics to compare
local indepvars "land_area1970 coastal pop_pm emp_rate_REIS_adult log_wage_pc log_curr_trans_ind_gov_pc log_curr_trans_ind_bus_pc log_pop frac_young frac_old frac_black"

* List variables for which you want to compare 1969-1978 trends
local indepvars2 "emp_rate_REIS_adult log_wage_pc pop_pm log_curr_trans_ind_gov_pc log_curr_trans_ind_bus_pc log_pop frac_young frac_old frac_black"

foreach var in frac_young frac_old frac_black emp_rate_REIS_adult {
replace `var'=100*`var'
}

preserve
bys county_fips: keep if _n==1
gen temp = 1 if hurr_county==1
egen temp2 = total(temp)
sum temp2
local hurr_cos=`r(max)'
drop temp temp2

gen temp = 1 if hurr_county==0 
egen temp2 = total(temp)
sum temp2
local nhurr_cos=`r(max)'
drop temp temp2

* *************************************
gen temp = 1 if hurr_county==1 & sample_hurr_state==1
egen temp2 = total(temp)
sum temp2
local hurr_cos2=`r(max)'
drop temp temp2

gen temp = 1 if hurr_county==0 & sample_hurr_state==1 
egen temp2 = total(temp)
sum temp2
local nhurr_cos2=`r(max)'
drop temp temp2
restore

* **********************************************************************
* Comparing 1969 characteristics
foreach var in `indepvars' {

reg `var' hurr_county if year==1969, cluster(county_fips)
sum `var' if e(sample) & hurr_county==1
local mean_h=r(mean)
sum `var' if e(sample) & hurr_county==0
local mean_nh=r(mean)

reg `var' hurr_county if year==1969 & sample_hurr_state==1, cluster(county_fips)
sum `var' if e(sample) & hurr_county==1
local mean_h=r(mean)
sum `var' if e(sample) & hurr_county==0
local mean_nh=r(mean)
}

keep if year<=1978

xi i.year*i.hurr_county
drop _Ihurr_coun_1

* **********************************************************************
* Comparing 1969-1978 trends
foreach var in `indepvars2' {

xtreg `var' _I*, fe vce(cluster county_fips)
test _IyeaXhur_1970_1 + _IyeaXhur_1971_1 + _IyeaXhur_1972_1 + _IyeaXhur_1973_1 + _IyeaXhur_1974_1 + _IyeaXhur_1975_1 + _IyeaXhur_1976_1 + _IyeaXhur_1977_1 + _IyeaXhur_1978_1=0
local Fp=`r(p)'

lincom _Iyear_1970 + _Iyear_1971 + _Iyear_1972 + _Iyear_1973 + _Iyear_1974 + _Iyear_1975 + _Iyear_1976 + _Iyear_1977 + _Iyear_1978 + _IyeaXhur_1970_1 + _IyeaXhur_1971_1 + _IyeaXhur_1972_1 + _IyeaXhur_1973_1 + _IyeaXhur_1974_1 + _IyeaXhur_1975_1 + _IyeaXhur_1976_1 + _IyeaXhur_1977_1 + _IyeaXhur_1978_1
local mean_h=`r(estimate)'

lincom _Iyear_1970 + _Iyear_1971 + _Iyear_1972 + _Iyear_1973 + _Iyear_1974 + _Iyear_1975 + _Iyear_1976 + _Iyear_1977 + _Iyear_1978
local mean_nh=`r(estimate)'

* **********************************************************************
xtreg `var' _I* if sample_hurr_state==1, fe vce(cluster county_fips)
test _IyeaXhur_1970_1 + _IyeaXhur_1971_1 + _IyeaXhur_1972_1 + _IyeaXhur_1973_1 + _IyeaXhur_1974_1 + _IyeaXhur_1975_1 + _IyeaXhur_1976_1 + _IyeaXhur_1977_1 + _IyeaXhur_1978_1=0
local Fp=`r(p)'

lincom _Iyear_1970 + _Iyear_1971 + _Iyear_1972 + _Iyear_1973 + _Iyear_1974 + _Iyear_1975 + _Iyear_1976 + _Iyear_1977 + _Iyear_1978 + _IyeaXhur_1970_1 + _IyeaXhur_1971_1 + _IyeaXhur_1972_1 + _IyeaXhur_1973_1 + _IyeaXhur_1974_1 + _IyeaXhur_1975_1 + _IyeaXhur_1976_1 + _IyeaXhur_1977_1 + _IyeaXhur_1978_1
local mean_h=`r(estimate)'

lincom _Iyear_1970 + _Iyear_1971 + _Iyear_1972 + _Iyear_1973 + _Iyear_1974 + _Iyear_1975 + _Iyear_1976 + _Iyear_1977 + _Iyear_1978
local mean_nh=`r(estimate)'
}		// End of var loop
}		// End of treatment versus control loop


*****************************************************************************
* MAIN RESULTS
if `main_regs' {
foreach outcome in `outcomelist' {
use "`path'Final_dataset_processed", clear

drop if missing(latitude,longitude, log_curr_trans_ind_gov_pc)

gen temp=1 if `outcome'!=. & time>=-10 & time<=10 
bys county_fips: egen num_obs=total(temp)
replace num_obs=21 if tot_hurr==0
keep if num_obs==21

* Generate residuals with controls
hdfe `outcome' hurricane hurr_* trend_pre trend_post post_ind hurr0_4 hurr5_9, absorb(i.year#i.coastal i.year#c.land_area1970 i.year#c.log_pop1969 i.year#c.frac_young1969 i.year#c.frac_old1969 i.year#c.frac_black1969 i.year#c.log_wage_pc1969 i.year#c.emp_rate1969 i.county_fips) generate(n)

* Generate residuals without controls
hdfe `outcome' hurricane hurr_*, absorb(i.year i.county_fips) generate(x)

tsset county_fips year
*********************************************
* EQUATION 1
* Regressions with controls
* Note: spatially clustered standard errors do not require a standard error correction for residualizing the variables prior to running the regression
* To obtain the code for ols_spatial_HAC, please contact Solomon Hsiang, shsiang@berkeley.edu.
ols_spatial_HAC n`outcome' nhurricane nhurr_*, ///
lat(latitude) lon(longitude) t(year) p(county_fips) dist(200) bartlett lag(5) 

* Note: if you do not have ols_spatial_HAC, you can obtain the paper's point estimates with standard errors clustered by county by running the following code (currently commented out)
* reghdfe `outcome' hurricane hurr_*, absorb(i.county_fips i.year#i.coastal i.year#c.land_area1970 i.year#c.log_pop1969 i.year#c.frac_young1969 i.year#c.frac_old1969 i.year#c.frac_black1969 i.year#c.log_wage_pc1969 i.year#c.emp_rate1969) vce(cluster county_fips)

sum `outcome' if e(sample) & F.hurricane==1
local dmean=`r(mean)'

nlcom exp(_b[nhurricane]+`dmean')-exp(`dmean')+`R'*(exp(_b[nhurr_1_2]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[nhurr_1_2]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[nhurr_3_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[nhurr_3_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[nhurr_5_6]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[nhurr_5_6]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[nhurr_7_8]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[nhurr_7_8]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[nhurr_9_10]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[nhurr_9_10]+`dmean')-exp(`dmean'))

* Regressions with no controls
ols_spatial_HAC x`outcome' xhurricane xhurr_*, lat(latitude) lon(longitude) t(year) p(county_fips) dist(200) bartlett lag(5) 

* Note: if you do not have ols_spatial_HAC, you can obtain the paper's point estimates with standard errors clustered by county by running the following code (currently commented out) 
* reghdfe `outcome' hurricane hurr_*, absorb(i.county_fips i.year) vce(cluster county_fips)

*********************************************
* EQUATION 2 (regressions with controls only)

ols_spatial_HAC n`outcome' nhurr0_4 nhurr5_9 nhurr_m nhurr_p, lat(latitude) lon(longitude) t(year) p(county_fips) dist(200) bartlett lag(5) 

* Note: if you do not have ols_spatial_HAC, you can obtain the paper's point estimates with standard errors clustered by county by running the following code (currently commented out)
* reghdfe `outcome' hurr0_4 hurr5_9 hurr_m hurr_p, absorb(i.county_fips i.year#i.coastal i.year#c.land_area1970 i.year#c.log_pop1969 i.year#c.frac_young1969 i.year#c.frac_old1969 i.year#c.frac_black1969 i.year#c.log_wage_pc1969 i.year#c.emp_rate1969) vce(cluster county_fips)

sum `outcome' if e(sample) & F.hurricane==1
local dmean=`r(mean)'

nlcom exp(_b[nhurr0_4]+`dmean')-exp(`dmean')+`R'*(exp(_b[nhurr0_4]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[nhurr0_4]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[nhurr0_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[nhurr0_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[nhurr5_9]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[nhurr5_9]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[nhurr5_9]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[nhurr5_9]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[nhurr5_9]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[nhurr5_9]+`dmean')-exp(`dmean'))

*********************************************
* EQUATION 3 (regressions with controls only)

ols_spatial_HAC n`outcome' ntrend_pre ntrend_post npost_ind nhurr_p nhurr_m, lat(latitude) lon(longitude) t(year) p(county_fips) dist(200) bartlett lag(5) 

* Note: if you do not have ols_spatial_HAC, you can obtain the paper's point estimates with standard errors clustered by county by running the following code (currently commented out) 
* reghdfe `outcome' trend_pre trend_post post_ind hurr_p hurr_m, absorb(i.county_fips i.year#i.coastal i.year#c.land_area1970 i.year#c.log_pop1969 i.year#c.frac_young1969 i.year#c.frac_old1969 i.year#c.frac_black1969 i.year#c.log_wage_pc1969 i.year#c.emp_rate1969) vce(cluster county_fips)

sum `outcome' if e(sample) & F.hurricane==1
local dmean=`r(mean)'

nlcom exp(_b[npost_ind]+`dmean')-exp(`dmean') ///
+`R'*(exp(_b[npost_ind]+_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^2*(exp(_b[npost_ind]+2*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^3*(exp(_b[npost_ind]+3*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^4*(exp(_b[npost_ind]+4*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^5*(exp(_b[npost_ind]+5*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^6*(exp(_b[npost_ind]+6*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^7*(exp(_b[npost_ind]+7*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^8*(exp(_b[npost_ind]+8*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^9*(exp(_b[npost_ind]+9*_b[ntrend_post]+`dmean')-exp(`dmean')) ///
+`R'^10*(exp(_b[npost_ind]+10*_b[ntrend_post]+`dmean')-exp(`dmean'))

*********************************************
* WIND SPEED REGRESSIONS

drop n`outcome' nhurr* ntrend* npost*

hdfe `outcome' cat1 cat2 cat3 cat1_1_2 cat2_1_2 cat3_1_2 cat1_3_4 cat2_3_4 cat3_3_4 cat1_5_6 cat2_5_6 cat3_5_6 cat1_7_8 cat2_7_8 cat3_7_8 ///
cat1_9_10 cat2_9_10 cat3_9_10 cat1_f3_4 cat2_f3_4 cat3_f3_4 cat1_f5_6 cat2_f5_6 cat3_f5_6 cat1_f7_8 cat2_f7_8 cat3_f7_8 ///
cat1_f9_10 cat2_f9_10 cat3_f9_10 cat1_p cat2_p cat3_p cat1_m cat2_m cat3_m ///
ccat1_0_4 ccat1_5_10 ccat2_0_4 ccat2_5_10 ccat3_0_4 ccat3_5_10 ///
tcat1_trend_pre tcat1_trend_post tcat1_post_ind tcat2_trend_pre tcat2_trend_post tcat2_post_ind tcat3_trend_pre tcat3_trend_post tcat3_post_ind ///
, absorb(i.county_fips i.year#i.coastal i.year#c.land_area1970 i.year#c.log_pop1969 i.year#c.frac_young1969 i.year#c.frac_old1969 i.year#c.frac_black1969 i.year#c.log_wage_pc1969 i.year#c.emp_rate1969) generate(n)

*********************************************************************************************
* Event study estimates
ols_spatial_HAC n`outcome' ncat*, ///
lat(latitude) lon(longitude) t(year) p(county_fips) dist(200) bartlett lag(5) 
sum `outcome' if e(sample) & F.hurricane==1
local dmean=`r(mean)'

* Net present value of variable
nlcom exp(_b[ncat1]+`dmean')-exp(`dmean')+`R'*(exp(_b[ncat1_1_2]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[ncat1_1_2]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[ncat1_3_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[ncat1_3_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[ncat1_5_6]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[ncat1_5_6]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[ncat1_7_8]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[ncat1_7_8]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[ncat1_9_10]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[ncat1_9_10]+`dmean')-exp(`dmean'))

nlcom exp(_b[ncat2]+`dmean')-exp(`dmean')+`R'*(exp(_b[ncat2_1_2]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[ncat2_1_2]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[ncat2_3_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[ncat2_3_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[ncat2_5_6]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[ncat2_5_6]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[ncat2_7_8]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[ncat2_7_8]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[ncat2_9_10]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[ncat2_9_10]+`dmean')-exp(`dmean'))

nlcom exp(_b[ncat3]+`dmean')-exp(`dmean')+`R'*(exp(_b[ncat3_1_2]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[ncat3_1_2]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[ncat3_3_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[ncat3_3_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[ncat3_5_6]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[ncat3_5_6]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[ncat3_7_8]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[ncat3_7_8]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[ncat3_9_10]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[ncat3_9_10]+`dmean')-exp(`dmean'))

*********************************************************************************************
* Combined estimates

ols_spatial_HAC n`outcome' nccat* ncat1_p ncat2_p ncat3_p ncat1_m ncat2_m ncat3_m, ///
lat(latitude) lon(longitude) t(year) p(county_fips) dist(200) bartlett lag(5) 
sum `outcome' if e(sample) & F.hurricane==1
local dmean=`r(mean)'

* Net present value of variable
nlcom exp(_b[nccat1_0_4]+`dmean')-exp(`dmean')+`R'*(exp(_b[nccat1_0_4]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[nccat1_0_4]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[nccat1_0_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[nccat1_0_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[nccat1_5_10]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[nccat1_5_10]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[nccat1_5_10]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[nccat1_5_10]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[nccat1_5_10]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[nccat1_5_10]+`dmean')-exp(`dmean'))

nlcom exp(_b[nccat2_0_4]+`dmean')-exp(`dmean')+`R'*(exp(_b[nccat2_0_4]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[nccat2_0_4]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[nccat2_0_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[nccat2_0_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[nccat2_5_10]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[nccat2_5_10]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[nccat2_5_10]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[nccat2_5_10]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[nccat2_5_10]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[nccat2_5_10]+`dmean')-exp(`dmean'))

nlcom exp(_b[nccat3_0_4]+`dmean')-exp(`dmean')+`R'*(exp(_b[nccat3_0_4]+`dmean')-exp(`dmean'))+`R'^2*(exp(_b[nccat3_0_4]+`dmean')-exp(`dmean')) ///
+ `R'^3*(exp(_b[nccat3_0_4]+`dmean')-exp(`dmean'))+`R'^4*(exp(_b[nccat3_0_4]+`dmean')-exp(`dmean')) ///
+ `R'^5*(exp(_b[nccat3_5_10]+`dmean')-exp(`dmean'))+`R'^6*(exp(_b[nccat3_5_10]+`dmean')-exp(`dmean')) ///
+ `R'^7*(exp(_b[nccat3_5_10]+`dmean')-exp(`dmean'))+`R'^8*(exp(_b[nccat3_5_10]+`dmean')-exp(`dmean')) ///
+ `R'^9*(exp(_b[nccat3_5_10]+`dmean')-exp(`dmean'))+`R'^10*(exp(_b[nccat3_5_10]+`dmean')-exp(`dmean'))

*********************************************************************************************
* Trend break
ols_spatial_HAC ntcat* ncat1_p ncat2_p ncat3_p ncat1_m ncat2_m ncat3_m, ///
lat(latitude) lon(longitude) t(year) p(county_fips) dist(200) bartlett lag(5) 
sum `outcome' if e(sample) & F.hurricane==1
local dmean=`r(mean)'

* Effects at time 2 and at time 7.5
foreach c in 1 2 3 {
nlcom _b[ntcat`c'_post_ind]+2*_b[ntcat`c'_trend_post]
nlcom _b[ntcat`c'_post_ind]+7.5*_b[ntcat`c'_trend_post]
}

****************************************************************
* Testing for differences between different categories

****************
* 1 versus 2
nlcom _b[ntcat1_post_ind]+2*_b[ntcat1_trend_post]-(_b[ntcat2_post_ind]+2*_b[ntcat2_trend_post])
nlcom (_b[ntcat1_post_ind]+7.5*_b[ntcat1_trend_post])-(_b[ntcat2_post_ind]+7.5*_b[ntcat2_trend_post])

****************
* 1 versus 3
nlcom _b[ntcat1_post_ind]+2*_b[ntcat1_trend_post]-(_b[ntcat3_post_ind]+2*_b[ntcat3_trend_post])
nlcom (_b[ntcat1_post_ind]+7.5*_b[ntcat1_trend_post])-(_b[ntcat3_post_ind]+7.5*_b[ntcat3_trend_post])

****************
* 2 versus 3
nlcom _b[ntcat2_post_ind]+2*_b[ntcat2_trend_post]-(_b[ntcat3_post_ind]+2*_b[ntcat3_trend_post])
nlcom (_b[ntcat2_post_ind]+7.5*_b[ntcat2_trend_post])-(_b[ntcat3_post_ind]+7.5*_b[ntcat3_trend_post])

********************************************************************************
* present discounted value for each category
nlcom exp(_b[ntcat1_post_ind]+`dmean')-exp(`dmean') ///
+`R'*(exp(_b[ntcat1_post_ind]+_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^2*(exp(_b[ntcat1_post_ind]+2*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^3*(exp(_b[ntcat1_post_ind]+3*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^4*(exp(_b[ntcat1_post_ind]+4*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^5*(exp(_b[ntcat1_post_ind]+5*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^6*(exp(_b[ntcat1_post_ind]+6*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^7*(exp(_b[ntcat1_post_ind]+7*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^8*(exp(_b[ntcat1_post_ind]+8*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^9*(exp(_b[ntcat1_post_ind]+9*_b[ntcat1_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^10*(exp(_b[ntcat1_post_ind]+10*_b[ntcat1_trend_post]+`dmean')-exp(`dmean'))

nlcom exp(_b[ntcat2_post_ind]+`dmean')-exp(`dmean') ///
+`R'*(exp(_b[ntcat2_post_ind]+_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^2*(exp(_b[ntcat2_post_ind]+2*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^3*(exp(_b[ntcat2_post_ind]+3*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^4*(exp(_b[ntcat2_post_ind]+4*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^5*(exp(_b[ntcat2_post_ind]+5*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^6*(exp(_b[ntcat2_post_ind]+6*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^7*(exp(_b[ntcat2_post_ind]+7*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^8*(exp(_b[ntcat2_post_ind]+8*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^9*(exp(_b[ntcat2_post_ind]+9*_b[ntcat2_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^10*(exp(_b[ntcat2_post_ind]+10*_b[ntcat2_trend_post]+`dmean')-exp(`dmean'))

nlcom exp(_b[ntcat3_post_ind]+`dmean')-exp(`dmean') ///
+`R'*(exp(_b[ntcat3_post_ind]+_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^2*(exp(_b[ntcat3_post_ind]+2*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^3*(exp(_b[ntcat3_post_ind]+3*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^4*(exp(_b[ntcat3_post_ind]+4*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^5*(exp(_b[ntcat3_post_ind]+5*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^6*(exp(_b[ntcat3_post_ind]+6*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^7*(exp(_b[ntcat3_post_ind]+7*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^8*(exp(_b[ntcat3_post_ind]+8*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^9*(exp(_b[ntcat3_post_ind]+9*_b[ntcat3_trend_post]+`dmean')-exp(`dmean')) ///
+`R'^10*(exp(_b[ntcat3_post_ind]+10*_b[ntcat3_trend_post]+`dmean')-exp(`dmean'))

}				// End of outcomelist loop
}				// End of main regressions loop
}				// End of analysis loop
