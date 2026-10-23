# plot_line.R - time series. If an X value repeats (replicates), plots
# mean +/- error per time point instead of zig-zagging through replicates.

plot_line <- function(df, xVar, yVars, mode, maxTiles, base_size = 12, errType = "SEM") {
  if (is_none(xVar) || !xVar %in% names(df) || !is.numeric(df[[xVar]])) user_stop("Select a numeric X (time) variable")
  ys <- head(keep_numeric(df, yVars), maxTiles)
  if (!length(ys)) user_stop("Select one or more numeric Y variables")
  long <- build_xy_long(df, rep(xVar, length(ys)), ys, pretty_label(ys))
  if (!nrow(long)) user_stop("No complete X/Y pairs")

  has_reps <- any(duplicated(long[, c(".variable", ".x")]))
  caption <- NULL
  if (has_reps) {
    long <- long %>%
      group_by(.variable, .x) %>%
      summarise(n = dplyr::n(), sd = stats::sd(.y), .y = mean(.y), .groups = "drop") %>%
      mutate(sem = sd / sqrt(n),
             err = switch(errType, "SD" = sd, "SEM" = sem,
                          "95% CI" = ifelse(n > 1, stats::qt(0.975, pmax(n - 1, 1)) * sem, NA_real_),
                          NA_real_))
    caption <- if (errType == "None") "Mean of replicates" else paste0("Mean +/- ", errType, " of replicates")
  }
  long <- long[order(long$.variable, long$.x), , drop = FALSE]
  n <- nlevels(long$.variable)
  overlay <- identical(mode, "Overlay")

  p <- if (overlay) ggplot(long, aes(.x, .y, colour = .variable, group = .variable))
       else ggplot(long, aes(.x, .y, group = .variable))
  fixed_col <- if (overlay) list() else list(colour = "#0072B2")
  p <- p + do.call(geom_line, c(list(linewidth = 0.8), fixed_col)) +
    do.call(geom_point, c(list(size = 2), fixed_col))
  if (has_reps && errType != "None") {
    p <- p + do.call(geom_errorbar, c(list(mapping = aes(ymin = .y - err, ymax = .y + err), width = 0), fixed_col))
  }
  p <- p + labs(x = pretty_label(xVar), y = if (length(ys) == 1) pretty_label(ys) else "Y value",
                caption = caption) + theme_pub(base_size)
  if (overlay) p + scale_colour_manual(values = cat_pal(n), name = NULL) else p + facet_if_multi(n)
}
