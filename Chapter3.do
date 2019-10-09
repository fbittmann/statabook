*******************************************************************************
*General Do-File Header*
clear all			//clear memory
capture log close	//close any log-files (if still running)
*version 15.0		//your current version, change this to your version (and remove asterisk)!
set more off		//do not halt to show all output
*******************************************************************************


*cd "path"		//enter the path to your working directory and uncomment this line

***Getting to know your data***
sysuse nlsw88		//open the dataset
describe			//basic information about the dataset


*Looking at special cases (Listing cases)
list if age < 40 & south == 1 & union == 1				//List all cases that satisfy the condition after "if"
list in 1/10											//List all information about first 10 cases
list idcode age grade union wage in 1/10 if age < 40	//Combine in and if


***Variable names and labels***
rename smsa metro			//renaming variable from "smsa" to "metro"
label variable metro "Standard Metropolitan Statistical Area"  //changing label
tabulate metro			//Inspect results


***Labeling values***
tabulate c_city						//inspect the variable c_city
label define yesno 1 "yes" 0 "no" 	//creating a new label
label values c_city yesno			//applying label to variable
tabulate c_city						//Inspect results


***IDs and unique identifiers***
isid idcode				//check if variable "idcode" is a unique identifier
generate ID = _n		// generate a new ID variable
label variable ID "new unique identifier"		//label new ID variable
duplicates list			//check for duplicates in the dataset

*IDs by Industry*
bysort industry: gen ind_ID = _n
/*This command sorts people by the industry they work in and creates a new ID
that identifies people within on industy group*/
order industry ind_ID			//Reorder columns for easier inspection
browse					//Inspect results
list ID ind_ID industry in 1/30, sepby(industry)					

*Bysort*
bysort industry (age): gen ind_age_ID = _n
/*This command sorts all people by industry and age and then creates a counter. By doing this,
the people within one industry group are further sorted by age. Compare what changes if you
omit the parentheses around age:*/
list ind_age_ID age industry in 1/30, sepby(industry)

bysort industry age: gen ind_age_ID2 = _n			//Not only order by age, also separate groups
order industry ind_ID ind_age_ID ind_age_ID2 age	//Reorder columns for easier inspection
browse												//Inspect results		
list ind_age_ID2 age industry in 1/30, sepby(industry)

***Sorting***
sort age
list ID age in 1/100		//Sort ascending
gsort -age
list ID age in 1/100		//Sort descending

***Missing values***
sysuse nlsw88, clear		//Undo changes, start fresh
misstable summarize, all	//receive an overview about missing values in the dataset

/* Now we want to count how many people are working more than 60 hours per week.
As we have missing values (depicted by dots) in this variable and missing values are
regarded as extremely large numbers by Stata, the following command will get us a wrong
result*/
count if hours > 60							//Stata counts 22 people, which is incorrect as 4 have missings!
count if hours > 60 & hours < .				//Correct result (18 people)
count if hours > 60 & !missing(hours)		//Alternative command


***Creating new variables***
generate ybirth = 1988 - age				//Generating year of birth of a person
label variable ybirth "Year of birth"		//Labeling variable
tabulate ybirth								//Inspecting results

generate age_squared = age^2				//Generating the squared version of age
*generate age_squared = age*age				//Alternative command
label variable age_squared "Aqe Squared"	//Labeling variable
tabulate age_squared						//Inspect results


***Special Functions***
*Inlist*
count if occupation == 1 | occupation == 2 | ///
	occupation == 3 | occupation == 4
count if inlist(occupation,1,2,3,4)				//Same result, shorter command


*Inlist, second usage*
count if inlist(1,union,smsa,c_city)
count if union == 1 | smsa == 1 | c_city == 1		//Alternative command



*Inrange*
count if wage >= 10 & wage <= 15
count if inrange(wage,10,15)					//Same result, shorter command

*Irecode*
generate hours_cat = .
replace hours_cat = 0 if hours <= 20
replace hours_cat = 1 if hours > 20 & hours <= 40
replace hours_cat = 2 if hours > 40 & hours !=.
tabulate hours_cat
drop hours_cat

generate hours_cat = irecode(hours,20,40)	//Same result, shorter command
tabulate hours_cat

*Autocode*
generate tenure_cat = autocode(tenure,5,0,27)
tabulate tenure_cat
tabulate tenure tenure_cat					//Crosscheck

*Egen*
egen maxvalue = rowmax(wage tenure hours)		//Find Maximum of all three variables for each case
list idcode maxvalue wage tenure hours in 1/20	//Inspect result


***The if qualifier***
count					//Shows number of observations in the dataset

/*Make sure that the variables used have no missing values as otherwise the results
might be wrong! This is important when you work with the following operators:
>
<
>=
<=
You can either delete all missings (drop if missing(age) == 1) or exclude these cases
as shown in the following examples.
*/

*Show number of people that are older or equal to 40 and are married:
count if age >= 40 & !missing(age) & married == 1

/*Show number of people that work in the mining industry or the construction industry
and are not white*/
count if (industry == 2 | industry == 3) & race != 1 & !missing(race)

/*Note that parentheses make a difference here! If you switch them, your result will differ*/
count if industry == 2 | industry == 3 & race != 1 & !missing(race)

*Show the number of people that are younger than 35 and earn 25 or more:
count if age < 35 & wage >= 25 & !missing(age) & !missing(wage)


