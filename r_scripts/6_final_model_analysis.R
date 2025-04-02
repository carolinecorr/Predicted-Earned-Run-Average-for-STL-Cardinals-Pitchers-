# Final Project ----
# Analysis of final model fit to whole training set

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load necessary objects
load(here('data_splits/stl_test.rda'))
load(here('results/final_fit.rda'))

# predictions on testing set ----
preds <- predict(final_fit, new_data = stl_test)

results <- bind_cols(preds, stl_test |> select(era))

# evaluate on rmse (primary), rsq, and mae
stl_metrics <- metric_set(rmse, rsq, mae)

# calculate performance metrics ----
performance_metrics <-
stl_metrics(results, truth = era, estimate = .pred) |>
  select(.metric, .estimate) |>
  knitr::kable(col.names = c('Metric', 'Estimate'), digits = 3)

# save performance table
save(performance_metrics, file = here('graphics/performance_metrics.rda'))

# plot predicted vs. true values ----
comp_plot_full <-
results |>
  ggplot(aes(era, .pred)) +
  geom_abline(lty = 2) +
  geom_point(alpha = 0.5) +
  labs(
    x = 'Earned Run Average',
    y = 'Predicted Earned Run Average'
  ) +
  theme_minimal() +
  coord_obs_pred()

# save full plot 
save(comp_plot_full, file = here('graphics/comp_plot_full.rda'))

# zoom in on plot where most preds are ----
comp_plot_zoom <-
results |>
  ggplot(aes(era, .pred)) +
  geom_abline(lty = 2) +
  geom_point(alpha = 0.2) +
  xlim(c(0, 15)) +
  ylim(c(0, 15)) +
  labs(
    x = 'Earned Run Average',
    y = 'Predicted Earned Run Average'
  ) +
  theme_minimal() +
  coord_obs_pred()

# save zoomed in plot
save(comp_plot_zoom, file = here('graphics/comp_plot_zoom.rda'))
