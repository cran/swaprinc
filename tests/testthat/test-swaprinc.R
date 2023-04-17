# Run tests for stats engine
test_that("swaprinc returns correct class for basic lm", {
  #Get iris data
  data(iris)

  #Run basic lm model using stats
  res <- swaprinc(data = iris,
                  formula = "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width",
                  pca_vars = c("Sepal.Width", "Petal.Length"),
                  n_pca_components = 2)

  #See if swaprinc returned a list
  expect_type(res, "list")


})

test_that("swaprinc works with logistic regression using stats engine", {
  suppressWarnings({
    # Get iris data
    data(iris)
    iris$Species_binary <- ifelse(iris$Species == "setosa", 1, 0)

    # Run logistic regression model using stats engine
    res_logistic <- swaprinc(data = iris,
                             formula = "Species_binary ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width",
                             engine = "stats",
                             pca_vars = c("Sepal.Length", "Petal.Width"),
                             n_pca_components = 2,
                             model_options = list(family = binomial(link = "logit")))

    # Check if swaprinc returned a list
    expect_type(res_logistic, "list")

    # Check if both models in the list are of class "glm"
    expect_s3_class(res_logistic$model_raw, "glm")
    expect_s3_class(res_logistic$model_pca, "glm")
  })
})

# Run tests for lme4 engine
test_that("A basic lme4 random intercept model works.", {

  # Set seed for reproducibility
  set.seed(42)

  # Define the number of subjects and observations per subject
  n_subjects <- 30
  n_obs_per_subject <- 10

  # Generate subject IDs
  subject_ids <- 1:n_subjects

  # Simulate the random effects for each subject
  random_intercepts <- rnorm(n_subjects, mean = 0, sd = 2)

  # Create an empty data frame to store the simulated data
  simulated_data <- data.frame()

  # Generate the data for each subject
  for (subject_id in subject_ids) {
    subject_data <- data.frame(
      Subject = rep(subject_id, n_obs_per_subject),
      Time = 1:n_obs_per_subject,
      X1 = rnorm(n_obs_per_subject, mean = 0, sd = 1),
      X2 = rnorm(n_obs_per_subject, mean = 0, sd = 1),
      Random_Intercept = rep(random_intercepts[subject_id], n_obs_per_subject)
    )

    # Simulate the response variable (e.g., Y) with fixed effects and the random intercept
    fixed_effects <- c(1.5, 2, -1)
    subject_data$Y <- fixed_effects[1] * subject_data$Time +
      fixed_effects[2] * subject_data$X1 +
      fixed_effects[3] * subject_data$X2 +
      subject_data$Random_Intercept +
      rnorm(n_obs_per_subject, mean = 0, sd = 1)

    # Combine the data for each subject into a single data frame
    simulated_data <- rbind(simulated_data, subject_data)
  }

  # Fit a random intercept model using lme4
  res_ri <- swaprinc(data = simulated_data,
                     formula = "Y ~ Time + X1 + X2 + (1 | Subject)",
                     pca_vars = c("Time", "X1", "X2"),
                     engine = "lme4",
                     n_pca_components = 2)

  #See if swaprinc returned a list
  expect_type(res_ri, "list")


})


test_that("Test that swaprinc throws error if a variable is included in both
          the random effects and pca_vars", {
  # Set seed for reproducibility
  set.seed(42)

  # Define the number of subjects and observations per subject
  n_subjects <- 30
  n_obs_per_subject <- 10

  # Generate subject IDs
  subject_ids <- 1:n_subjects

  # Simulate the random effects for each subject
  random_intercepts <- rnorm(n_subjects, mean = 0, sd = 2)
  random_slopes <- rnorm(n_subjects, mean = 0, sd = 1)

  # Create an empty data frame to store the simulated data
  simulated_data <- data.frame()

  # Generate the data for each subject
  for (subject_id in subject_ids) {
    subject_data <- data.frame(
      Subject = rep(subject_id, n_obs_per_subject),
      Time = 1:n_obs_per_subject,
      X1 = rnorm(n_obs_per_subject, mean = 0, sd = 1),
      X2 = rnorm(n_obs_per_subject, mean = 0, sd = 1),
      Random_Intercept = rep(random_intercepts[subject_id], n_obs_per_subject),
      Random_Slope = rep(random_slopes[subject_id], n_obs_per_subject)
    )

    # Simulate the response variable (e.g., Y) with fixed effects, random intercept, and random slope
    fixed_effects <- c(1.5, 2, -1)
    subject_data$Y <- fixed_effects[1] * subject_data$Time +
      fixed_effects[2] * subject_data$X1 +
      fixed_effects[3] * subject_data$X2 +
      subject_data$Random_Intercept +
      subject_data$Random_Slope * subject_data$Time +
      rnorm(n_obs_per_subject, mean = 0, sd = 1)

    # Combine the data for each subject into a single data frame
    simulated_data <- rbind(simulated_data, subject_data)
  }

  # Fit a random slope model using lme4
  expect_error(swaprinc(data = simulated_data,
                        formula = "Y ~ Time + X1 + X2 + (Time | Subject)",
                        pca_vars = c("Time", "X1", "X2"),
                        engine = "lme4",
                        n_pca_components = 2))

})

