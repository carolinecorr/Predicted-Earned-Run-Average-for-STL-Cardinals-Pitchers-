# Final Project OLR Model ----
# Define and fit simple linear regression model (ordinary least squares)

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doParallel)

# handle common conflicts
tidymodels_prefer()

# load recipes/resamples/controls
load(here('recipes/rec_1.rda'))
load(here('data_splits/stl_folds.rda'))
load(here('data_splits/keep_wflow.rda'))

# parallel processing
num_cores <- parallel::detectCores(logical = FALSE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)

# olr specification
olr_spec <-
  linear_reg() |>
  set_engine("lm")

# olr workflow
olr_wflow <-
  workflow() |>
  add_model(olr_spec) |>
  add_recipe(rec_1)

# fit olr
olr_fit <-
  olr_wflow |>
  fit_resamples(
    resamples = stl_folds,
    control = keep_wflow
  )

# halt parallel processing after fit
stopCluster(cl)

# save olr fit
save(olr_fit, file = here('results/olr_fit.rda'))
