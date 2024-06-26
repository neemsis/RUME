*-------------------------
*Arnaud NATAL
*arnaud.natal@ifpindia.org
*-----
*Transferts construction
*-----
clear all
macro drop _all
global directory = ""
cd"$directory"
*-------------------------



****************************************
* Remittances net
***************************************
use"RUME-HH", clear

egen remreceived_HH=rowtotal(remrectotalamount1 remrectotalamount2 remrectotalamount3)

egen remsent_indiv=rowtotal(remsenttotalamount1 remsenttotalamount2 remsenttotalamount3)
bysort HHID2010: egen remsent_HH=sum(remsent_indiv)
sort HHID2010 INDID2010

gen remittnet_HH=remreceived_HH-remsent_HH


keep HHID2010 remreceived_HH remsent_HH remittnet_HH
duplicates drop

save"outcomes\RUME-transferts_HH", replace
****************************************
* END
