# 01_constants.R - dropdown choices (replaces MATLAB setupControls lists)

PLOT_SCATTER <- "Scatter (4D) [single X,Y]"
PLOT_MULTI_X <- "Multi-X Scatter [Y fixed]"
PLOT_MULTI_Y <- "Multi-Y Scatter [X fixed]"
PLOT_LINE    <- "Line (Time Series) [X fixed]"
PLOT_BAR     <- "Bar Chart (mean + points)"
PLOT_BOX     <- "Box Plot (+ points)"
PLOT_HEATMAP <- "Heatmap [Y vars]"
PLOT_IC50    <- "IC50 Fit (4PL) [X = dose, Y = response]"

plotTypeChoices <- c(PLOT_SCATTER, PLOT_MULTI_X, PLOT_MULTI_Y, PLOT_LINE,
                     PLOT_BAR, PLOT_BOX, PLOT_HEATMAP, PLOT_IC50)

# Plot types that do not need an X variable
PLOTS_NO_X <- c(PLOT_BAR, PLOT_BOX, PLOT_HEATMAP)

normChoices      <- c("None", "Z-score (Y)", "Min-Max (Y)", "Log2 (Y+1)")
multiPlotChoices <- c("Tiled", "Overlay")
errorChoices     <- c("SEM", "SD", "95% CI", "None")
sigChoices       <- c("None", "Welch t-test", "Mann-Whitney")

exportChoices <- c("PNG (raster)" = "png",
                   "TIFF (LZW, raster)" = "tiff",
                   "PDF (vector)" = "pdf")

# Continuous colour maps (all colour-blind friendly viridis family)
cmapChoices <- c("viridis", "plasma", "magma", "inferno", "cividis",
                 "turbo", "mako", "rocket")

statsChoices <- c(
  "None",
  "Pearson Correlation (X1 vs Y1)",
  "Spearman Correlation (X1 vs Y1)",
  "Welch t-test (Group, 2 levels, Y1)",
  "Mann-Whitney (Group, 2 levels, Y1)",
  "One-way ANOVA (Group, Y1)",
  "Tukey HSD (Group, Y1)",
  "Dunnett vs Control (Group, Y1)",
  "Kruskal-Wallis + Dunn-style pairwise (Group, Y1)",
  "Chi-Square (X1 vs Group) [categorical]",
  "Correlation Matrix (Y vars)"
)

# Okabe-Ito colour-blind safe categorical palette
OKABE_ITO <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7", "#999999", "#000000")
