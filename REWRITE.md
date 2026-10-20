# Writer's brief: revise the Hawaii bigeye CAPN manuscript

## Purpose and boundary

Use this brief to update `doc/CAPN-US-Longline_REV5.docx` after the annual R analysis has been reviewed. The manuscript has **not** been edited. This file describes what changed, what the annual analysis retains from the prior draft, and which claims and figures need revision. It is not manuscript-ready prose.

Base revisions on `1-Seascape-valuation.R` and the outputs in `results/hawaii_capn_annual/`. The technical assumptions are documented in `doc/hawaii-capn-model.md`. Do not carry forward a number from the earlier Python results or manuscript tables without checking its definition against the current annual output.

## What changed from the previous analysis

The manuscript's intended 2010–2018 annual analysis remains, but the current R run reconstructs the inputs and parameters rather than reusing the old year-specific price curves.

| Component | Previous draft / calculation | Current annual R analysis |
| --- | --- | --- |
| Implementation | Earlier Python/model outputs and prior R figure code. | `capn` in R, using Chebyshev collocation to recover the value and price functions. |
| Years | Nine annual results, 2010–2018. | Still nine annual curves, 2010–2018, with a separate annual economic calibration. |
| Biomass | Draft table repeated biomass for 2010–2012 and 2013–2016 and mixed values/definitions from earlier assessment vintages. | Annual mean total biomass (`tb`) for each year from the Pacific Community 2026 diagnostic output. These are WCPO assessment estimates, not observations. |
| Biological growth | Earlier annual stock/MSY inputs and parameter choices. | One reduced-form logistic growth law fitted to assessment-implied annual growth from 1980–2023. `r = 0.4816/year`, `K = 1,205,670 mt`, and fitted `MSY = rK/4 = 145,158 mt/year`, held common across the annual curves. `K` is a fitted scale, not an official unfished biomass estimate. |
| Hawaii economics | Annual data in the previous draft, with earlier definitions and allocations. | The provided aggregate NOAA-economist CSV is used for each year's deep-set bigeye pounds sold, ex-vessel price, trip count, and variable cost per trip. Data are annual for 2010–2018, broken out by species and sector. |
| WCPO allocation | Earlier model treated the annual catch/effort allocation differently and did not establish a consistent area method. | The user approved carrying 2010 geographic shares forward as the working baseline. The 2010 WCPO retained-to-sold ratio (about 0.7734) proxies WCPO catch in all nine years. The 2010 all-gear WCPO share of WCPO plus EPO retained catch (72.51%) proxies WCPO trip equivalents in all nine years. Neither is an observed annual deep-set area share. |
| Discount rate | Draft methods specify 3%, but earlier R prototype used 2%. | Current R script and regenerated outputs use 3%, matching the manuscript. |
| Harvest and effort responses | Earlier parameterization and manuscript equation. | The annual code uses `H_t(s) = q_t s E_t(s)^alpha`, with `alpha = 1` and fixed effort response `gamma = 0`. It assumes other-fleet catch responds proportionally to stock (`beta = 1`). These are working assumptions; alpha and gamma are not established estimates. |
| Catchability | Earlier annual catchability calculations. | `q_t` is separately calibrated each year to reproduce the proxy Hawaii catch at that year's assessment stock and WCPO trip-equivalent effort. It is a calibration, not an independently estimated catchability coefficient. |
| Costs | Draft table reports annual cost per metric tonne. | Annual deep-set variable trip cost is allocated to bigeye using bigeye's share of all listed deep-set pounds that year. This assumes the catch-weight share is an acceptable proxy for allocating joint trip costs. |
| Figures | Old figures summarize previous parameter and stock inputs. | Five new vector PDFs reproduce the five manuscript figure types using the current annual estimates. See the list below. |

## What remains the same

- The research question remains the annual natural capital asset price of WCPO bigeye tuna associated with Hawaii deep-set longline fishing, conditional on the modeled economic program.
- The conceptual method remains Fenichel and Abbott's accounting-price approach. `capn` approximates the value function over stock, and the price is its stock derivative.
- The analysis still produces annual curves and evaluates prices at annual stock levels and at MSY. It still reports capitalization as price times stock and includes a 2018 stock sensitivity figure.
- The annual window remains 2010–2018, and economic data remain from the aggregate Hawaii fishery data supplied to the user by a NOAA economist.
- The model remains a single-stock WCPO bigeye analysis. It does not estimate broader ecosystem, cultural, recreational, or non-use values.

