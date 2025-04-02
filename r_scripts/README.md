## R Scripts

This subdirectory contains all of the R scripts used in the project pipeline.

## Items

-   `1_initial_setup.R`: conduct EDA of target variables, initial splits, resamples, and create metric set
-   `2_recipes.R`: creation of 3 recipes for model training
-   `3_fit_null.R`: train null/baseline model
-   `3_fit_olr.R`: train ordinary linear regression model
-   `3_tune_bt.R`: tune boosted tree model
-   `3_tune_en.R`: tune elastic net model
-   `3_tune_knn.R`: tune k-nearest neighbors model
-   `3_tune_rf.R`: tune random forest model
-   `4_model_analysis`: compare fit/tuned models, select best model
-   `5_train_final_model.R`: train best model (random forest) to whole training set
-   `6_final_model_analysis`: assess final fit on testing set
-   `PM1_scratchwork.R`: r script used for code necessary for progress memo 1
