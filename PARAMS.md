# Parameter and input register

This file records the parameters and calibration inputs used by `1-Seascape-valuation.R`, their current status, and what would be needed to estimate or validate them. “Can estimate?” refers to the data currently in this repository unless stated otherwise. Values in the current run are working inputs; a value in the script is not necessarily an empirical estimate.

## Status key

- **Observed / sourced:** directly taken from a supplied data source, subject to source and measurement validation.
- **Fitted:** estimated from data using the stated model; uncertainty and model validity still need review.
- **Calibrated:** chosen to reproduce a reference observation, not independently estimated.
- **Assumed / proxy:** imposed because data do not currently identify it.
- **Numerical setting:** controls computation rather than the fishery's economics or biology.

## Core biological and behavioral parameters

| Symbol / code name | Meaning in this model | Current value / source | Status with current data | Can it be estimated? How? |
| --- | --- | --- | --- | --- |
| `r_effective` (`r`) | Intrinsic growth rate in the common logistic stock-growth function, per year | 0.4816/year; fitted to assessment-implied growth transitions from 1980–2023 | **Fitted, provisional.** The dependent variable is constructed from annual biomass changes plus catch. It can absorb recruitment variation, assessment error/revisions, and timing effects. | It can be fit under a chosen stock-assessment and growth specification. Prefer assessment-estimated biological parameters or fit an age-structured/assessment-consistent production model. If retaining this reduced form, assess residuals, uncertainty, influential years, alternative windows/specifications, and parameter covariance. Do not treat the fit alone as a biological estimate of intrinsic growth. |
| `K_proxy` (`K`) | Logistic carrying-capacity scale; also determines fitted MSY as `r*K/4` | 1,205,670 mt from the same quadratic growth fit | **Fitted, provisional.** Not an official unfished biomass or assessment estimate. | Same route as `r`, but `r` and `K` are jointly determined and potentially weakly identified. Report joint uncertainty and sensitivity. Compare against assessment reference points and alternative stock-growth models. |
| `alpha` | Elasticity of Hawaii harvest with respect to effort in `H(s)=q*s*E(s)^alpha` | 1.0 | **Assumed. Not identified by current annual calibration.** Since `q` is recalibrated at each year's reference point, alpha cancels from the Hawaii harvest curve when that year's catch is matched. At `gamma=0`, it has no effect on the modeled harvest or cost curves. | In principle, estimate a catch production function with catch, stock, and an effort measure: for example, `log(H)=log(q)+alpha*log(E)+stock terms+controls`. Needs effort variation and controls for stock, area, gear, season, technology, and composition. Trips alone may be a poor effort measure; hooks, sets, trip duration, and location would improve it. The current nine aggregate annual observations are not a strong basis for a reliable estimate. Technical-efficiency scores are not estimates of alpha. |
| `gamma_hawaii` (`gamma`) | Elasticity of Hawaii effort with respect to stock: `E(s)=E_ref*(s/S_ref)^gamma` | 0.0 | **Assumed. Not identified by the current annual snapshots.** It fixes effort as stock varies within a curve. | Estimate effort response using effort (preferably sets/hooks, by area and season), stock, expected prices/costs, regulations, capacity, and time effects. This is a behavioral response, so stock-only correlation is not sufficient. A panel of vessels or longer, richer time series would help. With the current data, use clearly motivated scenarios and sensitivity ranges. |
| `beta_other` (`beta`) | Stock elasticity of other-fleet catch: `C_other(s)=C_other_ref*(s/S_ref)^beta` | 1.0 | **Assumed.** Other catch is derived as assessment total catch less proxy Hawaii WCPO catch; beta is not estimated. | Estimate a fleet-specific catch production relationship using catch, stock, fleet effort, technology, and management/time controls. If effort is unavailable, a catch-stock regression is possible but confounds stock response with changes in effort and catchability. The present nine-year residual series is too short and proxy-dependent for a strong estimate. |
| `delta` (`discount rate`) | Continuous discount rate supplied to `capn` | 0.03/year | **Set by author/manuscript choice.** Not estimated from these fishery data. | Use 3% as the requested baseline. If the manuscript needs robustness, report results at a prespecified range of defensible public/social discount rates and cite the rationale. |

