**** Examine former teacher 1999-2000 file ****
 
** change working directory to specified path
cd "D:\ECO4381\Stata_data"
dir

** record output in the log
log using "D:\ECO4381\Stata_logs\TFS_2000", text replace

** import Former Teacher 2000-2001 SAS files 
capture import sas using "D:\ECO4381\Stata_data\frmrtchr00_sas\frmrtchr00.sas7bdat", bcat("D:\ECO4381\Stata_data\frmrtchr00_sas\formats.sas7bcat") clear

** obtain summary statistics
describe
codebook,compact

** check if all observations in CNTLNUM are unique
isid CNTLNUM 

** tabulate STATUS 
tab STATUS

** drop any missing value
drop if missing(STATUS)

** keep variables for merging
keep CNTLNUM STATUS 

** save dataset
save formerT, replace



**** Examine current teacher 1999-2000 file ****

** import Current Teacher 2000-2001 SAS files 
clear
capture import sas using "D:\ECO4381\Stata_data\crnttchr00_sas\crnttchr00.sas7bdat", bcat("D:\ECO4381\Stata_data\crnttchr00_sas\formats.sas7bcat") clear

** obtain summary statistics
describe
codebook,compact

** check if all observations in CNTLNUM are unique
isid CNTLNUM 

** tabulate the status variable
tab STATUS

** drop any missing value
drop if missing(STATUS)

** filter special education variables
gen sped_t = (F0556==49|F0556==50|F0556==51|F0556==52|F0556==53|F0556==54|F0556==55|F0556==56|F0556==57|F0556==58|F0556==59|F0556==60|F0556==61|F0556==62|F0556==63)

** drop any missing value
drop if missing(sped_t)

** keep variables for merging
keep CNTLNUM STATUS 

** save dataset
save currentT, replace



**** Concatenate the two datasets ****

** clear memory
clear

** load currentT dataset and append formerT dataset to currentT
use currentT
append using formerT

** save appended dataset as appended_data
save appended_data, replace


**** Download public teacher file ****

** import Public Teacher 1999-2000 SAS files 
clear
capture import sas using "D:\ECO4381\Stata_data\tchpub99_sas\tchpub99.sas7bdat", bcat("D:\ECO4381\Stata_data\tchpub99_sas\formats.sas7bcat") clear
describe
codebook,compact

** check if all observations in CNTLNUM are unique
isid CNTLNUM 

** filter special education variables
gen sped_t = (T0102==49|T0102==50|T0102==51|T0102==52|T0102==53|T0102==54|T0102==55|T0102==56|T0102==57|T0102==58|T0102==59|T0102==60|T0102==61|T0102==62|T0102==63)
drop if missing(sped_t)

** general teacher characteristic variables
tab AGE_T	// teacher age
tab RACETH_T // race/ethnicity
tab TOTEXPER // total teaching experience

** student behavior variables
rename T0278 tardy	//tardy students
rename T0279 disruption	//interruptions
rename T0280 ever_threatened	//ever threatened
rename T0283 ever_attacked	//ever attacked
rename T0285 num_attacks //number of attacks
rename T0282 num_threats //number of threats

rename T0192 prek
rename T0193 kind
rename T0194 gr_1
rename T0195 gr_2
rename T0196 gr_3
rename T0197 gr_4
rename T0198 gr_5
rename T0199 gr_6
rename T0200 gr_7
rename T0201 gr_8
rename T0202 gr_9
rename T0203 gr_10
rename T0204 gr_11
rename T0205 gr_12

replace num_attacks = 0 if num_attacks < 0
replace num_threats = 0 if num_threats < 0

tab ATTACK
quietly tab TRDY
tab THREAT
tab EARNALL

** staff behavior variables
rename T0311 coop_effort

** admin behavior variables
rename T0300 admin_behavior	//admin supportive

** keep variables of interest
keep CNTLNUM sped_t tardy disruption ever_threatened ever_attacked num_attacks num_threats coop_effort admin_behavior AGE_T RACETH_T ATTACK TRDY THREAT TOTEXPER EARNALL prek kind gr_1 gr_2 gr_3 gr_4 gr_5 gr_6 gr_7 gr_8 gr_9 gr_10 gr_11 gr_12



** merge public teacher dataset with the appended dataset
merge 1:1 CNTLNUM using appended_data, keep(match)
tab _merge


*** generate new status variables
generate leaver=(STATUS=="L") if STATUS~=""
generate mover=(STATUS=="M") if STATUS~=""
generate stayer=(STATUS=="S") if STATUS~=""

tab leaver STATUS, missing
tab mover STATUS, missing
tab stayer STATUS, missing



** graph age vs teacher turnover(overall+special ed) 
//graph bar leaver, over(AGE_T) by(sped_t) b1title("Age") ytitle(Teacher Leaving) title(Age Distribution of Teachers Who Left) legend(on order(1 "1: <30 years" 2 "2: 30-39 years" 3 "3: 40-49 years" 4 "4: 50+ years"))
graph use "D:\ECO4381\sped vs overall age.gph"	//opens the age graph generated from the line above and edited using the Graph Editor