test_that("Test random slopes with variables not included in pca_vars", {
  # Set seed for reproducibility
  set.seed(42)

  # Define the number of subjects and observations per subject
  n_subjects <- 30
  n_obs_per_subject <- 10

  # Generate subject IDs
  subject_ids <- 1:n_subjects

  # Simulate the random effects for each subject
  random_intercepts <- rnorm(n_subjects, mean = 0, sd = 2)
  random_slopes <- rnorm(n_subjects, mean = 0, sd = 1)

  # Create an empty data frame to store the simulated data
  simulated_data <- data.frame()

  # Generate the data for each subject
  for (subject_id in subject_ids) {
    subject_data <- data.frame(
      Subject = rep(subject_id, n_obs_per_subject),
      Time = 1:n_obs_per_subject,
      X1 = rnorm(n_obs_per_subject, mean = 0, sd = 1),
      X2 = rnorm(n_obs_per_subject, mean = 0, sd = 1),
      Random_Intercept = rep(random_intercepts[subject_id], n_obs_per_subject),
      Random_Slope = rep(random_slopes[subject_id], n_obs_per_subject)
    )

    # Simulate the response variable (e.g., Y) with fixed effects, random intercept, and random slope
    fixed_effects <- c(1.5, 2, -1)
    subject_data$Y <- fixed_effects[1] * subject_data$Time +
      fixed_effects[2] * subject_data$X1 +
      fixed_effects[3] * subject_data$X2 +
      subject_data$Random_Intercept +
      subject_data$Random_Slope * subject_data$Time +
      rnorm(n_obs_per_subject, mean = 0, sd = 1)

    # Combine the data for each subject into a single data frame
    simulated_data <- rbind(simulated_data, subject_data)
  }

  # Fit a random slope model using lme4
  res_rs <- swaprinc(data = simulated_data,
                     formula = "Y ~ Time + X1 + X2 + (Time | Subject)",
                     pca_vars = c("X1", "X2"),
                     engine = "lme4",
                     n_pca_components = 2)

  # See if swaprinc returned a list
  expect_type(res_rs, "list")

  # Check if both models in the list are of class "merMod"
  expect_s4_class(res_rs$model_raw, "merMod")
  expect_s4_class(res_rs$model_pca, "merMod")
})

# Test norun_raw option
# Run tests for stats engine
test_that("swaprinc returns correct class for basic lm for norun_raw = TRUE", {
  #Get iris data
  data(iris)

  #Run basic lm model using stats
  res <- swaprinc(iris,
                  "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width",
                  pca_vars = c("Sepal.Width", "Petal.Length"),
                  n_pca_components = 2,
                  norun_raw = TRUE)

  #See if swaprinc returned a list
  expect_type(res, "list")


})

#Test scaling options option

test_that("swaprinc returns correct class for when lpca_center = 'all' &
          lpca_scale = 'all'", {
  #Get iris data
  data(iris)

  #Run basic lm model using stats
  res <- swaprinc(iris,
                  formula = "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width",
                  pca_vars = c("Sepal.Width", "Petal.Length"),
                  n_pca_components = 2,
                  lpca_center = "all",
                  lpca_scale = "all")

  #See if swaprinc returned a list
  expect_type(res, "list")


})

