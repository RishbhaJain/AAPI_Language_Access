library(ipumsr)
library(janitor)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(haven)

ddi <- read_ipums_ddi("usa_00002.xml")
data <- read_ipums_micro(ddi)
data <- clean_names(data)

selected_races <- c(1, 2, 3, 4, 5, 6)

filtered_data <- data %>%
  filter(
    race %in% selected_races,
    !is.na(speakeng),
    !is.na(hcovany),
    !is.na(educ)
  )

filtered_data <- filtered_data %>%
  mutate(race_label = case_when(
    race == 1 ~ "White",
    race == 2 ~ "Black/African American",
    race == 3 ~ "American Indian or Alaska Native",
    race == 4 ~ "Chinese",
    race == 5 ~ "Japanese",
    race == 6 ~ "Other Asian/Pacific Islander",
    TRUE ~ "Other"
  ))

filtered_data <- filtered_data %>%
  mutate(speakeng_label = case_when(
    speakeng == 1 ~ "Does not speak English",
    speakeng == 2 ~ "Yes, speaks English",
    speakeng == 3 ~ "Yes, speaks English well",
    speakeng == 4 ~ "Yes, speaks English very well",
    speakeng == 5 ~ "Yes, speaks English well",
    speakeng == 6 ~ "Yes, speaks English but not well",
    TRUE ~ "Other"
  ))

filtered_data <- filtered_data %>%
  mutate(hcovany_label = case_when(
    hcovany == 1 ~ "No health insurance coverage",
    hcovany == 2 ~ "With health insurance coverage",
    TRUE ~ "Other"
  ))

filtered_data <- filtered_data %>%
  filter(
    race_label != "Other",
    speakeng_label != "Other",
    hcovany_label != "Other"
  )

table_insurance <- table(filtered_data$speakeng_label, filtered_data$hcovany_label)
chisq_test_insurance <- chisq.test(table_insurance)
print(chisq_test_insurance)

table_education <- table(filtered_data$speakeng_label, filtered_data$educ)
chisq_test_education <- chisq.test(table_education)
print(chisq_test_education)


education_summary <- filtered_data %>%
  group_by(race_label, speakeng_label, educ) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(race_label, speakeng_label) %>%
  mutate(percent = round(100 * n / sum(n), 1)) %>%
  arrange(race_label, speakeng_label)

education_summary <- education_summary %>%
  mutate(speakeng_label = factor(speakeng_label, levels = c(
    "Does not speak English",
    "Yes, speaks English but not well",
    "Yes, speaks English",
    "Yes, speaks English well",
    "Yes, speaks English very well"
  )))

