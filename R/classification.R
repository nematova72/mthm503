library(DBI)         
library(RPostgres)    
library(dplyr)        
library(ggplot2)     
library(caret)       
library(randomForest) 
library(nnet)         
library(pROC)        
library(forcats)      

# Connect to Supabase PostgreSQL database
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  host = "aws-0-eu-west-2.pooler.supabase.com",
  port = 5432,
  user = "pgstudent.rvdwflidqvcvffdccwrh",
  password = "0%jkXK^tjMZwuG",
  sslmode = "require"
)

# Query the data from Supabase (joining casualties, accidents, and vehicles)
query <- "
SELECT 
    c.accident_index,
    c.casualty_severity,
    c.age_of_casualty,
    c.sex_of_casualty,
    a.light_conditions,
    a.weather_conditions,
    a.urban_or_rural_area,
    v.age_of_driver,
    v.sex_of_driver
FROM 
    stats19_casualties c
LEFT JOIN 
    stats19_accidents a
ON 
    c.accident_index = a.accident_index
LEFT JOIN 
    stats19_vehicles v
ON 
    c.accident_index = v.accident_index
"

# Fetch data into R
data_raw <- dbGetQuery(con, query)

# Close the database connection
dbDisconnect(con)

# Clean the data: remove missing values and convert variables to factors
data_clean <- data_raw %>%
  na.omit() %>%
  mutate(
    casualty_severity = as.factor(casualty_severity),
    sex_of_casualty = as.factor(sex_of_casualty),
    sex_of_driver = as.factor(sex_of_driver),
    light_conditions = as.factor(light_conditions),
    weather_conditions = as.factor(weather_conditions),
    urban_or_rural_area = as.factor(urban_or_rural_area)
  )


# PLOT 1: Casualty Severity Distribution (Bar Plot)
# Shows the count of each severity level in the dataset
ggplot(data_clean, aes(x = fct_infreq(casualty_severity))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Casualty Severity Distribution", 
       x = "Severity Level", 
       y = "Count") +
  theme_minimal()


# Split the data into training and test sets (80% train, 20% test)
set.seed(123) # For reproducibility

train_index <- createDataPartition(data_clean$casualty_severity, p = 0.8, list = FALSE)
train_data <- data_clean[train_index, ]
test_data <- data_clean[-train_index, ]


# Model 1: Random Forest Classification

rf_model <- randomForest(
  casualty_severity ~ age_of_casualty + sex_of_casualty + 
    light_conditions + weather_conditions + urban_or_rural_area + 
    age_of_driver + sex_of_driver,
  data = train_data,
  ntree = 100 # Number of trees in the forest
)


# Model 2: Multinomial Logistic Regression

mlogit_model <- multinom(
  casualty_severity ~ age_of_casualty + sex_of_casualty + 
    light_conditions + weather_conditions + urban_or_rural_area + 
    age_of_driver + sex_of_driver,
  data = train_data
)

# Evaluate the Random Forest model

rf_preds <- predict(rf_model, test_data)

# Confusion matrix for Random Forest
cm_rf <- confusionMatrix(rf_preds, test_data$casualty_severity)
print(cm_rf)

# Evaluate the Multinomial Logistic Regression model

mlogit_preds <- predict(mlogit_model, test_data)

# Confusion matrix for Multinomial Logistic Regression
cm_mlogit <- confusionMatrix(mlogit_preds, test_data$casualty_severity)
print(cm_mlogit)


# Calculate AUC (Area Under Curve) for Multi-class classification
# One vs Rest method is used via multiclass.roc from pROC

auc_rf <- multiclass.roc(as.numeric(test_data$casualty_severity), as.numeric(rf_preds))
print(paste("Random Forest AUC:", auc_rf$auc))

auc_mlogit <- multiclass.roc(as.numeric(test_data$casualty_severity), as.numeric(mlogit_preds))
print(paste("Multinomial Logistic Regression AUC:", auc_mlogit$auc))


# PLOT 2: Random Forest Variable Importance Plot
# Shows which variables were most important in the Random Forest model
varImpPlot(rf_model, main = "Random Forest Variable Importance")


# PLOT 3: Actual vs Predicted (Random Forest)
# Compares true severity levels with predictions in a bar chart

df_plot <- data.frame(
  Actual = test_data$casualty_severity,
  Predicted = rf_preds
)

ggplot(df_plot, aes(x = Actual, fill = Predicted)) +
  geom_bar(position = "dodge") +
  labs(title = "Random Forest: Actual vs Predicted Severity", 
       x = "Actual Severity", 
       y = "Count") +
  theme_minimal()