***Changing and replacing variables***
generate parttime = .									//Create new variable with missing values
replace parttime = 1 if hours <= 20						//Replace people who work 20 hours or less with value 1
replace parttime = 0 if hours > 20 & !missing(hours)	//Replace people who work more than 20 hours with value 0
tabulate parttime, missing								//Inspect results
tabulate hours parttime, missing						//Crosscheck results
label variable parttime "Working Part-time"				//Labeling variable
label values parttime yesno								//Label values with label "yesno" created above
tabulate parttime, missing

***Assert***
assert missing(hours) == missing(parttime)

*New variables and labels in one step
codebook race						//Check how numerical values are coded to labels
recode race (1 = 1 "yes") (2 3 = 0 "no"), gen(is_white)	//Create and label variable
tabulate race is_white					//Validate results


*Saving our results*
save "nlsw88_new.dta", replace		//Save results and overwrite existing dataset


***Removing Observations and Variables***
*(We wont save these changes to the file)
drop if grade < 4			//Remove people with less than 4 years of schooling
keep if occupation == 2		//Remove all persons that are NOT managers (just keep the managers)

drop parttime			//remove variable which we created before
describe		//test if command was successful

***Cleaning data systematically***
assert inrange(age,18,100)			//Age must be between 18 and 100 years
assert inrange(occupation,1,13)		//Gives error as some cases have missing values
assert inrange(occupation,1,13) | missing(occupation)


compare ttl_exp tenure

*******************************************************************************
*Combining datasets*
*******************************************************************************

/*If you are not using Stata 15 or 14, make sure to add the suffix
_old to any dataset here. So for example, instead of typing
append_a.dta use append_a_old.dta*/



******************************************
*1. Appending Datasets
******************************************
use "http://data.statabook.com/append_a.dta", clear		//Load dataset A
list													//Inspect dataset A
save "append_a", replace								//Save dataset A
use "http://data.statabook.com/append_b.dta", clear		//Load dataset B
list													//Inspect dataset B
save "append_b", replace								//Save dataset B
append using "append_a", generate(check_append)			//Merge and create testing variable
list													//Inspect results


******************************************
*2. One-to-One Merge
******************************************
use "http://data.statabook.com/1to1_a.dta", clear		//Load dataset A
list													//Inspect dataset A
save "1to1_a", replace									//Save dataset A
use "http://data.statabook.com/1to1_b.dta", clear		//Load dataset B
list													//Inspect dataset B
save "1to1_b", replace									//Save dataset B
merge 1:1 country using "1to1_a.dta"					//Merge A and B
list													//Inspect results


******************************************
*3. Many-to-One Merge
******************************************
use "http://data.statabook.com/mto1_b.dta", clear		//Load dataset B
list													//Inspect dataset B
save "mto1_b", replace									//Save dataset B
use "http://data.statabook.com/mto1_a.dta", clear		//Load dataset A
list													//Inspect dataset A
save "mto1_a", replace									//Save dataset A
merge m:1 school_ID using "mto1_b.dta"					//Merge A and B
list													//Inspect results


******************************************
*4. One-to-Many Merge
******************************************
/*This is basically the merge procedure from Many-to-One, yet the master file
(the file that is open in memory at the time of the merge) and the using file
(the file saved on your harddrive) is swapped. You can see this easily by
comparing the command from 3. and 4. Whenever you can perform one of the two merges,
you also can perform the other one. Just pay attention to which file has "many"
cases and which has only "one". If you find this hard to remember, try to think
of the "pupils and schools" example, as this is clear and logical, as there will always
be more pupils than schools. */


use "http://data.statabook.com/mto1_a.dta", clear		//Load dataset A
list													//Inspect dataset A
save "mto1_a", replace									//Save dataset A
use "http://data.statabook.com/mto1_b.dta", clear		//Load dataset B
list													//Inspect dataset B
save "mto1_b", replace									//Save dataset B
merge 1:m school_ID using "mto1_a.dta"					//Merge A and B
list													//Inspect results


******************************************
*5. Many-to-Many Merge
******************************************
/* Do not use this. Ever. To quote the Stata documentation:

"This is allowed for completeness, but it is difficult to imagine
an example of when it would be useful. (...) Use of merge m:m
is not encouraged."

https://www.stata.com/manuals13/dmerge.pdf (2018-01-18).

*/

******************************************
*6. All pairwise combinations (joinby)
******************************************

use "http://data.statabook.com/pairs_a.dta", clear		//Parent data
list
save "pairs_a", replace
use "http://data.statabook.com/pairs_b.dta", clear		//Child data
list
save "pairs_b", replace
joinby family_ID using "pairs_a"						//Form pairs
sort family_ID parent_ID child_ID 						//Sort data
order family_ID parent_ID age_P child_ID score			//Reorder variables
list, sepby(family_ID) 									//List results

*The sebpy option just inserts lines between families which makes
*the list more clear.




******************************************
*Reshaping Data
******************************************

use "http://data.statabook.com/reshape.dta", clear
list
reshape long score@, i(country) j(year) 				//Wide to long
list, sepby(country)									//List results

/* The data is in wide format as every observation takes exactly
one line. Now we reshape, specifying the ID ("id") which is
unique for each case. Then we specify a time variable that
Stata should create for us ("year"). "Long" tells Stata that we 
want to reshape into long format. We also tell Stata which
variables are not time constant. The @-sign tells Stata where
to look for the time information */

*We can go back by using the same command and just change "long" to "wide"

reshape wide score@, i(country) j(year)	//Long to wide
list


*Also shorter commands possible as no new variables are created*
reshape long
reshape wide
