# Final Project Null Model ----
# Define and fit baseline/null model

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

# null model specification
null_spec <- 
  null_model() |>
  set_engine('parsnip') |>
  set_mode('regression')

# null model workflow
null_wflow <-
  workflow() |>
  add_model(null_spec) |>
  add_recipe(rec_1) 

# fit null model
null_fit <-
  null_wflow |>
  fit_resamples(
    resamples = stl_folds,
    control = keep_wflow
  )
  
# halt parallel processing after fit
stopCluster(cl)

# save null fit
save(null_fit, file = here('results/null_fit.rda'))
  