# fct_stats.R - statistical tests (replaces runStats switch)
# Every test returns list(title, text, table = data.frame or NULL)

.get_y <- function(df, yVars) {
  y1 <- if (length(yVars)) yVars[1] else NULL
  if (is_none(y1) || !y1 %in% names(df)) user_stop("Select a Y variable")
  if (!is.numeric(df[[y1]])) user_stop("Y1 ('", y1, "') must be numeric")
  y1
}

.get_xnum <- function(df, xVars) {
  x1 <- if (length(xVars)) xVars[1] else NULL
  if (is_none(x1) || !x1 %in% names(df)) user_stop("Select an X variable")
  if (!is.numeric(df[[x1]])) user_stop("X1 ('", x1, "') must be numeric for correlation")
  x1
}

.group_data <- function(df, y1, groupVar, control = NULL) {
  if (is_none(groupVar) || !groupVar %in% names(df)) user_stop("Select a 'Group By' variable")
  d <- data.frame(y = df[[y1]], g = factor(df[[groupVar]]))
  d <- d[stats::complete.cases(d), , drop = FALSE]
  d$g <- droplevels(d$g)
  if (!is_none(control) && control %in% levels(d$g)) d$g <- stats::relevel(d$g, ref = control)
  if (nlevels(d$g) < 2) user_stop("Need at least 2 groups with data")
  d
}

.n_summary <- function(d) {
  s <- tapply(d$y, d$g, function(v) sprintf("n=%d, mean=%s, SD=%s", length(v), fmt_num(mean(v)), fmt_num(stats::sd(v))))
  paste(sprintf("  %s: %s", names(s), s), collapse = "\n")
}

