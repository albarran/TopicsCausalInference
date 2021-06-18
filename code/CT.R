library(tidyverse)
#install.packages("devtools")
#devtools::install_github("itamarcaspi/experimentdatar")
library(experimentdatar)        # contains data
#install.packages("devtools")
#devtools::install_github("susanathey/causalTree")
library(causalTree)

# Data
data(social)

# Data preprocessing

Y <- "outcome_voted"

D <- "treat_neighbors"

X <- c("yob", "city", "hh_size",
       "totalpopulation_estimate",
       "percent_male", "median_age",
       "percent_62yearsandover",
       "percent_white", "percent_black",
       "percent_asian", "median_income",
       "employ_20to64", "highschool",
       "bach_orhigher", "percent_hispanicorlatino",
       "sex","g2000", "g2002", "p2000",
       "p2002", "p2004")


# Data wrangling

df <- social %>% 
  dplyr::select(Y, D, X) %>% 
  rename(Y = outcome_voted, D = treat_neighbors)

set.seed(1203)

df_smpl <- df %>%
  sample_n(50000)

# Split the data to training, estimate, and test sets
  
split    <- initial_split(df_smpl, prop = 0.5)

df_train <- training(split) 
df_estim <- testing(split)


# Estimate causal tree

tree <- honest.causalTree(
  formula = "I(Y) ~ . - D",
  
  data      = df_train,
  treatment = df_train$D,
  
  est_data      = df_estim,
  est_treatment = df_estim$D,
  
  split.Rule   = "CT",
  split.Honest = TRUE,
  
  cv.option = "CT",  
  cv.Honest = TRUE,
  
  minsize = 200,
  HonestSampleSize = nrow(df_estim),
  cp=0
)


# Extract table of cross-validated values by tuning parameter

cptable <- as.data.frame(tree$cptable)


# Obtain optimal $cp$ to prune tree

min_cp      <- which.min(cptable$xerror)
optim_cp_ct <- cptable[min_cp, "CP"]

# Prune the tree at optimal $cp$

pruned_tree <- prune(tree = tree, cp = optim_cp_ct)


# The estimated tree
  
rpart.plot(
  tree,
  type = 3,
  clip.right.labs = TRUE,
  branch = .3
)

# Pruned tree
  
rpart.plot(
  pruned_tree,
  type = 3,
  clip.right.labs = TRUE,
  branch = .3
)

  
# Assign each observation to a specific leaf
  
df_all <- tibble(
  sample = c("training", "estimation"),
  data   = list(df_train, df_estim)
)

# Assign each observation in the training and estimation sets to a leaf based on `tree`

df_all_leaf <- df_all %>% 
  mutate(leaf = map(data, ~ predict(pruned_tree,
                                    newdata = .x,
                                    type = "vector"))) %>% 
  mutate(leaf = map(leaf, ~ round(.x, 3))) %>%
  mutate(leaf = map(leaf, ~ as.factor(.x))) %>%
  mutate(leaf = map(leaf, ~ enframe(.x, name = NULL, value = "leaf"))) %>% 
  mutate(data = map2(data, leaf, ~ bind_cols(.x, .y)))

# Estimate the condicional ATE using the causal tree
  
lm(Y ~ leaf + D * leaf - D - 1)

df_all_lm  <- 
  df_all_leaf %>% 
  mutate(model = map(data, ~ lm(Y ~ leaf + D * leaf 
                                - D - 1, data = .x))) %>% 
  mutate(tidy = map(model, broom::tidy, conf.int = TRUE)) %>% 
  unnest(tidy)

# Plot coefficients and confidence intervals
  
df_all_lm %>% 
  filter(str_detect(term, pattern = ":D")) %>%  # keep only interaction terms
  ggplot(aes(x = term,
             y = estimate, 
             ymin = conf.low,
             ymax = conf.high
  )
  ) +
  geom_hline(yintercept = 0, color = "red") +
  geom_pointrange(position = position_dodge(width = 1), size = 0.8) +
  labs(
    x = "",
    y = "CATE and confidence interval"
  ) +
  facet_grid(. ~ sample) +
  coord_flip()


  