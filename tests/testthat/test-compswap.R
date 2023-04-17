# Test case for compswap using lm

test_that("compswap works correctly with for lm", {
  # Load the iris dataset
  data(iris)

  # Define the formula
  formula <- "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width"

  # Define the pca_varlist
  pca_varlist <- list(c("Sepal.Width", "Petal.Length"),
                      c("Sepal.Width", "Petal.Width"))

  # Define the n_pca_list
  n_pca_list <- list(2, 2)

  # Set scaling values
  lpca_center_list <- list("none", "none")
  lpca_scale_list <- list("none", "none")
  lpca_undo_list <- list(FALSE, FALSE)

  # Run compswap
  compswap_results <- compswap(data = iris,
                               formula = formula,
                               engine = "stats",
                               .pca_varlist = pca_varlist,
                               .n_pca_list = n_pca_list,
                               .lpca_center_list = lpca_center_list,
                               .lpca_scale_list = lpca_scale_list,
                               .lpca_undo_list = lpca_undo_list)

  # Check if the output is a list with the expected length
  expect_type(compswap_results, "list")
  expect_equal(length(compswap_results), 2)

  # Check if the model_raw is included only once
  expect_s3_class(compswap_results$all_models$model_raw, "lm")
  expect_equal(sum(names(compswap_results$all_models) == "model_raw"), 1)

  # Check if the correct number of model_pca objects are included
  expect_equal(sum(grepl("model_pca", names(compswap_results$all_models))), 2)

  # Check if the correct number of comparisons dataframes are included
  expect_equal(sum(grepl("comparison", names(compswap_results))), 1)
})


test_that("compswap works correctly with for lm with recycling", {
  # Load the iris dataset
  data(iris)

  # Define the formula
  formula <- "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width"

  # Define the pca_varlist
  pca_varlist <- list(c("Sepal.Width", "Petal.Length"),
                      c("Sepal.Width", "Petal.Width"))

  # Define the n_pca_list
  n_pca_list <- list(2, 2)

  # Run compswap
  compswap_results <- compswap(data = iris,
                               formula = formula,
                               engine = "stats",
                               .pca_varlist = pca_varlist,
                               .n_pca_list = n_pca_list)

  # Check if the output is a list with the expected length
  expect_type(compswap_results, "list")
  expect_equal(length(compswap_results), 2)

  # Check if the model_raw is included only once
  expect_s3_class(compswap_results$all_models$model_raw, "lm")
  expect_equal(sum(names(compswap_results$all_models) == "model_raw"), 1)

  # Check if the correct number of model_pca objects are included
  expect_equal(sum(grepl("model_pca", names(compswap_results$all_models))), 2)

  # Check if the correct number of comparisons dataframes are included
  expect_equal(sum(grepl("comparison", names(compswap_results))), 1)
})


test_that("compswap works correctly with for lm with recycling and Gifi prc_eng", {
  # Load the iris dataset
  data(iris)

  # Define the formula
  formula <- "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width"

  # Define the pca_varlist
  pca_varlist <- list(c("Sepal.Width", "Petal.Length"),
                      c("Sepal.Width", "Petal.Width"))

  # Define the n_pca_list
  n_pca_list <- list(2, 2)

  # Run compswap
  compswap_results <- compswap(data = iris,
                               formula = formula,
                               engine = "stats",
                               .prc_eng_list = list("stats", "Gifi"),
                               .pca_varlist = pca_varlist,
                               .n_pca_list = n_pca_list)

  # Check if the output is a list with the expected length
  expect_type(compswap_results, "list")
  expect_equal(length(compswap_results), 2)

  # Check if the model_raw is included only once
  expect_s3_class(compswap_results$all_models$model_raw, "lm")
  expect_equal(sum(names(compswap_results$all_models) == "model_raw"), 1)

  # Check if the correct number of model_pca objects are included
  expect_equal(sum(grepl("model_pca", names(compswap_results$all_models))), 2)

  # Check if the correct number of comparisons dataframes are included
  expect_equal(sum(grepl("comparison", names(compswap_results))), 1)
})


test_that("compswap works correctly for lm with recycling and passing extra
          arguments to gifi_transform", {
            # Create a small simulated dataset
            set.seed(50)
            n <- 50
            x1 <- rnorm(n)
            x2 <- rnorm(n)
            x3 <- rnorm(n)
            x4 <- rnorm(n, 5, 2)
            x5 <- rnorm(n, 7, 8)

            y <- 1 + 2 * x1 + 3 * x2 + rnorm(n) + (1/2)*(x4 + x5)
            data <- data.frame(y, x1, x2, x3, x4, x5)

            x1q <- stats::quantile(data$x1,c(0,1/3,2/3,1))
            x2q <- stats::quantile(data$x2,c(0,1/4,3/4,1))
            x3q <- stats::quantile(data$x3,c(0,2/5,3/5,1))


            data <- data %>% dplyr::mutate(x1 = cut(x1, breaks=x1q, labels=c("low","middle","high"),include.lowest = TRUE),
                                           x2 = cut(x2, breaks=x2q, labels=c("small","medium","large"),include.lowest = TRUE),
                                           x3 = cut(x3, breaks=x3q, labels=c("short","average","tall"),include.lowest = TRUE))

  # Define the formula
  formula <- "y ~ x1 + x2 + x3 + x4 + x5"

  # Define the pca_varlist
  pca_varlist <- list(c("x1", "x2", "x3", "x4"),
                      c("x2", "x3", "x4", "x5"))

  # Define the n_pca_list
  n_pca_list <- list(2, 2)

  # Define the gifi transform
  gifi_transform_list = list("all")
  gifi_trans_vars_list = list(c("x1", "x2", "x3"))
  gifi_trans_dims_list = list(2)
  gifi_trans_options_list = list(list(ties = "t"))



  # Run compswap
  compswap_results <- compswap(data = data,
                               formula = formula,
                               engine = "stats",
                               .pca_varlist = pca_varlist,
                               .n_pca_list = n_pca_list,
                               .gifi_transform_list = gifi_transform_list,
                               .gifi_trans_vars_list = gifi_trans_vars_list,
                               .gifi_trans_dims_list = gifi_trans_dims_list,
                               .gifi_trans_options_list = gifi_trans_options_list)

  # Check if the output is a list with the expected length
  expect_type(compswap_results, "list")
  expect_equal(length(compswap_results), 2)

  # Check if the model_raw is included only once
  expect_s3_class(compswap_results$all_models$model_raw, "lm")
  expect_equal(sum(names(compswap_results$all_models) == "model_raw"), 1)

  # Check if the correct number of model_pca objects are included
  expect_equal(sum(grepl("model_pca", names(compswap_results$all_models))), 2)

  # Check if the correct number of comparisons dataframes are included
  expect_equal(sum(grepl("comparison", names(compswap_results))), 1)
})