### What the current specification implies for alpha and gamma

Substituting the effort rule into the harvest function gives

```text
H(s) = q * s * [E_ref * (s / S_ref)^gamma]^alpha
     = H_ref * (s / S_ref)^(1 + alpha * gamma)
```

because `q` is calibrated to match `H_ref` at `S_ref`. Thus harvest data along a stock curve identify the combined stock elasticity `1 + alpha*gamma`, not alpha and gamma separately, unless effort and harvest responses are independently observed or additional restrictions/data are supplied. In the current baseline `gamma = 0`, the exponent is one and alpha has no effect on the curve. Alpha can still matter in a model where catchability is held fixed across years or estimated independently, but that is not the current year-by-year calibration.

**Identification clarification (2026-10-20).** Away from the reference stock, alpha remains in the exponent `1 + alpha*gamma` when gamma is nonzero. Calibration removes its effect on the reference catch level, not its effect on every possible harvest curve. Generated stock curves are model outputs, not independent observations that estimate these parameters.

Pradhan, Sharma, and Leung (2003), equations (5), (8), and (9), estimate separate partial output responses to composite effort and a stock index. Their stock response holds effort and prices fixed. It cannot be substituted for the total stock response along an effort feedback rule to recover gamma using `(stock elasticity - 1)/alpha`. That substitution confuses a production response with a behavioral response. The earlier notes and conversational suggestion to derive gamma that way should not be used as an empirical parameter estimate.

For a generalized harvest function `H = q*S^theta*E^alpha`, the total stock elasticity along `E(S)` is `theta + alpha*gamma`. A partial stock elasticity informs theta, subject to compatible stock and effort definitions; it does not by itself identify gamma. Retaining `gamma = 0` therefore defines a fixed-effort scenario, rather than an estimated institutional response.

## Annual calibrations and sourced economic inputs

| Input / code name | Meaning | Current treatment | Status and estimation/validation path |
| --- | --- | --- | --- |
| `q_t` (`catchability`) | Annual Hawaii catchability coefficient | Recalibrated each year as proxy Hawaii WCPO catch divided by stock times trip-equivalent effort raised to alpha | **Calibrated**, not independently estimated. Needs reliable area-specific catch, stock, and effort measures. With annual q, cross-year catch variation cannot identify alpha. Consider whether annual q variation is intended to capture technology, targeting, composition, or measurement changes. |
| `stock_mt` (`S_t`) | WCPO bigeye total biomass at the year's reference point | Annual mean total biomass, 2010–2018, from Pacific Community 2026 diagnostic output | **Assessment-sourced**, not directly observed. Validate assessment vintage, units, annual timing, uncertainty, and the biomass definition against the manuscript. Do not mix total biomass with spawning biomass. |
| `wcpo_total_catch_mt` | All-fleet annual WCPO catch used in stock dynamics | Same assessment diagnostic series | **Assessment-sourced.** Verify years, catch definition, units, and consistency with stock dynamics. |
| `bigeye_sold_mt`, `price_usd_per_mt`, `deep_trips`, `varcost_per_trip` | Hawaii deep-set annual bigeye pounds sold, nominal ex-vessel price, trips, and variable trip cost | Read from `data/cost_per_pound.csv`; pounds and price converted to metric units | **Aggregate supplied data.** Validate field definitions, nominal/real dollar basis, coverage, and whether the trip/cost fields refer to the same sector population and year. No vessel-level observations are required to use the aggregate baseline, but they limit behavioral estimation. |
| `wcpo_retained_to_sold` | Converts all-area deep-set bigeye sold pounds to a WCPO retained-catch proxy | 2010 WCPO deep-set retained catch divided by 2010 all-area deep-set bigeye sold catch; held fixed through 2018 | **Proxy, user-approved baseline.** Not an observed annual area share. Better estimated from annual area-specific retained catch and comparable landings definitions; otherwise vary the ratio in sensitivity analysis. |
| `wcpo_effort_share` | Converts aggregate deep-set trips to WCPO trip-equivalents | 2010 all-gear WCPO retained catch divided by WCPO plus EPO retained catch; held fixed through 2018 | **Proxy.** Also not an observed deep-set trip share; catch shares need not equal trip shares, and a trip may cross management areas. Replace with trip/set-level area allocation if available; otherwise test alternatives and clearly label it. |
| `cost_per_bigeye_trip_usd` | Cost assigned to bigeye in the Hawaii profit flow | Sector variable trip cost multiplied by bigeye share of all listed deep-set pounds sold | **Calculated allocation assumption.** Validate the source cost definition and decide treatment of joint costs, labor, fixed costs, and opportunity costs. Test alternative allocations. This is not automatically economic profit or producer surplus. |
| `price_usd_per_mt` | Bigeye ex-vessel output price | Annual all-area deep-set average price from supplied aggregate data, converted from dollars per pound | **Observed aggregate input.** It assumes this price applies to the WCPO proxy catch. Check whether price is nominal; deflate to a common year if comparing real values across years. |
| `cost_multiplier` | Multiplier on allocated costs in `run_capn` | 1.0 | **Scenario control**, currently fixed. Can be varied to show sensitivity to costs, but it is not a parameter estimated by the model. |
| `other_catch_ref` | Other-fleet reference catch | Assessment total WCPO catch less proxy Hawaii catch | **Residual calibration.** Sensitive to both assessment catch and Hawaii area/catch proxy. Verify it is positive and conceptually consistent; it is not a directly observed “all other fleets” catch series. |

