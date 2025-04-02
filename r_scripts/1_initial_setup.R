# Final Project Initial Setup ----
# Data splitting & data folding

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# set seed
set.seed(1926) # first year the Cards won the World Series :)

# load data
load(here('data/stl_pitching.rda'))

##### NOTE #####
# Initial data quality checks and analysis of target variable occurred in PM1_scratchwork.R

# Further EDA: check for need for interaction terms ----
cor_matrix <- cor(stl_pitching %>% select_if(is.numeric), use = "complete.obs")

# potential interactions to include:
  # hits_per_nine_innings and fielding_independent_pitching (corr of 0.555)
  # hits_per_nine_innings and walks_per_nine_innings (corr of 0.398)
  # fielding_independent_pitching and walks_per_nine_innings (corr of 0.531)

## Initial Split
stl_split <- initial_split(stl_pitching, prop = 0.8, strata = era)

stl_train <- training(stl_split)
stl_test <- testing(stl_split)

# save results
save(stl_split, file = here('data_splits/stl_split.rda'))
save(stl_train, file = here('data_splits/stl_train.rda'))
save(stl_test, file = here('data_splits/stl_test.rda'))

## V-Fold Cross Validation: Using 8 folds and 5 repeats
stl_folds <- vfold_cv(stl_train, v = 8, repeats = 5, strata = era)

# controls for fitting to resamples
keep_wflow <- control_grid(save_workflow = TRUE)

# metrics for assessment (our main focus will be rmse)
stl_metrics <- metric_set(rmse, rsq, mae)

# save folds/controls/metrics
save(stl_folds, file = here('data_splits/stl_folds.rda'))
save(keep_wflow, file = here('data_splits/keep_wflow.rda'))
save(stl_metrics, file = here('data_splits/stl_metrics.rda'))


