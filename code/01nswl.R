library(tidyverse)
library(haven)
library(sandwich)
library(lmtest)

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
  
  model <-lm(data = data, form)
  SErob <- coeftest(model, vcov = vcovHC(model, "HC1"))    # robust; HC1 (Stata default)
  print(SErob)
}


# ------------------------------------------------------------------------------
  
# ****************************************************
# *** ATE
# ****************************************************
  
ate <- lm(data = data, re78 ~ treat)
print(coeftest(ate, vcov = vcovHC(ate, "HC1")))

# ---------------------------------------------------------------------------- #
  
# ****************************************************
# *** Including covariates
# ****************************************************
  
ate2 <- lm(data = data, re78 ~ treat + poly(age,2) + educ + black + hisp + marr + nodegree)
print(coeftest(ate2, vcov = vcovHC(ate2, "HC1")))

# ****************************************************
# *** Treatment heterogeneity
# ****************************************************
  
# ** by education

data <- data %>% mutate(higheduc = (educ>8) )

ateHet <- lm(data = data, re78 ~ treat*higheduc + poly(age,2) + educ + black + hisp + marr + nodegree)
print(coeftest(ateHet, vcov = vcovHC(ateHet, "HC1")))

sink()
