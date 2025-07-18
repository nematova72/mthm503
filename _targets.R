library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("DBI", "RPostgres", "dplyr", "ggplot2", "caret", "randomForest",
               "nnet", "pROC", "forcats", "tidyr", "factoextra", "cluster"),
  format = "rds"
)


list(
 
  tar_target(classification_data,
             {
               source("R/classification.R")
               data_clean
             }),
  
  tar_target(rf_model,
             {
               source("R/classification.R")
               rf_model
             }),
  
  tar_target(mlogit_model,
             {
               source("R/classification.R")
               mlogit_model
             }),
  
  
 
  tar_target(regression_data,
             {
               source("R/regression.R")
               df_model
             }),
  
  tar_target(regression_model,
             {
               source("R/regression.R")
               multinom_model
             }),
  
  

  tar_target(olive_data,
             {
               source("R/unsupervised.R")
               olive_scaled
             }),
  
  tar_target(clustering_result,
             {
               source("R/unsupervised.R")
               kmeans_result
             }),
  
  tar_target(silhouette_score,
             {
               source("R/unsupervised.R")
               mean_sil
             })
)
