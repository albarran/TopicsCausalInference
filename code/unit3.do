************************************************************************************************
*** DATA
************************************************************************************************
** Original data from NSW (experimental RCT)

use https://github.com/albarran/TopicsCausalInference/raw/main/data/nsw.dta, clear


* Now merge in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
append using https://github.com/albarran/TopicsCausalInference/raw/main/data/cps.dta

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

compress

************************************************************************************************
**** Regression
************************************************************************************************

reg re78 treat, vce(robust)

reg re78 treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, vce(robust)

** more general form of regression 

reg re78 i.treat##(c.age c.agesq c.agecube c.educ c.edusq i.marr i.nodegree i.black i.hisp c.re74 c.re75 i.u74 i.u75 c.interaction1), vce(robust) 

margins         , dydx(treat)
margins if treat, dydx(treat)

teffects ra (re78  ${XX}) (treat), vce(robust)
teffects ra (re78  ${XX}) (treat), vce(robust) atet


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

covbal treat age educ  marr nodegree black hisp re74 re75 u74 u75 

gen ipww=1/ps*treat+1/(1-ps)*(1-treat)
covbal treat age educ  marr nodegree black hisp re74 re75 u74 u75 , wt(ipww)


************************************************************************************************
* IPW
************************************************************************************************

* Use teffects to calculate inverse probability weighted regression

gen re78_scaled = re78/10000
cap n teffects ipw (re78_scaled) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap) atet
keep if overlap==0
drop overlap

cap n teffects ipw (re78_scaled) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap) atet
cap drop overlap


************************************************************************************************
* matching
************************************************************************************************

** Exact matching


capture teffects nnmatch (re78) (treat), atet ematch(black hisp marr educ) atet
            //---- FAILS, of course
            
 
* Nearest neighbor matching
teffects nnmatch (re78  age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1) (treat) , atet

teffects nnmatch (re78  age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1) (treat) , atet nn(5)

teffects nnmatch (re78  age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1) (treat) , atet biasadj(age agesq educ re74 re75)


** PS matching
teffects psmatch (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), atet gen(pstub_cps) nn(3) 


teffects overlap, ptlevel(1) n(400)


*** Coarsened exact matching
ssc install ebalance, replace
ebalance treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, tar(1) g(ebw)
reg re78 treat [pweight=ebw], robust

reg age treat [pweight=ebw], robust
