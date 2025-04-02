# Final Project ----
# Train winning model to full training set

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doParallel)

# handle common conflicts
tidymodels_prefer()

# load necessary objects
load(here('data_splits/stl_train.rda'))
load(here('results/rf_tuned.rda'))

# set seed for random processes
set.seed(06061969)

# final model workflow ----
final_wflow <-
  rf_tuned |>
  extract_workflow() |>
  finalize_workflow(select_best(rf_tuned, metric = 'rmse'))

# initialize parallel processing ----
num_cores <- parallel::detectCores(logical = FALSE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)

# fit model to entire training set ----
final_fit <-
  final_wflow |>
  fit(stl_train)

# halt parallel processing ----
stopCluster(cl)

# save final fit ----
save(final_fit, file = here('results/final_fit.rda'))
  