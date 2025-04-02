## Data Splits

This subdirectory contains all of the initial setup objects produced in `1_initial_setup.R`

## Items

-   `keep_wflow.rda`: controls for resamples, ensures workflows are kept for later extraction
-   `stl_folds.rda`: resamples (8 folds and 5 repeats used)
-   `stl_metrics.rda`: metric set for performance comparison
-   `stl_split.rda`: split object containing amount of observations used in training/testing sets
-   `stl_test.rda`: testing set used for predictions with final model
-   `stl_train.rda`: training set used for model fitting
