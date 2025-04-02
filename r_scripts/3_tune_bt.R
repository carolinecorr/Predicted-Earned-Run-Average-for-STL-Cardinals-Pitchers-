# Final Project BT Model ----
# Define and tune boosted tree model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doParallel)

# handle common conflicts
tidymodels_prefer()

# set seed
set.seed(12081999)

# load training data
load(here('data_splits/stl_train.rda'))

# load recipe/resamples/controls/metrics
load(here('recipes/rec_3.rda'))
load(here('data_splits/stl_folds.rda'))
load(here('data_splits/keep_wflow.rda'))

# model specification ----
bt_spec <-
  boost_tree(
    mtry = tune(),
    min_n = tune(),
    learn_rate = tune(),
    tree_depth = tune(),
    trees = 1000
  ) |>
  set_engine("xgboost") |>
  set_mode('regression')

# workflow ----
bt_wflow <-
  workflow() |>
  add_model(bt_spec) |>
  add_recipe(rec_3) 

# hyperparameter tuning values ----

## check ranges
hardhat::extract_parameter_set_dials(bt_spec)

## change ranges
bt_params <- 
  hardhat::extract_parameter_set_dials(bt_spec) |>
  update(
    mtry = mtry(c(5, 18)),
    min_n = min_n(c(1, 20)),
    learn_rate = learn_rate(c(0.001, 0.3)),
    tree_depth = tree_depth(c(3, 10))
  )

## build tuning grid
bt_grid <-
  grid_regular(bt_params, levels = 3)

# initialize parallel processing ----
num_cores <- parallel::detectCores(logical = FALSE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)

# fit models/workflows ----
bt_tuned <-
  bt_wflow |>
  tune_grid(
    resamples = stl_folds, 
    grid = bt_grid,
    control = keep_wflow
  )

# halt parallel processing ----
stopCluster(cl) 

# save out tuned model ----
save(bt_tuned, file = here('results/bt_tuned.rda'))