test_that("swaprinc returns correct class when lpca_center = 'all' &
          lpca_scale = 'all' and no_tresp = TRUE", {
            #Get iris data
            data(iris)

            #Run basic lm model using stats
            res <- swaprinc(iris,
                            formula = "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width",
                            pca_vars = c("Sepal.Width", "Petal.Length"),
                            n_pca_components = 2,
                            lpca_center = "all",
                            lpca_scale = "all",
                            no_tresp = TRUE)

            #See if swaprinc returned a list
            expect_type(res, "list")


          })


test_that("swaprinc works with prc_eng set to Gifi", {
  # Create a small simulated dataset
  set.seed(42)
  n <- 50
  x1 <- rnorm(n)
  x2 <- rnorm(n)
  x3 <- rnorm(n)
  y <- 1 + 2 * x1 + 3 * x2 + rnorm(n)
  data <- data.frame(y, x1, x2, x3)

  x1q <- stats::quantile(data$x1,c(0,1/3,2/3,1))
  x2q <- stats::quantile(data$x2,c(0,1/4,3/4,1))
  x3q <- stats::quantile(data$x3,c(0,2/5,3/5,1))


  data <- data %>% dplyr::mutate(x1 = cut(x1, breaks=x1q, labels=c("low","middle","high"),include.lowest = TRUE),
                          x2 = cut(x2, breaks=x2q, labels=c("small","medium","large"),include.lowest = TRUE),
                          x3 = cut(x3, breaks=x3q, labels=c("short","average","tall"),include.lowest = TRUE))

  # Run swaprinc with prc_eng set to Gifi
  swaprinc_result <- swaprinc(data,
                              formula = "y ~ x1 + x2 + x3",
                              pca_vars = c("x1", "x2", "x3"),
                              n_pca_components = 2,
                              prc_eng = "Gifi")

  # Check that the output is not NULL
  expect_true(!is.null(swaprinc_result))

  # Chec that swaprinc has correct dimensions
  expect_equal(length(swaprinc_result), 3)
})

test_that("swaprinc works with prc_eng set to stats_Gifi", {
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

  # Run swaprinc with prc_eng set to Gifi
  swaprinc_result <- swaprinc(data,
                              formula = "y ~ x1 + x2 + x3 + x4 + x5",
                              pca_vars = c("x1", "x2", "x3", "x4", "x5"),
                              n_pca_components = c("stats" = 1, "Gifi" = 1),
                              prc_eng = "stats_Gifi")

  # Check that the output is not NULL
  expect_true(!is.null(swaprinc_result))

  # Chec that swaprinc has correct dimensions
  expect_equal(length(swaprinc_result), 3)
})


test_that("swaprinc works with prc_eng set to stats_Gifi using named lists for
          pca_vars", {
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

  # Run swaprinc with prc_eng set to Gifi
  swaprinc_result <- swaprinc(data,
                              formula = "y ~ x1 + x2 + x3 + x4 + x5",
                              pca_vars = list("Gifi" = c("x1", "x2", "x3"),
                                                "stats" = c("x4", "x5")),
                              n_pca_components = c("stats" = 1, "Gifi" = 1),
                              prc_eng = "stats_Gifi")

  # Check that the output is not NULL
  expect_true(!is.null(swaprinc_result))

  # Chec that swaprinc has correct dimensions
  expect_equal(length(swaprinc_result), 3)
})


test_that("swaprinc works with gifi_trans_vars", {
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

            # Run swaprinc with prc_eng set to Gifi
            swaprinc_result <- swaprinc(data,
                                        formula = "y ~ x1 + x2 + x3 + x4 + x5",
                                        pca_vars = c("x1", "x2", "x3", "x4", "x5"),
                                        gifi_transform = "all",
                                        gifi_trans_vars = c("x1", "x2", "x3"),
                                        gifi_trans_dims = 2,
                                        n_pca_components = 2)

            # Check that the output is not NULL
            expect_true(!is.null(swaprinc_result))

            # Chec that swaprinc has correct dimensions
            expect_equal(length(swaprinc_result), 3)
          })


