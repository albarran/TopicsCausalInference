library(tidyverse)
library(haven)
library(sandwich)
library(lmtest)
library(estimatr)
library(margins)
library(ipw)
library(MatchIt)
library(Zelig)
library(ebal)


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
#* regression
#************************************************************************************************

ate1 <- lm(data = data, re78 ~ treat)
print(coeftest(ate1, vcov = vcovHC(ate1, "HC1")))

ate2 <- lm(data = data, 
           re78  ~ treat + age + agesq + agecube + educ + educsq + 
                           marr + nodegree + black + hisp + 
                          re74 + re75 + u74 + u75 + interaction1)
print(coeftest(ate2, vcov = vcovHC(ate2, "HC1")))

ate3 <- lm_robust(data = data, 
           re78  ~ treat*(age + agesq + agecube + educ + educsq + 
             marr + nodegree + black + hisp + 
             re74 + re75 + u74 + u75 + interaction1), se_type = "stata")

summary(margins(ate3))


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

# manual IPW

#- Manual with non-normalized weights using all data
data <- data %>% 
  mutate(d1 = treat/pscore,
         d0 = (1-treat)/(1-pscore))

s1 <- sum(data$d1)
s0 <- sum(data$d0)


data <- data %>% 
  mutate(y1 = treat * re78/pscore,
         y0 = (1-treat) * re78/(1-pscore),
         ht = y1 - y0)

summary(data %>% select(ht)) 

# ***

# ipw <- ipwpoint(exposure = treat, 
#                 family = "binomial", 
#                 link = "logit",
#                 denominator = ~ re78 + age + agesq + agecube + 
#                   educ + educsq + marr + nodegree + 
#                   black + hisp + re74 + re75 + u74 + interaction1,
#                 data = data)


m_out <- matchit(treat ~ age + agesq + agecube + educ +
                   educsq + marr + nodegree +
                   black + hisp + re74 + re75 + u74 + u75 + interaction1,
                 data = data, method = "nearest", 
                 distance = "logit", ratio =5)

m_data <- match.data(m_out)

z_out <- zelig(re78 ~ treat + age + agesq + agecube + educ +
                 educsq + marr + nodegree +
                 black + hisp + re74 + re75 + u74 + u75 + interaction1, 
               model = "ls", data = m_data)

x_out <- setx(z_out, treat = 0)
x1_out <- setx(z_out, treat = 1)

s_out <- sim(z_out, x = x_out, x1 = x1_out)

summary(s_out)

## Entropy Balance

TT <- data %>% select(treat) %>% 
  data.matrix %>% 
  array(c(nrow(.), 1, 1, ncol(.)))

X <- data %>% select(3:17) %>% data.matrix

eb.out <- ebalance(Treatment=TT,  X=X)

# means in treatment group data
apply(X[T==1,],2,mean)
# means in reweighted control group data
apply(X[T==0,],2,weighted.mean,w=eb.out$w)
# means in raw data control group data
apply(X[T==0,],2,mean)


