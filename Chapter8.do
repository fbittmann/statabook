*******************************************************************************
*General Do-File Header*
clear all			//clear memory
capture log close	//close any log-files (if still running)
*version 15.0		//your current version, change this to your version (and remove asterisk)!
set more off		//do not halt to show all output
*******************************************************************************

*cd "path"		//enter the path to your working directory and uncomment this line

webuse nhanes2, clear		//Open dataset from the internet
*set scheme plotplain 		//Uncomment if you want to use the same style as in the book

***Introduction***

tabulate heartatk		//Inspect dependent variable
summarize age, detail		//Inspect main independent variable
histogram age


spearman heartatk age		//Correlation between heartatk and age


*Model 1*
logit heartatk c.age
estat ic					//Inspect fit of the model

*Predicted values*
predict predi				//Predict estimated probabilities
scatter predi age			//Scatterplot


margins, atmeans				//Predicted probability at the mean age
/*The predicted probabilit for someone of age 47.58 to have a heart attack is
2.178% */

margins, at(age=(20(1)74))			//Predicted values for all ages
marginsplot, recast(line) recastci(rarea)	//Pretty graph


*Average Marginal Effects (AMEs)*
margins, dydx(age)
/*Margins calculcates the effect a _change_ of the independent variable has.
This means, if we increase the age of a person by 1 year, the probability
of suffering from a heart attack is increased by 0.35 percentage points (not percent!)*/


***Control variables***

logit heartatk c.age##c.age c.bmi i.region i.sex		//Model 2
estat ic
margins, dydx(*)

codebook sex
/*Women have a 3.7 percentage points lower probability of suffering from a heart attack than men,
all other variables held constant*/


quietly margins, at(age=(20(1)74))
marginsplot, recast(line) recastci(rarea)	//Graph for Model 2


quietly margins, at(age=(20(1)74)) by(sex)
marginsplot, recast(line) recastci(rarea)	//Gender differences visualized


quietly margins, dydx(sex) at(age=(20(1)74))
marginsplot, recast(line) recastci(rarea)	//Plot differences in probabilities in one graph


***Nested Models***
quietly logit heartatk c.age					//M1
estimates store M1
quietly logit heartatk c.age c.bmi i.region i.sex		//M2
estimates store M2
quietly logit heartatk c.age##c.age c.bmi i.region i.sex	//M3 with interaction effect age*age
estimates store M3
estimates tab M1 M2 M3, stats(N r2_p aic bic)				//Show table

/*The lower AIC and BIC, the better the model fit. Therefore we prefer model M3. If
there were any missing values you would hvae to check that all models use the same
number of cases! For an example check the Do-file for chapter 7.*/



*Likelihood-Ratio-Test*
lrtest M3 M2		//Model 3 VS Model 2
lrtest M2 M1		//Model 2 VS Model 1

/*Whenever we encounter a significant result (p < 0.05), we prefer the extended model (which
includes more variables*/



***Diagnostics***
quietly logit heartatk c.age##c.age c.bmi i.region i.sex	//Run Model M3 again
linktest
/*A good model shows a significant p-value for _hat (P>|z| smaller than 0.05)
and a not-significant p-value for _hatsq */



*Multicollinearity needs an ado for logistic regressions*
findit collin
/*A new window will pop up. Check all entries until you see one named "collin". Click this one.
If you cannot install the ado in the next window your Stata version is probably too old.
Also see https://stats.idre.ucla.edu/stata/ado/analysis/    
*/

collin age bmi region sex


*Outliers*
predict beta, dbeta				//Predict Pregibon's Betas
histogram beta					//Inspect distribution
scatter beta sampl, mlabel(sampl)		//Scatterplot with ID labels
*list if beta > 0.05 & missing(beta) == 0	//Inspect problematic cases individually


list heartatk sex age bmi region if sampl == 27438		//Inspect strange outlier in detail



*Run regression again without problematic case*
logit heartatk c.age##c.age c.bmi i.region i.sex if sampl != 27438
est store MReduced
logit heartatk c.age##c.age c.bmi i.region i.sex
est store MNormal
estimates tab MReduced MNormal, stats(N r2_p aic bic)		//Compare results



*** About Odds Ratios ***
/*Although the book emphasizes marginal effects and predicted probabilities as a more
modern solution, you will read a lot about Odds Ratios in older publications. Therefore,
here some information on them. Odds ratios are a statistic that tell us how much chances
or probabilities differ between two or more groups. Lets have an easy example from above.
How are men and women different in their chances of having a heart attack? Lets run
the model again: */

logit heartatk i.sex

/*We keep the model as simple as possible and only include one explanatory variable,
the gender. Note that result here are NOT Odds Ratios but Logits (-0.83722). If we want
Odds Ratios, we include the option "or" like so: */

logit heartatk i.sex, or

/*Notice how the results heading changes from "Coef" to "Odds Ratio". The resul is 0.4329.
Further notice that the "tipping point" for Odds Ratios is 1. If the result is 1 this means
that both groups have the same probability for the event to happen. If the result is smaller
than 1 (as in our case here), the probability for an event to happen is smaller for the
group of interest in comparison to the reference group. If the result is larger than 1,
then the probability is larger for the group of interest. In our case here, our group of interest
are women, the reference group are men (as men are coded with 0).
Therefore, we conclude that the risk to have a heart attack is smaller for the group of
interest (women) than for men. This result is highly significant as the p-value is 
smaller than 0.05.
For a more detailled interpretation, think as following: if the Odds Ratios is 2, then
the chance for the group of interest is twice has large as for the reference group. If
the Odds Ratios are 4, then the chance is four times as high. If the Odds Ratios are 0.5,
then the chance is only 50% as large as in the reference group.
In our case one could write: "women have, in comparison to men, 0.43 times the chance
to have a heart attack."
*/

	

