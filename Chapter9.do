*******************************************************************************
*General Do-File Header*
clear all			//clear memory
capture log close	//close any log-files (if still running)
*version 15.0		//your current version, change this to your version (and remove asterisk)!
set more off		//do not halt to show all output
*******************************************************************************

*cd "path"		//enter the path to your working directory and uncomment this line

sysuse nlsw88, clear			//open the dataset
*set scheme plotplain 		//Uncomment if you want to use the same style as in the book

ssc install kmatch, replace		//Install Ado
/*Alternatives:
ssc install psmatch2
ssc install st0026_2
help teffects psmatch
*/

kmatch ps union c.ttl_exp i.south c.age i.smsa (wage)	//PSM with Kernel

*Average Treatment Effect is 0.915


*Estimate Standard Errors and p-levels*
kmatch ps union c.ttl_exp i.south c.age i.smsa (wage), vce(bootstrap, reps(500))
*This might take a few  minutes to run*


*Combine with Exact Matching*
kmatch ps union c.ttl_exp i.south c.age i.smsa (wage), ///
	vce(bootstrap, reps(500)) att ematch(collgrad)
	
ssc install moremata, replace			//Some more ados are needed for the following commands
ssc install kdens, replace
***Matching diagnostics***
kmatch density										//Common Support
kmatch cdensity										//Differences Used Cases VS Sample
kmatch summarize									//Balancing of controls
kmatch density ttl_exp south age smsa				//Density Plot
kmatch box ttl_exp south age smsa					//Boxplot
kmatch cumul ttl_exp south age smsa					//Cumulative Plot




***Rosenbaum Bounds***
ssc install rbounds, replace 	//Install ado for metric dependent variable

*Run PSM again and save calculated results ("wage_PSM")
quietly kmatch ps union c.ttl_exp i.south c.age i.smsa (wage), ///
	att ematch(collgrad) generate(results) dy(wage_PSM) replace
	
help rbounds								//Study the documentation
rbounds wage_PSM, gamma(1 (0.1) 2)			//Calculate Rosenbaum Bounds


/*The interpretation is as follows: if the odds of entering the treatment group
(in comparison to entering the control group) change by the factor of 1.1 (that is
10%), the differences between the groups are still significant (0.0463 < 0.05).
However, if the odds change by 20% (see Gamma 1.2), the differences are no longer
significant.
This is a general rule of thumb to estimate how stable the effect is in respect to
hidden variables. The larger the Gamma that is still significant the more robust
the effect. You can also use the displayed Confidence Intervals (CI+ and CI-) which
provide the estimated Confidence Intervals for the ATT. If zero is included in
the interval, the effect is probably no longer significant*/
