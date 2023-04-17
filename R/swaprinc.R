#' Swap in Principal Components
#'
#' @description
#'
#' Compare a regression model using raw variables with another model where principal
#' components are extracted from a subset of the raw independent variables, and
#' a user-defined number of these principal components are then used to replace
#' the original subset of variables in the regression model.
#'
#' @param data A dataframe
#' @param formula A quoted model formula
#' @param engine The engine for fitting the model.  Options are 'stats' or 'lme4'.
#' @param prc_eng Then engine or extracting principal components.  Options are
#' 'stats', 'Gifi', and 'stats_Gifi'.  The stats_Gifi engine uses
#' `tidyselect::where(is.numeric)` to select the pca_vars for `stats::prcomp` and
#' `-tidyselect::where(is.numeric)` to select the pca_vars for `Gifi::princals`.
#' Read Rossiter (2021) for more on princals.
#' @param pca_vars Variables to include in the principal component analysis.
#' These variables will be swapped out for principal components
#' @param n_pca_components The number of principal components to include in the
#' model. If using a complex prc_eng (i.e., stats_Gifi) then provide a named
#' vector (i.e., n_pca_components = c("stats" = 2, "Gifi" = 3)).
#' @param norun_raw Include regression on raw variables if TRUE, exclude if FALSE.
#' @param lpca_center Center data as in the Step-by-Step PCA vignette
#' (Harvey & Hanson, 2022).  Only numeric variables will be included in the
#' centering.  Parameter takes values 'all' to center raw and pca variables, 'raw'
#' to only center variables for the raw variable model fitting, 'pca' to only
#' center pca_vars before pca regression model fitting, and 'none' to skip lpca
#' centering.
#' @param lpca_scale Scale data as in the Step-by-Step PCA vignette.  Only
#' numeric variables will be included in the scaling.  Parameter takes values
#' 'all' to scale raw and pca variables, 'raw' to only scale variables for the
#' raw variable model fitting, 'pca' to only scale pca_vars before pca regression
#' model fitting, and 'none' to skip lpca scaling.
#' @param lpca_undo Undo centering and scaling of pca_vars as in the Step-by-Step
#' PCA vignette.
#' @param gifi_transform Use Gifi optimal scaling to transform a set of variables.
#' Parameter takes values 'none', 'all', 'raw', and 'pca'
#' @param gifi_trans_vars A vector of variables to include in the Gifi optimal
#' scaling transformation
#' @param gifi_trans_dims Number of dimensions to extract in the Gifi optimal
#' scaling transformation algorithm
#' @param no_tresp When set to `TRUE`, no_tresp (No transform response) will exclude
#' the response variable from from pre-modeling and pre-pca transformations.
#' Specifically, setting no_tresp to TRUE will exclude the response variable from
#' the transformation specified in lpca_center and lpca_scale.
#' @param miss_handler Choose how `swaprinc` handles missing data on the input
#' data.  Default is 'none'.  Use 'omit' for complete case analysis.
#' @param model_options Pass additional arguments to statistical modeling functions
#' (i.e., `stats::lm`, `stats::glm`, `lme4::lmer`, `lme4::glmer`) Default is
#' 'noaddpars' (no additional parameters)
#' @param prcomp_options Pass additional arguments to `stats::prcomp` for
#' prc_eng = 'stats' and prc_eng = 'stats_Gifi' call. Default is 'noaddpars'
#' (no additional parameters)
#' @param gifi_princals_options Pass additional arguments to `Gifi::princals` for
#' prc_eng = 'Gifi' and prc_eng = 'stats_Gifi' call. Default is 'noaddpars'
#' (no additional parameters)
#' @param gifi_trans_options Pass additional arguments to `Gifi::princals` for
#' gifi_transform.  Default is 'noaddpars' (no additional parameters)
#'
#' @return A list with fitted models
#'
#' @references
#'
#' 1. Rossiter, D. G.  Nonlinear Principal Components Analysis: Multivariate Analysis with Optimal Scaling (MVAOS). (2021) <https://www.css.cornell.edu/faculty/dgr2/_static/files/R_html/NonlinearPCA.html>
#'
#' 2. Harvey, D. T., & Hanson, B. A. Step-by-Step PCA. (2022) <https://cran.r-project.org/package=LearnPCA/vignettes/Vig_03_Step_By_Step_PCA.pdf>
#'
#' @export
#'
#' @examples
#' data(iris)
#' res <- swaprinc(iris,
#' "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width",
#' pca_vars = c("Sepal.Width", "Petal.Length", "Petal.Width"),
#' n_pca_components = 2)
swaprinc <- function(data, formula, engine = "stats", prc_eng = "stats", pca_vars,
                     n_pca_components, norun_raw = FALSE, lpca_center = "none", lpca_scale = "none",
                     lpca_undo = FALSE, gifi_transform = "none", gifi_trans_vars,
                     gifi_trans_dims, no_tresp = FALSE, miss_handler = "none",
                     model_options = "noaddpars",
                     prcomp_options = "noaddpars",
                     gifi_princals_options = "noaddpars",
                     gifi_trans_options = "noaddpars") {

  invisible(utils::capture.output(output <- swaprinc_loud(data, formula, engine, prc_eng, pca_vars,
                          n_pca_components, norun_raw, lpca_center, lpca_scale,
                          lpca_undo, gifi_transform, gifi_trans_vars,
                          gifi_trans_dims, no_tresp, miss_handler,
                          model_options,
                          prcomp_options,
                          gifi_princals_options,
                          gifi_trans_options)))

  return(output)

}


