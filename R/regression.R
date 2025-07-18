# Load required libraries
library(DBI)
library(RPostgres)
library(dplyr)
library(ggplot2)
library(tidyr)
library(tidyr)
library(nnet)

# Establish database connection

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  host = "aws-0-eu-west-2.pooler.supabase.com",
  port = 5432,
  user = "pgstudent.rvdwflidqvcvffdccwrh",
  password = "0%jkXK^tjMZwuG",
  sslmode = "require"
)


# Load data from Supabase tables
# Fire rescue extrication data
extrication_data <- dbReadTable(con, "fire_rescue_extrication_casualties")

# Police-reported casualties data
police_data <- dbReadTable(con, "stats19_by_financial_year")

# Close the database connection
dbDisconnect(con)


# Clean and Prepare Extrication Data
# Preview data structure
str(extrication_data)

# Focus on relevant columns and remove missing values
df <- extrication_data %>%
  select(age_band, sex, extrication, n_casualties, financial_year) %>%
  filter(!is.na(age_band), !is.na(sex), !is.na(extrication))

# Convert variables to factors and order age_band
df <- df %>%
  mutate(
    extrication = as.factor(extrication),
    sex = as.factor(sex),
    age_band = factor(age_band, levels = c("0-16", "17-25", "26-35", "36-45", "46-55", "56-65", "66-75", "75+"))
  )

# Summarize Extrication Counts
summary_data <- df %>%
  group_by(sex, age_band, extrication) %>%
  summarise(total_casualties = sum(n_casualties), .groups = "drop")

# Plot 1: Bar plot of total extrications by sex and age_band
ggplot(summary_data, aes(x = age_band, y = total_casualties, fill = sex)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ extrication) +
  labs(
    title = "Number of Casualties by Extrication Status, Age Band, and Sex",
    x = "Age Band",
    y = "Number of Casualties"
  ) 
theme_minimal()

# Prepare Data for Multinomial Logistic Regression
# Remove "Unknown" category from 'sex' to avoid modeling issues
df_model <- df %>%
  filter(sex != "Unknown") %>%
  droplevels()

# Check levels to ensure factors are clean
levels(df_model$sex)
levels(df_model$extrication)


df_model <- df_model %>%
  filter(age_band == "0-16")


# Fit Multinomial Logistic Regression Model
# Predictors: 'sex' and 'financial_year'
multinom_model <- multinom(extrication ~ sex + financial_year, data = df_model)

multinom_model <- multinom(extrication ~ sex * financial_year, data = df_model)



# Model Summary and Interpretation
# View the summary of the model
summary(multinom_model)

# Calculate z-values and p-values for coefficients
z_values <- summary(multinom_model)$coefficients / summary(multinom_model)$standard.errors
p_values <- 2 * (1 - pnorm(abs(z_values)))

# Print p-values for significance testing
print("P-values for Multinomial Logistic Regression Coefficients:")
print(p_values)


# Get Odds Ratios for Interpretability
# Exponentiate the coefficients to get Odds Ratios
odds_ratios <- exp(coef(multinom_model))

# Print Odds Ratios
print("Odds Ratios for Predictors:")
print(odds_ratios)

# Predict Class Probabilities
# Get predicted probabilities for each observation
predicted_probs <- predict(multinom_model, type = "probs")

# View first few rows of predicted probabilities
head(predicted_probs)

# Visualize Predicted Probabilities
# Convert predicted probabilities to a data frame
pred_df <- as.data.frame(predicted_probs)
pred_df$sex <- df_model$sex
pred_df$financial_year <- df_model$financial_year

# Average predicted probabilities by sex
pred_df_long <- pred_df %>%
  pivot_longer(cols = -c(sex, financial_year), names_to = "extrication_type", values_to = "probability")

# Plot predicted probabilities
ggplot(pred_df_long, aes(x = financial_year, y = probability, fill = sex)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ extrication_type) +
  labs(
    title = "Predicted Probabilities of Extrication Type by Financial Year and Sex",
    x = "Financial Year",
    y = "Predicted Probability"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
