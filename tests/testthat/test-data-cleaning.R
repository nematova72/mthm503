library(testthat)

test_that("No missing values remain after cleaning", {
  expect_true(all(complete.cases(clean_data)))
})

test_that("Casualty severity has the correct levels", {
  levels_expected <- c("1", "2", "3")
  levels_actual <- levels(clean_data$casualty_severity)
  expect_true(all(levels_expected %in% levels_actual))
})



test_that("Model predictions return valid factor levels", {
  
  # Use your trained model to predict on test data
  preds <- predict(rf_model, test_data)
  
  # Check that predictions are factors and levels match
  expect_true(is.factor(preds))
  expect_setequal(levels(preds), levels(test_data$casualty_severity))
})



test_that("Olive oil data contains no missing values before clustering", {
  
  # Check for NA values in numeric columns before clustering
  olive_numeric <- select(olive_data, where(is.numeric))
  
  expect_equal(sum(is.na(olive_numeric)), 0)
})