## Numerical and reporting settings

| Setting | Current value | Status / check |
| --- | --- | --- |
| Valuation years | 2010–2018 | Author-selected study window; confirm manuscript consistency. |
| Growth-fit window | 1980–2023 | Script-selected window for fitted reduced-form growth; assess alternatives and leverage. |
| `polynomial_terms` | 50 | Numerical approximation setting. Check convergence by varying polynomial degree/order. |
| `node_count` | 500 | Numerical grid setting. Check convergence with alternative node counts and domain bounds. |
| Stock domain | 1% to 101% of fitted `K` | Numerical domain assumption. Confirm relevant evaluated stocks are inside the domain and that prices/values are stable near boundaries. |
| CAPN framework | CRAN `capn`, deterministic scalar stock case | Method implementation. Record package version and verify approximation/Bellman residuals; numerical accuracy does not validate the biological or economic specification. |

## Estimation priorities

1. **Keep alpha, gamma, and beta labeled as assumptions for the current baseline.** The current output is not an empirical estimate of them.
2. **For alpha and gamma, seek or construct fishing effort at the finest practical level** (vessel/ trip/ set, hooks, location, season, and year), linked to compatible catch and stock measures. Estimate the harvest and effort-response equations jointly or sequentially with defensible controls; account for endogeneity of effort and targeting.
3. **For beta, obtain WCPO fleet-specific catch and effort series** and fit other-fleet harvest responses to stock while controlling for effort, technology, and management changes. Aggregate all-fleet catch minus proxy Hawaii catch is only a starting residual.
4. **If those data are unavailable, use scenario analysis rather than pseudo-precision.** State parameter values as assumptions, present a plausible range with sources/rationale, and show resulting price and capitalization ranges. The scenario range should include uncertainty in area allocation, biology, costs, and behavioral responses, not just numerical approximation error.
5. **Separate parameter uncertainty from model-form uncertainty.** A narrow confidence interval around a fitted curve would not resolve whether logistic growth, proportional other-fleet catch, or the profit definition is appropriate.

## Sources of the current implementation

- Main implementation: [`1-Seascape-valuation.R`](1-Seascape-valuation.R)
- Model details and data notes: [`doc/hawaii-capn-model.md`](doc/hawaii-capn-model.md)
- Annual input/results tables: `results/hawaii_capn_annual/`
- Fenichel and Abbott (2014), [*Natural Capital: From Metaphor to Measurement*](https://doi.org/10.1086/676034)
- CRAN [`capn` reference manual](https://cran.r-project.org/web/packages/capn/capn.pdf)
