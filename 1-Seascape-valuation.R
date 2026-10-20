#!/usr/bin/env Rscript

# Annual Hawaii bigeye natural capital asset price curves, 2010-2018.
# Each year's observed economic program is held stationary to recover that
# year's conditional price curve, following the annual snapshot approach in
# the manuscript. See doc/annual-model-update-notes.md for assumptions.

if (!requireNamespace("capn", quietly = TRUE)) {
  stop("Install the CRAN package 'capn' before running this script.")
}

args <- commandArgs(trailingOnly = TRUE)
output_dir <- if (length(args) > 0L) args[[1L]] else "results/hawaii_capn_annual"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

lb_per_mt <- 2204.62262185
years <- 2010:2018
assessment <- 2026L
growth_start_year <- 1980L
alpha <- 1.0
gamma_hawaii <- 0.0
beta_other <- 1.0
delta <- 0.03
polynomial_terms <- 50L
node_count <- 500L

costs <- read.csv("data/cost_per_pound.csv", stringsAsFactors = FALSE)
assessment_data <- read.csv("data/wcpfc_bigeye_2026_diagnostic_annual.csv",
                            stringsAsFactors = FALSE)
geography <- read.csv("data/hawaii_bigeye_2010_geography.csv",
                      stringsAsFactors = FALSE)
assessment_data <- assessment_data[order(assessment_data$year), ]
reference_years <- assessment_data[assessment_data$year %in% years, ]
geography_2010 <- subset(geography, year == 2010L)

if (nrow(reference_years) != length(years) ||
    !all(reference_years$year == years) || nrow(geography_2010) != 1L) {
  stop("Expected annual stock records for 2010-2018 and one 2010 geography record.")
}

# Reduced-form logistic growth fit to the assessment series. This common
# biological law is held fixed across the nine annual economic snapshots.
growth_data <- assessment_data[-nrow(assessment_data),
                               c("year", "tb", "catch")]
growth_data$next_year <- assessment_data$year[-1L]
growth_data$next_biomass_mt <- assessment_data$tb[-1L]
growth_data$observed_growth_mt <- growth_data$next_biomass_mt -
  growth_data$tb + growth_data$catch
growth_window <- subset(growth_data, year >= growth_start_year)
growth_fit <- lm(observed_growth_mt ~ 0 + tb + I(tb^2), data = growth_window)
growth_coef <- coef(growth_fit)
r_effective <- unname(growth_coef[[1L]])
K_proxy <- -r_effective / unname(growth_coef[[2L]])
if (!is.finite(r_effective) || !is.finite(K_proxy) || r_effective <= 0 ||
    K_proxy <= max(reference_years$tb)) {
  stop("The common fitted logistic growth parameters are invalid for 2010-2018.")
}
growth_window$fitted_growth_mt <- as.numeric(predict(growth_fit))
growth_window$residual_mt <- growth_window$observed_growth_mt -
  growth_window$fitted_growth_mt
growth_fit_record <- data.frame(
  first_year = min(growth_window$year),
  last_year = max(growth_window$year),
  transitions = nrow(growth_window), r = r_effective, K_mt = K_proxy,
  peak_growth_mt_per_year = r_effective * K_proxy / 4,
  rmse_mt_per_year = sqrt(mean(growth_window$residual_mt^2)))
write.csv(growth_fit_record, file.path(output_dir, "growth_fit.csv"),
          row.names = FALSE)
write.csv(growth_window, file.path(output_dir, "growth_observations.csv"),
          row.names = FALSE)
grDevices::pdf(file.path(output_dir, "growth_diagnostics.pdf"),
               width = 8, height = 7)
old_par <- graphics::par(mfrow = c(2, 1), mar = c(4, 5, 3, 1))
graphics::plot(growth_window$year, growth_window$observed_growth_mt / 1000,
               pch = 16, cex = 0.65,
               xlab = "Year", ylab = "Implied growth (thousand tonnes)",
               main = sprintf("%d-%d assessment-based logistic growth fit",
                              min(growth_window$year),
                              max(growth_window$next_year)))
