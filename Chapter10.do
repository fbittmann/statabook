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


**********************************************************************
*Creating Tables
**********************************************************************

***Model 1***
regress wage c.ttl_exp		//Only include work experience
estimates store M1		//Save results

***Model 2***
regress wage c.ttl_exp i.union i.south	//Add binary variables
estimates store M2			//Save results

***Model 3***
regress wage c.ttl_exp i.union i.south i.race	//Add ordinal variable
estimates store M3					//Save results

*Produce output*
estimates table M1 M2 M3, se stats(r2 N)

*Change number format*
estimates table M1 M2 M3, se stats(r2 N) b(%7.3f) se(%7.2f)


***Using the estout-Ado***

ssc install estout, replace			//Install ado

eststo M1: regress wage c.ttl_exp
eststo M2: regress wage c.ttl_exp i.union i.south
eststo M3: regress wage c.ttl_exp i.union i.south i.race

esttab M1 M2 M3 using "new_table.rtf"	//Output table in current working directory

esttab M1 M2 M3 using "new_table.rtf",  nogaps nomtitles r2 ///
	star(# 0.10 * 0.05 ** 0.01 *** 0.001) b(3) se label replace

**********************************************************************
*Creating Graphs
**********************************************************************

ssc install coefplot, replace				//Install ado
quietly regress wage c.ttl_exp i.union i.south i.race
coefplot, xline(0)					//Create vertical line at zero



quietly regress wage c.ttl_exp i.union i.south i.race
margins				//Show average wage when all variables are at the mean
margins, atmeans		//Show the means for all variables

margins, at(ttl_exp=(0(5)30))	//Compute predicted values for certain values of job experience
marginsplot

margins union, at(ttl_exp=(0(5)30))		//Furthermore differentiate by union status
marginsplot

margins union, at(ttl_exp=(0(5)30) south=(0 1))	//Subgraphs by union status
marginsplot
marginsplot, by(south)



*Including an interaction between job experience and itself to account
*for higher ordered terms
regress wage c.ttl_exp##c.ttl_exp i.union i.south i.race		//Run new regression model
margins union, at(ttl_exp=(0(5)30) south=(0 1))
marginsplot, by(union)