#' Swap in Principal Components (Loud Version of swaprinc)
#'
#'
#'
#' @param data (see swaprinc documentation)
#' @param formula (see swaprinc documentation)
#' @param engine (see swaprinc documentation)
#' @param prc_eng (see swaprinc documentation)
#' @param pca_vars (see swaprinc documentation)
#' @param n_pca_components (see swaprinc documentation)
#' @param norun_raw (see swaprinc documentation)
#' @param lpca_center (see swaprinc documentation)
#' @param lpca_scale (see swaprinc documentation)
#' @param lpca_undo (see swaprinc documentation)
#' @param gifi_transform (see swaprinc documentation)
#' @param gifi_trans_vars (see swaprinc documentation)
#' @param gifi_trans_dims (see swaprinc documentation)
#' @param no_tresp (see swaprinc documentation)
#' @param miss_handler (see swaprinc documentation)
#' @param model_options (see swaprinc documentation)
#' @param prcomp_options (see swaprinc documentation)
#' @param gifi_princals_options (see swaprinc documentation)
#' @param gifi_trans_options (see swaprinc documentation)
#'
#' @keywords internal
#'
#' @return (see swaprinc documentation)
#'
#' @examples \dontrun{
#' #(see swaprinc documentation)
#' }
swaprinc_loud <- function(data, formula, engine, prc_eng, pca_vars,
                     n_pca_components, norun_raw, lpca_center, lpca_scale,
                     lpca_undo, gifi_transform, gifi_trans_vars,
                     gifi_trans_dims, no_tresp, miss_handler,
                     model_options,
                     prcomp_options,
                     gifi_princals_options,
                     gifi_trans_options) {

  # Missing data handler
  if (miss_handler == "omit"){
    data <- data[stats::complete.cases(data), ]
  }

  # Test function parameters
  if (!(lpca_center == "none" | lpca_center == "all" | lpca_center == "raw" |
        lpca_center == "pca")){
    rlang::abort("lpca_center must be set to: 'none', 'all', 'raw', or 'pca'")
  }

  if (!(lpca_scale == "none" | lpca_scale == "all" | lpca_scale == "raw" |
        lpca_scale == "pca")){
    rlang::abort("lpca_center must be set to: 'none', 'all', 'raw', or 'pca'")
  }

  if(lpca_undo == TRUE & (lpca_scale == "none" | lpca_scale == "raw" |
                          lpca_center == "none" | lpca_center == "raw" )) {
    rlang::abort("To use lpca_undo, lpca_scale and lpca_center must be set
                 to 'all' or 'pca'")
  }

  # Helper function to extract interaction variables
  extract_interaction_vars <- function(formula) {
    term_obj <- stats::terms(stats::as.formula(formula))
    term_matrix <- attr(term_obj, "factors")
    index <- term_matrix[grepl(':', colnames(term_matrix))]

    # Find variables involved in interactions
    interaction_vars <- rownames(term_matrix)[index == 1]

    return(interaction_vars)
  }

  # Inside your swaprinc function
  interaction_vars <- extract_interaction_vars(formula)

  if (any(interaction_vars %in% pca_vars)) {
    rlang::abort("swaprinc does not have support for including interaction variables in pca_vars")
  }

  # Helper function to get numerics
  get_nums <- function(df){
    dplyr::select(df, tidyselect::where(is.numeric))
  }

  # Helper function to bind processed numeric variables to non numeric variables
  bind_nums <- function(df_nums, df){
    dplyr::bind_cols(df_nums, dplyr::select(df, -tidyselect::where(is.numeric)))
  }

  # Helper function to get response for no_tresp
  get_resp <- function(df){
    df_resp <- dplyr::select(df, all.vars(stats::update(stats::as.formula(formula), . ~ 1)))
    df_pred <- dplyr::select(df, -all.vars(stats::update(stats::as.formula(formula), . ~ 1)))
    out <- list("df_resp" = df_resp,
                "df_pred" = df_pred)
  }

  # Helper function to bind response variable to processed variables
  bind_resp <- function(df_resp, df){
    dplyr::bind_cols(df_resp, df)
  }

  # Create helper function for lpca center and scale
  lpca_cs <- function(df, scl, cnt){
    if (no_tresp == TRUE){
      df <- get_resp(df)
      df_resp <- df$df_resp
      df <- df$df_pred
    }
    df <- scale(get_nums(df), scale = scl, center = cnt) %>%
      as.data.frame() %>%
      bind_nums(df)

    if (no_tresp == TRUE){
      df <- bind_resp(df_resp, df)
    }

    return(df)
  }

  # Create helper function to get os_trans vars
  gifi_trans <- function(df, gifi_trans_dims, gifi_trans_options){
    # Split data frame
    dftr <- dplyr::select(df, tidyselect::all_of(gifi_trans_vars))
    df_notr <- dplyr::select(df, -tidyselect::all_of(gifi_trans_vars))

    # Get transformed data
    if(gifi_trans_options == "noaddpars"){
      gifi_trans <- Gifi::princals(dftr, ndim=gifi_trans_dims)
    } else{
      gifi_trans <- do.call(Gifi::princals, c(list(data = substitute(dftr), ndim = gifi_trans_dims), gifi_trans_options))
    }


    # Combine transformed and non-transformed data
    df_trans <- gifi_trans$transform %>%
      as.data.frame() %>%
      dplyr::mutate_all(as.numeric) %>%
      cbind(df_notr)

    return(df_trans)
  }

  # Helper function for model fitting
  fit_model <- function(data, formula, engine, model_options) {
    if (engine == "stats") {
      if(model_options == "noaddpars"){
        glm_model <- try(stats::glm(formula, data), silent = TRUE)
      } else{
        glm_model <- try(do.call(stats::glm, c(list(formula = formula, data = substitute(data)),
                                               model_options)), silent = TRUE)
      }
      if (inherits(glm_model, "glm")) {
        return(glm_model)
      } else {
        if(model_options == "noaddpars"){
          lm_model <- try(stats::lm(formula, data), silent = TRUE)
        } else{
          lm_model <- try(do.call(stats::lm, c(list(formula = formula, data = substitute(data)),
                                               model_options)), silent = TRUE)
        }
        if (inherits(lm_model, "lm")) {
          return(lm_model)
        } else {
          rlang::abort("Neither lm nor glm from stats could fit the model.")
        }
      }
    } else if (engine == "lme4") {
      if(model_options == "noaddpars"){
        lmer_model <- try(lme4::lmer(formula, data), silent = TRUE)
      } else{
        lmer_model <- try(do.call(lme4::lmer, c(list(formula = formula, data = substitute(data)),
                                                model_options)), silent = TRUE)
      }
      if (inherits(lmer_model, "merMod")) {
        return(lmer_model)
      } else {
        if(model_options == "noaddpars"){
          glmer_model <- try(lme4::glmer(formula, data), silent = TRUE)
        } else{
          glmer_model <- try(do.call(lme4::glmer, c(list(formula = formula, data = substitute(data)),
                                                    model_options)), silent = TRUE)
        }
        if (inherits(glmer_model, "merMod")) {
          return(glmer_model)
        } else {
          rlang::abort("Neither lmer nor glmer from lme4 could fit the model.")
        }
      }
    } else {
      rlang::abort("Invalid engine specified.")
    }
  }

  # Transform All Data using Gifi::princals
  if(gifi_transform == "all"){
    data <- gifi_trans(data, gifi_trans_dims, gifi_trans_options)
  }

  # Scale All Data and Raw Data According to LearnPCA
  if(lpca_center == "all"){
    data <- lpca_cs(data, scl = FALSE, cnt = TRUE)
  }

  if(lpca_scale == "all"){
    data <- lpca_cs(data, scl = TRUE, cnt = FALSE)
  }

  # Fit the regular model conditionally
  if (!norun_raw) {
    # Copy data
    df_raw <- data

    # Gifi trans data
    if(gifi_transform == "raw"){
      df_raw <- gifi_trans(df_raw, gifi_trans_dims, gifi_trans_options)
    }

    # Scale raw data only according to LearnPCA
    if(lpca_center == "raw"){
      df_raw <- lpca_cs(df_raw, scl = FALSE, cnt = TRUE)
    }

    if(lpca_scale == "raw"){
      df_raw <- lpca_cs(df_raw, scl = TRUE, cnt = FALSE)
    }

    model_raw <- fit_model(df_raw, formula, engine, model_options)
  } else {
    model_raw <- NULL
  }

  # Perform PCA

  # Gifi trans data
  if(gifi_transform == "pca"){
    data <- gifi_trans(data, gifi_trans_dims, gifi_trans_options)
  }

  if(lpca_center == "pca"){
    data <- lpca_cs(data, scl = FALSE, cnt = TRUE)
  }

  if(lpca_scale == "pca"){
    data <- lpca_cs(data, scl = TRUE, cnt = FALSE)
  }

  # Get PCA data

  #Split data based on prc_eng
  split_stats_Gifi <- FALSE
  if (sum(names(pca_vars) == c("stats", "Gifi")) == 2 |
      sum(names(pca_vars) == c("Gifi", "stats")) == 2){
    pca_stats_Gifi_vars <- pca_vars
    pca_vars <- unlist(pca_vars, use.names = FALSE)
    split_stats_Gifi <- TRUE
  }

  pca_data <- data[, pca_vars]

  # Extraction helper functions
  extract_stats <- function(df = pca_data, comps = n_pca_components, prcomp_options){
    if(prcomp_options == "noaddpars"){
      pca_result <- stats::prcomp(df)
    } else{
      pca_result <- do.call(stats::prcomp, c(list(x = substitute(df)), prcomp_options))
    }


    if (lpca_undo == TRUE) {
      Xhat <- pca_result$x[, 1:comps] %*% t(pca_result$rotation[, 1:comps])
      Xhat <- scale(Xhat, center = FALSE, scale = 1/pca_result$scale)
      pca_scores <- scale(Xhat, center = -pca_result$center, scale = FALSE)
    } else {
      pca_scores <- pca_result$x[, 1:comps]
    }
  }

  extract_Gifi <- function(df = pca_data, comps = n_pca_components, gifi_princals_options){
    if(gifi_princals_options == "noaddpars"){
      gifi_results <- Gifi::princals(df, ndim=comps)
    } else{
      gifi_results <- do.call(Gifi::princals, c(list(data = substitute(df), ndim = comps), gifi_princals_options))
    }
    pca_scores <- gifi_results$objectscores
  }

  # Run prc_eng
  if (prc_eng == "stats"){
    pca_scores <- extract_stats(pca_data, n_pca_components, prcomp_options)
  } else if (prc_eng == "Gifi") {
    pca_scores <- extract_Gifi(pca_data, n_pca_components, gifi_princals_options)
  } else if (prc_eng == "stats_Gifi"){

    # Split pca_data by
    if (split_stats_Gifi){
      pca_data_stats <- pca_data %>% dplyr::select(pca_stats_Gifi_vars[["stats"]])
      pca_data_Gifi <- pca_data %>% dplyr::select(pca_stats_Gifi_vars[["Gifi"]])
    } else {
      pca_data_stats <- pca_data %>% dplyr::select(tidyselect::where(is.numeric))
      pca_data_Gifi <- pca_data %>% dplyr::select(-tidyselect::where(is.numeric))
    }

    #stats
    pca_scores_stats <- extract_stats(df = pca_data_stats,
                                      comps = n_pca_components[["stats"]],
                                      prcomp_options)
    #Gifi
    pca_scores_Gifi <- extract_Gifi(df = pca_data_Gifi,
                                    comps = n_pca_components[["Gifi"]],
                                    gifi_princals_options)
    #Collapse
    pca_scores <- cbind(pca_scores_stats, pca_scores_Gifi)
    n_pca_components <- sum(n_pca_components)
  }else {
    rlang::abort("Must specify a valid per_engine.  Use 'stats' to call prcomp,
    or 'Gifi to call princals")
  }

  colnames(pca_scores) <- paste0("PC", 1:n_pca_components)

  # Replace the original variables with the principal components
  data_pca <- data %>%
    dplyr::select(-tidyselect::one_of(pca_vars)) %>%
    cbind(pca_scores)

  replace_pca_vars_in_formula <- function(formula, pca_vars, pca_terms) {
    original_formula <- stats::as.formula(formula)
    response_var <- all.vars(original_formula)[1]

    # Separate fixed and random effects using gsub and strsplit
    #https://stackoverflow.com/questions/62966793/how-to-extract-just-the-random-effects-part-of-the-formula-from-lme4
    inp <- deparse(original_formula)
    formula_terms <- gsub(" ", "", unlist(strsplit(inp, "+", fixed = T)), fixed = T)

    # Identify and separate fixed and random effects
    fixed_effects <- formula_terms[!grepl("\\|", formula_terms)]
    random_effects_terms <- formula_terms[grepl("\\|", formula_terms)]

    # Remove the response variable from the fixed_effects
    fixed_effects[1] <- gsub(paste0(response_var, "~"), "", fixed_effects[1])

    # Remove pca_vars from the fixed_effects
    fixed_effects <- base::setdiff(fixed_effects, pca_vars)

    # Combine fixed_effects with the PCA terms
    fixed_effects <- c(fixed_effects, unlist(strsplit(pca_terms, " \\+ ")))

    if (length(random_effects_terms) > 0) {

      # Check that random effect variables are not included as principal components
      term_matrix <- attr(stats::terms(original_formula), "factors")
      random_effects_vars <- rownames(term_matrix)[apply(term_matrix, 1, function(x) any(x == 1))]
      random_effects_vars <- grep("\\|", random_effects_vars, value = TRUE)
      random_effects_vars <- unlist(strsplit(gsub("\\||\\(|\\)", "", random_effects_vars), split = " "))

      if (any(random_effects_vars %in% pca_vars)) {
        rlang::abort("Using a random effect variable as one of the pca_vars is not allowed.")
      }


      new_formula <- paste(response_var, "~", paste(fixed_effects, collapse = " + "), "+", paste(random_effects_terms, collapse = " + "))
    } else {
      new_formula <- paste(response_var, "~", paste(fixed_effects, collapse = " + "))
    }

    return(stats::as.formula(new_formula))
  }

  # Generate the string with the principal components
  pca_terms <- paste("PC", 1:n_pca_components, sep = "", collapse = " + ")

  # Replace the pca_vars in the formula with the pca_terms
  formula_pca <- replace_pca_vars_in_formula(formula, pca_vars, pca_terms)

  # Fit the PCA model
  model_pca <- fit_model(data_pca, formula_pca, engine, model_options)

  #Compare Models
  compare_models <- function(model_raw, model_pca) {
    # Tidy model output
    if (is.null(model_raw)){
      raw_summary <- NULL
    } else if (inherits(model_raw, "merMod")) {
      raw_summary <- broom.mixed::glance(model_raw)
    } else {
      raw_summary <- broom::glance(model_raw)
    }

    if (inherits(model_pca, "merMod")) {
      pca_summary <- broom.mixed::glance(model_pca)
    } else {
      pca_summary <- broom::glance(model_pca)
    }

    # Create comparison metrics data frame
    if(is.null(model_raw) & inherits(model_pca, c("glm", "glmerMod"))) {
      # For glm and glmer models

      comparison <- data.frame(
        model = c("PCA"),
        logLik = c(pca_summary$logLik),
        AIC = c(pca_summary$AIC),
        BIC = c(pca_summary$BIC)
      )
    } else if (inherits(model_raw, c("glm", "glmerMod")) & inherits(model_pca, c("glm", "glmerMod"))) {
      # For glm and glmer models

      comparison <- data.frame(
        model = c("Raw", "PCA"),
        logLik = c(raw_summary$logLik, pca_summary$logLik),
        AIC = c(raw_summary$AIC, pca_summary$AIC),
        BIC = c(raw_summary$BIC, pca_summary$BIC)
      )
    } else if (is.null(model_raw) & inherits(model_pca, "lm")) {
      # For lm models only
      comparison <- data.frame(
        model = c("PCA"),
        r_squared = c(pca_summary$r.squared),
        adj_r_squared = c(pca_summary$adj.r.squared),
        AIC = c(pca_summary$AIC),
        BIC = c(pca_summary$BIC)
      )
    } else if (inherits(model_raw, "lm") & inherits(model_pca, "lm")) {
      # For lm models only
      comparison <- data.frame(
        model = c("Raw", "PCA"),
        r_squared = c(raw_summary$r.squared, pca_summary$r.squared),
        adj_r_squared = c(raw_summary$adj.r.squared, pca_summary$adj.r.squared),
        AIC = c(raw_summary$AIC, pca_summary$AIC),
        BIC = c(raw_summary$BIC, pca_summary$BIC)
      )
    } else if (is.null(model_raw) & inherits(model_pca, "lmerMod")){
      # For lmer models only
      comparison <- data.frame(
        model = c("PCA"),
        logLik = c(pca_summary$logLik),
        AIC = c(pca_summary$AIC),
        BIC = c(pca_summary$BIC)
      )
    } else if (inherits(model_raw, "lmerMod") & inherits(model_pca, "lmerMod")) {
      # For lmer models only
      comparison <- data.frame(
        model = c("Raw", "PCA"),
        logLik = c(raw_summary$logLik, pca_summary$logLik),
        AIC = c(raw_summary$AIC, pca_summary$AIC),
        BIC = c(raw_summary$BIC, pca_summary$BIC)
      )
    } else {
      rlang::abort("The two models must be of the same type, either linear (lm or lmer) or generalized linear (glm or glmer).")
    }

    return(comparison)
  }


  # Get comparison
  model_comparison <- compare_models(model_raw, model_pca)

  return(list(model_raw = model_raw, model_pca = model_pca, comparison = model_comparison))



}
