# NOAA data inventory for updating the Hawaii longline model

**Purpose.** Record what public NOAA data can refresh the current 2010–2018 inputs, what the data could contribute to estimating `alpha`, `gamma`, and `beta`, and what still requires a request or a different source. This is a source inventory, not a claim that the parameters have already been estimated.

## Main finding

The aggregate CSV in `data/cost_per_pound.csv` is not the limit of available years. NOAA's Hawaii longline logbook program runs from 1990 to the present, and public reports and summary tools contain newer catch and effort statistics. NOAA also maintains a Hawaii longline trip-expenditure survey from 2004 to the present. The detailed logbook and trip-cost records are sensitive and are not public downloads, but nonconfidential summaries are available and NOAA identifies data contacts. Therefore, a current aggregate update is feasible; a microdata-based estimation comparable to Zhang and Smith (2011) may require NOAA approval or collaboration.

## Data sources and access

| Source | Coverage and content | Access and use for this project |
| --- | --- | --- |
| [Hawaii Longline Logbook, NOAA InPort 2721](https://www.fisheries.noaa.gov/inport/item/2721) | Daily logbook program, 1990–present; detailed catch, effort, and spatial information. Metadata says location resolution is degrees and tenths of minutes. Longline activity includes high seas and U.S. EEZ trips landing in Hawaii. | Detailed records are sensitive; NOAA says access requires written request and owner approval. Nonconfidential summaries have no access constraint. Ask NOAA for a research extract or suitable aggregates. NOAA specifically cautions that regulations changed repeatedly after 2001 and directs users to the data contact. |
| [NOAA Hawaiʻi/California longline reports archive](https://www.fisheries.noaa.gov/resource/data/pacific-islands-longline-quarterly-and-annual-reports) and [historical logbook report collection](https://www.fisheries.noaa.gov/resource/data/hawaii-and-california-longline-logbook-reports-2022) | Annual, semiannual, and quarterly report PDFs. Recent logbook reports summarize vessels, trips, sets, hooks, and species caught/kept/released by area and deep/shallow set; CPUE is reported as fish per 1,000 hooks. Historical Hawaii-based annual logbook summary reports include 2010 and earlier years. | Public reports are directly usable for a longer aggregate catch-effort series and some spatial/gear splits. Definitions and report formats change; use annual reports or official extracts rather than adding quarterly/half-year trip totals, which can double-count trips crossing reporting periods. Some current North Pacific summaries combine Hawaii and California vessels to meet reporting/confidentiality rules; select Hawaii-only fields/series. |
| [WPacFIN catch, effort, and CPUE query](https://apps-pifsc.fisheries.noaa.gov/wpacfin/catch-and-effort-data.php) | Public summary query; NOAA describes Hawaii longline logbook data from 2000 to present, with the site updated to 2025 in May 2026. | A promising reproducible route to annual species and gear summaries. Confirm query dimensions, geographic breakdown, and export functionality; retain query settings and download date with any extraction. |
| [Hawaii Longline Fishery Trip Expenditure, NOAA InPort 5662](https://www.fisheries.noaa.gov/inport/item/5662) | Trip expenditure survey, August 2004–present; ten variable-cost items (including fuel, bait, ice, gear, provisions, and communications), excluding labor. Survey covers observed trips; metadata reports 100% observer coverage for shallow sets and 20% for deep sets. | No public raw-data download. NOAA provides nonconfidential summaries; detailed business data are sensitive and access is controlled. The record says research users should contact the data steward, currently listed as Minling Pan, before drawing scientific conclusions. Ask whether updated annual, gear, area, and trip-level aggregates or a research extract can be provided. |
| [NOAA Bigeye Tuna resources](https://www.fisheries.noaa.gov/species/pacific-bigeye-tuna/resources) and WCPFC/Pacific Community assessments | Stock assessments and assessment inputs for WCPO bigeye; biology is a regional stock process rather than a Hawaii-only fleet measure. | Use consistent assessment biomass/catch/effort series for biological and fleet controls. A Hawaii NOAA annual report alone cannot estimate WCPO stock growth or the response of other WCPO fleets. |

## What the current CSV appears to contain

`data/cost_per_pound.csv` has annual rows for 2010–2018, sectors `D` and `S`, and three listed species (bigeye, yellowfin, swordfish). It includes pounds sold, average price per pound, trips, variable cost per trip, and two cost-per-pound columns. Its source is described by the author as aggregate data received from a NOAA economist. The repository does not contain the original email, source table, or data-generation notes, so the precise table/report lineage remains unverified.

The arithmetic in the CSV is consistent, to rounding, with these derived columns:

```text
cost_per_pound_species = varcost_per_trip * trips / that_species_pounds_sold
sharecost_per_pound = varcost_per_trip * trips / sum(listed_species_pounds_sold_in_sector)
```

This check confirms how the two columns were calculated from the fields in the file; it does **not** establish the original source, representativeness, price-year basis, or cost definition. In particular, `cost_per_pound` assigns the entire sector trip cost to one species at a time and should not be interpreted as a species-specific marginal cost. `sharecost_per_pound` is a sector-wide average over the species listed in this CSV.

The 2010 deep-set trip count in the CSV is 1,193, while the NOAA 2010 logbook report cited in the repository's reference log reports 1,205 and Pan (2018) reports 1,216 for its trip series. These are not interchangeable series. Reconcile definitions and samples with the NOAA economist before replacing one with another. The discrepancy is useful evidence that the CSV's lineage needs confirmation, not evidence that the supplied series is wrong.

## Which parameters the annual data can inform

### `alpha`: harvest response to effort

The NOAA logbook series provides species catch and effort, including hooks, sets, and trips; public reports may provide these in annual and spatial summaries. Paired with a compatible stock-abundance index and controls for area, season, gear, management, and technology, these data can inform a generalized catch production function. A simple annual catch/trips regression would not isolate the effort elasticity reliably. Hooks or set-level effort are preferable to trip counts, and spatial/seasonal stock availability matters for pelagic tuna.

There is also relevant historical Hawaii evidence in the user-supplied Pradhan, Sharma, and Leung (2003) paper. It uses trip observations and estimates species/trip-type-specific responses to composite effort and a CPUE stock index. For bigeye on tuna trips, its estimated composite-effort elasticity is 0.2753 (SE 0.1023) and its stock-index elasticity is 0.7955 (SE 0.0772), per Tables 5–7 as logged in `doc/CAPN-US-Longline_REV5.reference-log.md`. Those are useful historical benchmarks, not direct estimates of the present model's trips-only `alpha` or elasticity with respect to total WCPO biomass. The older sample can help check plausible magnitudes but should be updated if current logbook data allow.

### `gamma`: effort response to stock

Longer annual effort series can be used to examine whether fleet effort changes with stock, but a stock-only regression would combine behavioral response with output prices, operating costs, regulations, quota/catch limits, fleet capacity, and technology. NOAA logs, effort reports, prices, and available trip-cost summaries can support an exploratory reduced-form response model. A stronger estimate would use trip/vessel data and explicitly model these determinants and management regimes. The current 2010–2018 file is too short for that task on its own.

### `beta`: other-fleet harvest response to WCPO stock

NOAA Hawaii logbook data cover the Hawaii fleet only. They cannot identify how the rest of the WCPO fleet changes catch as stock changes. This requires fleet-specific catch and preferably effort data from WCPFC/Pacific Community assessment inputs or another regional source. Total WCPO catch minus Hawaii catch is a residual, not a measured other-fleet series. If reliable fleet data are unavailable, retain `beta` as a scenario assumption and show sensitivity rather than claim an estimate.

### Biology, price, and cost

- Use the WCPO assessment for stock status, catch, and biological dynamics; do not estimate a regional stock-growth curve solely from Hawaii logbook reports.
- Use current NOAA annual landings/price and cost summaries to refresh economic conditions. Convert to constant dollars before comparing values across years.
- Verify whether supplied pounds sold match NOAA logbook kept catch, dealer purchases, or another landings measure. These concepts differ and should not be silently substituted.
- Confirm geographic allocation. Hawaii-based vessels can fish across management areas; annual summaries by location may support an annual area split, while exact trip/set geography may require access to restricted logbook records.

## Recommended next data workflow

1. **Resolve provenance.** Ask the NOAA economist who supplied `cost_per_pound.csv` for its source table/report, exact definitions, data years, dollar basis, handling of observed trips, species coverage, and the reason the trip count differs from published logbook series.
2. **Build a public logbook panel.** Extract annual deep-set bigeye catch and hooks/sets/trips for the longest comparable Hawaii-only series available from NOAA reports/WPacFIN. Preserve area and unit definitions; do not combine incompatible report vintages or California vessels.
3. **Obtain compatible stock data.** Pair fishing-area catch/effort with WCPO assessment biomass and, where possible, assessment fleet-specific catch/effort. Document the stock metric and timing.
4. **Request the nonpublic economic summaries or a research extract.** Contact the trip-expenditure data steward and ask what annual/area/sector-level data can be released; request trip-level linkage only if allowed and necessary.
5. **Estimate before changing the CAPN baseline.** Test harvest/effort and effort/stock relationships, account for management/technology changes, and assess identification. Estimate `alpha`/`gamma` only if the data support them; treat `beta` separately using regional fleet data.
6. **Keep assumptions visible.** If estimates remain weak, report parameters as calibrated scenarios, and propagate the scenario range into the CAPN price and capitalization results.

## Sources checked

- [NOAA Hawaii Longline Logbook metadata (InPort 2721)](https://www.fisheries.noaa.gov/inport/item/2721)
- [NOAA Hawaii Longline Trip Expenditure metadata (InPort 5662)](https://www.fisheries.noaa.gov/inport/item/5662)
- [NOAA Pacific Islands Longline Quarterly and Annual Reports](https://www.fisheries.noaa.gov/resource/data/pacific-islands-longline-quarterly-and-annual-reports)
- [NOAA Hawaiʻi and California Longline Logbook Reports](https://www.fisheries.noaa.gov/resource/data/hawaii-and-california-longline-logbook-reports-2022)
- [WPacFIN catch, effort, and CPUE query](https://apps-pifsc.fisheries.noaa.gov/wpacfin/catch-and-effort-data.php)
- [NOAA Bigeye Tuna resources](https://www.fisheries.noaa.gov/species/pacific-bigeye-tuna/resources)
- Pan (2018), *Tracking Changes on Fishery Economic Performance: Continuous Economic Data Collection Programs for the Hawaii and American Samoa Longline Fisheries 2005–2016*, local citation/source record in `doc/CAPN-US-Longline_REV5.reference-log.md`.
- Pradhan, Sharma, and Leung (2003), user-supplied `doc/18.2_04Pradhan.pdf`; parameter evidence and limitations are logged in `doc/CAPN-US-Longline_REV5.reference-log.md`.
