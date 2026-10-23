# plot_xy_panels.R - Multi-X scatter, Multi-Y scatter
# Tiled = one facet per variable, Overlay = one colour per variable.
# (Data are passed as vectors, which fixes the old ~get() loop bug where
#  every overlay trace showed the last variable.)

.xy_panel_plot <- function(long, mode, xlab, ylab, base_size, facet_scales) {
  n <- nlevels(long$.variable)
  if (identical(mode, "Overlay")) {
    ggplot(long, aes(.x, .y, colour = .variable)) +
      geom_point(size = 2.2, alpha = 0.8) +
      scale_colour_manual(values = cat_pal(n), name = NULL) +
      labs(x = xlab, y = ylab) + theme_pub(base_size)
  } else {
    ggplot(long, aes(.x, .y)) +
      geom_point(colour = "#0072B2", size = 2, alpha = 0.8) +
      facet_if_multi(n, scales = facet_scales) +
      labs(x = xlab, y = ylab) + theme_pub(base_size)
  }
}

plot_multi_x <- function(df, xVars, yVar, mode, maxTiles, base_size = 12) {
  if (is_none(yVar) || !yVar %in% names(df) || !is.numeric(df[[yVar]])) user_stop("Select a numeric Y variable")
  xs <- head(keep_numeric(df, xVars), maxTiles)
  if (!length(xs)) user_stop("Select one or more numeric X variables")
  long <- build_xy_long(df, xs, rep(yVar, length(xs)), pretty_label(xs))
  if (!nrow(long)) user_stop("No complete X/Y pairs")
  xlab <- if (length(xs) == 1) pretty_label(xs) else "X value"
  .xy_panel_plot(long, mode, xlab, pretty_label(yVar), base_size, "free_x")
}

plot_multi_y <- function(df, xVar, yVars, mode, maxTiles, base_size = 12) {
  if (is_none(xVar) || !xVar %in% names(df) || !is.numeric(df[[xVar]])) user_stop("Select a numeric X variable")
  ys <- head(keep_numeric(df, yVars), maxTiles)
  if (!length(ys)) user_stop("Select one or more numeric Y variables")
  long <- build_xy_long(df, rep(xVar, length(ys)), ys, pretty_label(ys))
  if (!nrow(long)) user_stop("No complete X/Y pairs")
  ylab <- if (length(ys) == 1) pretty_label(ys) else "Y value"
  .xy_panel_plot(long, mode, pretty_label(xVar), ylab, base_size, "free_y")
}
