# Hawaii bigeye natural capital valuation

The annual R implementation is [1-Seascape-valuation.R](1-Seascape-valuation.R). It uses the CRAN `capn` package to estimate annual Hawaii bigeye natural capital asset price curves for 2010–2018. Each annual curve holds that year's economic inputs stationary and uses a common fitted stock-growth law. Run from the repository root:

```sh
Rscript 1-Seascape-valuation.R
```

The script writes annual inputs, valuation summaries, and price curves under `results/hawaii_capn_annual/`, along with five figure PDFs corresponding to the figure types in the manuscript and a growth diagnostic. See [the annual model notes](doc/hawaii-capn-model.md) for assumptions and [the manuscript update checklist](doc/annual-model-update-notes.md) for results and sections that need revision. The manuscript itself has not been changed.

The annual WCPO catch allocation is provisional: the data include only a 2010 geographic split, so the model carries the 2010 WCPO retained-to-sold ratio and all-gear catch share across the period. The figures should be reviewed with that limitation in mind. The 2010-only outputs from the previous working version are preserved under `results/hawaii_capn/` and are superseded by the annual outputs.

The script ran with R 4.4.1 and archived `capn` 1.0.0. R 4.5 or newer can install current CRAN `capn` 2.0.0; the script accommodates its changed `vaprox` interface. See the model notes for the archived install command for R 4.4.
