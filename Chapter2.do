*******************************************************************************
*General Do-File Header*
clear all			//clear memory
capture log close	//close any log-files (if still running)
*version 15.0		//your current version, change this to your version (and remove asterisk)!
set more off		//do not halt to show all output
*******************************************************************************



***Setting your current working directory***
cd "C:/Users/username/stata-course/"

/*You must replace this generic example with the path to the folder
where your files are saved*/


***Showing current working directory***
pwd


***Show all files in the current folder***
dir
ls			//Alternative command


*use "filename.dta"			//Open desired Stata file


***Alternative: absolute folder paths***
*use "C:\Users\username\stata-course\filename.dta"


***Entering data manually***
clear all					//Start with a fresh memory
set obs 10					//10 observations (cases)
generate age = .
generate income = .
generate gender = .
edit						//Edit data
browse						//Inspect data


***Using preinstalled data***
sysuse auto, clear			//Open preinstalled file
describe					//Inspect data


***Exporting data to (open) file formats***
outsheet using "auto_export.csv"	//CSV - Comma Separated Values
export excel using "etest.xls"		//XLS - Microsoft Excel File Format


***Delimit and line breaks***
sysuse nlsw88, clear
#delimit ;				//Tell Stata that all commands end with a semicolon from here on
count if age < 40 &
	smsa == 1 &
	wage > 20 &
	grade >= 7;			//Finally end your long command with the semicolon
#delimit cr				//Restore standard settings
