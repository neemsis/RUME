*-------------------------
*Arnaud NATAL
*arnaud.natal@ifpindia.org
*-----
*Assets construction
*-----
clear all
macro drop _all
global directory = ""
cd"$directory"
*-------------------------




  
****************************************
* ASSETS 2010
***************************************
use"RUME-HH", clear

/*
Assets = 
+ house value
+ livestock
+ goods
+ gold
+ land
*/

*** Livestock
gen livestockamount_cow=8000*livestocknb_cow
gen livestockamount_goat=1000*livestocknb_goat
egen livestockamount=rowtotal(livestockamount_cow livestockamount_goat)

*** Goods
forvalues i=1/10 {
gen goodsvalue`i'=.
replace goodsvalue`i'=100000*numbergoods`i' if listgoods`i'==1
replace goodsvalue`i'=1000*numbergoods`i' if listgoods`i'==2
replace goodsvalue`i'=5000*numbergoods`i' if listgoods`i'==3
replace goodsvalue`i'=5000*numbergoods`i' if listgoods`i'==4
replace goodsvalue`i'=1000*numbergoods`i' if listgoods`i'==5
replace goodsvalue`i'=1000*numbergoods`i' if listgoods`i'==6
replace goodsvalue`i'=1000*numbergoods`i' if listgoods`i'==7
replace goodsvalue`i'=1000*numbergoods`i' if listgoods`i'==8
replace goodsvalue`i'=5000*numbergoods`i' if listgoods`i'==9
replace goodsvalue`i'=500*numbergoods`i' if listgoods`i'==10
replace goodsvalue`i'=10000*numbergoods`i' if listgoods`i'==11
replace goodsvalue`i'=1000*numbergoods`i' if listgoods`i'==12
replace goodsvalue`i'=3000*numbergoods`i' if listgoods`i'==13
}
egen goodstotalamount=rowtotal(goodsvalue1 goodsvalue2 goodsvalue3 goodsvalue4 goodsvalue5 goodsvalue6 goodsvalue7 goodsvalue8 goodsvalue9 goodsvalue10)

*** Land
fre sizeownland drywetownland
gen amountownland=.
replace amountownland=600000*sizeownland if drywetownland==1
replace amountownland=1100000*sizeownland if drywetownland==2

gen sizedryownland=sizeownland if drywetownland==1
gen sizewetownland=sizeownland if drywetownland==2

***Gold
merge m:1 HHID2010 using "outcomes/RUME-gold_HH", keepusing(goldamount_HH)
drop _merge


****Total
egen assets=rowtotal(livestockamount goodstotalamount amountownland goldamount_HH housevalue)
egen assets_noland=rowtotal(livestockamount goodstotalamount goldamount_HH housevalue)
egen assets_noprop=rowtotal(livestockamount goodstotalamount goldamount_HH)

gen assets1000=assets/1000
gen assets1000_noland=assets_noland/1000
gen assets1000_noprop=assets_noprop/1000



***Clean
drop livestockamount_cow livestockamount_goat goodsvalue1 goodsvalue2 goodsvalue3 goodsvalue4 goodsvalue5 goodsvalue6 goodsvalue7 goodsvalue8 goodsvalue9 goodsvalue10


********** Variables
keep HHID2010 assets* livestockamount goodstotalamount amountownland goldamount_HH housevalue sizeownland
rename goldamount_HH goldamount
duplicates drop

* Rename
rename sizeownland assets_sizeownland
rename housevalue assets_housevalue
rename livestockamount assets_livestock
rename goodstotalamount assets_goods
rename amountownland assets_ownland
rename goldamount assets_gold
rename assets_noland assets_totalnoland
rename assets_noprop assets_totalnoprop
rename assets assets_total
rename assets1000 assets_total1000
rename assets1000_noland assets_totalnoland1000
rename assets1000_noprop assets_totalnoprop1000

* Share
foreach x in housevalue livestock goods ownland gold {
gen shareassets_`x'=assets_`x'*100/assets_total
replace shareassets_`x'=round(shareassets_`x',0.01)
}

gen test=100-shareassets_housevalue-shareassets_livestock-shareassets_goods-shareassets_ownland-shareassets_gold
ta test
drop test

recode shareassets_housevalue shareassets_livestock shareassets_goods shareassets_ownland shareassets_gold (.=0)

tabstat shareassets_housevalue shareassets_livestock shareassets_goods shareassets_ownland shareassets_gold, stat(n mean cv p50)

save"_temp\RUME-ass1", replace
****************************************
* END









****************************************
* Expenses 2010
***************************************
use"RUME-HH", clear

keep HHID2010 foodexpenses educationexpenses healthexpenses ceremoniesexpenses deathexpenses productexpenses1 productexpenses2 productexpenses3 productexpenses4 productexpenses5 

duplicates drop


* Annual expenses
foreach x in productexpenses1 productexpenses2 productexpenses3 productexpenses4 productexpenses5 foodexpenses educationexpenses healthexpenses ceremoniesexpenses deathexpenses {
replace `x'=0 if `x'==.
}

gen expenses_total=52*foodexpenses+educationexpenses+healthexpenses+ceremoniesexpenses+deathexpenses

gen expenses_food=52*foodexpenses
gen expenses_educ=educationexpenses
gen expenses_heal=healthexpenses
gen expenses_cere=ceremoniesexpenses+deathexpenses

* Agri
egen expenses_agri=rowtotal(productexpenses1 productexpenses2 productexpenses3 productexpenses4 productexpenses5)



drop productexpenses1 productexpenses2 productexpenses3 productexpenses4 productexpenses5 foodexpenses educationexpenses healthexpenses ceremoniesexpenses deathexpenses

foreach x in expenses_food expenses_educ expenses_heal expenses_cere {
label var `x' "Annual expenses"
}

label var expenses_total "food+educ+heal+cere+deat"


* Share
foreach x in food educ heal cere {
gen shareexpenses_`x'=expenses_`x'*100/expenses_total
}


* Test
gen test1=100-shareexpenses_food-shareexpenses_educ-shareexpenses_heal-shareexpenses_cere
ta test1
drop test1

* Reduce
foreach x in shareexpenses_food shareexpenses_educ shareexpenses_heal shareexpenses_cere {
replace `x'=round(`x',0.01)
}


merge 1:1 HHID2010 using "_temp\RUME-ass1"
drop _merge

save"outcomes\RUME-assets", replace
****************************************
* END
