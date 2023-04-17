
<!-- README.md is generated from README.Rmd. Please edit that file -->

# swaprinc

<!-- badges: start -->
<!-- badges: end -->

The objective of swaprinc is to streamline the comparison between a
regression model using original variables and a model in which some of
these variables have been swapped out for principal components.

## Installation

You can install the released version of swaprinc from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("swaprinc")
```

You can install the development version of swaprinc from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mncube/swaprinc")
```

## A Simple Example

In the simple example provided, a regression model estimates the
relationship between x1 and y, while controlling for variables x2
through x10.

By using the default engine, “stats”, the statistical model is fitted
with stats::lm, and by using the default prc_eng, “stats”, principal
components are extracted with stats::prcomp.

The “raw model” is specified by the formula parameter, which is passed
to stats::lm. The pca_vars and n_pca_components parameters indicate that
variables x2 to x10 will be used to extract three principal components.
Subsequently, the “PCA model” is passed to stats::lm as follows: y \~
x1 + PC1 + PC2 + PC3.

By setting the lpca_center and lpca_scale parameters to ‘pca’, the data
in pca_vars will be centered and scaled according to the guidelines in
the [Step-by-Step
PCA](https://cran.r-project.org/package=LearnPCA/vignettes/Vig_03_Step_By_Step_PCA.pdf)
vignette before being passed to stats::prcomp. The miss_handler
parameter, set to ‘omit’, ensures that only complete cases are included
by subsetting the data frame rows with stats::complete.cases.

``` r
library(swaprinc)

  # Create a small simulated dataset
  set.seed(40)
  n <- 50
  x1 <- rnorm(n)
  x2 <- rnorm(n, 5, 15)
  x3 <- rnorm(n, -5.5, 20)
  x4 <- rnorm(n, 3, 3) + x3*1.5
  x5 <- rnorm(n, -2, 4) + x3*.25
  x6 <- rnorm(n, -5, 5) + x4
  x7 <- rnorm(n, -2, 6)
  x8 <- rnorm(n, 2, 7)
  x9 <- rnorm(n, -2, 3) +x2*.4
  x10 <- rnorm(n, 5, 4)
  y <- 1 + 2 * x1 + 3 * x2 + 2.5*x4 - 3.5*x5 + 2*x6 + 1.5*x7 + x8 + 2*x9 + x10 + rnorm(n)
  data <- data.frame(y, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10)

  # Run swaprinc with
  swaprinc_result <- swaprinc(data,
                              formula = "y ~ x1 + x2 + x3 + x4 + x5 + x5 + x6 + x7 + x8 + x9 + x10",
                              pca_vars = c("x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9", "x10"),
                              n_pca_components = 3,
                              lpca_center = "pca", 
                              lpca_scale = "pca",
                              miss_handler = "omit")
  
  # Summarize raw model
  summary(swaprinc_result$model_raw)
#> 
#> Call:
#> stats::lm(formula = formula, data = data)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -2.22717 -0.55113  0.00573  0.45296  3.03938 
#> 
#> Coefficients:
#>             Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  1.75250    0.38418   4.562 4.94e-05 ***
#> x1           2.06070    0.17472  11.794 1.96e-14 ***
#> x2           2.93211    0.02976  98.525  < 2e-16 ***
#> x3           0.06272    0.07596   0.826    0.414    
#> x4           2.40907    0.06368  37.830  < 2e-16 ***
#> x5          -3.48453    0.04467 -78.007  < 2e-16 ***
#> x6           2.04578    0.03497  58.501  < 2e-16 ***
#> x7           1.49816    0.02621  57.158  < 2e-16 ***
#> x8           0.97008    0.02530  38.345  < 2e-16 ***
#> x9           2.12426    0.06502  32.670  < 2e-16 ***
#> x10          0.99118    0.03787  26.174  < 2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.064 on 39 degrees of freedom
#> Multiple R-squared:  0.9999, Adjusted R-squared:  0.9999 
#> F-statistic: 7.237e+04 on 10 and 39 DF,  p-value: < 2.2e-16
  
  # Summarize pca model
  summary(swaprinc_result$model_pca)
#> 
#> Call:
#> stats::lm(formula = formula, data = data)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -0.47301 -0.16369 -0.03991  0.15923  0.48937 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  4.130e-17  3.701e-02   0.000    1.000    
#> x1           6.056e-02  4.050e-02   1.495    0.142    
#> PC1          4.227e-01  1.955e-02  21.621  < 2e-16 ***
#> PC2          3.692e-01  2.781e-02  13.275  < 2e-16 ***
#> PC3         -1.513e-01  3.422e-02  -4.423 6.11e-05 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.2617 on 45 degrees of freedom
#> Multiple R-squared:  0.9371, Adjusted R-squared:  0.9315 
#> F-statistic: 167.6 on 4 and 45 DF,  p-value: < 2.2e-16
  
  # Get model comparisons
  print(swaprinc_result$comparison)
#>   model r_squared adj_r_squared      AIC       BIC
#> 1   Raw 0.9999461     0.9999323 159.7190 182.66323
#> 2   PCA 0.9370900     0.9314980  14.5812  26.05334
```

## The Motivating Example

A common challenge in applied statistics and data science involves
performing logistic regression with a set of categorical independent
variables. In this motivating example, swaprinc is employed to compare a
‘raw’ logistic regression model containing seven categorical independent
variables with a ‘pca’ logistic regression model. The latter model
replaces six of the independent variables with their first three
principal components, using Gifi::princals to extract principal
components. For a comprehensive tutorial on Gifi, refer to [Nonlinear
Principal Components Analysis: Multivariate Analysis with Optimal
Scaling
(MVAOS)](https://www.css.cornell.edu/faculty/dgr2/_static/files/R_html/NonlinearPCA.html#2_Package).

I recommend using the ‘broom’ and ‘broom.mixed’ packages to summarize
model results when utilizing the ’\*\_options’ parameters for passing
arguments to functions within ‘swaprinc’. This approach helps prevent
[overly extensive summaries caused by
‘do.call’](https://stackoverflow.com/questions/75512192/r-do-call-function-returns-to-much/75512429#75512429).

``` r
 # Create a small simulated dataset
  set.seed(42)
  n <- 50
  x1 <- rnorm(n, 0.5, 4)
  x2 <- rnorm(n, 3, 15)
  x3 <- rnorm(n, -2.5, 5)
  x4 <- -2.5*x2 + 3*x3 + rnorm(n, 0, 4)
  x5 <- x2*x3 + rnorm(n, -5, 5)*rnorm(n, 5, 10)
  x6 <- rnorm(n, -2, 4)*rnorm(n, 3, 5)
  x7 <- x4 + x6 + rnorm(n, 0, 3)
  y <- 1 + 2*x1 + 3*x2 + -2*x3 + .5*x4 + x5 + 1.5*x6 + x7 + rnorm(n)
  data <- data.frame(y, x1, x2, x3, x4, x5, x6, x7)

  # Categorize the variables
  yq <- stats::quantile(data$y,c(0,1/2, 1))
  x1q <- stats::quantile(data$x1,c(0,1/2, 1))
  x2q <- stats::quantile(data$x2,c(0,1/4,3/4,1))
  x3q <- stats::quantile(data$x3,c(0,2/5,3/5,1))
  x4q <- stats::quantile(data$x4,c(0,1/5,4/5,1))
  x5q <- stats::quantile(data$x5,c(0,2/5,3/5,1))
  x6q <- stats::quantile(data$x6,c(0,2/5,4/5,1))
  x7q <- stats::quantile(data$x7,c(0,2/5,3/5,1))


  data <- data %>% dplyr::mutate(
    y = cut(y, breaks=yq, labels=c("0", "1"),include.lowest = TRUE),
    x1 = cut(x1, breaks=x1q, labels=c("control", "treatment"),include.lowest = TRUE),
    x2 = cut(x2, breaks=x2q, labels=c("small","medium","large"),include.lowest = TRUE),
    x3 = cut(x3, breaks=x3q, labels=c("short","average","tall"),include.lowest = TRUE),
    x4 = cut(x4, breaks=x4q, labels=c("lowbit","most","highbit"),include.lowest = TRUE),
    x5 = cut(x5, breaks=x5q, labels=c("under","healthy","over"),include.lowest = TRUE),
    x6 = cut(x6, breaks=x6q, labels=c("small","medium","large"),include.lowest = TRUE),
    x7 = cut(x7, breaks=x7q, labels=c("small","medium","large"),include.lowest = TRUE)) %>%
    dplyr::mutate(y = as.numeric(ifelse(y == "0", 0, 1)))

  # Run swaprinc with prc_eng set to Gifi
  swaprinc_result <- swaprinc(data,
                              formula = "y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7",
                              pca_vars = c("x2", "x3", "x4", "x5", "x6", "x7"),
                              n_pca_components = 3,
                              prc_eng = "Gifi",
                              model_options = list(family = binomial(link = "logit")))
#> Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred
  
  # Summarize raw model
  broom::tidy(swaprinc_result$model_raw)
#> # A tibble: 14 × 5
#>    term         estimate std.error statistic p.value
#>    <chr>           <dbl>     <dbl>     <dbl>   <dbl>
#>  1 (Intercept) -2.90e+ 1  39239.   -7.38e- 4   0.999
#>  2 x1treatment  8.68e- 1      2.20  3.94e- 1   0.693
#>  3 x2medium    -2.76e+ 1  36042.   -7.66e- 4   0.999
#>  4 x2large     -3.26e+ 1  38090.   -8.57e- 4   0.999
#>  5 x3average    2.51e+ 1  18410.    1.36e- 3   0.999
#>  6 x3tall       4.67e+ 0  17688.    2.64e- 4   1.00 
#>  7 x4most       9.15e-12      2.51  3.65e-12   1.00 
#>  8 x4highbit   -2.22e+ 1  39541.   -5.61e- 4   1.00 
#>  9 x5healthy    4.02e+ 1  16106.    2.50e- 3   0.998
#> 10 x5over       5.23e+ 1  21037.    2.49e- 3   0.998
#> 11 x6medium    -4.18e+ 0  19682.   -2.12e- 4   1.00 
#> 12 x6large      5.65e+ 1  23134.    2.44e- 3   0.998
#> 13 x7medium    -8.68e- 1      2.20 -3.94e- 1   0.693
#> 14 x7large      3.00e+ 1  20792.    1.44e- 3   0.999
  
  # Summarize pca model
  broom::tidy(swaprinc_result$model_pca)
#> # A tibble: 5 × 5
#>   term        estimate std.error statistic  p.value
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 (Intercept)   -0.162     0.567    -0.286 0.775   
#> 2 x1treatment    0.303     0.810     0.374 0.708   
#> 3 PC1           -2.00      0.539    -3.72  0.000201
#> 4 PC2           -0.501     0.387    -1.29  0.195   
#> 5 PC3            0.339     0.381     0.891 0.373
  
  # Get model comparisons
  print(swaprinc_result$comparison)
#>   model     logLik      AIC      BIC
#> 1   Raw  -4.539636 37.07927 63.84759
#> 2   PCA -20.382553 50.76511 60.32522
```

## Compare Multiple Models

Utilizing the same dataset as in the logistic regression model mentioned
earlier, it is beneficial to compare outcomes for various swaps. In the
example below, the compswap helper function facilitates the comparison
of results with 2, 3, 4, and 5 principal components replacing six
original independent variables.

``` r
  # Run swaprinc with prc_eng set to Gifi
  compswap_results <- compswap(data,
                              formula = "y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7",
                              .pca_varlist = list(c("x2", "x3", "x4", "x5", "x6", "x7")),
                              .n_pca_list = list(2, 3, 4, 5),
                              .prc_eng_list = list("Gifi"),
                              .model_options_list = list(list(family = binomial(link = "logit"))))
#> Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

  # Show available models
  summary(compswap_results$all_models)
#>             Length Class Mode
#> model_raw   30     glm   list
#> model_pca_1 30     glm   list
#> model_pca_2 30     glm   list
#> model_pca_3 30     glm   list
#> model_pca_4 30     glm   list
  
  # Get model comparisons
  print(compswap_results$all_comparisons)
#>   model     logLik      AIC      BIC   model_set
#> 1   Raw  -4.539636 37.07927 63.84759   model_raw
#> 2   PCA -21.390567 50.78113 58.42923 model_pca_1
#> 3   PCA -20.382553 50.76511 60.32522 model_pca_2
#> 4   PCA -13.780908 39.56182 51.03395 model_pca_3
#> 5   PCA -11.616326 37.23265 50.61681 model_pca_4
  
  # View model summaries
  lapply(compswap_results$all_models, broom::tidy)
#> $model_raw
#> # A tibble: 14 × 5
#>    term         estimate std.error statistic p.value
#>    <chr>           <dbl>     <dbl>     <dbl>   <dbl>
#>  1 (Intercept) -2.90e+ 1  39239.   -7.38e- 4   0.999
#>  2 x1treatment  8.68e- 1      2.20  3.94e- 1   0.693
#>  3 x2medium    -2.76e+ 1  36042.   -7.66e- 4   0.999
#>  4 x2large     -3.26e+ 1  38090.   -8.57e- 4   0.999
#>  5 x3average    2.51e+ 1  18410.    1.36e- 3   0.999
#>  6 x3tall       4.67e+ 0  17688.    2.64e- 4   1.00 
#>  7 x4most       9.15e-12      2.51  3.65e-12   1.00 
#>  8 x4highbit   -2.22e+ 1  39541.   -5.61e- 4   1.00 
#>  9 x5healthy    4.02e+ 1  16106.    2.50e- 3   0.998
#> 10 x5over       5.23e+ 1  21037.    2.49e- 3   0.998
#> 11 x6medium    -4.18e+ 0  19682.   -2.12e- 4   1.00 
#> 12 x6large      5.65e+ 1  23134.    2.44e- 3   0.998
#> 13 x7medium    -8.68e- 1      2.20 -3.94e- 1   0.693
#> 14 x7large      3.00e+ 1  20792.    1.44e- 3   0.999
#> 
#> $model_pca_1
#> # A tibble: 4 × 5
#>   term        estimate std.error statistic  p.value
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 (Intercept)   -0.285     0.545    -0.523 0.601   
#> 2 x1treatment    0.464     0.767     0.604 0.546   
#> 3 PC1           -1.91      0.519    -3.68  0.000229
#> 4 PC2           -0.483     0.375    -1.29  0.198   
#> 
#> $model_pca_2
#> # A tibble: 5 × 5
#>   term        estimate std.error statistic  p.value
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 (Intercept)   -0.162     0.567    -0.286 0.775   
#> 2 x1treatment    0.303     0.810     0.374 0.708   
#> 3 PC1           -2.00      0.539    -3.72  0.000201
#> 4 PC2           -0.501     0.387    -1.29  0.195   
#> 5 PC3            0.339     0.381     0.891 0.373   
#> 
#> $model_pca_3
#> # A tibble: 6 × 5
#>   term        estimate std.error statistic p.value
#>   <chr>          <dbl>     <dbl>     <dbl>   <dbl>
#> 1 (Intercept)   -0.348     0.752    -0.463 0.643  
#> 2 x1treatment    1.28      1.14      1.12  0.261  
#> 3 PC1           -2.78      0.851    -3.26  0.00110
#> 4 PC2           -1.32      0.723    -1.83  0.0674 
#> 5 PC3            0.533     0.565     0.943 0.346  
#> 6 PC4            1.79      0.680     2.63  0.00851
#> 
#> $model_pca_4
#> # A tibble: 7 × 5
#>   term        estimate std.error statistic p.value
#>   <chr>          <dbl>     <dbl>     <dbl>   <dbl>
#> 1 (Intercept)   -0.737     0.844    -0.874 0.382  
#> 2 x1treatment    1.98      1.39      1.43  0.153  
#> 3 PC1           -3.39      1.22     -2.77  0.00567
#> 4 PC2           -1.69      0.953    -1.77  0.0769 
#> 5 PC3            1.00      0.791     1.27  0.205  
#> 6 PC4            2.44      0.973     2.50  0.0123 
#> 7 PC5            0.420     0.536     0.785 0.432
```
