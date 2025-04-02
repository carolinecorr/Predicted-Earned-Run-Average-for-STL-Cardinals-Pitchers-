# Final Project Recipes ----
# Setup pre-processing/recipes

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load training data
load(here('data_splits/stl_train.rda'))

## create recipe 1 (use for null and olr models) ----
rec_1 <-
  recipe(
    era ~ .,
    data = stl_train
  ) |>
  step_rm(innings_pitched, earned_runs) |>
  step_impute_mode(position) |>
  step_zv(all_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe
rec_1 |>
  prep() |>
  bake(new_data = NULL)

## create recipe 2 (use for all except baselines, bt, and rf) ----
rec_2 <-
recipe(
  era ~ .,
  data = stl_train
) |>
  step_rm(innings_pitched, earned_runs, name) |>
  update_role(name, new_role = "id") |>
  step_impute_mode(position) |>
  step_zv(all_predictors()) |>
  step_interact(
    ~ hits_per_nine_innings : fielding_independent_pitching +
      hits_per_nine_innings : walks_per_nine_innings +
      walks_per_nine_innings : fielding_independent_pitching
  ) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe 2
rec_2 |>
  prep() |>
  bake(new_data = NULL)

## create recipe 3 (use for bt and rf) ----
rec_3 <-
recipe(
  era ~ .,
  data = stl_train
) |>
  step_rm(innings_pitched, earned_runs, name) |>
  update_role(name, new_role = "id") |>
  step_impute_mode(position) |>
  step_zv(all_predictors()) |>
  step_interact(
    ~ hits_per_nine_innings : fielding_independent_pitching +
      hits_per_nine_innings : walks_per_nine_innings +
      walks_per_nine_innings : fielding_independent_pitching
  ) |>
  step_dummy(all_nominal_predictors())

# check recipe 3
rec_3 |>
  prep() |>
  bake(new_data = NULL)

# save recipes ----
save(rec_1, file = here('recipes/rec_1.rda'))
save(rec_2, file = here('recipes/rec_2.rda'))
save(rec_3, file = here('recipes/rec_3.rda'))
