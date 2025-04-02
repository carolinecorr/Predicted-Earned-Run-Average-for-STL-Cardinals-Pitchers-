# Final Project Trained Model Analysis ----
# Analysis of tuned and trained models (comparisons)
# Select final model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load tuned/trained models
list.files(
  here('results/'),
  pattern = ".rda",
  full.names = TRUE
) |>
  map(load, envir = .GlobalEnv)

## pm2: demonstrate successful fit by showing rmse of each model type ----

# null model
# null_metrics <-
# null_fit |>
#   collect_metrics() |>
#   mutate(model = "Null")
# 
# # olr model
# olr_metrics <-
#   olr_fit |>
#   collect_metrics() |>
#   mutate(model = "OLR")
# 
# # make table
# early_rmse_table <-
# bind_rows(null_metrics, olr_metrics) |>
#   filter(.metric == 'rmse') |>
#   select(model, mean, n, std_err) |>
#   mutate(mean = round(mean, digits = 3),
#          std_err = round(std_err, digits = 4)) |>
#   knitr::kable(
#     caption = "RMSE Values for First 2 Models",
#     col.names = c("Model Type", "Mean RMSE", "N", "Standard Error")
#   )
# 
# # save table
# save(early_rmse_table, file = here('graphics/early_rmse_table.rda'))

# performance metrics for all models
tuning_results <-
  as_workflow_set(
    `Boosted Tree` = bt_tuned,
    `Random Forest` = rf_tuned,
    `Elastic Net` = en_tuned,
    `K-Nearest Neighbors` = knn_tuned,
    `Ordinary Linear Regression` = olr_fit,
    `Null` = null_fit
  )


# first_tuning_rmse <-
# tuning_results |>
#   collect_metrics() |>
#   filter(.metric == 'rmse') |>
#   slice_min(mean, by = wflow_id) |>
#   select(wflow_id, mean, std_err, n) |>
#   arrange(mean) |>
#   knitr::kable(digits = 4, col.names = c('Model Type', 'RMSE', 'Std Error', 'N'))

first_tuning_rmse
save(first_tuning_rmse, file = here('graphics/first_tuning_rmse.rda'))

bt_plot <-
bt_tuned |>
  autoplot()
# changing hyperparam ranges doesn't seem like it would improve rmse
save(bt_plot, file = here('graphics/bt_plot.rda'))

rf_plot <-
rf_tuned |>
  autoplot()
# search higher values for mtry>
save(rf_plot, file = here('graphics/rf_plot.rda'))

en_plot <-
en_tuned |>
  autoplot()
# changing hyperparam ranges doesn't seem like it would improve rmse
save(en_plot, file = here('graphics/en_plot.rda'))

knn_plot <-
knn_tuned |>
  autoplot()
# nearest neighbors = 10 minimizes rmse, no need for further search
save(knn_plot, file = here('graphics/knn_plot.rda'))

second_tuning_rmse <-
tuning_results |>
  collect_metrics() |>
  filter(.metric == 'rmse') |>
  slice_min(mean, by = wflow_id) |>
  select(wflow_id, mean, std_err, n) |>
  arrange(mean) |>
  mutate(hps = c('Mtry = 35, Min N = 3',
                 'Mtry = 18, Min N = 1, Tree Depth = 3, Learn Rate = 1.0023',
                 'Penalty = 1.0023, Mixture = 0',
                 'Neighbors = 10',
                 'Not Tuned',
                 'Not Tuned')) |>
  knitr::kable(digits = 4, col.names = c('Model Type', 'RMSE', 'Std Error', 'N', 'Best Hyperparameters'))

save(second_tuning_rmse, file = here('graphics/second_tuning_rmse.rda'))

# improved rmse for RF by 0.1612 - try one more time with minimal node size and maximum range for mtry

third_tuning_rmse <-
  tuning_results |>
  collect_metrics() |>
  filter(.metric == 'rmse') |>
  slice_min(mean, by = wflow_id) |>
  select(wflow_id, mean, std_err, n) |>
  arrange(mean) |>
  knitr::kable(digits = 4, col.names = c('Model Type', 'RMSE', 'Std Error', 'N'))

# didn't improve rmse - keep as is

# winning model: random forest

rmse_graph <-
tuning_results |>
  autoplot(metric = 'rmse', select_best = TRUE)

save(rmse_graph, file = here('graphics/rmse_graph.rda'))

# best model for each model type
knn_best <-
knn_tuned |>
  select_best(metric = 'rmse')

rf_best <-
rf_tuned |>
  select_best(metric = 'rmse')

bt_best <-
bt_tuned |>
  select_best(metric = 'rmse')

# lasso model was best for en!
en_best <-
en_tuned |>
  select_best(metric = 'rmse')

# best hyperparam table ----
best_hyperparams <-
bind_rows(
  knn_best, rf_best, bt_best, en_best
) |>
  mutate(
    model = c('KNN', 'RF', 'BT', 'EN')
  ) |>
  select(model, neighbors, mtry, min_n, tree_depth, learn_rate, penalty, mixture) |>
  knitr::kable(col.names = c('Model Type', 'Neighbors', 'Mtry', 'Min N', 'Tree Depth',
                             'Learn Rate', 'Penalty', 'Mixture'), digits = 4)

# save table
save(best_hyperparams, file = here('graphics/best_hyperparams.rda'))