** graph race vs teacher turnover(overall+special ed)  
//graph bar leaver, over(RACETH_T) by(sped_t) b1title("Race") ytitle(Teacher Leaving) title(Race/Ethnicity of Teachers Who Left) legend(on order(1 "1: Native American" 2 "2: Asian/Pacific Islander" 3 "3: Black" 4 "4: White" 5 "5: Hispanic"))
graph use "D:\ECO4381\sped vs overall race.gph"

** graph teaching experience vs teacher turnover(overall+special ed)
gen totexper_bins = 1 if (inrange(TOTEXPER,0,1))
replace totexper_bins = 2 if (inrange(TOTEXPER,2,5))
replace totexper_bins = 3 if (inrange(TOTEXPER,6,10))
replace totexper_bins = 4 if (inrange(TOTEXPER,11,15))
replace totexper_bins = 5 if (inrange(TOTEXPER,16,20))
replace totexper_bins = 6 if (inrange(TOTEXPER,21,30))
replace totexper_bins = 7 if (inrange(TOTEXPER,31,40))
replace totexper_bins = 8 if (inrange(TOTEXPER,41,50))
//graph bar leaver, over(totexper_bins) by(sped_t) b1title(Years of Teaching) ytitle(Teacher Leaving) title(Teaching Experience of Teachers Who Left) legend(on order(1 "1: 0-1 yrs" 2 "2: 2-5 yrs" 3 "3: 6-10 years" 4 "4: 11-15 years" 5 "5: 16-20 years" 6 "6: 21-30 years" 7 "7: 31-40 years" 8 "8: 40+ yrs"))
graph use "D:\ECO4381\sped vs overall teaching exp.gph" //opens the teaching exp graph generated from the line above and edited using the Graph Editor


 
 ** graph number of attacks vs teacher turnover (overall+special ed) 
gen num_attacks_bins = 1 if (inrange(num_attacks,0,1))
replace num_attacks_bins = 2 if (inrange(num_attacks,2,3))
replace num_attacks_bins = 3 if (inrange(num_attacks,4,5))
replace num_attacks_bins = 4 if (inrange(num_attacks,6,10))
replace num_attacks_bins = 5 if (inrange(num_attacks,11,15))
replace num_attacks_bins = 6 if (inrange(num_attacks,16,20))
replace num_attacks_bins = 7 if (inrange(num_attacks,20,90))
//graph bar leaver, over(num_attacks_bins) by(sped_t) b1title(Number of Attacks) ytitle(Teacher Leaving) title(Teachers Who Left vs Number of Attacks Against Teachers) legend(on order(1 "1: 0-1" 2 "2: 2-3" 3 "3: 3-4" 4 "4: 6-10" 5 "5: 11-15" 6 "6: 16-20" 7 "7: 20+"))
graph use "D:\ECO4381\sped vs overall num_attacks.gph" //opens the num_attacks graph generated from the line above and edited using the Graph Editor



** graph num of threats vs teacher turnover (overall+special ed)
gen num_threats_bins = 1 if (inrange(num_threats,0,1))
replace num_threats_bins = 2 if (inrange(num_threats,2,3))
replace num_threats_bins = 3 if (inrange(num_threats,4,5))
replace num_threats_bins = 4 if (inrange(num_threats,6,10))
replace num_threats_bins = 5 if (inrange(num_threats,11,15))
replace num_threats_bins = 6 if (inrange(num_threats,16,20))
replace num_threats_bins = 7 if (inrange(num_threats,20,90))
//graph bar leaver, over(num_threats_bins) by(sped_t) b1title(Number of Threats) ytitle(Teacher Leaving) title(Teachers Who Left vs Number of Threats Against Teachers) legend(on order(1 "1: 0-1" 2 "2: 2-3" 3 "3: 3-4" 4 "4: 6-10" 5 "5: 11-15" 6 "6: 16-20" 7 "7: 20+"))
graph use "D:\ECO4381\sped vs overall num_threats.gph" //opens the num_threats graph generated from the line above and edited using the Graph Editor



** graph admin behavior vs teacher turnover (overall+special ed)
//graph bar leaver, over(admin_behavior) by(sped_t) ytitle(Teacher Leaving) title(Teachers Who Left vs Administrative Support) legend(on order(1 "1: Strongly Agree" 2 "2: Somewhat Agree" 3 "3: Somewhat Disagree" 4 "4: Strongly Disagree")) caption("Do you agree that the school administration's behavior toward the staff is supportive and encouraging?")
graph use "D:\ECO4381\sped vs overall admin_support.gph" //opens the admin_support graph generated from the line above and edited using the Graph Editor