graphics::lines(growth_window$year,
                growth_window$fitted_growth_mt / 1000,
                lwd = 2, col = "steelblue4")
graphics::legend("bottomright", c("Assessment-implied", "Logistic fit"),
                 pch = c(16, NA), lty = c(NA, 1),
                 col = c("black", "steelblue4"), bty = "n")
graphics::plot(growth_window$year, growth_window$residual_mt / 1000,
               type = "h", xlab = "Year",
               ylab = "Growth residual (thousand tonnes)")
graphics::abline(h = 0, col = "grey40")
graphics::par(old_par)
invisible(grDevices::dev.off())

# The only geographic split available is 2010. Apply the 2010 deep-set
# retained/sold ratio to each year's sold bigeye as an explicit proxy, and
# use the all-gear 2010 WCPO catch share for trip-equivalent effort.
deep_2010 <- subset(costs, year == 2010L & sector == "D")
bigeye_2010 <- subset(deep_2010, species == "bigeye")
if (nrow(bigeye_2010) != 1L ||
    !is.finite(bigeye_2010$pounds_sold) || bigeye_2010$pounds_sold <= 0) {
  stop("Cannot establish the 2010 deep-set bigeye geography proxy.")
}
wcpo_catch_share <- geography_2010$wcpo_retained_mt /
  (geography_2010$wcpo_retained_mt + geography_2010$epo_retained_mt)
wcpo_retained_to_sold <- geography_2010$wcpo_deep_set_retained_mt /
  (bigeye_2010$pounds_sold / lb_per_mt)

economy <- lapply(years, function(y) {
  deep <- subset(costs, year == y & sector == "D")
  bigeye <- subset(deep, species == "bigeye")
  stock <- subset(reference_years, year == y)
  if (nrow(bigeye) != 1L || nrow(stock) != 1L ||
      any(!is.finite(c(bigeye$pounds_sold, bigeye$price_per_pound,
                       bigeye$varcost_per_trip, bigeye$trips,
                       stock$tb, stock$catch))) ||
      bigeye$pounds_sold <= 0 || bigeye$trips <= 0) {
    stop(sprintf("Missing or invalid annual economic/stock data for %d.", y))
  }
  all_species_lb <- sum(deep$pounds_sold)
  list(year = y, stock_mt = stock$tb, wcpo_total_catch_mt = stock$catch,
       bigeye_sold_mt = bigeye$pounds_sold / lb_per_mt,
       hawaii_wcpo_catch_mt = bigeye$pounds_sold / lb_per_mt *
         wcpo_retained_to_sold,
       price_usd_per_mt = bigeye$price_per_pound * lb_per_mt,
       deep_trips = bigeye$trips,
       wcpo_effort_share = wcpo_catch_share,
       wcpo_trip_equivalents = bigeye$trips * wcpo_catch_share,
       cost_per_bigeye_trip_usd = bigeye$varcost_per_trip *
         bigeye$pounds_sold / all_species_lb,
       all_area_bigeye_share_deep_set_pounds = bigeye$pounds_sold /
         all_species_lb)
})
names(economy) <- as.character(years)

