# plot_bar.R - mean bar + error bar + individual points + optional stars
# Returns list(plot, table = per-group summary)

plot_bar <- function(df, yVars, group, errType = "SEM", showPoints = TRUE, sigTest = "None",
                     control = NULL, base_size = 12, maxTiles = 9) {
  ys <- head(keep_numeric(df, yVars), maxTiles)
  if (!length(ys)) user_stop("Select at least one numeric Y variable")
  long <- build_group_long(df, ys, group, control)
  if (!nrow(long)) user_stop("No numeric values to plot")
  summ <- summarise_groups(long, errType)

  p <- ggplot(summ, aes(x = .g, y = mean, fill = .g)) +
    geom_col(width = 0.65, colour = "black", linewidth = 0.3, alpha = 0.85)
  if (errType != "None") {
    p <- p + geom_errorbar(aes(ymin = mean - err, ymax = mean + err), width = 0.2, linewidth = 0.4)
  }
  if (isTRUE(showPoints)) {
    p <- p + geom_point(data = long, aes(x = .g, y = .y), inherit.aes = FALSE,
                        position = position_jitter(width = 0.12, height = 0, seed = 1),
                        size = 1.6, alpha = 0.8)
  }
  p <- p + facet_if_multi(length(ys)) +
    scale_fill_manual(values = cat_pal(nlevels(summ$.g)), guide = "none") +
    labs(x = if (is_none(group)) NULL else pretty_label(group),
         y = if (length(ys) == 1) pretty_label(ys) else "Value",
         caption = if (errType == "None") "Bars: mean" else paste0("Bars: mean +/- ", errType)) +
    theme_pub(base_size)
  p <- add_sig_layer(p, long, summ, group, sigTest, control, base_size)

  tab <- summ %>%
    transmute(Variable = .variable, Group = .g, n, Mean = signif(mean, 4), SD = signif(sd, 4),
              SEM = signif(sem, 4), CI95 = signif(ci95, 4))
  list(plot = p, table = as.data.frame(tab))
}