run_stat_test <- function(df, test, xVars, yVars, groupVar, controlGroup) {
  if (is.null(test) || test == "None") return(list(title = "No test", text = "Choose a test first.", table = NULL))
  tryCatch({
    y1 <- .get_y(df, yVars)

    if (test %in% c("Pearson Correlation (X1 vs Y1)", "Spearman Correlation (X1 vs Y1)")) {
      x1 <- .get_xnum(df, xVars)
      ok <- stats::complete.cases(df[[x1]], df[[y1]])
      if (sum(ok) < 3) user_stop("Need at least 3 complete X/Y pairs")
      if (grepl("Pearson", test)) {
        ct <- stats::cor.test(df[[x1]][ok], df[[y1]][ok], method = "pearson")
        txt <- sprintf("Pearson correlation: %s vs %s\nn = %d\nr = %.4f\n95%% CI [%.3f, %.3f]\np = %.4g",
                       x1, y1, sum(ok), ct$estimate, ct$conf.int[1], ct$conf.int[2], ct$p.value)
      } else {
        ct <- suppressWarnings(stats::cor.test(df[[x1]][ok], df[[y1]][ok], method = "spearman", exact = FALSE))
        txt <- sprintf("Spearman correlation: %s vs %s\nn = %d\nrho = %.4f\np = %.4g",
                       x1, y1, sum(ok), ct$estimate, ct$p.value)
      }
      return(list(title = sub(" \\(.*", "", test), text = txt, table = NULL))
    }

    if (test %in% c("Welch t-test (Group, 2 levels, Y1)", "Mann-Whitney (Group, 2 levels, Y1)")) {
      d <- .group_data(df, y1, groupVar, controlGroup)
      if (nlevels(d$g) != 2) user_stop("This test needs exactly 2 groups (found ", nlevels(d$g), ")")
      lv <- levels(d$g)
      a <- d$y[d$g == lv[2]]; b <- d$y[d$g == lv[1]]
      if (grepl("Welch", test)) {
        tt <- stats::t.test(a, b)
        sp <- sqrt(((length(a) - 1) * stats::var(a) + (length(b) - 1) * stats::var(b)) / (length(a) + length(b) - 2))
        txt <- sprintf("Welch two-sample t-test (%s vs %s)\nt = %.3f, df = %.1f\np = %.4g\nMean difference = %s, 95%% CI [%s, %s]\nCohen's d = %.3f\n\n%s",
                       lv[2], lv[1], tt$statistic, tt$parameter, tt$p.value,
                       fmt_num(mean(a) - mean(b)), fmt_num(tt$conf.int[1]), fmt_num(tt$conf.int[2]),
                       (mean(a) - mean(b)) / sp, .n_summary(d))
      } else {
        wt <- stats::wilcox.test(a, b, exact = FALSE)
        txt <- sprintf("Mann-Whitney U (%s vs %s)\nW = %.1f\np = %.4g\n\n%s",
                       lv[2], lv[1], wt$statistic, wt$p.value, .n_summary(d))
      }
      return(list(title = sub(" \\(.*", "", test), text = txt, table = NULL))
    }

    if (test %in% c("One-way ANOVA (Group, Y1)", "Tukey HSD (Group, Y1)")) {
      d <- .group_data(df, y1, groupVar, controlGroup)
      fit <- stats::aov(y ~ g, data = d)
      sm <- summary(fit)[[1]]
      eta2 <- sm[1, "Sum Sq"] / sum(sm[, "Sum Sq"])
      res <- stats::residuals(fit)
      shap <- if (length(res) >= 3 && length(res) <= 5000) stats::shapiro.test(res)$p.value else NA
      bart <- tryCatch(stats::bartlett.test(y ~ g, data = d)$p.value, error = function(e) NA)
      checks <- sprintf("Assumption checks:\n  Shapiro-Wilk on residuals p = %s%s\n  Bartlett equal variance p = %s%s",
                        fmt_num(shap), if (!is.na(shap) && shap < 0.05) "  (non-normal: consider Kruskal-Wallis)" else "",
                        fmt_num(bart), if (!is.na(bart) && bart < 0.05) "  (unequal variances)" else "")
      head_txt <- sprintf("One-way ANOVA: %s by %s\nF(%d, %d) = %.3f\np = %.4g\neta squared = %.3f\n\n%s\n\n%s",
                          y1, groupVar, sm[1, "Df"], sm[2, "Df"], sm[1, "F value"], sm[1, "Pr(>F)"],
                          eta2, checks, .n_summary(d))
      if (grepl("Tukey", test)) {
        tk <- as.data.frame(stats::TukeyHSD(fit)$g)
        tk <- data.frame(Comparison = rownames(tk), Difference = tk$diff, CI_low = tk$lwr,
                         CI_high = tk$upr, p_adj = tk$`p adj`, Signif = p_to_stars(tk$`p adj`))
        return(list(title = "Tukey HSD", text = head_txt, table = tk))
      }
      return(list(title = "One-way ANOVA", text = head_txt, table = NULL))
    }

    if (test == "Dunnett vs Control (Group, Y1)") {
      if (!HAS_MULTCOMP) user_stop("Install the 'multcomp' package for Dunnett: install.packages('multcomp')")
      if (is_none(controlGroup)) user_stop("Choose a Control group in the Variables panel")
      d <- .group_data(df, y1, groupVar, controlGroup)
      fit <- stats::aov(y ~ g, data = d)
      s <- summary(multcomp::glht(fit, linfct = multcomp::mcp(g = "Dunnett")))
      tab <- data.frame(Comparison = names(s$test$coefficients),
                        Estimate = unname(s$test$coefficients),
                        SE = unname(s$test$sigma), t = unname(s$test$tstat),
                        p_adj = unname(s$test$pvalues),
                        Signif = p_to_stars(unname(s$test$pvalues)))
      return(list(title = paste0("Dunnett vs ", levels(d$g)[1]),
                  text = paste0("Dunnett many-to-one comparisons, control = ", levels(d$g)[1], "\n\n", .n_summary(d)),
                  table = tab))
    }

    if (grepl("^Kruskal", test)) {
      d <- .group_data(df, y1, groupVar, controlGroup)
      kw <- stats::kruskal.test(y ~ g, data = d)
      pw <- stats::pairwise.wilcox.test(d$y, d$g, p.adjust.method = "BH", exact = FALSE)
      pm <- as.data.frame(as.table(pw$p.value))
      pm <- pm[!is.na(pm$Freq), ]
      tab <- data.frame(Comparison = paste(pm$Var1, "vs", pm$Var2), p_adj_BH = pm$Freq,
                        Signif = p_to_stars(pm$Freq))
      txt <- sprintf("Kruskal-Wallis: chi-squared = %.3f, df = %d\np = %.4g\n\nPairwise Wilcoxon, BH-adjusted (table below)\n\n%s",
                     kw$statistic, kw$parameter, kw$p.value, .n_summary(d))
      return(list(title = "Kruskal-Wallis", text = txt, table = tab))
    }

    if (test == "Chi-Square (X1 vs Group) [categorical]") {
      x1 <- if (length(xVars)) xVars[1] else NULL
      if (is_none(x1) || is_none(groupVar)) user_stop("Need X1 and Group By (both categorical)")
      tbl <- table(df[[x1]], df[[groupVar]])
      ct <- suppressWarnings(stats::chisq.test(tbl))
      warn <- if (any(ct$expected < 5)) "\nWarning: some expected counts < 5. Fisher's exact test may be more appropriate." else ""
      fisher <- if (any(ct$expected < 5)) {
        fp <- tryCatch(stats::fisher.test(tbl, simulate.p.value = TRUE)$p.value, error = function(e) NA)
        sprintf("\nFisher's exact (simulated) p = %s", fmt_num(fp))
      } else ""
      return(list(title = "Chi-Square",
                  text = sprintf("Chi-squared = %.3f, df = %d\np = %.4g%s%s", ct$statistic, ct$parameter, ct$p.value, warn, fisher),
                  table = as.data.frame.matrix(tbl)))
    }

    if (test == "Correlation Matrix (Y vars)") {
      yv <- keep_numeric(df, yVars)
      if (length(yv) < 2) user_stop("Select at least 2 numeric Y variables")
      cm <- stats::cor(df[, yv, drop = FALSE], use = "pairwise.complete.obs")
      tab <- data.frame(Variable = rownames(cm), round(cm, 3), check.names = FALSE)
      return(list(title = "Correlation Matrix (Pearson, pairwise complete)",
                  text = paste(utils::capture.output(print(round(cm, 3))), collapse = "\n"),
                  table = tab))
    }

    user_stop("Unknown test: ", test)
  }, error = function(e) list(title = "Could not run test", text = conditionMessage(e), table = NULL))
}
