*******************************************************************************
*General Do-File Header*
clear all			//clear memory
capture log close	//close any log-files (if still running)
*version 15.0		//your current version, change this to your version (and remove asterisk)!
set more off		//do not halt to show all output
*******************************************************************************

*cd "path"		//enter the path to your working directory and uncomment this line
*set scheme plotplain		//Uncomment if you want to use the same style as in the book
sysuse nlsw88, clear		//open the dataset


***Model 1 - Union Membership***
regress wage i.union
codebook union

/*As non-union is the reference, the effect is calculated in contrast to this group.
Therefore union members earn on average 1.47 more per hour than non-members. This effect
is highly significant (p<0.05)*/


***Model 2 - Education***
*Create ordinal variable "education" from metric variable "grade".
recode grade (0/10 = 1 "low education") (11/13 = 2 "medium education") ///
	(14/18 = 3 "high education"), generate(education)
tabulate grade education			//Check results
codebook education 					//Inspect the independent variable

regress wage i.education			//Run regression

/*The reference is "low education", the other two categories are seen in contrast
to this one. Therefore people with medium education make 1.90 more per hour on average than
people with low education. People with high education make on average 5.21 more per hour than
people with low education. Both effects are highly significant*/


*Alternatively with recoding into dummies*			//Old workflow
tabulate education, gen(edu_dummies)				//Generates 3 new variables
tab1 edu_dummies1 edu_dummies2 edu_dummies3	//Inspect Results
regress wage i.edu_dummies2 i.edu_dummies3			//Yields exact same results as command above

regress wage ib3.education		//Change category of reference to "high education"






***Model 3 - Total work experience***
regress wage c.ttl_exp

/*One year more of work experiences will yield an increase of wages by 0.33. The effect is
highly significant */


***Model 3 - Total work experience with controls***
regress wage c.ttl_exp i.union i.south c.grade


***Interaction effects***
regress wage i.union							//Basic model
regress wage i.union i.collgrad c.ttl_exp		//All variables, but no interaction
regress wage i.union##i.collgrad c.ttl_exp		//Interactiom effect introduced


*Calculating absolute effects using the margins command
margins, dydx(union) at(collgrad=(0 1))
margins, dydx(union) by(collgrad)			//Alternative command, same results

/*The resulting number indicates the wage of a person who is union member, from the south,
has a job experience of zero and a low education. By combining the values of your
variables you can precisely tell Stata to calculate certain effects, but there are even
better ways to do this.*/


*Predicted values*
margins, at(union = (0 1) collgrad=(0 1))
marginsplot


*Separate analyses by subgroups*
bysort collgrad: regress wage i.union c.ttl_exp

*This command does the same as:
regress wage i.union c.ttl_exp if collgrad == 0
regress wage i.union c.ttl_exp if collgrad == 1


***Standardized regression coefficients***
regress wage c.ttl_exp, beta

*Doing this manually:
quietly sum wage
generate zwage = (wage-r(mean))/r(sd)
quietly sum ttl_exp
generate zttl_exp = (ttl_exp-r(mean))/r(sd)
regress zwage c.zttl_exp


***What about ANOVAs?***
sysuse bpwide, clear 					//Open new example dataset
oneway bp_before agegrp, tabulate 		//Run ANOVA
regress bp_before i.agegrp				//Same results with regression
test 2.agegrp = 3.agegrp				//Test equality of coefficients
