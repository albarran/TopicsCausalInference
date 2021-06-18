library(tidyverse)
library(hdm)

data("GrowthData")

# Rename the response and "treatment" variables:
  
df <- 
  GrowthData %>% 
  rename(YT = Outcome, Y0 = gdpsh465)

# Transform the data to vectors and matrices (to be used in the `rlassoEffect()` function)

YT <- df %>% dplyr::select(YT) #%>% pull()

Y0 <- df %>% dplyr::select(Y0) #%>% pull()

X <- df %>%
  dplyr::select(-c("Y0", "YT")) %>%
  as.matrix()

Y0_X <- df %>%
  dplyr::select(-YT) %>%
  as.matrix()


# OLS 

ols <- lm(YT ~ ., data = df)

summary(ols)

# Naive (rigorous) Lasso

naive_Lasso <- rlasso(x = Y0_X, y = YT)

naive_Lasso$beta[2]

summary(naive_Lasso)

# Partialling out Lasso

part_Lasso <- 
  rlassoEffect(
    x = X, y = YT, d = Y0,
    method = "partialling out"
  )

summary(part_Lasso)

# Double-selection Lasso

double_Lasso <- 
  rlassoEffect(
    x = X, y = YT, d = Y0,
    method = "double selection"
  )


summary(double_Lasso)