** graph staff cooperation vs teacher turnover(overall+special ed)
//graph bar leaver, over(coop_effort) by(sped_t) ytitle(Teacher Leaving) title(Teachers Who Left vs Staff Cooperation) legend(on order(1 "1: Strongly Agree" 2 "2: Somewhat Agree" 3 "3: Somewhat Disagree" 4 "4: Strongly Disagree")) caption("Do you believe there is a great deal of cooperative effort among the staff members?")
graph use "D:\ECO4381\sped vs overall coop_effort.gph" //opens the coop_effort graph generated from the line above and edited using the Graph Editor




gen all_grades=.
replace all_grades=0 if kind==1
replace all_grades=1 if gr_1==1 & missing(all_grades)
replace all_grades=2 if gr_2==1 & missing(all_grades)
replace all_grades=3 if gr_3==1 & missing(all_grades)
replace all_grades=4 if gr_4==1 & missing(all_grades)
replace all_grades=5 if gr_5==1 & missing(all_grades)
replace all_grades=6 if gr_6==1 & missing(all_grades)
replace all_grades=7 if gr_7==1 & missing(all_grades)
replace all_grades=8 if gr_8==1 & missing(all_grades)
replace all_grades=9 if gr_9==1 & missing(all_grades)
replace all_grades=10 if gr_10==1 & missing(all_grades)
replace all_grades=11 if gr_11==1 & missing(all_grades)
replace all_grades=12 if gr_12==1 & missing(all_grades)

** graph grade level vs teacher turnover
//graph bar leaver, over(all_grades) by(sped_t) title(Teacher Turnover by Grade Level) b1title(Grade) ytitle(Teacher Leaving) 
graph use "D:\ECO4381\sped vs overall grade.gph" //opens the grade graph generated from the line above and edited using the Graph Editor



** descriptive summary statistics
summarize leaver tardy disruption ever_threatened ever_attacked num_attacks num_threats coop_effort admin_behavior AGE_T RACETH_T TOTEXPER EARNALL all_grades


** run correlation
correlate leaver tardy disruption ever_threatened ever_attacked num_attacks num_threats coop_effort admin_behavior AGE_T RACETH_T TOTEXPER EARNALL all_grades

** plot logistic regression of ever_attack vs teacher leaving
logit leaver ever_attacked
predict predicted_value1
twoway (scatter leaver ever_attacked) (line predicted_value1 ever_attacked, sort), title(Likelihood of Leaving by Assault Against Teachers) xtitle(Ever attacked) ytitle(Teacher Leaving)

** plot logistic regression of num of attacks vs teacher leaving
logit leaver num_attacks
predict predicted_value2
twoway (scatter leaver num_attacks) (line predicted_value2 num_attacks, sort), title(Likelihood of Leaving by Number of Attacks Against Teachers) xtitle(Number of Attacks) ytitle(Teacher Leaving)

** plot logistic regression of num of attacks vs special ed teacher leaving
logit leaver num_attacks if sped_t==1
predict predicted_value3
twoway (scatter leaver num_attacks) (line predicted_value3 num_attacks, sort), title(Likelihood of Leaving by # of Attacks Against Special Educators) xtitle(Number of Attacks) ytitle(Teacher Leaving)

** plot logistic regression of tardiness vs teacher leaving
logit leaver tardy
predict predicted_value4
twoway (scatter leaver tardy) (line predicted_value4 tardy, sort), title(Relationship Between Student Tardiness and Likelihood of Teacher Leaving) xtitle(Number of Tardy Students) ytitle(Teacher Leaving)

** plot logistic regression of grade level vs teacher leaving
logit leaver all_grades
predict predicted_value5
twoway (scatter leaver all_grades) (line predicted_value5 all_grades, sort), title(Relationship Between Grade Level and Likelihood of Teacher Leaving) xtitle(Grade Level) ytitle(Teacher Leaving)


** run multiple regression (Model 1) - excludes teacher characteristic variables
regress leaver tardy disruption ever_threatened ever_attacked num_threats num_attacks coop_effort admin_behavior 
estimates store Model1


** run multiple regression (Model 2) - uses sped_t as a variable to determine whether special ed teachers are more or less likely to leave teaching
regress leaver tardy disruption ever_threatened ever_attacked num_threats num_attacks coop_effort admin_behavior sped_t
estimates store Model2

** run multiple regression (Model 3) - includes teacher characteristic variables
regress leaver tardy disruption ever_threatened ever_attacked num_threats num_attacks coop_effort admin_behavior AGE_T ib4.RACETH_T TOTEXPER EARNALL i.all_grades
//for RACETH_T, white teachers (4) are used as the reference group 
//for all_grades, kindergarten(0) is used as the reference group
estimates store Model3


** run multiple regression (Model 4) - filters to only special ed teachers, includes teacher characteristic variables
regress leaver tardy disruption ever_threatened ever_attacked num_threats num_attacks  coop_effort admin_behavior AGE_T ib4.RACETH_T TOTEXPER EARNALL i.all_grades if sped_t==1
//for RACETH_T, white teachers (4) are used as the reference group 
//for all_grades, kindergarten (0) is used as the reference group
estimates store Model4

** runs table of the estimation results for each model
estimates table Model1 Model2 Model3 Model4, star stats(r2)


** close log
log close 






