# plot_heatmap.R - values are shown AFTER the Preprocessing normalisation
# (no second normalisation here, which the old version did)

plot_heatmap <- function(df, yVars, cmap = "viridis", base_size = 12) {
  ys <- keep_numeric(df, yVars)
  if (!length(ys)) user_stop("Select one or more numeric Y variables")
  if (nrow(df) > 5000) user_stop("Heatmap limited to 5000 rows; use Select Range to subset")
  long <- do.call(rbind, lapply(ys, function(v) {
    data.frame(.variable = pretty_label(v), .row = seq_len(nrow(df)), .value = as.numeric(df[[v]]))
  }))
  long$.variable <- factor(long$.variable, levels = pretty_label(ys))
  ggplot(long, aes(.variable, .row, fill = .value)) +
    geom_tile() +
    scale_fill_viridis_c(option = cmap %||% "viridis", na.value = "grey85", name = "Value") +
    scale_y_reverse(expand = c(0, 0)) +
    scale_x_discrete(expand = c(0, 0)) +
    labs(x = NULL, y = "Row") +
    theme_minimal(base_size = base_size) +
    theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45, hjust = 1))
}
