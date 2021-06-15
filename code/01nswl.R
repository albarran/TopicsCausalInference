library(tidyverse)
library(haven)

# ------------------------------------------------------------------------------
setwd("/home/albarran/Dropbox/UABCourse/TopicsCausalInference/")
#sink("./log/01nsw_R.txt")


# ------------------------------------------------------------------------------

data <- read_dta("./data/nsw.dta")

glimpse(data)     # str(data)

# ------------------------------------------------------------------------------
#  ****************************************************
#  * Checking balancing of observed characteristics
#  ****************************************************
  
XX <- c("age", "educ", "black", "hisp", "marr", "nodegree")

for (X in seq_along(XX) ) {
  print(XX[X])
  
  form <- paste0(XX[X],"~treat")

  print(summary(lm(data = data, form)))
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

sink()
