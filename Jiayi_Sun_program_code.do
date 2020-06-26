* -------------------------------------------------------------------------------------------------------------------------------- * 
*
* BFI Data Task For Applicant 3
* Jiayi Sun
* June 24, 2020
*
* -------------------------------------------------------------------------------------------------------------------------------- * 
* Change directory to where the data is located
* Create new output folder and set global output directory
global dataFolder "/home/jsun50/GitHub/BFI_Data_Task"
mkdir output
global outdir "output"

* ------------------------------------------------------------------------------------------ *	
* Section 2: Data Cleaning
*
* Goal: Collapse gird-level dataset into a district-level dataset
*
* Basic steps: 
*
* (1) Process dataset & identidy patterns of rainfall and temperature datasets: 
* Longitude takes 31 possible values between [67.5, 97.5], 
* Latitude takes 31 possible values between [7.5, 37.5].
* In total 961 combinations of longitudes and latitudes.
* This 961 combinations gets repeated every day in every year.
* We only need to figure out which district(s) each combination belong to.
*
* (2) Assign district and weight to each value
* 2.1 - Calculate distances between each one of the 961 latitude-longitude combinations and center point of the districts (75 in total)
* 2.2 - Determine if each distance is below 100km and hence belong to a certain district
* 2.3 - Calculate weight as inverse of squared distance from the district center
*
* (3) Use the weights to calculate weighted averages of rainfall and temperatures
*
* ------------------------------------------------------------------------------------------ *
* Generate dta files to replace csv files for easier processing
insheet using "$dataFolder/district_crosswalk_small.csv"
save "$dataFolder/district_crosswalk_small.dta"
clear
global years "2009 2010 2011 2012 2013"
foreach x of global years {
insheet using "$dataFolder/Rainfall/rainfall_`x'.csv"
save "$dataFolder/Rainfall/rainfall_`x'.dta"
clear
insheet using "$dataFolder/Temperature/temperature_`x'.csv"
save "$dataFolder/Temperature/temperature_`x'.dta"
clear
}

* Paste rainfall 2009 data into the district data
clear
use "$dataFolder/district_crosswalk_small.dta"
append using "$dataFolder/Rainfall/rainfall_2009.dta" 

* Generate centroid latitude and longtitude variables for later calculation
forvalues x = 1/75{
gen centroid_lat_`x' = centroid_latitude[`x']
gen centroid_long_`x' = centroid_longitude[`x']
}

* Only leave the 20090101 data to calculate weights
drop if date == .
drop *_iaa
drop centroid_longitude
drop centroid_latitude
drop unique_dist_id
drop if date != 20090101

* Calculate distances between centroid and each of the 961 points
forvalues y = 1/75 {
	geodist latitude longitude centroid_lat_`y' centroid_long_`y', gen(dist`y')
	gen index_`y' = .
}
 
* Document weights if the distance is smaller than or equal to 100km
forvalues y = 1/75 {
	forvalues x = 1/961 {
		if dist`y'[`x'] <= 100 {
			replace index_`y' = 1/(dist`y'[`x'])^2 if _n == `x'
		}
}
}

* Save the dataset with weights and expand the dimension to match that of a year dataset
keep index*
save "$dataFolder/weights.dta"
clear

use "$dataFolder/Rainfall/rainfall_2009.dta"

count
set obs `=`r(N)'+ 349804'

forvalues m = 1/365 {
		forvalues j = 1/961 {
			forvalues n = 1/75 {
				replace index_`n' = index_`n'[`j'] if _n == `m'*961+`j'
			} 
		}
}

save "$dataFolder/weights.dta"

* Append all years in one dataset
foreach x of global years {
	use "$dataFolder/Rainfall/rainfall_`x'.dta"
	merge 1:1 _n using "$dataFolder/weights.dta"
	save "$dataFolder/Rainfall/rainfall_`x'_weights.dta"
	clear
	use "$dataFolder/Temperature/temperature_`x'.dta"
	merge 1:1 _n using "$dataFolder/weights.dta"
	save "$dataFolder/Temperature/temperature_`x'_weights.dta"
	clear
}

* Put together all years of rainfall in one dataset
clear
use "$dataFolder/Rainfall/rainfall_2009_weights.dta"
append using "$dataFolder/Rainfall/rainfall_2010_weights.dta" 
append using "$dataFolder/Rainfall/rainfall_2011_weights.dta" 
append using "$dataFolder/Rainfall/rainfall_2012_weights.dta" 
append using "$dataFolder/Rainfall/rainfall_2013_weights.dta" 
save "$dataFolder/rainfall_all_with_weights.dta"

* Put together all years of temperature in one dataset
clear
use "$dataFolder/Temperature/temperature_2009.dta"
append using "$dataFolder/Temperature/temperature_2010.dta" 
append using "$dataFolder/Temperature/temperature_2011.dta" 
append using "$dataFolder/Temperature/temperature_2012.dta" 
append using "$dataFolder/Temperature/temperature_2013.dta" 
drop date
save "$dataFolder/temp_all_with_weights.dta"

* Merge two datasets
clear
use "$dataFolder/rainfall_all_with_weights.dta"
merge 1:1 _m using "$dataFolder/temp_all_with_weights.dta"

* Append new entries into the dataset
forvalues i = 1/961 {
	forvalues = 
	if month == ""
		count
		set obs `=`r(N)'+1'
		replace date = date[961] if _n == 962
}

//if date != . {
//display "x"
//up_bound_lat = latitude + 1
//up_bound_long = longitude + 1
//low_bound_lat = latitude - 1
//low_bound_long = longitude - 1 
//}


//	if centroid_lat_`y'[`x'] > latitude[`x'] + 1 {//|| centroid_lat_`y'[`x'] < latitude[`x'] - 1 || centroid_long_`y'[`x'] > longitude[`x'] + 1 || centroid_long_`y'[`x'] < longitude[`x'] - 1 {
//	replace index_`y' = 0 if _n = `x'
//	}
//	if (centroid_lat_`y'[`x'] <= latitude[`x'] + 1 && centroid_lat_`y'[`x'] >= latitude[`x'] - 1) || (centroid_long_`y'[`x'] <= longitude[`x'] + 1 && centroid_long_`y'[`x'] >= longitude[`x'] - 1) {

* ----------------------------------------------------------Section 3----------------------------------------------------------------- *




