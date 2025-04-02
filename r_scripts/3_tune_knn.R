# Final Project KNN Model ----
# Define and tune k-nearest neighbors model

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
knn_spec <-
  nearest_neighbor(
    neighbors = tune()
  ) |>
  set_engine("kknn") |>
  set_mode('regression')

# workflow ----
knn_wflow <-
  workflow() |>
  add_model(knn_spec) |>
  add_recipe(rec_2) 

# hyperparameter tuning values ----

## check ranges
hardhat::extract_parameter_set_dials(knn_spec)

## change ranges
knn_params <- 
  hardhat::extract_parameter_set_dials(knn_spec) |>
  update(
    neighbors = neighbors(c(1, 40))
  )

## build tuning grid
knn_grid <-
  grid_regular(knn_params, levels = 5)

# initialize parallel processing ----
num_cores <- parallel::detectCores(logical = FALSE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)

# fit models/workflows ----
knn_tuned <-
  knn_wflow |>
  tune_grid(
    resamples = stl_folds, 
    grid = knn_grid,
    control = keep_wflow
  )

# halt parallel processing ----
stopCluster(cl) 

# save out tuned model ----
save(knn_tuned, file = here('results/knn_tuned.rda'))