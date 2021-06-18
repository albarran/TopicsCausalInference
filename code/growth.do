clear all
capture log close

set more off


/* -------------------------------------------------------------------------- */

cd "/home/albarran/Dropbox/UABCourse/TopicsCausalInference/"
log using ./log/growth.log, replace

*********************************************

import delimited ./data/GrowthData.csv

* Data checking
describe

* OLS

reg outcome gdpsh465 bmp1l-tot1, vce(robust)

* Naive Lasso

rlasso outcome gdpsh465 bmp1l-tot1, sqrt


* Double selection Lasso
pdslasso outcome gdpsh465 (bmp1l-tot)


log close
