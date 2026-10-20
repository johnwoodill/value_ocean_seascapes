# Reference log: Hawaii bigeye CAPN parameter audit

- Manuscript: `doc/CAPN-US-Longline_REV5.docx`; model notes: `doc/hawaii-capn-model.md`
- Scope and eligibility: Sources for the Fenichel–Abbott valuation method, WCPO bigeye biomass and catch inputs, and Hawaii trip costs. Focused audit of model and parameter claims only; no full manuscript citation audit.
- Citation style: Author-year, provisional.
- Last updated: 2026-10-19 14:16 PDT

## Invocation history

### 2026-10-20 PDT, parameter-estimation feasibility and elasticity correction
- Task: Assess whether obtaining credible alpha, gamma, and other-fleet beta estimates is a straightforward data retrieval task, and recommend a bounded feasibility decision.
- Searches: No new discovery query. Reopened NOAA InPort items 2721 and 5662 and the University of Hawaii-hosted Pradhan, Sharma, and Leung (2003) reprint. This was a targeted definition/access audit, not an exhaustive literature search.
- Material inspected: Pradhan et al., equations (4)–(9), printed pp. 174–175, and effort/data definitions on pp. 176–177; NOAA metadata Summary and Access Information sections. Also inspected current `PARAMS.md`, earlier reference entries, and the current R valuation reference-point calculation.
- Changes: Clarified in `PARAMS.md` that Pradhan's partial stock elasticity cannot identify gamma through `(elasticity - 1)/alpha`. In a generalized production function, partial stock response and behavioral effort response are distinct. Corrected the implication that annual catchability calibration eliminates alpha everywhere even with nonzero gamma.
- Decision basis: Public aggregate data can refresh inputs and support exploratory associations. Detailed data access and a defensible identification strategy are separate requirements for structural response estimates. Recommend a bounded data/identification and sensitivity exercise before committing to manuscript revision.
- Additional implementation finding: The current R script evaluates its “price at MSY” at `r*K/4`, a yield in tonnes/year. For the stated logistic growth law, the corresponding stock is `K/2` tonnes. This benchmark requires correction before interpretation; no numerical outputs changed in this audit.
- Stopping reason and gaps: Source definitions resolve the conceptual question. No data extract or parameter estimation was performed. Restricted-data release, current coefficient availability, and adequacy of public spatial/temporal aggregates remain unconfirmed. Pradhan DOI/publisher notice checks remain unresolved as recorded in its existing entry; this audit verified definitions in the author-hosted reprint, not full bibliographic status.

