classification_model <- function(casualties, accidents, vehicles) {
  data <- casualties |>
    left_join(accidents, by = "accident_index") |>
    left_join(vehicles, by = "accident_index") |>
    filter(casualty_type == "Pedestrian") |>
    mutate(severity = factor(casualty_severity, levels = c("Slight", "Serious", "Fatal")))
  
  split <- initial_split(data, prop = 0.8)
  train <- training(split)
  test <- testing(split)
  
  rec <- recipe(severity ~ age_of_casualty + sex_of_driver + light_conditions + urban_or_rural_area, data = train) |>
    step_dummy(all_nominal_predictors()) |>
    step_impute_median(all_numeric_predictors()) |>
    prep()
  
  train_proc <- bake(rec, train)
  test_proc <- bake(rec, test)
  
  rf <- rand_forest(mode = "classification") |>
    set_engine("ranger")
  
  model <- workflow() |>
    add_recipe(rec) |>
    add_model(rf) |>
    fit(data = train)
  
  predictions <- predict(model, test_proc) |> bind_cols(test_proc)
  metrics <- yardstick::metrics(predictions, truth = severity, estimate = .pred_class)
  
  list(model = model, metrics = metrics)
}
