# Final Project RF Model ----
# Define and tune random forest model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doParallel)

# handle common conflicts
tidymodels_prefer()

# set seed
set.seed(07301969)

# load training data
load(here('data_splits/stl_train.rda'))

# load recipe/resamples/controls/metrics
load(here('recipes/rec_3.rda'))
load(here('data_splits/stl_folds.rda'))
load(here('data_splits/keep_wflow.rda'))

# model specification ----
rf_spec <-
  rand_forest(
    trees = 1000,
    mtry = tune(),
    min_n = tune()
  ) |>
  set_engine("ranger") |>
  set_mode('regression')

# workflow ----
rf_wflow <-
  workflow() |>
  add_model(rf_spec) |>
  add_recipe(rec_3) 

# hyperparameter tuning values ----

## check ranges
hardhat::extract_parameter_set_dials(rf_spec)

## change ranges
rf_params <- 
  hardhat::extract_parameter_set_dials(rf_spec) |>
  update(
    mtry = mtry(c(20, 35)),
    min_n = min_n(c(1, 5))
  )

## build tuning grid
rf_grid <-
  grid_regular(rf_params, levels = c(5, 3))

# initialize parallel processing ----
num_cores <- parallel::detectCores(logical = FALSE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)

# fit models/workflows ----
rf_tuned <-
  rf_wflow |>
  tune_grid(
    resamples = stl_folds, 
    grid = rf_grid,
    control = keep_wflow
  )

# halt parallel processing ----
stopCluster(cl) 

# save out tuned model ----
save(rf_tuned, file = here('results/rf_tuned.rda'))