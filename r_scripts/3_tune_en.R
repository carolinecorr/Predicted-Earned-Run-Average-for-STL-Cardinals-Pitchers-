# Final Project EN Model ----
# Define and tune elastic net model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doParallel)

# handle common conflicts
tidymodels_prefer()

# load training data
load(here('data_splits/stl_train.rda'))

# load recipe/resamples/controls/metrics
load(here('recipes/rec_2.rda'))
load(here('data_splits/stl_folds.rda'))
load(here('data_splits/keep_wflow.rda'))

# model specification ----
en_spec <-
  linear_reg(
    penalty = tune(),
    mixture = tune()
  ) |>
  set_engine("glmnet") |>
  set_mode('regression')

# workflow ----
en_wflow <-
  workflow() |>
  add_model(en_spec) |>
  add_recipe(rec_2) 

# hyperparameter tuning values ----

## check ranges
hardhat::extract_parameter_set_dials(en_spec)

## change ranges
en_params <- 
  hardhat::extract_parameter_set_dials(en_spec) |>
  update(
    penalty = penalty(c(0.001, 1)),
    mixture = mixture(c(0, 1))
  )

## build tuning grid
en_grid <-
  grid_regular(en_params, levels = c(7, 5))

# initialize parallel processing ----
num_cores <- parallel::detectCores(logical = FALSE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)

# fit models/workflows ----
en_tuned <-
  en_wflow |>
  tune_grid(
    resamples = stl_folds, 
    grid = en_grid,
    control = keep_wflow
  )

# halt parallel processing ----
stopCluster(cl) 

# save out tuned model ----
save(en_tuned, file = here('results/en_tuned.rda'))