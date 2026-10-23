# plot_scatter_4d.R - X, Y + Group colour / numeric colour / bubble size

plot_scatter_4d <- function(df, xName, yName, groupVar, sizeVar, colorVar, cmap, base_size = 12) {
  if (is_none(xName) || !xName %in% names(df)) user_stop("Select an X variable")
  if (is_none(yName) || !yName %in% names(df)) user_stop("Select a Y variable")
  d <- df[!is.na(df[[xName]]) & !is.na(df[[yName]]), , drop = FALSE]
  if (nrow(d) == 0) user_stop("No rows with both X and Y present")

  useGroup <- !is_none(groupVar) && groupVar %in% names(d)
  useSize  <- !is_none(sizeVar)  && sizeVar  %in% names(d) && is.numeric(d[[sizeVar]])
  useColor <- !useGroup && !is_none(colorVar) && colorVar %in% names(d) && is.numeric(d[[colorVar]])
  if (useGroup) d[[groupVar]] <- factor(d[[groupVar]])
  colVar <- if (useGroup) groupVar else if (useColor) colorVar else NULL

  pts <- if (!is.null(colVar) && useSize) {
    geom_point(aes(colour = .data[[colVar]], size = .data[[sizeVar]]), alpha = 0.75)
  } else if (!is.null(colVar)) {
    geom_point(aes(colour = .data[[colVar]]), size = 2.5, alpha = 0.85)
  } else if (useSize) {
    geom_point(aes(size = .data[[sizeVar]]), colour = "#0072B2", alpha = 0.75)
  } else {
    geom_point(colour = "#0072B2", size = 2.5, alpha = 0.85)
  }

  p <- ggplot(d, aes(x = .data[[xName]], y = .data[[yName]])) + pts +
    labs(x = pretty_label(xName), y = pretty_label(yName),
         colour = if (!is.null(colVar)) pretty_label(colVar) else NULL,
         size = if (useSize) pretty_label(sizeVar) else NULL) +
    theme_pub(base_size)
  if (useGroup) p <- p + scale_colour_manual(values = cat_pal(nlevels(d[[groupVar]])))
  if (useColor) p <- p + scale_colour_viridis_c(option = cmap %||% "viridis")
  if (useSize)  p <- p + scale_size_continuous(range = c(1.5, 9))
  p
}