run_capn <- function(econ, technology = alpha, gamma = gamma_hawaii,
                     beta = beta_other, discount = delta,
                     cost_multiplier = 1, growth_r = r_effective,
                     growth_K = K_proxy) {
  stock_ref <- econ$stock_mt
  hawaii_catch_ref <- econ$hawaii_wcpo_catch_mt
  all_fleet_catch <- econ$wcpo_total_catch_mt
  other_catch_ref <- all_fleet_catch - hawaii_catch_ref
  reference_effort <- econ$wcpo_trip_equivalents
  if (stock_ref <= 0 || growth_K <= stock_ref || reference_effort <= 0 ||
      hawaii_catch_ref <= 0 || other_catch_ref <= 0 ||
      !is.finite(econ$price_usd_per_mt) ||
      !is.finite(econ$cost_per_bigeye_trip_usd)) {
    stop(sprintf("Invalid calibrated inputs for %d.", econ$year))
  }
  lower <- 0.01 * growth_K
  upper <- 1.01 * growth_K
  nodes <- capn::chebnodegen(node_count, lower, upper)
  catchability <- hawaii_catch_ref /
    (stock_ref * reference_effort^technology)
  effort <- function(s) reference_effort * (s / stock_ref)^gamma
  hawaii_harvest <- function(s) catchability * s * effort(s)^technology
  other_harvest <- function(s) other_catch_ref * (s / stock_ref)^beta
  profit <- function(s) econ$price_usd_per_mt * hawaii_harvest(s) -
    cost_multiplier * econ$cost_per_bigeye_trip_usd * effort(s)
  stock_change <- function(s) growth_r * s * (1 - s / growth_K) -
    hawaii_harvest(s) - other_harvest(s)

  simulation_data <- cbind(stock = nodes, sdot = stock_change(nodes),
                           benefit = profit(nodes))
  space <- capn::aproxdef(polynomial_terms, lower, upper, discount)
  coefficients <- if ("sdata" %in% names(formals(capn::vaprox))) {
    capn::vaprox(space, simulation_data)
  } else {
    capn::vaprox(space, nodes, simulation_data[, "sdot"],
                 simulation_data[, "benefit"])
  }
  simulation <- capn::vsim(coefficients, matrix(nodes, ncol = 1L),
                           profit(nodes))
  if (length(simulation$shadowp) != length(nodes) ||
      any(!is.finite(simulation$shadowp))) {
    stop(sprintf("capn returned invalid prices for %d.", econ$year))
  }
  result <- data.frame(
    year = econ$year, stock_mt = as.numeric(nodes),
    shadow_price_usd_per_mt = as.numeric(simulation$shadowp),
    value_function_usd = as.numeric(simulation$vfun),
    hawaii_harvest_mt_per_year = hawaii_harvest(nodes),
    other_harvest_mt_per_year = other_harvest(nodes),
    stock_change_mt_per_year = stock_change(nodes),
    hawaii_profit_usd_per_year = profit(nodes))
  result$bellman_residual_usd_per_year <- discount * result$value_function_usd -
    result$stock_change_mt_per_year * result$shadow_price_usd_per_mt -
    result$hawaii_profit_usd_per_year
  result[order(result$stock_mt), ]
}

curves <- lapply(economy, run_capn)
curves_all <- do.call(rbind, curves)
write.csv(curves_all, file.path(output_dir, "annual_price_curves.csv"),
          row.names = FALSE)

annual_summary <- do.call(rbind, lapply(economy, function(econ) {
  curve <- curves[[as.character(econ$year)]]
  price_at_stock <- approx(curve$stock_mt, curve$shadow_price_usd_per_mt,
                           xout = econ$stock_mt)$y
  value_at_stock <- approx(curve$stock_mt, curve$value_function_usd,
                           xout = econ$stock_mt)$y
  price_at_msy <- approx(curve$stock_mt, curve$shadow_price_usd_per_mt,
                         xout = r_effective * K_proxy / 4)$y
  data.frame(
    year = econ$year, stock_mt = econ$stock_mt,
    msy_mt_per_year = r_effective * K_proxy / 4,
    price_at_stock_usd_per_mt = price_at_stock,
    price_at_msy_usd_per_mt = price_at_msy,
    capitalization_at_stock_usd = price_at_stock * econ$stock_mt,
    value_function_at_stock_usd = value_at_stock,
    wcpo_total_catch_mt = econ$wcpo_total_catch_mt,
    hawaii_wcpo_catch_proxy_mt = econ$hawaii_wcpo_catch_mt,
    hawaii_all_area_sold_mt = econ$bigeye_sold_mt,
    market_price_usd_per_mt = econ$price_usd_per_mt,
    deep_trips = econ$deep_trips,
    wcpo_effort_share_proxy = econ$wcpo_effort_share,
    wcpo_trip_equivalents = econ$wcpo_trip_equivalents,
    allocated_bigeye_cost_per_trip_usd = econ$cost_per_bigeye_trip_usd,
    annual_profit_at_reference_usd = econ$price_usd_per_mt *
      econ$hawaii_wcpo_catch_mt - econ$cost_per_bigeye_trip_usd *
      econ$wcpo_trip_equivalents,
    bellman_rmse_usd_per_year = sqrt(mean(
      curve$bellman_residual_usd_per_year^2)),
    r_effective = r_effective, K_proxy_mt = K_proxy,
    alpha = alpha, gamma_hawaii = gamma_hawaii, beta_other = beta_other,
    discount_rate = delta)
}))
write.csv(annual_summary, file.path(output_dir, "annual_valuation.csv"),
          row.names = FALSE)
