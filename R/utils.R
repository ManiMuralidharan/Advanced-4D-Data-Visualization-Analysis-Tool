# utils.R - small shared helpers

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# TRUE when a selector value means "nothing selected"
is_none <- function(x) {
  is.null(x) || length(x) == 0 || is.na(x[1]) || !nzchar(x[1]) || identical(x[1], "None")
}

pretty_label <- function(x) {
  if (is.null(x) || length(x) == 0) return("")
  gsub("_", " ", as.character(x), fixed = TRUE)
}

numeric_cols <- function(df) {
  if (is.null(df)) return(character(0))
  names(df)[vapply(df, is.numeric, logical(1))]
}

# Keep only variables that exist and are numeric
keep_numeric <- function(df, vars) {
  vars <- as.character(vars %||% character(0))
  vars[vapply(vars, function(v) v %in% names(df) && is.numeric(df[[v]]), logical(1))]
}

cat_pal <- function(n) {
  if (n <= length(OKABE_ITO)) OKABE_ITO[seq_len(n)] else grDevices::hcl.colors(n, "Dark 3")
}

p_to_stars <- function(p) {
  ifelse(is.na(p), "",
  ifelse(p < 1e-4, "****",
  ifelse(p < 1e-3, "***",
  ifelse(p < 0.01, "**",
  ifelse(p < 0.05, "*", "ns")))))
}

fmt_num <- function(x, digits = 3) {
  ifelse(is.na(x), "NA", formatC(signif(x, digits), format = "g", digits = digits))
}

# Publication-style ggplot theme
theme_pub <- function(base_size = 12) {
  theme_classic(base_size = base_size) +
    theme(
      strip.background = element_blank(),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold"),
      plot.caption = element_text(size = rel(0.75), colour = "grey30", hjust = 0),
      axis.text = element_text(colour = "black")
    )
}

# Facet only when several variables are shown
facet_if_multi <- function(n_vars, scales = "free_y") {
  if (n_vars > 1) facet_wrap(~.variable, scales = scales, ncol = ceiling(sqrt(n_vars))) else NULL
}

# Stop with a message meant for the user (shown in the plot area)
user_stop <- function(...) stop(paste0(...), call. = FALSE)