test_that("swaprinc works with gifi_trans_vars with gifi_trans_options", {
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

  # Run swaprinc with prc_eng set to Gifi
  swaprinc_result <- swaprinc(data,
                              formula = "y ~ x1 + x2 + x3 + x4 + x5",
                              pca_vars = c("x1", "x2", "x3", "x4", "x5"),
                              gifi_transform = "all",
                              gifi_trans_vars = c("x1", "x2", "x3"),
                              gifi_trans_dims = 2,
                              n_pca_components = 2,
                              gifi_trans_options = list(ties = "t"))

  # Check that the output is not NULL
  expect_true(!is.null(swaprinc_result))

  # Chec that swaprinc has correct dimensions
  expect_equal(length(swaprinc_result), 3)
})

test_that("swaprinc works with prc_eng set to Gifi and extra parameters passed
          to Gifi::princals (gifi_princals_options)", {
  # Create a small simulated dataset
  set.seed(42)
  n <- 50
  x1 <- rnorm(n)
  x2 <- rnorm(n)
  x3 <- rnorm(n)
  y <- 1 + 2 * x1 + 3 * x2 + rnorm(n)
  data <- data.frame(y, x1, x2, x3)

  x1q <- stats::quantile(data$x1,c(0,1/3,2/3,1))
  x2q <- stats::quantile(data$x2,c(0,1/4,3/4,1))
  x3q <- stats::quantile(data$x3,c(0,2/5,3/5,1))


  data <- data %>% dplyr::mutate(x1 = cut(x1, breaks=x1q, labels=c("low","middle","high"),include.lowest = TRUE),
                                 x2 = cut(x2, breaks=x2q, labels=c("small","medium","large"),include.lowest = TRUE),
                                 x3 = cut(x3, breaks=x3q, labels=c("short","average","tall"),include.lowest = TRUE))

  # Run swaprinc with prc_eng set to Gifi
  swaprinc_result <- swaprinc(data,
                              formula = "y ~ x1 + x2 + x3",
                              pca_vars = c("x1", "x2", "x3"),
                              n_pca_components = 2,
                              prc_eng = "Gifi",
                              gifi_princals_options = list(ties = "t"))

  # Check that the output is not NULL
  expect_true(!is.null(swaprinc_result))

  # Chec that swaprinc has correct dimensions
  expect_equal(length(swaprinc_result), 3)
})

test_that("swaprinc works with miss_handler set to omit", {
  #Get iris data
  data(iris)

  iris <- iris %>%
    dplyr::mutate(Petal.Length = ifelse(Petal.Length >= 6.0, NA, Petal.Length))

  #Run basic lm model using stats
  res <- swaprinc(data = iris,
                  formula = "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width",
                  pca_vars = c("Sepal.Width", "Petal.Length"),
                  n_pca_components = 2,
                  miss_handler = "omit")

  #See if swaprinc returned a list
  expect_type(res, "list")


})


test_that("swaprinc works with interactions if the interaction variables are not
          part of the pca_vars vector", {
  suppressWarnings({
    # Get iris data
    data(iris)
    iris$Species_binary <- ifelse(iris$Species == "setosa", 1, 0)

    # Run logistic regression model using stats engine
    res_logistic <- swaprinc(data = iris,
                             formula = "Species_binary ~ Sepal.Length + Sepal.Width*Petal.Length + Petal.Width",
                             engine = "stats",
                             pca_vars = c("Sepal.Length", "Petal.Width"),
                             n_pca_components = 2,
                             model_options = list(family = binomial(link = "logit")))

    # Check if swaprinc returned a list
    expect_type(res_logistic, "list")

    # Check if both models in the list are of class "glm"
    expect_s3_class(res_logistic$model_raw, "glm")
    expect_s3_class(res_logistic$model_pca, "glm")
  })
})

test_that("swaprinc throws error if the interaction variables are part of the
          pca_vars vector", {
              # Get iris data
              data(iris)
              iris$Species_binary <- ifelse(iris$Species == "setosa", 1, 0)

              # Check if swaprinc returns error
              expect_error(swaprinc(data = iris,
                                    formula = "Species_binary ~ Sepal.Length + Sepal.Width + Petal.Length*Petal.Width",
                                    engine = "stats",
                                    pca_vars = c("Sepal.Length", "Petal.Width"),
                                    n_pca_components = 2,
                                    model_options = list(family = binomial(link = "logit"))),
                           "swaprinc does not have support for including interaction variables in pca_vars")

          })
