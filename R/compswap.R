#' Compare swaprinc Models
#'
#' @description
#'
#' The `swaprinc` function compares a regression model using raw variables to a
#' model with principal components swapped in. The `compswap` function compares
#' a regression model with raw variables to multiple models with principal
#' components swapped in. Parameter lists are recycled to ensure they are the
#' same length as the longest parameter list.
#'
#' @param data A dataframe
#' @param formula A quoted model formula
#' @param engine The engine for fitting the model.  Options are "stats" or"lme4".
#' @param .prc_eng_list A list of prc_eng values (see swaprinc documentation)
#' @param .pca_varlist A list of pca_vars (see swaprinc documentation)
#' @param .n_pca_list A list of n_pca_components (see swaprinc documentation)
#' @param .lpca_center_list A list of lpca_center values (see swaprinc documentation)
#' @param .lpca_scale_list A list of lpca_scale values (see swaprinc documentation)
#' @param .lpca_undo_list A list of lpca_undo values (see swaprinc documentation)
#' @param .gifi_transform_list A list of gifi_transform values (see swaprinc documentation)
#' @param .gifi_trans_vars_list A list of gifi_trans_vars values (see swaprinc documentation)
#' @param .gifi_trans_dims_list A list of gifi_trans_dims values (see swaprinc documentation)
#' @param .no_tresp_list A list of no_tresp values (see swaprinc documentation)
#' @param .miss_handler_list A list of miss_handler values (see swaprinc documentation)
#' @param .model_options_list A list of model_options (see swaprinc documentation)
#' @param .prcomp_options_list A list of prcomp_options (see swaprinc documentation)
#' @param .gifi_princals_options_list A list of gifi_princals_options (see swaprinc documentation)
#' @param .gifi_trans_options_list A list of gifi_trans_options (see swaprinc documentation)
#'
#' @return A list containing a list of fitted models and a comparison metrics
#' data frame.
#' @export
#'
#' @examples
#'# Load the iris dataset
#'data(iris)
#'
#'# Define the formula
#'formula <- "Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width"
#'
#'# Define the pca_varlist
#'pca_varlist <- list(c("Sepal.Width", "Petal.Length"),
#'                    c("Sepal.Width", "Petal.Width"))
#'
#'# Define the n_pca_list
#'n_pca_list <- list(2, 2)
#'
#'# Set scaling values
#'lpca_center_list <- list("none", "none")
#'lpca_scale_list <- list("none", "none")
#'lpca_undo_list <- list(FALSE, FALSE)
#'
#'# Run compswap
#'compswap_results <- compswap(data = iris,
#'                             formula = formula,
#'                             engine = "stats",
#'                             .pca_varlist = pca_varlist,
#'                             .n_pca_list = n_pca_list,
#'                             .lpca_center_list = lpca_center_list,
#'                             .lpca_scale_list = lpca_scale_list,
#'                             .lpca_undo_list = lpca_undo_list)
compswap <- function(data, formula,
                     engine = "stats",
                     .prc_eng_list = list("stats"),
                     .pca_varlist = list(c(NULL)),
                     .n_pca_list = list(NULL),
                     .lpca_center_list = list("none"),
                     .lpca_scale_list = list("none"),
                     .lpca_undo_list = list(FALSE),
                     .gifi_transform_list = list("none"),
                     .gifi_trans_vars_list = list(c(NULL)),
                     .gifi_trans_dims_list = list(NULL),
                     .no_tresp_list = list(FALSE),
                     .miss_handler_list = list("none"),
                     .model_options_list = list("noaddpars"),
                     .prcomp_options_list = list("noaddpars"),
                     .gifi_princals_options_list = list("noaddpars"),
                     .gifi_trans_options_list = list("noaddpars")) {

  n <- max(length(.pca_varlist), length(.n_pca_list), length(.prc_eng_list),
           length(.lpca_center_list), length(.lpca_scale_list),
           length(.lpca_undo_list), length(.gifi_transform_list),
           length(.gifi_trans_vars_list), length(.gifi_trans_dims_list),
           length(.no_tresp_list), length(.miss_handler_list),
           length(.model_options_list), length(.prcomp_options_list),
           length(.gifi_princals_options_list), length(.gifi_trans_options_list))

  # Recycle parameters to match the length of n
  .pca_varlist <- rep(.pca_varlist, length.out = n)
  .n_pca_list <- rep(.n_pca_list, length.out = n)
  .prc_eng_list <- rep(.prc_eng_list, length.out = n)
  .lpca_center_list <- rep(.lpca_center_list, length.out = n)
  .lpca_scale_list <- rep(.lpca_scale_list, length.out = n)
  .lpca_undo_list <- rep(.lpca_undo_list, length.out = n)
  .gifi_transform_list <- rep(.gifi_transform_list, length.out = n)
  .gifi_trans_vars_list <- rep(.gifi_trans_vars_list, length.out = n)
  .gifi_trans_dims_list <- rep(.gifi_trans_dims_list, length.out = n)
  .no_tresp_list <- rep(.no_tresp_list, length.out = n)
  .miss_handler_list <- rep(.miss_handler_list, length.out = n)
  .model_options_list <- rep(.model_options_list, length.out = n)
  .prcomp_options_list <- rep(.prcomp_options_list, length.out = n)
  .gifi_princals_options_list <- rep(.gifi_princals_options_list, length.out = n)
  .gifi_trans_options_list <- rep(.gifi_trans_options_list, length.out = n)



  all_models <- list()
  all_comparisons <- data.frame()

  norun_raw <- FALSE

  for (i in seq_along(.pca_varlist)) {
    pca_vars <- .pca_varlist[[i]]
    n_pca_components <- .n_pca_list[[i]]
    prc_eng <- .prc_eng_list[[i]]
    lpca_center <- .lpca_center_list[[i]]
    lpca_scale <- .lpca_scale_list[[i]]
    lpca_undo <- .lpca_undo_list[[i]]
    no_tresp <- .no_tresp_list[[i]]
    miss_handler <- .miss_handler_list[[i]]
    gifi_transform <- .gifi_transform_list[[i]]
    gifi_trans_vars <- .gifi_trans_vars_list[[i]]
    gifi_trans_dims <- .gifi_trans_dims_list[[i]]
    model_options <- .model_options_list[[i]]
    prcomp_options <- .prcomp_options_list[[i]]
    gifi_princals_options <- .gifi_princals_options_list[[i]]
    gifi_trans_options <- .gifi_trans_options_list[[i]]

    swaprinc_result <- swaprinc(data, formula, engine, prc_eng, pca_vars,
                                n_pca_components, norun_raw = norun_raw,
                                lpca_center, lpca_scale, lpca_undo,
                                gifi_transform, gifi_trans_vars, gifi_trans_dims,
                                no_tresp, miss_handler, model_options,
                                prcomp_options, gifi_princals_options,
                                gifi_trans_options)

    if (!norun_raw) {
      all_models$model_raw <- swaprinc_result$model_raw
      norun_raw <- TRUE
    }

    all_models[[paste0("model_pca_", i)]] <- swaprinc_result$model_pca

    comparison_df <- swaprinc_result$comparison
    comparison_df$model_set <- paste0("model_pca_", i)
    all_comparisons <- rbind(all_comparisons, comparison_df)

    if (i == 1) {
      all_comparisons[all_comparisons$model == "Raw", "model_set"] <- "model_raw"
    }
  }

  return(list(all_models = all_models, all_comparisons = all_comparisons))
}


