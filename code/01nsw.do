clear all
capture log close

set more off


/* -------------------------------------------------------------------------- */

cd "/home/albarran/Dropbox/UABCourse/TopicsCausalInference/"
log using ./log/01nsw.log, replace

*********************************************

use ./data/nsw.dta, replace

* Data checking
describe

/* -------------------------------------------------------------------------- */

****************************************************
* Checking balancing of observed characteristics
****************************************************

global XX "age educ black hisp marr nodegree"

foreach X of global XX {
    display "`X'"
    ttest `X', by(treat) unequal

    reg `X' treat, vce(robust)
}


/* -------------------------------------------------------------------------- */

****************************************************
*** ATE
****************************************************

ttest re78, by(treat) unequal

reg re78 treat, vce(robust)

/* -------------------------------------------------------------------------- */

****************************************************
*** Including covariates
****************************************************

gen agesq = age^2

reg re78 treat ${XX} agesq, vce(robust)

****************************************************
*** Treatment heterogeneity
****************************************************

** by education
gen higheduc = (educ>8)
reg re78 treat i.treat##i.higheduc ${XX}, vce(robust)

log close