education_plot=ggplot(education_summary, aes(x = speakeng_label, y = percent, fill = factor(educ))) +
  geom_col(position = "stack") +
  facet_wrap(~ race_label) +
  labs(
    title = "Education Level by English Proficiency and Race",
    x = "English Proficiency",
    y = "Percent of Group",
    fill = "Education Level Code"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

insurance_summary <- filtered_data %>%
  group_by(race_label, speakeng_label, hcovany_label) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(race_label, speakeng_label) %>%
  mutate(percent = round(100 * n / sum(n), 1)) %>%
  arrange(race_label, speakeng_label)

insurance_plot=ggplot(insurance_summary, aes(x = speakeng_label, y = percent, fill = hcovany_label)) +
  geom_col(position = "fill") +
  facet_wrap(~ race_label) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Proportion of Health Insurance Coverage by English Proficiency and Race",
    x = "English Proficiency",
    y = "Percentage",
    fill = "Health Insurance"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("education_plot.png", plot = education_plot, width = 10, height = 6, dpi = 300)
ggsave("insurance_plot.png", plot = insurance_plot, width = 10, height = 6, dpi = 300)

filtered_data <- filtered_data %>%
  mutate(hcovany_binary = ifelse(hcovany == 2, 1, 0))

# Fit logistic regression, check probabilities
model <- glm(hcovany_binary ~ speakeng_label + race_label, data = filtered_data, family = binomial)
summary(model)

filtered_data <- filtered_data %>%
  mutate(languaged = case_when(
    languaged == 1200 ~ "Spanish",
    languaged == 5000 ~ "Vietnamese",
    languaged == 5400 ~ "Filipino, Tagalog"
    languaged == 1800 ~ "Russian"
    languaged == 4300 ~ "Chinese"
    TRUE ~ "Other"
  ))


filtered_data_cali_languages <- filtered_data %>%
    filter((puma >= 6001 & puma <= 6999), speakeng_label!="Yes, speaks English very well", languaged!=100)

total_non_english_speakers <- sum(filtered_data_cali_languages$perwt, na.rm = TRUE)

filtered_data_cali_languages <- filtered_data_cali_languages %>%
  mutate(languaged_label = case_when(
    languaged == 1200 ~ "Spanish",
    languaged == 5000 ~ "Vietnamese",
    languaged == 5400 ~ "Filipino, Tagalog",
    languaged == 1800 ~ "Russian",
    languaged == 4300 ~ "Chinese",
    TRUE ~ "Other"
  ))


top_languages <- filtered_data_cali_languages %>%
  count(languaged_label, sort = TRUE) %>%
  mutate(pct = round(100 * n / sum(n), 2))

head(top_languages, 10)

top_5_langs <- top_languages$languaged_label[1:6]
filtered_data_cali_languages <- filtered_data_cali_languages %>%
  mutate(lang_group = ifelse(languaged_label %in% top_5_langs, as.character(languaged_label), "Other"))

lang_summary <- filtered_data_cali_languages %>%
  count(lang_group) %>%
  mutate(pct = round(100 * n / sum(n), 1))


# Plot
ggplot(lang_summary, aes(x = "", y = pct, fill = lang_group)) +
  geom_col(width = 1) +
  coord_polar("y") +
  labs(title = "LEP Individuals by Language Group (Top 5 vs. Others)") +
  theme_void()

filtered_data <- filtered_data %>%
  mutate(native_status = case_when(
    speakeng_label == "Yes, speaks English very well" ~ "Native",
    TRUE ~ "Non-native"
  ))

filtered_data <- filtered_data %>%
  mutate(educ_level = case_when(
    educ >= 06 ~ "High school or more",
    educ < 06 ~ "Less than high school",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(educ_level))

summary_table <- filtered_data %>%
  group_by(native_status, educ_level) %>%
  summarise(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = educ_level, values_from = count)

print(summary_table)

#PSM analysis

psm_input <- filtered_data_cali_languages %>%
  mutate(
    native_binary = ifelse(speakeng_label %in% c("Yes, speaks English very well", "Yes, speaks English well", "Yes, speaks English"), 0, 1)
  ) %>%
  select(native_binary, race_label, age, educ, sex, citizen, empstat, inctot, poverty, hcovany_binary) %>%
  drop_na()  # remove any missing values

ps_model <- glm(
  native_binary ~ race_label + age + educ + sex + citizen + empstat + inctot,
  data = psm_input,
  family = binomial
)

psm_input$pscore <- predict(ps_model, type = "response")

psm_input <- psm_input %>%
  mutate(weight = ifelse(native_binary == 1,
                         1 / pscore,
                         1 / (1 - pscore)))


insurance_model <- glm(
  hcovany_binary ~ native_binary,
  data = psm_input,
  weights = weight,
  family = binomial
)

summary(insurance_model)

psm_input$predicted_prob <- predict(insurance_model, type = "response")


pred_summary <- psm_input %>%
  group_by(native_binary) %>%
  summarise(
    mean_prob = mean(predicted_prob),
    se = sd(predicted_prob) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
    label = ifelse(native_binary == 0, "English Proficient", "Limited English Proficient")
  )



ggplot(pred_summary, aes(x = label, y = mean_prob, fill = label)) +
  geom_col(width = 0.6, color = "black") +
  geom_errorbar(
    aes(ymin = mean_prob - 1.96 * se, ymax = mean_prob + 1.96 * se),
    width = 0.2,
    color = "black"
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Predicted Probability of Being Insured",
    x = NULL,
    y = "Predicted Probability (with 95% CI)"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none")

