## Analysis of target variable: ERA (Earned_Run_Average)

## packages & data ----
library(tidyverse)
library(here)

stl_pitching <- read_csv(here('data/STL_pitching.csv'))

# change column names to snake case
stl_pitching <-
stl_pitching |> 
  rename_with(tolower)

# change target variable name for ease of use, retyping variables
stl_pitching <-
stl_pitching |>
 # rename('era' = earned_run_average) |>
  mutate(
    position = factor(position, levels = c("SP", "CL", "RP")),
    dominant_hand = factor(dominant_hand, levels = c("Right", "Left"))
  )

# accidentally added a variable twice with a typo, deleting it
stl_pitching <-
stl_pitching |>
  mutate(positon = NULL)

# save out altered dataset
save(stl_pitching, file = here('data/stl_pitching.rda'))

# visualize target variable: ERA
era_univariate <-
stl_pitching |>
  ggplot(aes(era)) +
  geom_histogram(bins = 100) +
  xlim(c(0, 20)) +
  theme_minimal() +
  labs(
    title = "Distribution of ERA",
    x = "Earned Run Average (ERA)",
    y = "Count",
    caption = "Extremely high ERAs (>20) excluded from visual for ease of viewing"
  )

save(era_univariate, file = here('graphics/era_univariate.rda'))

## updates for pm2: need to make next year's era column
load(here('data/stl_pitching.rda'))

# there are 5 instances where era is coded as Inf because of a division by 0 problem
# since this is a small amount, I will just remove them from the dataset

stl_pitching <-
stl_pitching |>
  filter(!(innings_pitched == 0 & earned_runs > 0))
  # check to see inf values have been removed
  # summarize(
    # sd = sd(era),
    # mean = mean(era)
  # )

save(stl_pitching, file = here('data/stl_pitching.rda'))