write.csv(do.call(rbind, economy),
          file.path(output_dir, "annual_inputs.csv"), row.names = FALSE)

# The paper's five figure types: a representative 2018 curve, capitalization
# over time, two annual reference-price series, annual curves, and 2018 stock
# sensitivity. All are vector PDFs suitable for review and manuscript layout.
save_pdf <- function(path, width, height, draw) {
  grDevices::pdf(path, width = width, height = height, onefile = TRUE)
  on.exit(grDevices::dev.off())
  draw()
}
fmt_dollar <- function(x) paste0("$", format(round(x), big.mark = ",", nsmall = 0))

curve2018 <- curves[["2018"]]
row2018 <- subset(annual_summary, year == 2018L)
save_pdf(file.path(output_dir, "figure1_2018_price_curve.pdf"), 9, 6, function() {
  plot(curve2018$stock_mt, curve2018$shadow_price_usd_per_mt, type = "l",
       lwd = 2, xlab = "WCPO bigeye total biomass (metric tonnes)",
       ylab = "Natural capital asset price (USD/tonne)",
       main = "2018 Hawaii bigeye asset price curve")
  points(row2018$msy_mt_per_year,
         row2018$price_at_msy_usd_per_mt, pch = 19, col = "steelblue4")
  points(row2018$stock_mt, row2018$price_at_stock_usd_per_mt,
         pch = 17, col = "firebrick3")
  abline(v = c(row2018$msy_mt_per_year, row2018$stock_mt),
         lty = 3, col = c("steelblue4", "firebrick3"))
  legend("topright", c("Price curve", "Price at logistic MSY", "Price at 2018 stock"),
         lty = c(1, NA, NA), pch = c(NA, 19, 17),
         col = c("black", "steelblue4", "firebrick3"), bty = "n")
  mtext(sprintf("MSY %.0f mt: %s/mt | Stock %.0f mt: %s/mt",
                row2018$msy_mt_per_year, fmt_dollar(row2018$price_at_msy_usd_per_mt),
                row2018$stock_mt, fmt_dollar(row2018$price_at_stock_usd_per_mt)),
        side = 3, line = 0.1, cex = 0.8)
})

save_pdf(file.path(output_dir, "figure2_capitalization_by_year.pdf"), 9, 6, function() {
  values <- annual_summary$capitalization_at_stock_usd / 1e9
  bp <- barplot(values, names.arg = annual_summary$year,
                ylab = "Capitalization at annual stock (USD billions)",
                xlab = "Year", col = "steelblue4", border = NA,
                ylim = c(0, max(values) * 1.14))
  text(bp, values, labels = sprintf("$%.2fB", values), pos = 3, cex = 0.8)
})

save_pdf(file.path(output_dir, "figure3_annual_prices.pdf"), 9, 6, function() {
  plot(annual_summary$year, annual_summary$price_at_msy_usd_per_mt,
       type = "o", pch = 16, lty = 1, col = "steelblue4",
       ylim = range(c(annual_summary$price_at_msy_usd_per_mt,
                     annual_summary$price_at_stock_usd_per_mt)),
       xaxt = "n", xlab = "Year", ylab = "Natural capital price (USD/tonne)")
  axis(1, at = years)
  lines(annual_summary$year, annual_summary$price_at_stock_usd_per_mt,
        type = "o", pch = 17, lty = 2, col = "firebrick3")
  legend("topright", c("Price at logistic MSY", "Price at annual stock"),
         col = c("steelblue4", "firebrick3"), pch = c(16, 17),
         lty = c(1, 2), bty = "n")
})

