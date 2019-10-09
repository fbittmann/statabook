*******************************************************************************
*General Do-File Header*
clear all			//clear memory
capture log close	//close any log-files (if still running)
*version 15.0		//your current version, change this to your version (and remove asterisk)!
set more off		//do not halt to show all output
*******************************************************************************

*cd "path"		//enter the path to your working directory and uncomment this line

sysuse nlsw88, clear		//open the dataset
*set scheme plotplain 		//Uncomment if you want to use the same style as in the book
***Regression***
/*We will use the following regression model for all diagnostics throughout
this chapter*/

regress wage c.ttl_exp i.union i.south c.grade


***Exogeneity***
estat ovtest			//Ramsey test

/*The significant result (0.05 > 0.073) tells us that there might be
something wrong with the model, possibly some important variables are missing*/



***Linearity***
twoway (scatter wage ttl_exp) ///
	(lfit wage ttl_exp) (lowess wage ttl_exp)	//Visualize relation graphically

ssc install binscatter, replace			//Install ado if not installed yet (Version 13+)
binscatter wage ttl_exp				//Better scatterplot

*Alternative way of detection*
regress wage c.ttl_exp i.union i.south c.grade
predict r1, resid		//Create residuals in variable "r1"
scatter r1 ttl_exp		//Create scatterplot with "ttl_exp"
binscatter r1 ttl_exp	//Scatter with other command
/*As long as there is no pattern visible the relation is linear*/



***Nested models***
regress wage c.ttl_exp i.union i.south c.grade		//Complex Model
estimates store complex
regress wage c.ttl_exp if _est_complex
/*This procedure guarantees that both models use the same number of cases. Start with your
most complex model and then "work your way down" to the most simple one*/



***Multicollinearity***

quietly regress wage c.ttl_exp i.union i.south c.grade
estat vif
*vif		//The old command
/*As we do not see any variables with values larger than 10 we can conclude that
there is no great amount of multicollinearity in the data. If you find
variables with large values exlude them from the analysis and run
the regression again. This does not hold for higher ordered terms as these always
have a high correlation to their derived variable */





***Heteroscedasticity***
quietly regress wage c.ttl_exp i.union i.south c.grade
rvfplot, yline(0)
/*As the data points are not distributed homogeneously, we might encounter
large heteroscedasticity here (Note the triangular shape of the data cloud)*/

estat hettest		//Formal test
/*As the value is smaller than 0.05 we conclude that the result is highly
significant, which underlines that we have to deal with heteroscedasticity*/


*Option 1: Transform dependent variable manually*
histogram wage		//Inspect distribution of dependet variable
gladder wage		//See which transformation works best --> Log
generate lwage = log(wage)	//Create logarithmized variable of log
regress lwage c.ttl_exp i.union i.south c.grade		//Run regression again
rvfplot, yline(0)				//Inspect residuals
estat hettest					//Test again

/*After transforming the dependent variable the distribution of the
residuals is much more homogeneous and the p-value is larger, which tells
us that we clearly reduced heteroscedasticity. */


*Option 2: Transform dependent variable automatically*
bcskew0 wage_trans = wage		//Make variable as symmetrical as possible
quietly regress wage_trans c.ttl_exp i.union i.south c.grade
rvfplot, yline(0)				//Inspect residuals
estat hettest					//Not significant anymore


*Option 3: Use robust standard errors*
regress wage c.ttl_exp i.union i.south c.grade, vce(robust)

/*Note that regression coefficients are unchanged, only the standard
errors are different (and therefore also p-values and significance levels*/

*Option 4: Transform, predict and Retransform*
*Make sure to generate lwage as described above!
regress lwage c.ttl_exp i.union i.south c.grade
margins union, at(ttl_exp=(0(4)24)) expression(exp(predict(xb)))
marginsplot




***Influential observations***

*DFBETAS*
regress wage c.ttl_exp i.union i.south c.grade
dfbeta										//Create dfbeta-variables

scatter _dfbeta_1 idcode, mlabel(idcode)	//Inspect problematic cases visually
scatter _dfbeta_2 idcode, mlabel(idcode)
scatter _dfbeta_3 idcode, mlabel(idcode)
scatter _dfbeta_4 idcode, mlabel(idcode)


graph box _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4 //Boxplot

display 2 / sqrt(1846)							//Calculate rule of thumb limit
count if _dfbeta_1 > 0.0465 & !missing(_dfbeta_1)		//Count number of problematic cases
list if _dfbeta_1 > 0.0465 & !missing(_dfbeta_1)		//Inspect number of problematic cases


*Cooks Distance*
regress wage c.ttl_exp i.union i.south c.grade
predict cook, cooksd
scatter cook idcode, mlabel(idcode)
list wage ttl_exp union south grade if idcode == 856	//Inspect strange case
count if cook > 4/1876						//Count problematic cases


lvr2plot, mlabel(idcode)		//Leverage VS squared residuals plot





***Local variables / local macros***
local controls c.age c.tenure i.race
regress wage i.union `controls'
*You have to select the two lines above and run them at the same time!



***Global variables / glöobal macros***
global test grade wage
summarize $test
