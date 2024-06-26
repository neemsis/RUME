*-------------------------
*Arnaud NATAL
*arnaud.natal@ifpindia.org
*-----
*Education construction
*-----
clear all
macro drop _all
global directory = ""
cd"$directory"
*-------------------------



****************************************
* Education
****************************************
use"RUME-HH", clear

fre education
*Edulevel
gen edulevel=.
replace edulevel=0 if education==0
replace edulevel=1 if education==1
replace edulevel=2 if education==2
replace edulevel=3 if education==3
replace edulevel=3 if education==4
replace edulevel=4 if education==5
replace edulevel=5 if education==6
replace edulevel=5 if education==7
replace edulevel=5 if education==8

tab education

label define edulevel 0"Below primary" 1"Primary completed" 2"High school (8th-10th)" 3"HSC/Diploma (11th-12th)" 4"Bachelors (13th-15th)" 5"Post graduate (15th and more)", replace
label values edulevel edulevel
tab edulevel

keep HHID2010 INDID2010 edulevel

save"outcomes\RUME-education", replace
****************************************
* END
