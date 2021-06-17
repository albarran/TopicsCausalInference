library(tidyverse)
library(haven)


data0 <- read_dta("https://github.com/albarran/TopicsCausalInference/raw/main/data/nsw.dta")
  

data  <- read_dta("https://github.com/albarran/TopicsCausalInference/raw/main/data/cps.dta") %>% 
  bind_rows(data0) %>% 
  mutate(agesq = age^2,
         agecube = age^3,
         educsq = educ*educ,
         u74 = case_when(re74 == 0 ~ 1, TRUE ~ 0),
         u75 = case_when(re75 == 0 ~ 1, TRUE ~ 0),
         interaction1 = educ*re74,
         re74sq = re74^2,
         re75sq = re75^2,
         interaction2 = u74*hisp)



#************************************************************************************************
#* Now estimate the propensity score
#************************************************************************************************
  
logit_nsw <- glm(treat ~ age + agesq + agecube + educ + educsq + 
                   marr + nodegree + black + hisp + re74 + re75 + u74 +
                   u75 + interaction1, family = binomial(link = "logit"), 
                 data = data)

data <- data %>% 
  mutate(pscore = logit_nsw$fitted.values)

# mean pscore 
pscore_control <- data %>% 
  filter(treat == 0) %>% 
  pull(pscore) %>% 
  mean()

pscore_treated <- data %>% 
  filter(treat == 1) %>% 
  pull(pscore) %>% 
  mean()

# histogram
data %>% 
  filter(treat == 0) %>% 
  ggplot() +
  geom_histogram(aes(x = pscore))

data %>% 
  filter(treat == 1) %>% 
  ggplot() +
  geom_histogram(aes(x = pscore))

#************************************************************************************************
#  * IPW
#************************************************************************************************
 
 
