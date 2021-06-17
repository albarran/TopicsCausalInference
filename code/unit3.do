************************************************************************************************
*** DATA
************************************************************************************************
** Original data from NSW (experimental RCT)

use https://github.com/albarran/TopicsCausalInference/blob/main/data/nsw.dta, clear


* Now merge in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
append using https://github.com/albarran/TopicsCausalInference/blob/main/data/cps.dta

gen agesq=age^2
gen agecube=age^3
gen edusq=educ^2

gen     u74 = 0 if re74!=.
replace u74 = 1 if re74==0

gen u75     = 0 if re75!=.
replace u75 = 1 if re75==0

gen interaction1 = educ*re74

gen re74sq=re74^2
gen re75sq=re75^2

gen interaction2 = u74*hisp

************************************************************************************************
**** Regression
************************************************************************************************

reg re78 train, vce(robust)

reg re78 train age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, vce(robust)

** more general form of regression 

reg re78 i.train##(c.age c.agesq c.agecube c.educ c.edusq i.marr i.nodegree i.black i.hisp c.re74 c.re75 i.u74 i.u75 i.interaction1), vce(robust) 

margins         , dydx(train)
margins if train, dydx(train)

teffects ra (re78  ${XX}) (train), vce(robust)
teffects ra (re78  ${XX}) (train), vce(robust) atet


************************************************************************************************
* Now estimate the propensity score
************************************************************************************************

logit treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1 
predict pscore

* Checking mean propensity scores for treatment and control groups
su pscore if treat==1, detail
su pscore if treat==0, detail

* Now look at the propensity score distribution for treatment and control groups
histogram pscore, by(treat) binrescale


**** Checking balancing

capture ssc install covbal

covbal train ${XX}

gen ipww=1/ps*train+1/(1-ps)*(1-train)
covbal train ${XX}, wt(ipww)


foreach X of varlist age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1 {
    di "*****************  ", "`X'", "  ***********************"
    reg `X' train, vce(robust)
    treatrew `X' train ${XX}, model(probit)
    *teffects ipw (`X') (train ${XX}, probit)
    *teffects ipw (`X') (train ${XX}, probit), atet
}


************************************************************************************************
* IPW
************************************************************************************************

* Use teffects to calculate inverse probability weighted regression

gen re78_scaled = re78/10000
cap n teffects ipw (re78_scaled) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap)
keep if overlap==0
drop overlap

cap n teffects ipw (re78_scaled) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap)
cap drop overlap


************************************************************************************************
* matching
************************************************************************************************

** Exact matching

teffects nnmatch (re78) (train), atet ematch(black hisp married)
reg re78 train black hisp married, robust

capture teffects nnmatch (re78) (train), atet ematch(black hisp married educ)
            //---- FAILS, of course
            
 
* Nearest neighbor matching
teffects nnmatch (re78 treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1) (train) , atet

teffects nnmatch (re78 treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1) (train) , atet nn(5)

teffects nnmatch (re78 treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1) (train) , atet biasadj(age agesq educ re74 re75)


** PS matching
teffects psmatch (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), atet gen(pstub_cps) nn(3) atet


teffects overlap, ptlevel(1) n(400)


*** Coarsened exact matching
ssc install cem, replace
cem age (10 20 30 40 60) age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, treatment(treat)
reg re78 treat [iweight=cem_weights], robust