save_pdf(file.path(output_dir, "figure4_annual_price_curves.pdf"), 11, 8, function() {
  old <- par(mfrow = c(3, 3), mar = c(2.2, 2.2, 2.0, 0.8),
             oma = c(3.2, 3.2, 2.5, 0.5))
  on.exit(par(old))
  yrange <- range(curves_all$shadow_price_usd_per_mt, finite = TRUE)
  for (i in seq_along(years)) {
    y <- years[i]
    dat <- curves[[as.character(y)]]
    vals <- subset(annual_summary, year == y)
    plot(dat$stock_mt, dat$shadow_price_usd_per_mt, type = "l", lwd = 1.5,
         xlim = c(0, K_proxy), ylim = yrange,
         xlab = "", ylab = "", main = y, cex.axis = 0.75,
         xaxt = "n", yaxt = "n")
    if (i > 6L) axis(1, cex.axis = 0.7)
    if ((i - 1L) %% 3L == 0L) axis(2, cex.axis = 0.7)
    points(vals$msy_mt_per_year, vals$price_at_msy_usd_per_mt,
           pch = 19, col = "steelblue4")
    points(vals$stock_mt, vals$price_at_stock_usd_per_mt,
           pch = 17, col = "firebrick3")
  }
  mtext("Stock (metric tonnes)", side = 1, outer = TRUE, line = 1.3)
  mtext("Natural capital price (USD/tonne)", side = 2, outer = TRUE, line = 1.3)
  mtext("Annual Hawaii bigeye asset price curves", outer = TRUE,
        side = 3, line = 0.6, cex = 1.1)
})

stock_multipliers <- c(0.5, 0.75, 1, 1.25, 1.5)
curve2018_price <- approxfun(curve2018$stock_mt,
                             curve2018$shadow_price_usd_per_mt, rule = 1)
sensitivity2018 <- data.frame(
  stock_multiplier = stock_multipliers,
  stock_mt = row2018$stock_mt * stock_multipliers)
sensitivity2018$price_usd_per_mt <- curve2018_price(sensitivity2018$stock_mt)
sensitivity2018$capitalization_usd <- sensitivity2018$stock_mt *
  sensitivity2018$price_usd_per_mt
sensitivity2018$change_from_baseline_usd <- sensitivity2018$capitalization_usd -
  sensitivity2018$capitalization_usd[sensitivity2018$stock_multiplier == 1]
sensitivity2018$change_from_baseline_percent <- 100 *
  sensitivity2018$change_from_baseline_usd /
  sensitivity2018$capitalization_usd[sensitivity2018$stock_multiplier == 1]
write.csv(sensitivity2018,
          file.path(output_dir, "stock_sensitivity_2018.csv"), row.names = FALSE)
save_pdf(file.path(output_dir, "figure5_2018_stock_sensitivity.pdf"), 9, 6, function() {
  values <- sensitivity2018$capitalization_usd / 1e9
  bp <- barplot(values,
                names.arg = c("-50%", "-25%", "2018 baseline", "+25%", "+50%"),
                ylab = "Capitalization (USD billions)",
                xlab = "Stock change from 2018 baseline", col = "steelblue4",
                border = NA, ylim = c(0, max(values) * 1.18))
  text(bp, values, labels = sprintf("$%.2fB", values), pos = 3, cex = 0.85)
})

cat(sprintf("Annual CAPN curves saved for %d-%d; 2018 stock price %s/tonne; capitalization %s.\n",
            min(years), max(years),
            fmt_dollar(row2018$price_at_stock_usd_per_mt),
            fmt_dollar(row2018$capitalization_at_stock_usd)))