Clarify that this is an annual **snapshot** analysis, not a simulation of the observed stock and fleet moving through a single time-varying dynamic program. Each year's economic conditions are held stationary within that year's CAPN calculation. The shared biological growth function and parameters are held fixed over all nine annual calculations.

## Current results to use provisionally

The current 3% run reports:

- Shadow price evaluated at each year's assessed stock: about **$215–$324 per metric tonne** over 2010–2018.
- Capitalization at each year's assessed stock: about **$124–$186 million**.
- 2018 shadow price at assessed stock: about **$304 per tonne**; capitalization: about **$173 million**.
- 2018 shadow price at fitted MSY (about 145,158 mt): about **$1,068 per tonne**.

Use the exact, unrounded values in `results/hawaii_capn_annual/annual_valuation.csv` when preparing tables or figure labels. Distinguish these three quantities throughout:

1. `p(s)`: marginal accounting price of one additional tonne of stock.
2. `p(s) * s`: capitalization at a specified stock level.
3. `V(s)`: value function, the discounted value of modeled future Hawaii profit flows under the specified stock dynamics and economic program.

The annual price range is much lower than the draft's stated $8,165–$10,827 per tonne, and the capitalization is much lower than the draft's multi-billion-dollar values. Treat this as a change in model specification and input definitions, not a small update. Explain what each estimate measures and reconcile the old and new definitions before presenting a substantive comparison. Do not imply that either set of estimates is confirmed solely because the code runs.

## Parameter and interpretation issues for the writer

### Alpha and gamma

