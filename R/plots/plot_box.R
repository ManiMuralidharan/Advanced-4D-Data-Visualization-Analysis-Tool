# plot_box.R - box plot + individual points + optional stars

plot_box <- function(df, yVars, group, showPoints = TRUE, sigTest = "None",
                     control = NULL, base_size = 12, maxTiles = 9) {
  ys <- head(keep_numeric(df, yVars), maxTiles)
  if (!length(ys)) user_stop("Select at least one numeric Y variable")
  long <- build_group_long(df, ys, group, control)
  if (!nrow(long)) user_stop("No numeric values to plot")

  p <- ggplot(long, aes(x = .g, y = .y, fill = .g)) +
    geom_boxplot(width = 0.6, alpha = 0.7, outlier.shape = if (isTRUE(showPoints)) NA else 19)
  if (isTRUE(showPoints)) {
    p <- p + geom_point(position = position_jitter(width = 0.12, height = 0, seed = 1),
                        size = 1.6, alpha = 0.8, show.legend = FALSE)
  }
  p <- p + facet_if_multi(length(ys)) +
    scale_fill_manual(values = cat_pal(nlevels(long$.g)), guide = "none") +
    labs(x = if (is_none(group)) NULL else pretty_label(group),
         y = if (length(ys) == 1) pretty_label(ys) else "Value") +
    theme_pub(base_size)
  p <- add_sig_layer(p, long, NULL, group, sigTest, control, base_size)

  tab <- long %>%
    group_by(Variable = .variable, Group = .g) %>%
    summarise(n = dplyr::n(), Median = signif(stats::median(.y), 4),
              Q1 = signif(stats::quantile(.y, 0.25), 4), Q3 = signif(stats::quantile(.y, 0.75), 4),
              .groups = "drop")
  list(plot = p, table = as.data.frame(tab))
}
