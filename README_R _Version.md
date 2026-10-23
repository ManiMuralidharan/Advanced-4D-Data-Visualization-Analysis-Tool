#Advanced-4D-Data-Visualization-Analysis-Tool

Shiny port of the MATLAB "Scientist Data Suite": import Excel/CSV, preprocess, plot
(scatter 4D, multi-X/Y, time series, bar, box, heatmap, IC50 4PL), run statistics and
export publication figures.

## Run

```r
setwd("path/to/ScientistDataSuite")
source("install_packages.R")   # first time only
shiny::runApp()
```

Click **Load demo data** to try every plot type immediately.

## Folder layout

```
ScientistDataSuite/
├── app.R                  # loads R/ in fixed order, starts the app
├── install_packages.R
├── www/custom.css
└── R/
    ├── 00_packages.R      # package checks + library() calls (loads first)
    ├── 01_constants.R     # dropdown choices, palettes
    ├── utils.R            # small helpers, publication theme
    ├── fct_data.R         # import, range, NA, outlier, normalisation, demo data
    ├── fct_stats.R        # all statistical tests
    ├── fct_ic50.R         # 4PL fitting (drc with nls fallback), per-group fits
    ├── fct_plotting.R     # shared plot helpers, significance stars, dispatcher
    ├── plots/             # one file per plot type, all return ggplot
    ├── mod_*.R            # Shiny modules (UI + server pairs)
    ├── app_ui.R
    └── app_server.R
```

## Data flow

file -> sheet -> range (non-destructive) -> drop NA -> **base data** (statistics)
-> outlier filter -> normalisation -> **processed data** (plots).

Each plot is built once as a ggplot: shown on screen via plotly, exported via ggsave,
so the exported figure always matches the screen.

## Fixes versus the single-file version

- Overlay plots showed only the last variable (lazy `~get()` in loops) - fixed
- `fit_ic50` misaligned x and y - fixed
- Outlier filter was on by default (3 SD) - now off; removed rows are reported
- Statistics silently used normalised data - now raw by default, with an option
- Range crop overwrote the sheet - now non-destructive with Reset
- PNG/TIFF/PDF export usually wrote HTML - now real files at chosen size and DPI
- Heatmap normalised twice - fixed
- Deprecated `aes_string()` replaced; column names with spaces work

## Added

- Bar charts with individual points, SD/SEM/95% CI, stars vs control (BH-adjusted)
- Box plots with points; time series averages replicates with error bars
- IC50 per group with 95% CI, Hill, R2 and a downloadable parameter table
- Welch t-test, Tukey HSD, Kruskal-Wallis with pairwise tests, assumption checks,
  effect sizes, Fisher fallback for chi-square
- Summary table and processed-data tabs, CSV downloads, demo dataset
