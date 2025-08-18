# --- Setup --------------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)   # dplyr, ggplot2, forcats, purrr, readr
  library(Hmisc)       # binconf, describe
})

# --- Load & describe ----------------------------------------------------------
data <- readr::read_csv(here::here("data.csv"))
Hmisc::describe(data)

# --- Target variable ----------------------------------------------------------
data <- data %>%
  mutate(death_dummy = as.integer(death != 0))

overall_death_rate <- mean(data$death_dummy, na.rm = TRUE)

# --- AGE: hypothesis test -----------------------------------------------------
dead  <- filter(data, death_dummy == 1)
alive <- filter(data, death_dummy == 0)

mean_dead_age  <- mean(dead$age,  na.rm = TRUE)
mean_alive_age <- mean(alive$age, na.rm = TRUE)

age_ttest <- t.test(alive$age, dead$age,
                    alternative = "two.sided", conf.level = 0.95)

# --- GENDER: hypothesis test --------------------------------------------------
male_rate   <- mean(filter(data, gender == "male")$death_dummy,   na.rm = TRUE)
female_rate <- mean(filter(data, gender == "female")$death_dummy, na.rm = TRUE)

gender_ttest <- t.test(
  x = filter(data, gender == "male")$death_dummy,
  y = filter(data, gender == "female")$death_dummy,
  alternative = "two.sided", conf.level = 0.95
)

# --- Plot 1: Age distribution by outcome -------------------------------------
p_age <- data %>%
  filter(!is.na(age)) %>%
  mutate(outcome = factor(if_else(death_dummy == 1, "died", "survived"),
                          levels = c("survived", "died"))) %>%
  ggplot(aes(outcome, age, fill = outcome)) +
  geom_violin(alpha = 0.30, width = 0.9, colour = NA) +
  geom_boxplot(width = 0.25, outlier.alpha = 0.20) +
  scale_fill_manual(values = c("survived" = "#9cadc7", "died" = "#de2d26")) +
  labs(title = "Age vs Outcome", x = NULL, y = "Age (years)") +
  theme_bw() +
  theme(legend.position = "none")

# --- Helper: summarize death rate + Wilson CI --------------------------------
summarize_rate <- function(df, group_var) {
  stopifnot("death_dummy" %in% names(df))
  df %>%
    filter(!is.na(.data[[group_var]])) %>%
    group_by(group = .data[[group_var]] ) %>%
    summarise(
      n = n(),
      deaths = sum(death_dummy, na.rm = TRUE),
      rate = deaths / n,
      .groups = "drop"
    ) %>%
    mutate(
      ci_mat = map2(deaths, n, ~ Hmisc::binconf(.x, .y, method = "wilson")),
      lower  = map_dbl(ci_mat, ~ .x[, "Lower"]),
      upper  = map_dbl(ci_mat, ~ .x[, "Upper"])
    ) %>%
    select(group, n, deaths, rate, lower, upper)
}

# --- Plot 2: Mortality by gender with 95% CI ---------------------------------
gender_rates <- summarize_rate(data, "gender") %>% drop_na(group)

p_gender <- gender_rates %>%
  ggplot(aes(fct_reorder(group, rate), rate)) +
  geom_col(fill = "#9cadc7", width = 0.7) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.15) +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Death rate by gender (95% Wilson CI)",
       x = NULL, y = "Death rate") +
  theme_bw()

# --- Loop: death rates by age band -------------------------------------------
age_breaks  <- c(0, 30, 50, 70, Inf)
age_labels  <- c("0–29", "30–49", "50–69", "70+")
data <- data %>%
  mutate(age_band = cut(age, breaks = age_breaks,
                        labels = age_labels, right = FALSE,
                        include.lowest = TRUE))

for (b in levels(data$age_band)) {
  n_b  <- sum(data$age_band == b, na.rm = TRUE)
  if (n_b == 0) next
  dr_b <- mean(data$death_dummy[data$age_band == b], na.rm = TRUE)
  cat(sprintf("Age band %-5s: n=%-4d  death rate=%5.2f%%\n", b, n_b, 100 * dr_b))
}

# --- Save figures -------------------------------------------------------------
# ggsave(here::here("figures", "age_vs_outcome.png"),  p_age,    width = 6, height = 4, dpi = 300)
# ggsave(here::here("figures", "gender_rate_ci.png"), p_gender, width = 6, height = 4, dpi = 300)