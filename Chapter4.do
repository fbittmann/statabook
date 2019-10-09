*******************************************************************************
*General Do-File Header*
clear all			//clear memory
capture log close	//close any log-files (if still running)
*version 15.0		//your current version, change this to your version (and remove asterisk)!
set more off		//do not halt to show all output
*******************************************************************************

*cd "path"		//enter the path to your working directory and uncomment this line

sysuse nlsw88, clear			//open the dataset

ssc install fre, replace		//Install fre ado
fre industry
tabulate industry
numlabel, add
tabulate industry
numlabel, remove


***Summarizing Information***
summarize age, detail			//computes most important statistics
centile age, centile(33)		//compute 33% percentile of age
summarize age never_married collgrad union wage


***Exporting descriptive results using estout***
ssc install estout, replace
estpost summarize age never_married collgrad union wage
esttab using "out.rtf", cells("mean sd min max") noobs replace


***Using stored results***
summarize wage, detail			//Run command
return list						//See what Stata saved
*ereturn list					//Use this for some commands like "regress"

display r(mean)					//Access saved results
generate z_wage2 = (wage-r(mean)) / r(sd)	//Generate a new score
summarize z_wage2


***Histograms***
/*If you want your graphs to be optically identical to the ones from the book,
run the following two lines of code*/
ssc install blindschemes, replace
set scheme plotplain


histogram age			
/*The problem is that the number of distinct numerical values is
quite small so the histogram looks odd. We can fix this with the option "discrete"*/

histogram age, discrete
kdensity age 				//Kernel-density plot
twoway (kdensity wage if collgrad==0) (kdensity wage if collgrad==1)		//Combine plots


***Creating Boxplots***
graph box wage				//Summarize information of a metric variable
graph box wage, over(union)	//Compare binary or ordinal categories


***Dealing with outliers***
/*As we fix and remove cases temporally, we will make a copy of the variable we
change so the original one is untouched*/

clonevar wage2 = wage				//Clone variable wage
histogram wage2						//Show histogram of wage
		
replace wage2 = 25 if wage2 > 25 & !missing(wage)	//Fix outliers to a limit
histogram wage2						//Inspect result
drop wage2							//Remove cloned variable

clonevar wage2 = wage				//Clone variable wage again
replace wage2 = . if wage2 > 25		//Remove outliers as we set them to a missing value
histogram wage2						//Inspect result
drop wage2							//Remove cloned variable


***Simple Bar Charts***
tabulate industry				//Produce a graph from this table
ssc install catplot, replace	//Install Ado
catplot industry, blabel(bar)	//Create Graph with frequencies
catplot industry				//Same graph without frequencies shown


***Scatterplots***
scatter wage ttl_exp		//Scatterplot with wage on the y-axis and Total Job Experience on the x-axis
graph matrix wage ttl_exp	//Slightly more advanced graph
scatter wage ttl_exp, jitter(10)	//Using jitter to avoid plotting data points on top of each other
ssc install binscatter, replace		//Installing binscatter ado (Stata 13+)
binscatter wage ttl_exp				//Create binscatter graph


***Tables***
tabulate union south						//Simple Crosstab
tabulate union south, column				//Summarize by Column (column-percentages)
tabulate union south, row					//Summarize by row (row-percentages)
tabulate union south, cell					//Show relative frequency of each cell
tabulate union south, column row cell		//All in one (not a good idea)
bysort c_city: tabulate union south, column	//Create a 3-way-table
table union south, by(c_city) contents(freq) //Alternative command


***Summarizing information by categories***
tabulate collgrad, summarize(wage)
bysort collgrad: summarize wage				//Summarize wage by categories of the variable collgrad	
tabulate union south, summarize(wage)


/*Note that "bysort VAR:" and "by VAR, sort:" do exactly the same thing.
Stata introduced the command "bysort" as forgetting the sort
option with "by" happened often and is a little inconvenient. I recommend
to always use bysort as it is easy to remember and less error prone*/



***Bar charts***
graph bar (mean) wage, over(collgrad) blabel(bar)	//Creates a bar graph summarizing the same information

*You can also introduce a second (or more!) categorical variable to calculate means for:
graph bar (mean) wage, over(collgrad) over(south) blabel(bar)
graph bar (mean) wage, over(collgrad) over(south) blabel(bar, format(%5.2f)) 	//Formatting numbers, 2 decimals
graph bar (mean) wage, over(collgrad) over(south) blabel(bar, format(%5.3f)) 	//Formatting numbers, 3 decimals

graph dot (mean) wage, over(occupation)		//Using a Dot-graph instead of a bar-graph.
graph dot (mean) wage, over(occupation, sort((mean) wage))		//Sort values from low to high


***Editing and exporting graphs***

histogram age, discrete		//Create histogram of age with discrete option

/*You can now start the Graph Editor, which is not possible in Do-Files. But there are
other options you can try here */

histogram age, discrete title(Age of Person)	///	Create graph and give it a Title
	note(Source: NLSW88)						///	add a Note
	name(age, replace)							//	name graph

graph save "histogram_age.gph", replace					//save graph in Stata format
graph export "histogram_age.png", as(png) replace		//export graph to .png
graph export "histogram_age.pdf", as(pdf) replace		//export graph to .pdf


/*If you are not content with the resolution of the png-file, you can resize the image
for a higher quality. Specify the desired width of the image. Stata will
automatically choose the correct height so the aspect ratio is kept*/

graph export "histogram_age_big.png", as(png) replace width(1600)		

***Combining Graphs***

*First we create several graphs and then combine them

histogram age, discrete name(age, replace)
histogram wage, name(wage, replace)
graph box tenure, name(boxplot_tenure, replace)
kdensity ttl_exp, name(kernel_exp, replace)

graph combine age wage boxplot_tenure kernel_exp, name(overview, replace)
graph save "combination.gph", replace
graph export "combination.png", as(png) replace

/*The basic idea is to create a graph normall and add a name label to it. You can then
proceed normally and edit the graph using the Graph Editor. After you are finished you
can use the combine command to combine all desired graphs in one image, which can also
be named, saved and exported. */
	
***Correlations***
pwcorr wage ttl_exp, sig	//Pairwise correlations with significance level shown
corr wage ttl_exp			//Alternative command without significance levels
spearman wage grade			//Calculating Spearman's Rho
ktau wage grade				//Calculating Kendall's Tau


***Testing for normality***
qnorm ttl_exp				//Quantile-Quantile Plot
sfrancia ttl_exp			//Numerical test
*The results indicate that the distribution is NOT normal as Prob>z is smaller than 0.05

***T-Test for groups***
ttest wage, by(collgrad)		//College VS not college education

