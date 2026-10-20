# Hawaii bigeye CAPN model: annual 2010–2018 run

## Scope and status

`1-Seascape-valuation.R` calculates an annual conditional accounting-price curve for Hawaii deep-set bigeye fishing for 2010–2018 using the CRAN `capn` package. For each year it holds that year's economic program fixed and evaluates the resulting curve at that year's WCPO bigeye stock and at the fitted logistic MSY. This is an annual snapshot exercise: each year's economic conditions are treated as if they persisted, rather than solving a fully time-varying 2010–2018 dynamic program.

The main annual results and five figure PDFs are under `results/hawaii_capn_annual/`. The 2010-only prototype is retained in `results/hawaii_capn/` for comparison and is superseded. These outputs are a working model for review, not final estimates. They are conditional on a geographic allocation proxy, a reduced-form logistic fit, and provisional behavioral parameters.

## Annual data and assumptions

| Input | Annual treatment |
| --- | --- |
| Bigeye stock | Annual mean total biomass (`tb`) for 2010–2018 from the Pacific Community 2026 diagnostic output, in metric tonnes. These are assessment estimates for the WCPO stock, not observations. |
| Growth | One common logistic law fitted to assessment-implied annual growth, 1980–2023: `r = 0.4816/year`, `K = 1,205,670 tonnes`; fitted MSY is `rK/4 = 145,158 tonnes/year`. This `K` is a reduced-form fitted scale, not an official unfished biomass estimate. |
| All-fleet catch | Annual WCPO catch from the same assessment output. Hawaii's proxy catch is subtracted to derive other-fleet catch for each annual snapshot. |
| Hawaii bigeye landings and price | Annual deep-set bigeye pounds sold and price per pound from the user's aggregate NOAA-economist CSV, converted to metric tonnes and dollars per metric tonne. The CSV does not identify fishing area. |
| Hawaii trips and costs | Annual deep-set trip count and variable cost per trip from the same aggregate CSV. The bigeye cost allocation is the sector variable cost per trip multiplied by bigeye's share of all listed deep-set pounds sold that year. |
| WCPO catch allocation | Because geographic catch data are only available for 2010, the 2010 WCPO deep-set retained-catch / all-area deep-set bigeye sold ratio (about 0.7734) is applied to all years' bigeye sold tonnage as a catch proxy. This aligns the 2010 proxy to NOAA's 3,535 tonnes of WCPO deep-set retained catch. |
| WCPO trip allocation | The 2010 all-gear WCPO share of WCPO plus EPO retained bigeye catch (72.51%) is applied to each year's aggregate deep-set trip count. These are trip-equivalents, not observed trip-area splits. |
| Behavioral assumptions | `alpha = 1` (linear effort exponent), `gamma_hawaii = 0` (fixed effort as stock changes within each year's curve), `beta_other = 1` (other-fleet catch proportional to stock), and discount rate `delta = 3%` (as specified in the manuscript). These are explicit working assumptions, not all empirically estimated parameters. |

Hawaii-based trips can fish in the WCPO, EPO, and Hawaii EEZ, sometimes crossing multiple areas on a trip. The CSV's aggregate trips and economics do not identify location. NOAA's [2018 technical memorandum](https://repository.library.noaa.gov/view/noaa/18661/noaa_18661_DS1.pdf) describes the areas and multi-area trips. Applying the 2010 area proxies to 2011–2018 is therefore a substantial limitation and should be tested against any annual geographic data that can be obtained.

The annual CSV contains `cost_per_pound` and `sharecost_per_pound`; the model does not use either as a bigeye-only cost. The former assigns the whole sector trip cost to every species, while the latter is an average sector cost per pound. Instead, variable cost per trip is apportioned using bigeye's fraction of deep-set pounds sold. This assumes the species revenue/pound share is an adequate proxy for allocating trip cost. NOAA's survey variable costs exclude labor, but the exact cost-field definitions in the supplied aggregate have not been independently confirmed.

## Calculation

For each year `t`, the script calibrates catchability to the proxy Hawaii WCPO catch `H_t` at the assessment stock `S_t` and trip-equivalent effort `E_t`:

```text
E_t = aggregate deep-set trips_t * 2010 WCPO trip-share proxy
H_t = all-area deep-set bigeye sold_t * 2010 WCPO retained/sold ratio
q_t = H_t / (S_t * E_t^alpha)
H_t(s) = q_t * s * E_t(s)^alpha
E_t(s) = E_t * (s / S_t)^gamma_hawaii
other_catch_t(s) = (assessment catch_t - H_t) * (s / S_t)^beta_other
profit_t(s) = bigeye price_t * H_t(s) - allocated bigeye trip cost_t * E_t(s)
stock_change_t(s) = r*s*(1 - s/K) - H_t(s) - other_catch_t(s)
```

`capn` approximates the value function and derives its shadow price over 500 Chebyshev nodes from 1% to 101% of `K`. Each year is calibrated separately, including its catchability and observed economic inputs; `r`, `K`, `alpha`, `gamma_hawaii`, `beta_other`, and `delta` are held common. Annual capitalization is the annual shadow price at the assessed stock multiplied by that stock. This is an asset-value accounting measure based on the model's benefit stream, not the present value `V(S)` and not a consumer-surplus estimate.

## Results from the current run

With the 3% discount rate, the annual shadow price at observed stock ranges from about **$215 to $324 per tonne** during 2010–2018. Capitalization ranges from about **$124 million to $186 million**. The 2018 estimate is about **$304 per tonne**, with capitalization of about **$173 million**; the price at fitted MSY is about **$1,068 per tonne**. The 2018 stock sensitivity figure evaluates the 2018 price curve at 50%, 75%, 100%, 125%, and 150% of the assessed stock.

The price range differs materially from the draft manuscript's earlier $8,165–$10,827 per-tonne values, and the new capitalization values differ from its multi-billion-dollar estimates. The annual model uses a different stock series, a single common fitted growth law, a proxy WCPO allocation, and revised cost allocation, so the draft results should not be carried forward without reconciling the model definitions. See [`annual-model-update-notes.md`](annual-model-update-notes.md); no manuscript edits have been made.

The accounting price and capitalization are not expected to be stable merely because they use the same method. Annual prices depend on the calibrated annual catchability, price, trip costs, and effort, while capitalization also depends on stock. A small annual change can reflect offsetting movements in those inputs; it should not be presented as evidence of management success without further analysis.

## Outputs

- `annual_inputs.csv`: source-derived annual economic inputs and geography proxies.
- `annual_price_curves.csv`: all 500 stock-node calculations for each year, including price, value function, harvest, profits, and Bellman residuals.
- `annual_valuation.csv`: annual price at assessed stock, price at fitted MSY, capitalization, and model inputs/diagnostics.
- `stock_sensitivity_2018.csv`: 2018 stock perturbation values underlying Figure 5.
- `figure1_2018_price_curve.pdf` through `figure5_2018_stock_sensitivity.pdf`: the five paper figure types, updated for this model.
- `growth_fit.csv`, `growth_observations.csv`, and `growth_diagnostics.pdf`: reduced-form biological fit and diagnostics.

Run with `Rscript 1-Seascape-valuation.R`. The local run used R 4.4.1 and archived `capn` 1.0.0. With R 4.5 or newer, current CRAN `capn` 2.0.0 is supported; for R 4.4, install the archived package:

```sh
Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/capn/capn_1.0.0.tar.gz", repos = NULL, type = "source")'
```

## Sources

- Fenichel and Abbott (2014), [*Natural Capital: From Metaphor to Measurement*](https://www.journals.uchicago.edu/doi/full/10.1086/676034).
- Pradhan, Sharma, and Leung (2003), [*Analyzing Technical and Economic Interrelationships in Hawaii's Longline Fishery*](https://www.soest.hawaii.edu/PFRP/reprints/pradhan_analyzing_2003.pdf).
- Pacific Community, [2026 bigeye diagnostic annual output](https://raw.githubusercontent.com/PacificCommunity/ofp-sam-bet-2026-diagnostic/main/TAF/output/summary.csv) and [generation code](https://github.com/PacificCommunity/ofp-sam-bet-2026-diagnostic/blob/main/TAF/output_pop.R).
- NOAA, [2015 regulatory impact review](https://downloads.regulations.gov/NOAA-NMFS-2015-0085-0003/content.pdf), Table 1 (local copy in `doc/`).
- NOAA, [Pan (2018) Hawaii longline fishery economic performance technical memorandum](https://repository.library.noaa.gov/view/noaa/18661/noaa_18661_DS1.pdf).
