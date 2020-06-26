use "$dataFolder/weights.dta"
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