#### Sources and citation uses for this audit
- **PradhanSharmaLeung2003** (existing entry): [author-hosted paper](https://www.soest.hawaii.edu/PFRP/reprints/pradhan_analyzing_2003.pdf); DOI unresolved in this audit. Equations (5), (8), and (9) support the distinction between partial output responses and an effort feedback rule. The conclusion that these do not identify gamma is our mathematical interpretation. No new coefficient value is claimed.
- **NOAA2010sTripExpenditure** (existing entry): [NOAA InPort 5662](https://www.fisheries.noaa.gov/inport/item/5662); DOI not listed in inspected metadata. Rechecked 2026-10-20: ongoing cost collection, nonconfidential public summaries, and no listed raw-data distribution. Supports data-access assessment, not provenance of the supplied CSV.
- **NOAAHawaiiLonglineLogbook**: Pacific Islands Fisheries Science Center. *Hawaii Longline Logbook*. [NOAA InPort 2721](https://www.fisheries.noaa.gov/inport/item/2721); DOI not listed in inspected metadata. Metadata/title/access information checked 2026-10-20. Describes records from 1990 onward, restricted detailed data, unrestricted nonconfidential summaries, and owner approval for detailed access. Used to distinguish existence of a data program from availability of a research extract. No numerical parameter estimates are supplied by this record.

### 2026-10-19 14:16 PDT, Hawaii trip geography and baseline correction
- Task and manuscript version: Verify whether Hawaii-based longline trips can be assumed to fish only in the WCPO, summarize the changed model state, and assess readiness for review.
- Searches: NOAA technical memorandum search, 2026-10-19: `NOAA Pan 2018 Hawaii longline trip WCPO EPO EEZ location priority trips fish across areas`.
- Screening and citation chasing: Pan (2018), *Tracking Changes on Fishery Economic Performance*, states that Hawaii longline trips may fish in the EEZ, WCPO, and EPO, including multiple areas on one trip. NOAA's classification uses an area-priority rule, so Hawaii home port does not identify trip fishing area.
- Changes: Restored the transparent all-gear WCPO share of retained bigeye catch as the baseline proxy for area allocation (72.51%, about 865 equivalents from 1,193 aggregate deep-set trips); retained 60%–100% allocation cases including the all-WCPO case. Corrected the README description and reran `1-Seascape-valuation.R` using R 4.4.1 and `capn` 1.0.0. Baseline outputs: $223.63/tonne marginal price, $129.05 million capitalization, and $820.83 million reference value function.
- Stopping reason and gaps: The code and outputs are ready for review as a working model. The baseline area allocation remains a proxy, and biological/economic assumptions remain provisional; see `doc/hawaii-capn-model.md` before interpreting results.

### 2026-10-19 14:03 PDT, direct aggregate trip count
- Task and manuscript version: Respond to the user's clarification that the supplied CSV is already broken out by species and sector and includes trip counts; revise the baseline to use those aggregate fields directly.
- Searches: None. Used the local CSV schema and prior source review.
- Screening and citation chasing: Confirmed the script selects 2010 deep-set bigeye rows for pounds and price, and the corresponding aggregate sector trip count and cost. The CSV does not identify the trips' area split.
- Changes: Temporarily removed the NOAA all-gear catch-share proxy and assigned all 1,193 deep-set trips to the modeled WCPO contribution. This was superseded in the 14:16 entry after checking NOAA's description of Hawaii trip geography.
- Stopping reason and gaps: The CSV provides aggregate fields but not the trip fishing-area split; the baseline now uses an explicitly labeled catch-share proxy and retains alternative area allocations as sensitivity scenarios.

### 2026-10-19 14:00 PDT, user clarification on cost data
- Task and manuscript version: Incorporate the user's clarification that `data/cost_per_pound.csv` contains aggregate data received from a NOAA economist; no manuscript text edited.
- Searches: None. Used user-provided provenance clarification and prior NOAA source review.
- Screening and citation chasing: Clarified that the CSV is aggregate, not trip-level microdata or a published NOAA table. Retained the difference between 1,193 trips in the supplied aggregate and 1,216 in Pan (2018) as unresolved, potentially reflecting coverage or definitions.
- Changes: Updated model notes to state the aggregate-data provenance and qualify whether its cost fields share NOAA survey definitions. No numerical model changes.
- Stopping reason and gaps: General provenance is now known. The exact aggregation procedure, trip-count definition, and whether all costs exclude labor remain unverified; these are useful for final parameter documentation but do not block the working model.

### 2026-10-19 13:56 PDT, cost CSV provenance check
- Task and manuscript version: Check whether the supplied 2010 deep-set trip cost and count can be traced to a public NOAA source; no manuscript text edited.
- Searches: Web search, 2026-10-19, no filters: `"23203.68" Hawaii longline 2010`; `"23,203.68" deep set longline 2010 trip`; `"1193" "2010" "deep-set" trips Hawaii costs`; `NOAA Hawaii longline 2010 variable cost per trip 23203`. Result counts unavailable. Inspected NOAA trip-expenditure metadata and Pan (2018) report, especially Tables 3 and 8 and cost definitions.
- Screening and citation chasing: Exact supplied CSV amounts were not located in indexed public sources. NOAA trip-expenditure metadata has no public data distribution. Pan (2018) uses all deep-set trips and surveyed costs, but its published table reports 1,216 deep-set trips in 2010 versus 1,193 in the CSV.
- Changes: Added the qualified trip-count discrepancy to `doc/hawaii-capn-model.md`; no CSV or model figure changed.
- Stopping reason and gaps: Public report confirms its survey costs exclude labor and shows geographic cost heterogeneity, but does not identify the CSV's exact extraction, aggregation, or exclusion rule. The model runs without that detail.

### 2026-10-19 13:52 PDT, working-model follow-up
- Task and manuscript version: Stabilize the 2010 R model with a transparent baseline and documented parameter evidence; no manuscript text edited.
- Searches: Current CRAN `capn` 2.0.0 manual checked at https://cran.r-project.org/web/packages/capn/capn.pdf on 2026-10-19 for `vaprox` and `vsim` signatures. No new scholarly literature search; reused the directly inspected Pradhan et al. (2003) and Fenichel and Abbott (2014) evidence from the prior audits. Result counts not applicable.
- Screening and citation chasing: No new scholarly records screened. Confirmed that the new `capn` API takes stock, dynamics, and welfare vectors separately; the archived 1.0.0 API takes one combined matrix.
- Changes: Qualified the Pradhan citation in `doc/hawaii-capn-model.md`; set fixed Hawaii effort as the reference policy, retained the uncertain 0.07589 effort response as a scenario, and added illustrative catch and cost scenarios. No citation inserted into the manuscript.
- Stopping reason and gaps: The working model runs with R 4.4.1 and `capn` 1.0.0; the current `capn` 2.0.0 branch follows the official manual but has not been run locally because R 4.5 is unavailable. Cost CSV lineage and empirical annual fleet responses remain unresolved.

### 2026-10-19 13:45 PDT, advisor attachment review
- Task and manuscript version: Assess whether the user-supplied Pradhan, Sharma, and Leung (2003) paper and advisor correspondence identify logistic bigeye growth parameters or Hawaii harvest parameters; no manuscript citation was edited.
- Searches: Web search, 2026-10-19, no filters: `"Analyzing Technical and Economic Interrelationships in Hawaii’s Longline Fishery" DOI Pradhan Sharma Leung 2003`; `bigeye tuna western central Pacific surplus production model intrinsic growth rate carrying capacity r K`; `WCPFC 2026 bigeye tuna assessment MSY BMSY biomass reference points`; `"Analyzing Technical and Economic Interrelationships in Hawaii's Longline Fishery" "10."`; `Pradhan Sharma Leung 2003 Marine Resource Economics 18 167 193 DOI`; publisher-domain search for title and candidate DOI. Result counts unavailable. Inspected local PDF text and images of Tables 5–7, University of Hawaii-hosted author reprint, and the WCPFC 2026 assessment listing.
- Screening and citation chasing: The attached 2003 paper is directly relevant to Hawaii longline harvest response. The 1999 technical-efficiency paper was mentioned in the correspondence but was not inspected here. Search results did not identify a directly verified WCPO bigeye logistic `r,K` source. The 2026 WCPFC stock assessment uses an age-structured model; it was not inspected for a logistic parameter pair in this invocation.
- Changes: Added Pradhan et al. as a proposed source for historical Hawaii bigeye catch response only. Its Table 7 reports tuna-trip bigeye effort elasticity 0.2753 (SE 0.1023) and stock-index elasticity 0.7955 (SE 0.0772); Tables 5–6 give different values for swordfish and mixed trips. These are not logistic growth `r,K`; effort is trip days times vessel net tonnage and the stock index is quarterly fish per 1,000 hooks, so neither elasticity can be directly inserted as the current trip exponent or total-biomass elasticity. Candidate DOI found in a secondary index could not be confirmed by DOI resolver, Crossref, or publisher, all inaccessible through the web tool.
- Stopping reason and gaps: Enough evidence to answer whether the attachment supplies `r,K` or a directly transferable `alpha`; a broader search for a biological model remains. Publisher DOI and update status unresolved. No numerical model changes.

### 2026-10-19 PDT
- Task and manuscript version: Rebuild model parameters and implement a Hawaii `capn` run; reviewed supplied REV5 manuscript and both parameter documents.
- Searches: Web search on 2026-10-19, no filters: `Fenichel Abbott 2014 Natural Capital From Metaphor to Measurement equation q alpha gamma y cost reef fish carrying capacity`; `site:wcpfc.int bigeye tuna 2018 spawning biomass 655441 159020 MSY`; `"623,121" "bigeye" biomass`; `"742,967" "108,520" bigeye`; `site:meetings.wcpfc.int "2,286,000" "742,967" "108,520"`; `site:noaa.gov Hawaii longline cost per trip bigeye 2018 variable cost trip NOAA`; `WCPFC 2020 bigeye assessment annual total biomass csv 2010 2018`; `site:github.com/PacificCommunity 2020 bigeye assessment biomass data`. Result counts unavailable; inspected publisher paper, WCPFC assessment and overview reports, NOAA metadata, and a Pacific Community diagnostic output described below.
- Screening and citation chasing: Started with user-supplied Fenichel and Abbott paper and the manuscript's WCPFC/NOAA citations. Used WCPFC original reports where available. Excluded search snippets and third-party mirrors as evidence.
- Changes: Added parameter-method and data-source records below. No manuscript citations edited. Documented that the old annual biomass series mixes assessment vintages and biomass types.
- Stopping reason and gaps: Enough primary material to construct a provisional one-period calibration. The 2026 Pacific Community public diagnostic CSV contains annual *relative spawning* status, not absolute total biomass; it cannot directly supply the required annual state. A coherent annual total-biomass series, WCPO-only Hawaii economics, independently estimated effort elasticities, and CSV lineage remain unavailable. DOI resolver and Crossref pages did not load through the web tool; paper DOI and identity were confirmed on the publisher page. Publisher notice check was limited to the article page.

### 2026-10-19 PDT, follow-up search
- Task: Locate a numeric annual WCPO total-biomass series and a Hawaii WCPO/EPO bigeye catch and effort split for the working model.
- Searches: `site:github.com/PacificCommunity/ofp-sam-bet-2026-diagnostic total biomass csv annual`; `site:fisheries.noaa.gov Hawaii longline 2010 WCPO EPO bigeye catch effort annual report`; `site:repository.library.noaa.gov 2010 Hawaii longline WCPO EPO bigeye catch effort`; `"2010" "3,576" "1,356" "3,535" bigeye`; `"2010" "3,535" "42" "bigeye" Hawaii`. Result counts unavailable. Inspected Pacific Community repository tree, TAF source and CSV; NOAA 2010 logbook and 2011 WCPFC Part I reports; NOAA 2019 environmental assessment. The 2015 NOAA regulatory impact review was found via indexed text, but direct access to the host returned HTTP 403.
- Findings: The Pacific Community 2026 diagnostic `TAF/output/summary.csv` has annual 1952–2024 `tb` total biomass, `sb` spawning biomass and `catch`; copied without transformation to `data/wcpfc_bigeye_2026_diagnostic_annual.csv`. NOAA 2015 review Table 1 distinguishes 2010 Hawaii WCPO/EPO retained bigeye and WCPO deep/shallow-set catch. NOAA 2011 WCPFC report independently gives 3,576 tonnes U.S. North Pacific WCPO longline bigeye in 2010, while its treatment of dual-permit, Hawaii-landed catches follows territory attribution rules.
- Limits: The 2026 diagnostic is a single fitted model, not an uncertainty ensemble, and cannot be combined directly with 2011 `B_0`/MSY. NOAA catch weights are estimates from logbook numbers and average landed weights and differ from the supplied pounds-sold CSV. The public 2010 Hawaii logbook's area tables separate EEZ from other waters, not WCPO from EPO; no WCPO-specific trip, cost or price split was found. The 2015 review's deep/shallow values remain provisional until its PDF can be opened directly.

### 2026-10-19 PDT, aggregate-data implementation
- Task: Implement WCPO Hawaii catch and a trip-share scenario calibration using public aggregates.
- Searches: `Hawaii longline 2010 WCPO EPO fishing effort hooks sets public table`; `site:meetings.wcpfc.int 2010 United States Hawaii longline effort WCPO hooks`; `site:fisheries.noaa.gov Hawaii longline catch effort western central eastern pacific public aggregate`; `"2010" "3,535" "deep" "bigeye" "Hawaii"`. Result counts unavailable. Inspected NOAA-hosted Hawaii fleet programming study and the indexed NOAA 2015 regulatory impact review table.
- Findings: The 2015 review's Table 1 provides geographic and gear catch splits, but no trip counts. The Hawaii fleet study reports separate 2012 WCPO and EPO cost summaries and 2010 vessel participation by target; its vessel counts overlap and cannot be treated as trip shares. Implemented a catch-share proxy plus 60%–100% trip-share scenarios. No manuscript citations changed.
- Limits: The NOAA review PDF remained inaccessible directly. The trip-share range is a judgmental scenario range, not a confidence interval. Price and per-trip cost still use the supplied all-area CSV. A single assessment vintage for the annual biomass calibration remains outstanding.

### 2026-10-19 PDT, supplied NOAA PDF check
- Task: Verify the 2010 geographic catch split directly in the user-supplied NOAA regulatory impact review.
- Material inspected: `doc/NOAA-NMFS-2015-0085-0003_content.pdf`, title page, text preceding Table 1, Table 1 and source/notes on printed pages 12–13 (PDF pages 14–15). Local PDF SHA-256: `5915f8dbc96d21b8e80d79fdb00b1a445bd7c418ee4953fc3a8a13c3b0adee35`.
- Finding: The PDF confirms 2010 WCPO 3,576 tonnes, EPO 1,356 tonnes, WCPO deep-set 3,535 tonnes and WCPO shallow-set 42 tonnes. The table excludes the longline fisheries of the three U.S. Participating Territories. The estimates use logbook fish counts and average fish weights from landings; revisions and confidentiality exclusions are noted.
- Action: Mark NOAA geographic catch figures as directly verified. The current R calibration already uses 3,535 tonnes, so no numerical model change was needed.

### 2026-10-19 PDT, single-vintage stock calibration
- Task: Replace the older 2011 biomass/MSY logistic proxy with a growth fit using one 2026 diagnostic assessment output; rerun the valuation and inspect the other-fleet response assumption.
- Sources reviewed: Pacific Community public 2026 diagnostic `TAF/output/summary.csv` and `TAF/output_pop.R`, previously logged below; WCPFC 2026 stock-assessment document listing at https://meetings.wcpfc.int/node/33590. No new manuscript citations were inserted.
- Calculation: For annual mean `tb` and annual `catch`, computed implied growth `B[t+1]-B[t]+C[t]` and fit `r B[t] - (r/K) B[t]^2` without an intercept. Baseline 1980–2023 gives `r=0.4815835`, `K=1,205,670 t`, annual-growth RMSE 24,094 t. The 2010 biomass state is 577,051 t and all-fleet assessment catch is 136,971.9 t. Fit windows 1952, 1970, 1975, 1980, 1990 and 2000 were compared; windows with fitted `K` below the period's largest stock were excluded from valuation scenarios.
- Reproducibility: The local `data/wcpfc_bigeye_2026_diagnostic_annual.csv` used for the fit has SHA-256 `6c681acdee0de65863139f2e45b664ad9e2014977cf31b8d062d25d013f7196c`.
- Response assumption: `beta_other=1` is a constant-exploitation scenario; 1.25, 1.5 and 2 are sensitivity cases. Aggregate log-catch/log-biomass slopes varied from negative to positive with period, so they were not used to identify fleet behavior.
- Limits: The 2026 diagnostic is a single assessment fit. The age-structured model has recruitment and timing effects absent from a deterministic logistic approximation. In 2010, the baseline growth residual is about -24,033 t, so the reduced-form trajectory does not reproduce that year's biomass change. Growth-window and response scenarios are not confidence intervals.

## Reference entries

### Pan2018
- Full reference: Pan, Minling. 2018. *Tracking Changes on Fishery Economic Performance: Continuous Economic Data Collection Programs for the Hawaii and American Samoa Longline Fisheries 2005–2016*. NOAA Technical Memorandum NMFS-PIFSC-73. Pacific Islands Fisheries Science Center.
- In-text citation: Pan (2018).
- DOI: https://doi.org/10.25923/hqhf-d906 (listed by NOAA repository; independent DOI resolver check unavailable).
- Paper: https://repository.library.noaa.gov/view/noaa/18661
- Full text: https://repository.library.noaa.gov/view/noaa/18661/noaa_18661_DS1.pdf, NOAA PDF.
- Publication type and status: NOAA technical memorandum; no notice seen on inspected repository page, independent update check unavailable.
- Bibliographic verification: Title, author, date, report type, and DOI shown on NOAA repository record on 2026-10-19; Table 3 and cost definitions checked in the NOAA PDF.
- Status check: NOAA repository record inspected 2026-10-19; separate notice registry unavailable.
- Material inspected: Cost data definitions, trip sample table, and geographic cost discussion, especially pp. 11–15, 21–24.
- Use status: Cited in model notes for trip-count discrepancy; not cited in manuscript.

#### Citation use: 2010 trip count and scope
- Manuscript claim: Proposed wording in model notes: “Pan (2018) reports 1,216 total Hawaii deep-set tuna trips in 2010, versus 1,193 in the supplied CSV; the source of the difference is unknown.”
- Reason for citing: Establishes a public cross-check for the CSV's effort denominator and cost definition.
- Supporting evidence: Table 3 gives 1,216 total deep-set trips in 2010. The report states its trip costs exclude labor and describes separate EEZ, EPO, and WCPO cost samples.
- Evidence locator: Table 3, PDF p. 19; discussion of cost scope, PDF pp. 21, 27; geographic definitions and Table 8, PDF pp. 29–32.
- Fit and limits: Direct for the NOAA report; cannot identify why the user's CSV has 1,193 trips or whether its exact $23,203.68 per-trip figure came from the same processing pipeline.
- Action: Added qualified comparison to model notes; do not replace the user CSV without a source reconciliation.

### PradhanSharmaLeung2003
- Full reference: Pradhan, Naresh C., Khem R. Sharma, and PingSun Leung. 2003. “Analyzing Technical and Economic Interrelationships in Hawaii’s Longline Fishery.” *Marine Resource Economics* 18(2): 167–193.
- In-text citation: Pradhan, Sharma, and Leung (2003).
- DOI: Candidate `https://doi.org/10.1086/mre.18.2.42629391` appears in a secondary index; not confirmed by authoritative DOI or publisher record.
- Paper: https://www.soest.hawaii.edu/PFRP/reprints/pradhan_analyzing_2003.pdf (University of Hawaii-hosted author reprint; publisher landing page unavailable).
- Full text: User-supplied `doc/18.2_04Pradhan.pdf`, matched to the University of Hawaii-hosted reprint.
- Publication type and status: Journal article; publisher notice and registry status checks unavailable.
- Bibliographic verification: Title, complete ordered author list, venue, year, and pages matched the local full text and University of Hawaii reprint on 2026-10-19. Volume issue inferred from indexed record and journal issue; authoritative publisher page inaccessible. DOI unresolved.
- Status check: Attempted publisher and DOI resolver on 2026-10-19; both inaccessible via the web tool. No conclusion on notices.
- Material inspected: Full text methods on stock and effort indices; Tables 5–7 and discussion, especially pp. 177–179 and 185–188.
- Use status: Cited in `doc/hawaii-capn-model.md` for historical Hawaii catch-response context; not cited in manuscript.

#### Citation use: historical catch response
- Manuscript claim: Proposed wording: “A trip-level study of Hawaii longliners using 1991–1998 data found positive bigeye catch responses to composite effort and a CPUE-based abundance index, with estimates varying by trip type.”
- Reason for citing: Empirical context for uncertainty in harvest response parameters and multispecies production.
- Supporting evidence: Bigeye on tuna trips has composite-effort elasticity 0.2753 (SE 0.1023) and stock-index elasticity 0.7955 (SE 0.0772). On swordfish and mixed trips, the respective elasticities are 0.3641/0.4676 and 0.3939/0.3787.
- Evidence locator: Tables 5–7, printed pp. 185, 186, 188; definitions of effort and stock index, pp. 177–178.
- Fit and limits: Direct for historical trip-level associations under the study's composite effort and CPUE-index definitions. Does not identify logistic `r,K`, a trips-only `alpha`, or a total-biomass catch elasticity in 2010.
- Action: Added qualified context in model notes and illustrative `alpha` scenarios in the R output; did not substitute its elasticities directly into the model or insert the citation into the manuscript.

### FenichelAbbott2014
- Full reference: Fenichel, Eli P., and Joshua K. Abbott. 2014. “Natural Capital: From Metaphor to Measurement.” *Journal of the Association of Environmental and Resource Economists* 1(1/2): 1–27.
- In-text citation: Fenichel and Abbott (2014).
- DOI: https://doi.org/10.1086/676034 (printed by publisher; resolver unavailable in this audit).
- Paper: https://www.journals.uchicago.edu/doi/full/10.1086/676034
- Full text: Publisher HTML, inspected.
- Publication type and status: Journal article; no notice found on inspected publisher page; independent update check unavailable.
- Bibliographic verification: Title, authors, journal, volume/issue, date, DOI matched publisher page on 2026-10-19; page span also appears in the supplied manuscript bibliography.
- Status check: Publisher page inspected 2026-10-19; Crossmark/registry check unavailable.
- Material inspected: Empirical reef-fish application, calibration and numerical approximation, capitalization discussion.
- Use status: Currently cited in manuscript; method source for new script.

#### Citation use: model specification
- Manuscript claim: The asset price can be approximated from a stock dynamic and net benefit function under an observed management program.
- Reason for citing: Original method and empirical precedent for `capn` application.
- Supporting evidence: The paper models logistic biomass growth, generalized Schaefer harvest, empirical effort response, profit as price times harvest minus cost per effort, and collocation of the value function.
- Evidence locator: Empirical application, equations 15–16 and surrounding text; numerical approximation paragraph.
- Fit and limits: Direct method support; its Gulf parameters do not estimate Hawaii parameters.
- Action: Retain method citation; qualify Hawaii calibration as separate.

### HarleyWilliamsNicolHampton2011
- Full reference: Harley, Shelton J., Peter Williams, Simon Nicol, and John Hampton. 2011. *The Western and Central Pacific Tuna Fishery: 2010 Overview and Status of Stocks*. Tuna Fisheries Assessment Report 11. Nouméa: Secretariat of the Pacific Community.
- In-text citation: Harley et al. (2011).
- DOI: DOI not found in checked WCPFC report.
- Paper: https://meetings.wcpfc.int/file/606/download
- Full text: WCPFC-hosted PDF, inspected.
- Publication type and status: Technical report; update notices not found on inspected report.
- Bibliographic verification: Title, complete author list, report number, year, and publisher matched title page and suggested citation on 2026-10-19.
- Status check: WCPFC report inspected 2026-10-19; no separate notice registry checked.
- Material inspected: Title and Table 3.
- Use status: Proposed in model notes; not inserted in manuscript.

#### Citation use: 2011 assessment inputs
- Manuscript claim: Proposed wording: “The 2011 assessment reports recent total biomass of 623,121 t, unfished biomass of 1,432,000 t, and MSY of 76,760 t/year.”
- Reason for citing: Distinguishes observed recent biomass from unfished biomass for a single assessment vintage.
- Supporting evidence: Table 3 defines `B_current` as a recent 3–4 year average and reports `B_0`, `B_current`, and MSY separately.
- Evidence locator: Table 3, PDF page 30.
- Fit and limits: Direct for assessment quantities; does not establish logistic carrying capacity or 2010-specific biomass.
- Action: Use in parameter record and model notes; qualify time interpretation.

#### Citation use: original 2010 WCPO catch
- Manuscript claim: Proposed wording: “The 2011 report provisionally estimated 2010 WCPO bigeye catch at 125,757 t; a later report revised that year to 140,199 t.”
- Reason for citing: Defines a source-revision sensitivity scenario.
- Supporting evidence: The 2011 report identifies 125,757 t as provisional for 2010; Brouwer et al. (2018), Table 2, reports 140,199 t for 2010.
- Evidence locator: Harley et al. (2011), Overview and Table 2; Brouwer et al. (2018), Table 2.
- Fit and limits: Direct for reported figures; the reason for each revision was not traced.
- Action: Use later revised catch in baseline and earlier provisional catch in sensitivity.

### HarleyDaviesHamptonMcKechnie2014
- Full reference: Harley, Shelton, Nick Davies, John Hampton, and Sam McKechnie. 2014. *Stock Assessment of Bigeye Tuna in the Western and Central Pacific Ocean*. WCPFC-SC10-2014/SA-WP-01, Rev. 1. Secretariat of the Pacific Community.
- In-text citation: Harley et al. (2014).
- DOI: DOI not found in checked WCPFC report.
- Paper: https://meetings.wcpfc.int/file/3483/download
- Full text: WCPFC-hosted PDF, inspected.
- Publication type and status: Technical stock assessment; update notices not found on inspected report.
- Bibliographic verification: Title, full author list, year, report symbol and revision matched title page on 2026-10-19.
- Status check: WCPFC report inspected 2026-10-19; no separate notice registry checked.
- Material inspected: Title, Table 7, current/latest definitions.
- Use status: Proposed in model notes; not inserted in manuscript.

#### Citation use: old annual series interpretation
- Manuscript claim: Proposed wording: “The 742,967 t value is a recent mean total biomass from the 2014 assessment, not an annual estimate for 2013–2016.”
- Reason for citing: Corrects the old model's repeated annual stock assignment.
- Supporting evidence: Table 7 labels the quantity `B_current` and defines “current” as the average over 2008–2011; `B_0` is 2,286,000 t and MSY is 108,520 t/year in the reference case.
- Evidence locator: Table 7, PDF page 46.
- Fit and limits: Direct; does not provide a 2014 annual total biomass value.
- Action: Use in model notes; seek a coherent annual series before manuscript time-series claims.

### BrouwerEtAl2018
- Full reference: Brouwer, Stephen, Graham Pilling, John Hampton, Peter Williams, Laura Tremblay-Boyer, Matthew Vincent, Neville Smith, and Thomas Peatman. 2018. *The Western and Central Pacific Tuna Fishery: 2017 Overview and Status of Stocks*. Tuna Fisheries Assessment Report 18. Nouméa: Pacific Community.
- In-text citation: Brouwer et al. (2018).
- DOI: DOI not found in checked WCPFC report.
- Paper: https://meetings.wcpfc.int/file/6839/download
- Full text: WCPFC-hosted PDF, inspected.
- Publication type and status: Technical report; update notices not found on inspected report.
- Bibliographic verification: Title, all authors in order, report number, publisher and year matched title and catalog pages on 2026-10-19.
- Status check: WCPFC report inspected 2026-10-19; no separate notice registry checked.
- Material inspected: Tables 2, 3, and 6; biomass definitions.
- Use status: Proposed in model notes; not inserted in manuscript.

#### Citation use: total WCPO removals
- Manuscript claim: Proposed wording: “WCPO bigeye catch in 2010 was 140,199 t across fleets.”
- Reason for citing: Stock dynamics require all-fleet removals from the WCPO biomass state.
- Supporting evidence: Table 2 lists bigeye catch by year; Table 6 provides gear detail.
- Evidence locator: Tables 2 and 6, PDF pages 36 and 43.
- Fit and limits: Direct; catch estimates were revised after 2010 and are not identical to Hawaii sold landings.
- Action: Use in model inputs; document date and region.

#### Citation use: spawning biomass mismatch
- Manuscript claim: Proposed wording: “The 665,441 t number is a recent average of spawning potential, not total biomass, and the source does not support 655,441 t.”
- Reason for citing: Prevents combining incompatible biomass types and identifies a likely transcription error.
- Supporting evidence: Table 3 reports `SB_recent = 665,441 t` and `SB_F=0 = 1,858,775 t`, with explicit definitions.
- Evidence locator: Table 3, PDF page 37.
- Fit and limits: Direct for type and reported value; transcription-error diagnosis is an inference from the old code and report.
- Action: Exclude from total-biomass model until a consistent assessment series is obtained.

### NOAA2010sTripExpenditure
- Full reference: Pacific Islands Fisheries Science Center. 2026. *Hawaii Longline Fishery Trip Expenditure (2004 to present)*. NOAA Fisheries InPort dataset metadata, item 5662.
- In-text citation: Pacific Islands Fisheries Science Center (2026).
- DOI: DOI not found in checked metadata.
- Paper: https://www.fisheries.noaa.gov/inport/item/5662
- Full text: Metadata page inspected; raw confidential survey not accessed.
- Publication type and status: Dataset metadata, updated 2026-03-04.
- Bibliographic verification: NOAA item title, organization, citation and update date matched page on 2026-10-19.
- Status check: NOAA metadata page inspected 2026-10-19; no notice found.
- Material inspected: Summary, cost items, access and lineage.
- Use status: Proposed in model notes; not inserted in manuscript.

#### Citation use: cost scope
- Manuscript claim: Proposed wording: “NOAA's trip expenditure survey tracks variable trip costs but omits labor costs.”
- Reason for citing: Defines the economic scope of the supplied cost proxy.
- Supporting evidence: NOAA summary names ten variable cost items and states that labor costs are excluded.
- Evidence locator: InPort item 5662, Summary.
- Fit and limits: Direct for NOAA survey; lineage of `data/cost_per_pound.csv` to this dataset is unverified.
- Action: Use as contextual source; verify CSV creation before attributing its values to NOAA.

## Unresolved candidates and exclusions

- 2020 WCPFC bigeye assessment: inspected as a candidate for a consistent 2010–2018 biomass series. The accessible report provides time-series figures, but no numeric annual total-biomass table was identified. No annual series transcribed from plots.
- Pacific Community 2026 public [diagnostic status CSV](https://github.com/PacificCommunity/ofp-sam-bet-2026-ensemble/blob/main/data/diagnostic/dynamic-status.csv): annual depletion, `SB/SB_MSY`, and `F/F_MSY` for 1952–2024, but no absolute total biomass in tonnes. The separate 2026 diagnostic TAF summary does contain absolute annual total biomass.
- `doc/Model Parameters.docx` values for `alpha`, `gamma`, `y`, `q`, and `r`: retained as historical working assumptions, not verified empirical Hawaii estimates.

### PacificCommunityBET2026Diagnostic
- Full reference: Pacific Community. 2026. *BET 2026 Diagnostic model*, TAF output, `summary.csv` and `output_pop.R`.
- In-text citation: Pacific Community (2026).
- DOI: None identified.
- Data: https://raw.githubusercontent.com/PacificCommunity/ofp-sam-bet-2026-diagnostic/main/TAF/output/summary.csv
- Method: https://github.com/PacificCommunity/ofp-sam-bet-2026-diagnostic/blob/main/TAF/output_pop.R
- Publication type and status: Public model repository, diagnostic fit. The 2026 WCPFC assessment is documented separately at https://meetings.wcpfc.int/node/33590; equivalence of this repository snapshot to the final WCPFC assessment reference fit was not checked.
- Material inspected: `TAF/README.md`, `TAF/output_pop.R`, `TAF/output/summary.csv`, `TAF/output/biomass.csv`.
- Use status: Data copied into repository as a candidate annual state series; not yet used by the valuation script.

#### Citation use: annual stock state
- Proposed claim: “A single 2026 bigeye diagnostic fit estimates WCPO annual total biomass of 577,051 tonnes in 2010 and 570,509.75 tonnes in 2018.”
- Supporting evidence: The CSV reports these values under `tb`; generation code computes `tb` from `seasonMeans(totalBiomass(rep))`, aggregated across areas by year. `sb` is separately derived from `SB(rep)`.
- Evidence locator: `TAF/output_pop.R`, Summary block; `TAF/output/summary.csv`, 2010 and 2018 rows.
- Fit and limits: Direct for this diagnostic output. This is model-estimated annual total biomass, not an observed survey series or ensemble average. Matching growth parameters are still needed.
- Action: Preserve raw CSV and use only with a consistent assessment calibration.

### NOAA2011USWCPFCReport
- Full reference: National Marine Fisheries Service and Pacific Islands Fisheries Science Center. 2011. *2011 Annual Report to the Western and Central Pacific Fisheries Commission, United States of America, Part I (for 2010)*. PIFSC Data Report DR-11-009.
- In-text citation: NMFS and PIFSC (2011).
- DOI: None identified.
- Report: https://repository.library.noaa.gov/view/noaa/5296/noaa_5296_DS1.pdf
- Material inspected: Introduction and Table 1f, including treatment of dual-permit vessels.
- Use status: Supports WCPO 2010 U.S. North Pacific longline bigeye landings and flags attribution caveat.

#### Citation use: Hawaii geographic catch
- Proposed claim: “The report attributes 3,576 tonnes of 2010 bigeye landings to the U.S. North Pacific longline fishery within the WCPFC statistical area.”
- Supporting evidence: Introduction and Table 1f give 3,576 tonnes, while Table 1f also separately gives 315 tonnes landed by Hawaii-based dual-permit vessels attributed to American Samoa in the North Pacific.
- Evidence locator: PDF pages 1, 9 and 19.
- Fit and limits: Direct for reported regulatory fleet categories; a Hawaii-landed economic series can include catches assigned to another territory and also EPO landings.
- Action: Do not replace all-Hawaii economic catch with 3,576 tonnes without reconciling geography and permit attribution.

### NOAA2010HawaiiLogbook
- Full reference: Pacific Islands Fisheries Science Center. 2011. *The Hawaii-based Longline Logbook Summary Report, January–December 2010*. PIFSC Data Report DR-11-003.
- In-text citation: PIFSC (2011).
- DOI: None identified.
- Report: https://repository.library.noaa.gov/view/noaa/4996/noaa_4996_DS1.pdf
- Material inspected: Pages 1–2 and Tables 1–8.
- Use status: Candidate effort source, but no WCPO/EPO division in its published area tables.

#### Citation use: effort geography
- Proposed claim: “The Hawaii-based fleet made 1,205 deep-set trips in 2010, and the report's geography tables divide EEZ and non-EEZ areas rather than WCPO and EPO.”
- Supporting evidence: Text and Tables 1–8.
- Evidence locator: PDF pages 1–9.
- Fit and limits: Direct for logbook report; the supplied cost CSV reports 1,193 deep-set trips, a separate series requiring lineage reconciliation.
- Action: Do not use the logbook's EEZ share as a WCPO share.

### NOAA2015BigeyeRIR
- Full reference: National Marine Fisheries Service, Pacific Islands Regional Office. 2015. *Regulatory Impact Review for a Rule to Implement Decisions of the Western and Central Pacific Fisheries Commission for: Bigeye Tuna Catch Limits in Longline Fisheries for 2015*. RIN 0648-BF19. July 2015.
- In-text citation: NMFS (2015).
- DOI: None identified.
- Report: https://downloads.regulations.gov/NOAA-NMFS-2015-0085-0003/content.pdf
- Local copy: `doc/NOAA-NMFS-2015-0085-0003_content.pdf`.
- Material inspected: Title page, printed pages 12–13 (PDF pages 14–15), including Table 1 and its notes. Direct web request returned HTTP 403, but the user supplied the PDF locally.
- Use status: Directly verified catch split used in the provisional R calibration.

#### Citation use: 2010 WCPO/EPO and gear split
- Proposed claim: “The review tabulates 2010 Hawaii bigeye retained catch as 3,576 tonnes WCPO and 1,356 tonnes EPO, with 3,535 tonnes WCPO deep-set and 42 tonnes WCPO shallow-set.”
- Supporting evidence: Table 1 provides the figures. The source note says NMFS estimated weights from logbook numbers of fish and average fish weights derived from landings; the report notes later revisions and confidentiality exclusions.
- Evidence locator: Table 1 and notes, printed page 13, PDF page 15; fleet-scope statement on printed page 12, PDF page 14.
- Fit and limits: Direct for the reported fishery categories. WCPO aggregate is independently corroborated in NOAA's 2011 WCPFC report. Rounded gear components sum to 3,577 tonnes, one tonne above the reported WCPO total. The figures are estimated retained catch, not the supplied pounds-sold series or a trip count.
- Action: Retain 3,535 tonnes as the provisional model's 2010 WCPO deep-set catch and cite the directly inspected report.

### HawaiiFleetPMPStudy
- Full reference: *How Do Fishery Policies Affect Hawaii's Longline Fishing Industry? Calibrating a Positive Mathematical Programming Model*. NOAA institutional-repository copy; complete bibliographic details were not checked in this targeted audit.
- In-text citation: To be finalized after bibliographic verification.
- DOI: Not checked.
- Paper: https://repository.library.noaa.gov/view/noaa/54805/noaa_54805_DS1.pdf
- Material inspected: Tables 1–2 and associated modeling description.
- Use status: Context for sensitivity design; no numerical cost figures imported into the current valuation.

#### Citation use: geographic economics
- Proposed claim: “Public research separates WCPO and EPO fishing costs for a 2012 Hawaii vessel sample and reports vessels fishing in both areas.”
- Supporting evidence: Table 1 reports cost summaries by target; Table 2 reports 2010 WCPO and EPO modeled vessel counts and notes that vessels may fish more than one target.
- Evidence locator: PDF pages 24–25.
- Fit and limits: Supports treating geographic effort/cost allocation as uncertain. 2012 sampled costs do not give 2010 WCPO trip counts or a direct ratio to apply to the supplied cost CSV.
- Action: Cite only for scenario motivation; do not substitute its figures for 2010 observations.