Keep `alpha = 1` labeled as a provisional Schaefer benchmark, not an empirical estimate. In the `capn` harvest specification, alpha is the harvest elasticity with respect to effort ([CRAN `capn` manual](https://cran.r-project.org/web/packages/capn/capn.pdf)). Do not equate it with a technical-efficiency score. Sharma and Leung (1999) report mean technical efficiency of 84%; that statistic is not automatically the harvest-effort elasticity ([article record and abstract](https://www.journals.uchicago.edu/doi/abs/10.1086/mre.13.4.42629241)). Verify the exact estimates and input definitions before citing the manuscript's `0.84` and `0.74` entries as alpha.

The present baseline sets `gamma = 0`, so effort is fixed as stock changes. Under this baseline, catchability is recalibrated at each year's reference point and the harvest curve is proportional to stock; changing alpha alone does not change the curve. Do not claim the current annual results establish alpha. A future alpha sensitivity should be paired with a nonzero effort response and clearly identified behavioral scenarios.

The notes contain an unverified `gamma = 0.07589` proposal and a separate calculation that may imply a negative response. Do not report either as an established Hawaii parameter. The underlying elasticity definitions, inversions, and trip types need to be checked against Pradhan, Sharma, and Leung (2003). The paper uses composite effort and seasonal stock indices; these are not directly the annual trips-only effort and total-biomass response in this model ([paper](https://www.soest.hawaii.edu/PFRP/reprints/pradhan_analyzing_2003.pdf)).

### Other current assumptions

- **Discount rate:** 3% annually, as specified in the manuscript.
- **Biology:** Logistic growth fitted to 1980–2023 assessment transitions. Assessment residuals include recruitment, timing, and model effects not captured by logistic growth. The reported growth-fit RMSE is about 24,094 mt/year.
- **Other fleets:** Other-fleet reference catch is annual all-fleet WCPO assessment catch less the proxy Hawaii catch. Its harvest changes proportionally with stock (`beta = 1`).
- **Area:** The 2010 catch and trip ratios are carried forward to all years by user agreement. State that this is the working baseline and a proxy, not measured annual geography. Hawaii longline trips can cross management areas.
- **Prices and costs:** Annual all-area ex-vessel prices and costs are applied to the proxy WCPO activity. Variable trip costs are apportioned by bigeye's share of deep-set pounds sold. Clarify that joint trip costs are not directly species-specific and that labor/fixed costs may not be included.
- **Catchability:** A new `q_t` is calibrated for each year; do not describe it as an estimate from trip-level catch-per-unit-effort data.
- **Stock definition:** Use annual mean total biomass from the same assessment vintage. Do not mix total biomass, spawning biomass, MSY catch flows, or biomass values taken from different assessment vintages.

## Manuscript sections to revise

1. **Abstract.** Replace the old price and wealth ranges only after the new parameter choices are reviewed. Report the annual period, stock definition, three-percent discount rate, and the geographic proxy in concise terms. Avoid claiming that stable values prove effective management.
2. **Introduction and study aim.** State consistently that the model values WCPO bigeye stock conditional on the Hawaii deep-set fleet's modeled benefit stream. Remove inconsistent descriptions of the valued fishery as the entire U.S. or WCPO fleet if the analysis remains Hawaii-specific.
3. **Materials and Methods.** Replace old data and equations with the current annual workflow. Describe the 2026 assessment biomass and catch, common fitted logistic growth law, annual economic calibration, area proxies, cost allocation, alpha/gamma/beta assumptions, and annual snapshot interpretation. Correct the discount rate to 3%. Define effort consistently; do not call trips `CPUE`.
4. **Parameter table.** Replace old repeated annual stock/MSY values and inconsistent entries with current annual stock values, annual economic observations, shared `r` and `K`, fitted MSY, 3% discount rate, and clearly labeled assumptions/proxies. Separate observed inputs, assessment estimates, fitted values, calibrations, and assumed behavioral parameters.
5. **Results and tables.** Replace old prices, capitalization, and claims. Resolve internal draft conflicts, including two different 2018 asset-price figures and differing wealth-change ranges. Give units and definitions for every price/value quantity.
6. **Figures 1–5.** Use the refreshed figures in `results/hawaii_capn_annual/` after scientific review:
   - `figure1_2018_price_curve.pdf`: 2018 curve with assessed-stock and fitted-MSY points.
   - `figure2_capitalization_by_year.pdf`: capitalization at each annual stock.
   - `figure3_annual_prices.pdf`: prices evaluated at annual stock and fitted MSY.
   - `figure4_annual_price_curves.pdf`: nine annual price curves.
   - `figure5_2018_stock_sensitivity.pdf`: 2018 price curve evaluated at stock changes of −50%, −25%, baseline, +25%, and +50%.
7. **Discussion, limitations, and conclusion.** Reassess claims that price or capitalization trends demonstrate sustainable management or causal policy effects. Discuss assessment uncertainty, the reduced-form growth law, the area proxy, joint-cost allocation, and uncertain effort response. The analysis measures market-based fishery benefits and omits nonmarket ecosystem values.
8. **Supplement and citations.** Reconcile every equation and parameter statement with the R script. Audit the cited alpha values and gamma calculation against the original sources. Ensure citations support the exact parameter interpretation, not merely a related technical-efficiency or composite-effort result.
9. **Copyediting and consistency.** Correct the current inconsistencies in 2018 prices, stock units, “price” versus “capitalization,” figure numbering, terminology, equation symbols, and cross-references after replacing tables and figures.

## Claims to avoid or qualify

- Do not call the fitted `K` an official carrying capacity or unfished biomass estimate.
- Do not call the 2010 geographic ratios observed 2011–2018 trip/catch shares.
- Do not call `alpha = 1`, `gamma = 0`, or `beta = 1` empirical estimates.
- Do not infer that a price trend caused a wealth trend or demonstrates management effectiveness.
- Do not equate a lower modeled shadow price with a lower market price or with total social value.
- Do not describe the model as valuing all WCPO fishing benefits; it is conditional on the Hawaii benefit stream represented here.
- Do not call `V(s)` capitalization. Capitalization is `p(s) * s` in this analysis.

## Outstanding analysis before final manuscript claims

- Verify the published definitions behind candidate alpha values and the gamma calculation. The current run does not identify alpha because its baseline fixes effort with stock.
- Run alpha/gamma sensitivities after choosing defensible scenarios. The current annual results are not a parameter-uncertainty analysis.
- Confirm the scope of variable trip costs and whether the intended profit measure should include labor or fixed costs.
- Review the fitted growth residuals and stock-assessment uncertainty. The `capn` numerical residual checks the approximation, not the biological model.
- If any annual area-specific catch or trip evidence becomes available, replace the carried 2010 area ratios and regenerate all annual outputs and figures.

## Files for revision

- Manuscript: `doc/CAPN-US-Longline_REV5.docx` (leave unchanged until the author begins the rewrite).
- Annual implementation: `1-Seascape-valuation.R`.
- Annual results: `results/hawaii_capn_annual/annual_valuation.csv` and `annual_price_curves.csv`.
- Model documentation: `doc/hawaii-capn-model.md`.
- Previous writer checklist: `doc/annual-model-update-notes.md`.
