# Manuscript update notes for the annual CAPN run

This note records model outputs and manuscript sections to revisit. **The manuscript `CAPN-US-Longline_REV5.docx` has not been edited.** The new estimates are conditional on the annual model and its assumptions; do not paste them in as final until the geographic allocation and parameter choices have been reviewed.

## Current annual model results

The R script now generates separate 2010–2018 CAPN curves, one for each year's economic inputs. It uses the same fitted biological growth law across years and evaluates each curve at that year's assessment stock and at fitted logistic MSY. This follows the paper's annual-curve organization while replacing the old repeated/mixed-vintage stock series.

- Shadow price at annual assessed stock: approximately **$215–$324 per metric tonne**.
- Capitalization at annual assessed stock: approximately **$124–$186 million**.
- 2018 shadow price at assessed stock: approximately **$304/tonne**; capitalization: approximately **$173 million**.
- 2018 shadow price at fitted MSY (about 145,158 tonnes): approximately **$1,068/tonne**.
- Shared fitted growth parameters: `r ≈ 0.4816/year`, `K ≈ 1.206 million tonnes`; fitted MSY `rK/4 ≈ 145,158 tonnes/year`.

These results differ materially from the manuscript's prior reported price range ($8,165–$10,827/tonne) and multi-billion-dollar capitalization. The model definition and inputs changed, so this is not a simple data refresh. Reconcile why the price levels differ before presenting the new series as a revised finding.

## Geographic and economic assumptions to review

The supplied NOAA-economist aggregate CSV contains year, species, sector, pounds sold, price, trips, and variable cost for 2010–2018. It does not include fishing area. The only geographic split currently in the repo is 2010. The R script therefore:

1. Applies the 2010 WCPO deep-set retained-catch / all-area deep-set bigeye sold ratio to each year's sold bigeye tonnage as a WCPO catch proxy.
2. Applies the 2010 all-gear WCPO/(WCPO+EPO) retained-catch share (72.51%) to each year's deep-set trips as a WCPO trip-equivalent proxy.
3. Allocates each year's deep-set variable trip cost to bigeye in proportion to bigeye's share of total deep-set pounds sold.

The catch and effort shares are proxies, not observed annual WCPO allocations. Hawaii longline trips can cross WCPO, EPO, and Hawaii EEZ boundaries. Seek annual geographic catches/sets if possible, or preserve these assumptions and show sensitivity analyses prominently. The model also treats all-area market prices and average species-allocation costs as representative of the WCPO contribution.

## Manuscript sections and figures to revisit

- **Abstract:** Replace the reported annual asset-price range, wealth change, and management interpretation only after reviewing the new series and its assumptions.
- **Introduction:** Resolve conflicting 2018 price and wealth numbers currently reported in separate paragraphs; align the stated study scope with a Hawaii-fleet contribution to WCPO stock valuation.
- **Materials and Methods:** Update the data years and sources, growth fit, `r`/`K`/MSY derivation, harvest and other-fleet equations, annual catchability calibration, geographic allocation, effort response, cost allocation, and the interpretation of annual snapshots. The model now uses the manuscript's 3% discount rate. Ensure the text matches the actual R script rather than the old Python implementation.
- **Table 1 (annual data):** Replace the repeated 2010–2012 and 2013–2016 biomass/MSY values and the 2018 value whose source/stock definition was previously flagged. Rebuild from `results/hawaii_capn_annual/annual_valuation.csv` and identify assessment biomass, fitted MSY, annual economic observations, and proxy-derived quantities separately.
- **Results:** Replace all prior annual price and capitalization values, including the inconsistent 2018 price statements ($9,963.28 versus $9,463.58) and the $5.43–$6.87 billion / $65 million change claims. Distinguish shadow price, capitalization (`p × stock`), and value function `V(stock)`.
- **Figures 1–5:** The updated counterparts are `figure1_2018_price_curve.pdf`, `figure2_capitalization_by_year.pdf`, `figure3_annual_prices.pdf`, `figure4_annual_price_curves.pdf`, and `figure5_2018_stock_sensitivity.pdf` in `results/hawaii_capn_annual/`. Review annotation terminology, fitted-MSY definition, and units when placing them.
- **Discussion and conclusion:** Reassess claims that stable asset value demonstrates effective/sustainable management. Annual prices reflect a stationary snapshot model with proxy area allocation and common biology; stability alone does not identify a management effect.
- **Limitations and supplement:** Document the 2010 geographic proxy carried over all years, all-area cost/price assumptions, annual snapshot interpretation, fitted-logistic residuals, and uncertain behavioral elasticities. Reconcile supplemental equations with `alpha = 1`, fixed Hawaii effort (`gamma = 0`), and other-fleet catch proportional to stock (`beta = 1`).
- **Figures/table cross-references and bibliography:** Renumber or relabel as needed after replacing figures, ensure every cited data source supports the revised series, and remove or qualify unsupported claims about parameters coming from the literature.

## Files produced

- `results/hawaii_capn_annual/annual_inputs.csv`
- `results/hawaii_capn_annual/annual_valuation.csv`
- `results/hawaii_capn_annual/annual_price_curves.csv`
- `results/hawaii_capn_annual/stock_sensitivity_2018.csv`
- Five figure PDFs and growth diagnostics in the same directory

The technical choices and source interpretations are documented in [`hawaii-capn-model.md`](hawaii-capn-model.md). This checklist is not manuscript text.
