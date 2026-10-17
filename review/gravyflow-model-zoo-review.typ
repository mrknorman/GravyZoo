#set document(title: "gravyflow model zoo: literature review", author: "Michael Norman")
#set page(paper: "a4", margin: (x: 1.7cm, top: 2cm, bottom: 2cm), numbering: "1",
  header: context { if counter(page).get().first() > 1 [#set text(size: 7.5pt, fill: luma(110)); gravyflow model zoo: literature review #h(1fr) Work in progress] })
#set text(size: 9.6pt, lang: "en", region: "gb")
#set par(justify: true, leading: 0.62em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => { v(0.6em); it; v(0.25em) }
#show link: set text(fill: rgb("#24527a"))
#let gr-c = box(fill: rgb("#d9eed9"), inset: (x: 2pt, y: 1pt), radius: 1.5pt, text(size: 6pt, "comparable"))
#let gr-k = box(fill: rgb("#f6ead2"), inset: (x: 2pt, y: 1pt), radius: 1.5pt, text(size: 6pt, "conditional"))
#let gr-n = box(fill: rgb("#ececec"), inset: (x: 2pt, y: 1pt), radius: 1.5pt, text(size: 6pt, "not comparable"))
#let pend = text(fill: rgb("#9a5b00"), style: "italic", "pending")
#let callout(title, body) = block(width: 100%, fill: rgb("#f2f6fb"), stroke: (left: 2.2pt + rgb("#3a6ea5")), inset: (x: 8pt, y: 6pt), radius: 1.5pt, breakable: true)[#text(weight: "bold", title) #linebreak() #body]
#let tbl(..args) = { set text(size: 6.6pt); set par(justify: false, leading: 0.45em); table(stroke: 0.35pt + luma(185), inset: (x: 3pt, y: 2.4pt), ..args) }

#align(center)[
  #text(size: 17pt, weight: "bold")[Machine learning for gravitational-wave detector data:\ a literature review catalogue for the gravyflow model zoo]
  #v(0.4em)
  #text(size: 11pt)[Michael Norman]
  #v(0.2em)
  #text(size: 9pt)[Status: *Work in progress* #h(1em) October 2026]
]
#v(0.8em)
#block(inset: (x: 1.2em))[#text(weight: "bold")[Abstract.] We catalogue 313 machine-learning models for gravitational-wave detector data, 138 from the first catalogue (seeded by a thesis literature review) and 175 added by completeness sweeps, and extract 3160 reported metrics from the papers, 676 of them read from figures. For each model we place its headline results on a small set of comparison axes that the literature supports: efficiency at a false-alarm rate normalised per month and in hertz, sensitive distance or volume at a false-alarm rate, Gravity Spy accuracy and macro-F1 with the dataset release, waveform overlap for denoisers, calibration and bias for parameter estimation, and sensitivity depth for continuous waves. Only 26 models are directly comparable on a shared contract and 79 more conditionally; 208 report metrics that cannot be placed on a shared axis. We list 381 suspected errors or internal inconsistencies across 228 papers, record which models release code (106) and trained weights (29), and set out the programme for reproducing these models in gravyflow. Every model carries a placeholder for our reproduction, which is pending.]
#v(0.4em)
#outline(depth: 1, indent: auto)
#pagebreak()
= Scope and method <sec-scope>
*Sources.* The starting point was the literature review of the owner's thesis, which contributed 46 of the original 138 entries; arXiv and web searches completed the first catalogue. The completeness sweeps then proposed 186 further papers. Four were dropped at the sweep (a review, a population-level classifier, a likely duplicate and an ID fix); of the remaining 182, 175 are kept and 7 are dropped here because they do not train on or apply to gravitational-wave detector data (Table 2). Duplicates in the first catalogue had been merged before.

*Metric extraction.* Each paper was read by an extraction agent from its PDF, with figures rendered as page images. For every reported metric the agent recorded the value, units, the conditions under which it was measured (noise, population, SNR range, test-set size), its location in the paper (table, figure or section) and whether it was stated in the text or read from a figure; read-from-figure values carry the reading uncertainty noted in the catalogue. The agents also recorded code repositories (checked on the hosting site for licence, last commit and trained weights) and every internal inconsistency they found, with its evidence.

*Grading.* The synthesiser then placed the headline metrics of each paper on the shared axes of Table 1, converted false-alarm rates to per month (30-day months, the MLGWSC-1 convention) and to hertz where the paper states a rate or a fraction over disjoint segments of stated length, and graded each model comparable, conditionally comparable or not comparable, saying what differs. Suspected errors highlighted in this review are a selection of the extracted inconsistencies, stated neutrally; they are reading notes, not verdicts, and each should be checked against the paper before it is relied on. All 381 extracted notes are kept in the machine-readable catalogue.

*Archive.* PDFs were downloaded from arXiv only; 276 of the 313 models have a paper in the private archive. The remaining 37 have no arXiv version: their dossiers rest on the publisher's or INSPIRE's abstract page, and they are marked as such. The archive is private and is not redistributed.

*Numbers.* Every number in the tables is the paper's, located by table, figure or section; "read-from-figure" marks values read from a plot. No value was invented or interpolated by the synthesiser beyond the unit conversions stated.

#v(0.3em)
*Table 1.* Comparison axes and grades used throughout.

#tbl(columns: (auto, 1fr), table.header([*Axis*], [*Meaning*]),
  "eff@FAR", "Detection efficiency (TPR) at a FAR that is a rate per unit time; far_hz and far_per_month given.",
  "FAR@eff", "FAR at fixed efficiency.",
  "reach@FAR", "Sensitive distance or volume (or hrss50 for bursts) at a stated FAR; the search-grade comparison.",
  "eff@FAP", "TPR at a per-window or per-sample false-alarm probability: not a rate; comparable only with the same window length, noise and SNR distribution.",
  "AUC", "Area under ROC; quoted only where noise and SNR distribution are stated, otherwise noted as such.",
  "GS", "Glitch classification on a Gravity Spy release: accuracy and macro-F1 with release, class count and split.",
  "overlap", "Denoising/extraction: overlap or match with the injected waveform.",
  "range", "Noise regression: BNS inspiral-range or VT gain on real data.",
  "PE", "Parameter estimation: calibration (P-P / coverage), bias or JSD against a sampler, sampling efficiency.",
  "depth@pfa", "Continuous waves: sensitivity depth at a false-alarm probability per frequency band.",
  "events", "Real catalogue events recovered (supplementary; never a substitute for efficiency at FAR).",
  "other", "A headline metric outside the shared axes.",
  [#gr-c], "Same contract as a published reference (MLGWSC-1, LVK injection sets, Gravity Spy split with re-trained baselines, CW depth at pfa), so numbers can be set side by side.",
  [#gr-k], "On a shared axis but with a stated difference (noise, population, detector count, dataset release, relative-only gain).",
  [#gr-n], "No shared axis: per-window fractions, private toy sets, qualitative or unread.",
)

*Table 2.* Added models dropped because they are not trained on or applied to gravitational-wave detector data.

#tbl(columns: (auto, auto, 1fr), table.header([*Key*], [*arXiv*], [*Reason (dossier)*]),
  "badaracco2020", "2005.09289", "Not applied to GW strain (uses seismic correlations; Virgo is not NN-limited so C_NN is modelled, not measured); one hour of data; universality of c(N)=a(1-1/bN) is unexplained; no real cancellation test.",
  "baltus2022light", "none", "Thesis body not read. The ML content is a compilation of Baltus et al. 2021 (PRD 103, 102003; baltus2021), the CBMI 2021 paper (baltus2021b), Baltus et al. 2022 (PRD 106, 042002; baltus2022), plus a sub-solar-mass matched-filter search and a sky-localisation chapter whose papers are not in the catal",
  "boudart2023", "none", "Thesis body not read. Its ML chapters correspond to catalogue entries boudart2022 (ALBUS, arXiv 2201.08727) and boudart2022glitch (arXiv 2210.04588).",
  "khan2021", "2112.07669", "Trained and tested on noiseless NRHybSur3dq8 surrogate waveforms; no detector noise or detector data is used anywhere (PyCBC comparison uses a flat PSD only to set the likelihood). It is a waveform-manifold regression study. Flagged for the owner: keep only as a noise-free PE reference, not as a ...",
  "mitra2023", "2310.15649", "No detector noise, no SNR/distance dependence, no detection stage; axisymmetric sims lack realistic prompt convection; one progenitor; classification of EOS labels not regression. Not an ML-on-detector-data model: the network is trained and tested on noise-free simulated waveforms, so is_ml_on_gw_de",
  "puecher2024", "2408.10678", "Trained on NR simulation parameters, not on detector data; classifier outputs depend on NR physics and EoS coverage (authors state this is the dominant uncertainty).",
  "whittaker2022", "2201.06461", "Not applied to detector data, noise, detection or parameter inference; the proof of principle is on a synthetic generator derived from the same 123 fits.",
)
= A short history and taxonomy <sec-history>
*Detection on whitened windows (2017-2019).* Two groups showed in 2017-2018 that a small convolutional network on one-second windows of whitened strain can approach matched-filter sensitivity for binary black holes at fixed per-window false-alarm probabilities #cite(<george2018>) #cite(<gabbard2018>), and that the same networks run on real O1 noise #cite(<george2018b>). A critique followed: per-window fractions are not search false-alarm rates, and networks must be judged on continuous data #cite(<gebhard2019>).

*Search-grade evaluation (2020-2022).* Schafer et al. reported sensitive distance against false-alarm rate on months of continuous simulated data and studied training strategies that keep the network usable at low false-alarm rates #cite(<schafer2020>) #cite(<schafer2021a>) #cite(<schafer2021b>). MLGWSC-1 made this contract a benchmark with four datasets, the last on real O3a noise, and found that the best entries came close to PyCBC on simulated noise but fell further behind on real noise #cite(<mlgwsc2022>).

*Production searches (2023-2026).* Networks then ran over full observing runs with time-slide backgrounds and the LVK injection campaigns: Aframe and its BNS extension #cite(<marx2024>) #cite(<marx2025aframeO3>) #cite(<gupta2026>), AresGW and Sage on MLGWSC-1 and O3 #cite(<nousi2022>) #cite(<koloniari2024>) #cite(<nagarajan2025>), SNR-series networks #cite(<beveridge2025o3>) #cite(<mcleod2025>) and anomaly pipelines #cite(<inguglia2026>). Machine learning inside cWB followed a parallel route for bursts #cite(<szczepanczyk2022>) #cite(<alvarez2022cwbml>).

*Glitches, denoising and inference.* Gravity Spy set the image format and labels for glitch classification #cite(<zevin2017>) #cite(<bahaadini2017>), later extended to O3 #cite(<soni2021>) #cite(<glanzer2023>). Denoising began with recurrent autoencoders #cite(<shen2017>) and noise regression from witness channels #cite(<ormiston2020>). Inference moved from point regressors to normalising-flow posteriors validated against samplers on real events #cite(<green2020>) #cite(<dax2021>) #cite(<dax2022>).

*Taxonomy.* We organise the catalogue by task (compact-binary detection, early warning, bursts, anomalies, continuous waves, glitches, denoising, parameter estimation, space-based detectors, other) and, within each task, by family. A second axis cuts across tasks: the input representation (whitened strain, time-frequency images, matched-filter SNR series, pipeline triggers or alert products, auxiliary witness channels). The representation determines most of the adaptation work in gravyflow (Section @sec-repro).

*Table 3.* Models per section, with grades.

#tbl(columns: (1fr, auto, auto, auto, auto, auto), table.header([*Section*], [*Models*], [*Added*], [*Comparable*], [*Conditional*], [*Not comparable*]),
  "Compact-binary detection", "92", "40", "12", "24", "56",
  "Early warning", "9", "3", "0", "3", "6",
  "Burst and unmodelled transients", "33", "12", "5", "10", "18",
  "Anomaly and multi-signal detection", "11", "7", "2", "1", "8",
  "Continuous and long-duration waves", "18", "14", "5", "5", "8",
  "Glitch classification and data quality", "56", "32", "0", "14", "42",
  "Denoising and signal extraction", "32", "19", "0", "13", "19",
  "Parameter estimation", "33", "28", "2", "9", "22",
  "Space-based detectors", "14", "12", "0", "0", "14",
  "Other: alerts, generators, lensing, backgrounds", "15", "8", "0", "0", "15",
)
= Compact-binary detection <sec-cbc>
Compact-binary coalescence (CBC) detection is the largest category. The early papers asked whether a network could match matched filtering on short whitened windows of simulated noise; the later ones ask whether a network-based search, run over months of real data with a measured background, reaches the sensitive distance of the production pipelines. Only the second kind of result can be compared across papers.

== Families and lineage
=== Deep Filtering and 1D classifiers on whitened strain
The first wave fed one-second windows of whitened strain to small 1D networks and compared them with matched filtering at fixed per-window false-alarm probabilities #cite(<george2018>) #cite(<gabbard2018>); real O1 noise and two-detector coincidence followed #cite(<george2018b>) #cite(<george2018plb>). Later work varied the waveform space (binary neutron stars, #cite(<krastev2020>) #cite(<krastev2021>); precession, #cite(<verma2022>); eccentricity and higher modes, #cite(<rebei2018>)), the architecture or training #cite(<xia2021>) #cite(<deighan2020>) #cite(<meijer2024>), and the output (Bayesian networks, #cite(<lin2021>); ensembles, #cite(<ma2022>); four classes, #cite(<qiu2022>)).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 37 models: #cite(<george2018plb>), #cite(<gabbard2018>), #cite(<george2018>), #cite(<george2018b>), #cite(<rebei2018>), #cite(<bresten2019>), #cite(<fan2019>), #cite(<lin2019>), #cite(<luo2019>), #cite(<schmitt2019>), #cite(<chauhan2020>), #cite(<deighan2020>), #cite(<krastev2020>), #cite(<li2020>), #cite(<santos2020>), #cite(<dodia2021residual>), #cite(<krastev2021>), #cite(<lin2021>), #cite(<verma2021>), #cite(<xia2021>), #cite(<zhan2021>), #cite(<jiang2022>), #cite(<jiang2022real>), #cite(<ma2022>), #cite(<menendez2022sub>), #cite(<qiu2022>), #cite(<verma2022>), #cite(<yan2022>), #cite(<zhang2022>), #cite(<garg2024>), #cite(<kumar2023>), #cite(<sharma2023>), #cite(<meijer2024>), #cite(<sharma2024>), #cite(<ussipov2024>), #cite(<gupta2026q>), #cite(<weerasinghe2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Per-timestep (WaveNet) ensembles
Gebhard et al. argued that a detector must run on continuous data and be judged by its false positives per unit time #cite(<gebhard2019>). The WaveNet-style ensembles of Huerta, Wei and collaborators label each time step and add coincidence across models and detectors #cite(<wei2021ensemble>) #cite(<huerta2021>) #cite(<chaturvedi2022>), later with higher modes and graph layers #cite(<tian2023>) #cite(<tian2024gnn>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 7 models: #cite(<gebhard2019>), #cite(<gunny2021>), #cite(<huerta2021>), #cite(<wei2021ensemble>), #cite(<chaturvedi2022>), #cite(<tian2023>), #cite(<tian2024gnn>). Results will be placed on the shared axes of this section beside the published values.]

=== Search-grade evaluation and the MLGWSC-1 benchmark
Schafer et al. measured sensitive distance against FAR on continuous simulated data #cite(<schafer2020>) #cite(<schafer2021a>) #cite(<schafer2021b>), and the first Machine Learning Gravitational-Wave Search Mock Data Challenge (MLGWSC-1) fixed that contract for four datasets, the last on real O3a noise #cite(<mlgwsc2022>). Entries and successors on the same datasets include AresGW #cite(<nousi2022>) #cite(<koloniari2024>), the updated TPI FSU Jena search #cite(<zelenka2024>), Sage #cite(<nagarajan2025>), a matched-filter hybrid #cite(<yamamoto2025>) and the transformer pipelines GW-Whisper and CASTOR #cite(<chatterjee2024>) #cite(<chatterjee2026>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 10 models: #cite(<schafer2020>), #cite(<schafer2021a>), #cite(<schafer2021b>), #cite(<mlgwsc2022>), #cite(<nousi2022>), #cite(<koloniari2024>), #cite(<zelenka2024>), #cite(<nagarajan2025>), #cite(<yamamoto2025>), #cite(<chatterjee2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Production-style searches on observing-run data
Aframe brought a 1D ResNet to real-time and offline O3 searches with year-long time-slide backgrounds and the LVK injection sets #cite(<marx2024>) #cite(<marx2025aframeO3>), and was extended to binary neutron stars #cite(<gupta2026>). Other O3 searches with measured backgrounds include Q-transform ResNets #cite(<menendezvazquez2021>) #cite(<andrescarcasona2023>) #cite(<menendez2024>), SNR-series networks #cite(<beveridge2023>) #cite(<beveridge2025o3>) #cite(<mcleod2025>), and lightweight or alternative-physics detectors #cite(<tiki2025>) #cite(<silver2025>) #cite(<wang2025exotic>) #cite(<jadhav2023>) #cite(<trovato2023>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 15 models: #cite(<menendezvazquez2021>), #cite(<andrews2022>), #cite(<andrescarcasona2023>), #cite(<beveridge2023>), #cite(<jadhav2023>), #cite(<trovato2023>), #cite(<marx2024>), #cite(<menendez2024>), #cite(<beveridge2025o3>), #cite(<marx2025aframeO3>), #cite(<mcleod2025>), #cite(<silver2025>), #cite(<tiki2025>), #cite(<wang2025exotic>), #cite(<gupta2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Matched-filter front ends
A template bank inside or in front of the network: learnable template layers #cite(<wang2020>) #cite(<yan2021>), matched filtering after denoising #cite(<ma2024tempfree>), SNR-map classifiers #cite(<mobilia2026>), and overlap statistics against reconstructed signals #cite(<badger2024>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 6 models: #cite(<wang2020>), #cite(<yan2021>), #cite(<ma2024tempfree>), #cite(<badger2024>), #cite(<ma2025et>), #cite(<mobilia2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Time-frequency images
Spectrogram or Q-transform images fed to image backbones, often ImageNet-pretrained #cite(<alvares2021>) #cite(<aveiro2022>) #cite(<wang2023tf>) #cite(<sasaoka2023attr>), including Einstein Telescope studies #cite(<alhassan2022>) #cite(<alhassan2023pymerger>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 11 models: #cite(<alvares2021>), #cite(<dodia2021specgrav>), #cite(<fan2021_2d>), #cite(<g2net2022_acm>), #cite(<alhassan2022>), #cite(<aveiro2022>), #cite(<alhassan2023pymerger>), #cite(<sasaoka2023_cbc>), #cite(<sasaoka2023attr>), #cite(<wang2023tf>), #cite(<rai2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Re-ranking inside existing pipelines
Classifiers or density estimators that re-rank the triggers of GstLAL, PyCBC or GRB-triggered searches rather than read strain #cite(<kim2015grb>) #cite(<kim2019>) #cite(<jadhav2020>) #cite(<mcisaac2022>) #cite(<insley2026flows>) #cite(<ashton2025>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 6 models: #cite(<kim2015grb>), #cite(<kim2019>), #cite(<jadhav2020>), #cite(<mcisaac2022>), #cite(<ashton2025>), #cite(<insley2026flows>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (36 of 92); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gabbard2018") #cite(<gabbard2018>)], "eff@FAP", "CNN vs matched filter TPR at FAP 0.1, rho_opt 4: ~0.44 vs ~0.31; at FAP 1e-3, rho_opt 6: ~0.49 (both) (Fig 3; read-from-figure)", "-", [#gr-k #"Per-SNR balanced test sets of 1 s windows in Gaussian aLIGO-design noise, non-spinning BBH; FAP is per window, so no rate. The paired matched-filter curve on identical data is the paper's comparison."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bresten2019") #cite(<bresten2019>)], "AUC", "mixed-SNR (2.1-18) test: raw CNN 0.50, TDA 0.76, raw+TDA 0.79 (Fig 4; stated)", "-", [#gr-k #"White (uncoloured) Gaussian noise with a stated SNR range; AUC comparable only to other white-noise toy studies."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gebhard2019") #cite(<gebhard2019>)], "eff@FAR", "~89 % of injections (SNR 5-20) at one false positive per 19.5 min (Sec VII A; stated)", "2.22e+03 /month; 0.000855 Hz", [#gr-k #"Real O1 noise, clustered triggers on continuous data: a true rate, but at ~2.2e3 per month and over a uniform-SNR injection set rather than a population."], [#pend],
  [], "events", "all GWTC-1 events except GW170817 (Sec VII C; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jadhav2020") #cite(<jadhav2020>)], "reach@FAR", "VT ratio MLStat/base 1.32 / 1.27 / 1.30 / 1.29 at IFAR 0.1 / 1 / 10 / 100 yr (chirp mass 5-50 Msun) (Fig 3 bottom; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [#gr-k #"PyCBC re-ranking with a glitch classifier on O1/O2 chunks; VT ratios relative to the base statistic."], [#pend],
  [], "events", "GW151012 IFAR 5.84 to 218.1 yr; GW170729 0.73 to 55.8 yr (Sec IV; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2020") #cite(<schafer2020>)], "reach@FAR", "sensitive distance ~130 Mpc at 10 per month (BNS); PyCBC Live reconstructed ~245 Mpc at 0.5 per month (Abstract, Sec V, Fig 4; stated)", "10 /month; 3.86e-06 Hz", [#gr-c #"Continuous ~101 d of Gaussian aLIGO-design H1+L1 data with BNS injections, sensitive distance vs FAR: the template for the later MLGWSC-1 metric. Gaussian noise only."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "menendezvazquez2021") #cite(<menendezvazquez2021>)], "eff@FAR", "L1-H1 SNR for 50 / 80 / 99 % efficiency: 11 / 12 / 19 (low mass), 5 / 6 / 7 (high mass) at ~25 false positives per day (Table III; stated)", "750 /month; 0.000289 Hz", [#gr-k #"Threshold set for ~25 false positives per day on a test set; the real O2 scan gives 34-180 per day, so the rate is nominal."], [#pend],
  [], "events", "8 of 11 O1-O2 catalogue events (Table IV; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2021a") #cite(<schafer2021a>)], "reach@FAR", "sensitive distance ~2150 Mpc vs matched filter ~2340 Mpc at 1 per month (single detector, BBH 10-50 Msun) (Sec IV A, Fig 5; stated)", "1 /month; 3.86e-07 Hz", [#gr-k #"Single detector, Gaussian design noise, with a matched-filter baseline on the same data; sensitive distance at a true FAR. Distances differ from MLGWSC-1 by detector count and population."], [#pend],
  [], "eff@FAP", "efficiency 0.90-0.94 at SNR 9, FAP 1e-4 (Sec IV B; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2021b") #cite(<schafer2021b>)], "reach@FAR", "two-detector coincidence retains 92.4 % of the time-coincident matched-filter distance down to ~4e-4 per month; ~2200 Mpc at 4e-4/month (Sec II H, Fig 2; stated (ratio); read-from-figure (distance))", "0.0004 /month; 1.54e-10 Hz", [#gr-k #"Gaussian design noise, H1+L1, ~200 yr time-shift background; ML and matched filter on the same data."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2021ensemble") #cite(<wei2021ensemble>)], "eff@FAR", "no efficiency; 3 false positives in 200 h of August 2017 H1+L1 data (~1 per 2.7 d) (Abstract, Sec IV; stated)", "10.8 /month; 4.17e-06 Hz", [#gr-k #"A true FAR on real data but with no injection campaign, so no efficiency to pair it with."], [#pend],
  [], "events", "GW170104, 0729, 0809, 0814, 0817, 0818, 0823, GW190412 (0608 and 190521 after fine-tuning) (Figs 4, 7; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xia2021") #cite(<xia2021>)], "AUC", "ConvNet5 0.91 vs basic 0.86 (SNR 7-7.5); 0.98 vs 0.96 (SNR 7-15) (Table IV; stated)", "-", [#gr-k #"Gaussian noise, stated SNR ranges, 500-sample test sets (AUC uncertainty ~0.01-0.02)."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "andrews2022") #cite(<andrews2022>)], "eff@FAP", "TAP ~0.86 at 3 sigma (FAP 1.3e-3) and ~0.81 at 4 sigma, H1+L1, real O1 noise (Fig 3 left; read-from-figure)", "-", [#gr-k #"Real O1 noise with a BBH injection population, but FAP is a fraction of background windows without time slides."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcisaac2022") #cite(<mcisaac2022>)], "reach@FAR", "VT gain of the tuned chi^2 at FAR 1/yr: ~4 % (100-300 Msun) to ~11 % (300-600 Msun); band labels +2 to +17 % (Fig 5, Sec V; stated)", "0.0821 /month; 3.17e-08 Hz", [#gr-k #"Relative VT gain inside a PyCBC IMBH search on 8 held-out days."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "reach@FAR", "DS4 (real O3a): PyCBC 1544, Virgo-AUTh 1092, MFCNN 650, CNN-Coinc 0, TPI 0 Mpc at 1/month (Table IV; stated)", "1 /month; 3.86e-07 Hz", [#gr-c #"The reference contract: one month of H1+L1 test data per dataset, IMRPhenomXPHM injections, FAR per month from injection-free background, chirp-distance-weighted sensitive distance."], [#pend],
  [], "reach@FAR", "DS1 (Gaussian): PyCBC 2492, TPI 2363, AUTh 2116 Mpc at 1/month (Table IV; stated)", "1 /month; 3.86e-07 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "andrescarcasona2023") #cite(<andrescarcasona2023>)], "eff@FAR", "network SNR for 80 / 90 / 95 % efficiency, H1-L1-V1: 17.3 / 21.1 / 25.8 (Table IV; stated)", "-", [#gr-k #"Real O3 search with time-slide FAR down to 1/152.6 yr, but the threshold behind Table IV is not clearly stated."], [#pend],
  [], "other", "O3 merger-rate upper limits 560 to 3e6 Gpc^-3 yr^-1 (asymmetric, sub-solar) (Sec IV; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beveridge2023") #cite(<beveridge2023>)], "eff@FAR", "TPR ~0.17 / ~0.48 at network SNR 8 / 10 at 1 per 2 months (1.9e-7 Hz) (Fig 8; read-from-figure)", "0.5 /month; 1.93e-07 Hz", [#gr-k #"Simulated coloured Gaussian noise with simulated glitches; a true FAR from 6e6 s of background, but the alert threshold lies in the extrapolated tail."], [#pend],
  [], "eff@FAR", "34 % of 10,000 GWTC-3-like injections at FAR < 1 per 2 months (Sec III B 1; stated)", "0.5 /month; 1.93e-07 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jadhav2023") #cite(<jadhav2023>)], "reach@FAR", "sensitive distance at 1/month on 8.8 d of O3: 140 / 996 / 2173 Mpc for chirp mass 1-10 / 10-40 / 40-80 Msun (Sec VI B, Fig 16; stated)", "1 /month; 3.86e-07 Hz", [#gr-k #"Real O3 data with injections and a sensitive distance at a true FAR, but mass bins and the distance definition differ from MLGWSC-1."], [#pend],
  [], "AUC", "CBC vs PyCBC background triggers 0.976 (0.989 after GAN training) (Fig 14b; stated)", "-", [], [#pend],
  [], "events", "GW190519 and GW190521_074359 at FAR < 1/20,350 yr (Sec VI; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nousi2022") #cite(<nousi2022>)], "reach@FAR", "MLGWSC-1 DS4: ~1575 Mpc at 1/month (PyCBC ~1540, cWB ~1255 on the same figure) (Fig 10; read-from-figure)", "1 /month; 3.86e-07 Hz", [#gr-c #"MLGWSC-1 DS4 with the challenge evaluation: directly comparable with the challenge entries."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tian2023") #cite(<tian2023>)], "eff@FAR", "TPR ~0.97 at SNR 8.4 and ~0.55-0.65 at SNR 6.2 for 2-3 false positives per year (coloured Gaussian HLV, O4/O5 PSDs) (Fig 2, Table 1; read-from-figure)", "0.246 /month; 9.51e-08 Hz", [#gr-k #"A year of synthetic coloured Gaussian HLV noise: a FAR, but for Gaussian noise only."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tian2024gnn") #cite(<tian2024gnn>)], "AUC", "ROC AUC 0.982 / 0.973 / 0.965 (2 / 3 / 4 models) at network SNR 8.4 (Table 1; stated)", "-", [#gr-k #"Decade of synthetic coloured Gaussian noise; the real-data month is a tuned ensemble with manual vetting."], [#pend],
  [], "eff@FAR", "TPR 0.45 / 0.33 / 0.27 at SNR 6.2 for 7 / 3 / 2 false positives per decade (synthetic HLV) (Fig 1 insets; read-from-figure)", "0.0246 /month; 9.51e-09 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "trovato2023") #cite(<trovato2023>)], "eff@FAR", "efficiency at FAR 1e-5 Hz: TCN/IT 0.49 / 0.75 / 0.91 at SNR 9.5 / 11.5 / 14.5; CNN 0.43 / 0.68 / 0.85 (Fig 5; read-from-figure)", "25.9 /month; 1e-05 Hz", [#gr-k #"Single-detector L1 O1 test segments; FAR is the test-set false-alarm count per second of segments, not time slides; model selected on the test set."], [#pend],
  [], "eff@FAR", "TCN ~0.76 at 1e-6 Hz (averaged over SNR 8-20) (Fig 4; read-from-figure)", "2.59 /month; 1e-06 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "badger2024") #cite(<badger2024>)], "eff@FAR", "overlap statistic TPR ~0.06 vs matched filter ~0.22 at 12/yr (astrophysical population, simulated A+ Gaussian, single detector) (Fig 4; read-from-figure)", "0.986 /month; 3.8e-07 Hz", [#gr-k #"Single-detector simulated A+ noise with FAR from one month of noise; a paired matched-filter baseline on the same injections."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "koloniari2024") #cite(<koloniari2024>)], "events", "34 of 43 published O3 events in range at p_astro > 0.5; 28 at FAR < 1/yr; 8 new candidates (Sec VI A, Tables I, III; stated)", "-", [#gr-k #"Real O3 search with a 10 yr time-shifted background but no injection-based sensitivity: events recovered is the only efficiency."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marx2024") #cite(<marx2024>)], "reach@FAR", "sensitive volume at 1/yr: Aframe ~10.3 vs PyCBC-BBH ~9.7, GstLAL ~9.8 Gpc^3 (35+35 Msun); 20+10 Msun: ~0.7 vs ~1.55 (Fig 4; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [#gr-c #"O3 data with a year of time slides and the GWTC-3 pipelines' public injection sets: comparable with the LVK searches on sensitive volume at FAR."], [#pend],
  [], "events", "9 of 9 GWTC-3 candidates in the test period (Table IV; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "menendez2024") #cite(<menendez2024>)], "eff@FAR", "network SNR for 50 / 80 / 99 % efficiency at 1/week: 10 / 12 / 20 (high mass), 20 / 24 / 39 (low mass) (Table 2; stated)", "4.29 /month; 1.65e-06 Hz", [#gr-k #"Real O3 HLV data with time-slide FAR down to 1/152.6 yr; efficiency in network SNR rather than distance."], [#pend],
  [], "events", "26 of 50 three-detector O3 events at 1/week (22 of 31 in range) (Sec 5; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2023tf") #cite(<wang2023tf>)], "reach@FAR", "U-Net sensitive distance ~230 Mpc at 1/month, ~950 at 100/month (own O3a time-shifted background) (Fig 4; read-from-figure)", "1 /month; 3.86e-07 Hz", [#gr-k #"Sensitive distance in the MLGWSC-1 style but on 32.5 d of its own background from 10 shifts of 3.25 d, and MLGWSC-1 curves are overplotted from a different data set."], [#pend],
  [], "events", "all O1/O2 BBH and 59 of 73 O3 BBH (union over detectors) (Sec III C; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zelenka2024") #cite(<zelenka2024>)], "reach@FAR", "MLGWSC-1 DS4: updated TPI FSU Jena 1316 Mpc at 1/month (original submission 0) (Sec IV C 2, Fig 4; stated)", "1 /month; 3.86e-07 Hz", [#gr-c #"MLGWSC-1 DS4 with the challenge evaluation, but the update is selected as the best of six runs on the real-noise test data."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beveridge2025o3") #cite(<beveridge2025o3>)], "reach@FAR", "sensitive hyper-volume per mass pair vs GWTC-3 pipelines on 83,815 O3 injections (p_astro >= 0.5, FAR < 2/day): comparable above chirp mass ~25 Msun, lower below (Table I, Fig 5; stated)", "60 /month; 2.31e-05 Hz", [#gr-c #"Real O3 data with the GWTC-3 injection campaign and the LVK detection criterion: search-grade."], [#pend],
  [], "events", "2,916 of 10,472 week-4/6/8 injections at FAR < 1 per 2 months (PyCBC-BBH 3,751) (Table III; stated)", "0.5 /month; 1.93e-07 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marx2025aframeO3") #cite(<marx2025aframeO3>)], "reach@FAR", "sensitive volume at 1/yr, 35+35 Msun: Aframe ~10.8 vs GstLAL ~9.8, PyCBC-BBH ~9.5 Gpc^3; 35+20: ~4.8 vs ~5.8 / ~5.6 (Fig 2; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [#gr-c #"Offline O3 search over 202.4 d against GWTC-3 pipeline curves for the same four mass distributions."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcleod2025") #cite(<mcleod2025>)], "reach@FAR", "BNS sensitive distance ~172 Mpc at 1 per 2 months (PyCBC ~175, MBTA ~172, GstLAL ~163) on the GWTC-3 O3 week-4 injections (Fig 7; read-from-figure)", "0.5 /month; 1.93e-07 Hz", [#gr-c #"Real O3 noise and the official GWTC-3 BNS injection set: directly comparable with the LVK pipelines on that set."], [#pend],
  [], "eff@FAR", "34 % of 2,800 BNS injections at FAR < 1 per 2 months (Sec V A; stated)", "0.5 /month; 1.93e-07 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nagarajan2025") #cite(<nagarajan2025>)], "reach@FAR", "MLGWSC-1 DS4: Sage-Broad 1638 Mpc at 1/month vs PyCBC 1539, AresGW 1574, Aframe 1441 (Table V; stated)", "1 /month; 3.86e-07 Hz", [#gr-c #"MLGWSC-1 DS4 with the challenge evaluation; best-of-three seeds reported."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tiki2025") #cite(<tiki2025>)], "reach@FAR", "median sensitive volume 5.4 Gpc^3 at median FAR 20.5/yr; 4.6 Gpc^3 at the zero-FP threshold (O3b, 10,000 BBH) (Abstract, Sec 3; stated)", "1.68 /month; 6.5e-07 Hz", [#gr-k #"Real O3 noise with shifted-noise FAR and a fixed BBH population; population and FAR definition differ from MLGWSC-1 and Aframe."], [#pend],
  [], "events", "8-9 of 13 O3b GWTC-3 events, 0-1 false triggers in 22.7 d (Sec 3; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2025exotic") #cite(<wang2025exotic>)], "reach@FAR", "sensitive distance ~750 Mpc at 10/yr (GR injections), real O1 noise, 4-day test (Fig 6; read-from-figure)", "0.821 /month; 3.17e-07 Hz", [#gr-k #"Volume-averaged distance in the MLGWSC-1 style but on a narrow chirp-mass and mass-ratio window and 21 d of background."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2025") #cite(<yamamoto2025>)], "reach@FAR", "MLGWSC-1 DS1: 2428 Mpc at 1/month (PyCBC 2492), 2743 at 100/month (PyCBC 2687) (Table III; stated)", "1 /month; 3.86e-07 Hz", [#gr-c #"MLGWSC-1 DS1 with the challenge script: directly comparable with the DS1 entries."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2026") #cite(<chatterjee2026>)], "reach@FAR", "MLGWSC-1 at 1/month: CASTOR 1482 Mpc (DS3), 1350 Mpc (DS4) (Sec V, Fig 4; stated)", "1 /month; 3.86e-07 Hz", [#gr-c #"MLGWSC-1 DS3/DS4 with the public evaluation code."], [#pend],
  [], "events", "14 of 31 confident O3b BBH at FAR <= 1/month (Table II; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gupta2026") #cite(<gupta2026>)], "reach@FAR", "BNS sensitive volume at 1/yr: Aframe-BNS 0.0065 vs MBTA 0.0078, PyCBC-Hyperbank 0.0077, GstLAL 0.0059 Gpc^3 (1.4+1.4 Msun) (Fig 4; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [#gr-c #"Real O3 noise with 10 yr time slides, compared with GWTC-3 matched-filter numbers; Aframe FAR carries a factor-2 trials penalty."], [#pend],
  [], "events", "O3 MDC: 671 of 1790 injections at FAR < 1/month (MBTA 648, GstLAL 528) (Table II; stated)", "1 /month; 3.86e-07 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "insley2026flows") #cite(<insley2026flows>)], "eff@FAR", "+35 injections (+0.78 %) recovered at FAR < 1/yr over the histogram baseline (HLV +3.85 %), one O3 week (Sec V A, Fig 4; stated)", "0.0821 /month; 3.17e-08 Hz", [#gr-k #"Normalising flows replace a histogram inside the PyCBC ranking statistic; the gain is relative to PyCBC on one week of O3 data."], [#pend],
)

*MLGWSC-1 contract.* Sensitive distance (Mpc) at FAR 100, 10 and 1 per month on the four MLGWSC-1 datasets, from the challenge paper and from later papers that used its evaluation code. Dataset 4 is real O3a noise; datasets 1-3 are simulated. Values marked read-from-figure are read from plotted curves.

#tbl(columns: (auto, auto, 1.6fr, auto, auto, auto, 1.2fr, auto), table.header([*DS*], [*Source*], [*Search*], [*D\@100*], [*D\@10*], [*D\@1*], [*Location; how*], [*gravyflow*]),
  "1", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "A MFCNN", "1587", "852", "779", "MLGWSC-1 Table IV; stated", [#pend],
  "1", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "B PyCBC", "2687", "2551", "2492", "MLGWSC-1 Table IV; stated", [#pend],
  "1", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "C CNN-Coinc", "1372", "1045", "1002", "MLGWSC-1 Table IV; stated", [#pend],
  "1", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "D TPI FSU Jena", "2635", "2472", "2363", "MLGWSC-1 Table IV; stated", [#pend],
  "1", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "E Virgo-AUTh", "2512", "2318", "2116", "MLGWSC-1 Table IV; stated", [#pend],
  "1", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2025") #cite(<yamamoto2025>)], "MF + CNN hybrid", "2743", "2582", "2428", "Table III; stated", [#pend],
  "2", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "A MFCNN", "1532", "582", "449", "MLGWSC-1 Table IV; stated", [#pend],
  "2", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "B PyCBC", "1720", "1600", "1544", "MLGWSC-1 Table IV; stated", [#pend],
  "2", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "C CNN-Coinc", "554", "444", "374", "MLGWSC-1 Table IV; stated", [#pend],
  "2", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "D TPI FSU Jena", "1712", "1544", "1455", "MLGWSC-1 Table IV; stated", [#pend],
  "2", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "E Virgo-AUTh", "1609", "1410", "1242", "MLGWSC-1 Table IV; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "A MFCNN", "885", "473", "356", "MLGWSC-1 Table IV; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "B PyCBC", "1734", "1630", "1577", "MLGWSC-1 Table IV; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "C CNN-Coinc", "620", "468", "402", "MLGWSC-1 Table IV; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "D TPI FSU Jena", "1728", "1578", "1488", "MLGWSC-1 Table IV; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "E Virgo-AUTh", "1647", "1495", "1241", "MLGWSC-1 Table IV; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "F cWB", "1462", "1360", "1252", "MLGWSC-1 Table IV; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2026") #cite(<chatterjee2026>)], "CASTOR", "-", "-", "1482", "Sec V; stated", [#pend],
  "3", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024") #cite(<chatterjee2024>)], "GW-Whisper", "1180", "1030", "890", "Fig 2a; read-from-figure", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "A MFCNN", "1269", "999", "650", "MLGWSC-1 Table IV; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "B PyCBC", "1722", "1610", "1544", "MLGWSC-1 Table IV; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "C CNN-Coinc", "961", "621", "0", "MLGWSC-1 Table IV; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "D TPI FSU Jena", "258", "0", "0", "MLGWSC-1 Table IV; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "E Virgo-AUTh", "1609", "1400", "1092", "MLGWSC-1 Table IV; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "F cWB", "1407", "1332", "1229", "MLGWSC-1 Table IV; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nagarajan2025") #cite(<nagarajan2025>)], "Aframe (private comm.)", "1708", "1570", "1441", "Table V; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nousi2022") #cite(<nousi2022>)], "AresGW", "1815", "1630", "1575", "Fig 10; read-from-figure", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2026") #cite(<chatterjee2026>)], "CASTOR", "-", "-", "1350", "Sec V; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024") #cite(<chatterjee2024>)], "GW-Whisper", "1185", "1025", "905", "Fig 2b; read-from-figure", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nagarajan2025") #cite(<nagarajan2025>)], "Sage-Broad (best of 3)", "1859", "1722", "1638", "Table V; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nagarajan2025") #cite(<nagarajan2025>)], "Sage-Limited", "1852", "1711", "1553", "Table V; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zelenka2024") #cite(<zelenka2024>)], "TPI FSU Jena (updated)", "-", "-", "1316", "Sec IV C 2; stated", [#pend],
  "4", [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nagarajan2025") #cite(<nagarajan2025>)], "TPI-FSU Jena 2024", "1584", "1424", "1316", "Table V; stated", [#pend],
)
== What cannot be compared, and why
Most CBC papers report a true-positive rate at a per-window false-alarm probability, an accuracy on a balanced set, or an AUC over a mixture of SNRs. None of these converts to a false-alarm rate without the window stride and the clustering rule, and none fixes the injected population, so a 98 % accuracy in one paper and a 0.9 TPR in another say nothing about each other. Real-event recoveries are listed for completeness but are not efficiencies: windows are often placed on the known event, and the denominator is the catalogue, not an injection set. Comparable rows are those on the MLGWSC-1 contract or on the LVK injection campaigns (sensitive distance or volume at a stated FAR); conditional rows have a true FAR but a different noise model, population or detector count.

The 56 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2015grb") #cite(<kim2015grb>)], "efficiency at per-trigger FAP ~1e-4: ANN 0.56-0.74 vs detection statistic 0.50-0.64 (Fig 7; read-from-figure)", "GRB-triggered coherent CBC search on S5/VSR1, per-trigger FAP; the MLR is built from the same samples it is scored on.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018plb") #cite(<george2018plb>)], "sensitivity ~45 / ~77 / ~93 % at SNR 5 / 6 / 7 vs matched filter ~52 / ~87 / ~97 % at <1 % false alarms per window (Fig 1 left; read-from-figure)", "Proceedings version of george2018b; per-window FAP.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018") #cite(<george2018>)], "100 % TPR for SNR >= 10 (shallow) / >= 9 (deep) at ~0.5 % false alarms per 1 s window (Results, Figs 8, 12; stated)", "One operating point per network on Gaussian ZDHP noise; the \"false alarm rate\" is a per-window fraction.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018b") #cite(<george2018b>)], "100 % TPR for SNR > 10 at <1 % false alarms per window (single detector) (Sec III, Fig 4; stated); GW150914 recovered with masses inside published errors (Sec III; stated)", "Real O1 noise but one operating point; the two-detector 0.01 % squares the single-detector fraction.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "rebei2018") #cite(<rebei2018>)], "100 % sensitivity for SNR >= 10 on eccentric higher-mode NR waveforms (Fig 8; stated)", "Sensitivity on a few NR waveforms; the false-positive sentence is garbled in the PDF.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fan2019") #cite(<fan2019>)], "TPR 98.7 % at network SNR 8, 100 % at >= 9, 0.4 % false alarms per 2 s window (HLV) (Sec III A, Fig 4; stated)", "Fixed-SNR balanced test sets in coloured Gaussian noise; one operating point.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2019") #cite(<kim2019>)], "RF 0.666 / 0.689 vs GstLAL 0.633 / 0.658 (H1 / L1 triggers) (Fig 1; stated)", "Trigger-level re-ranking inside GstLAL with GW150914-like injections against time-slide triggers; the FAR in Hz is a GstLAL-style conversion of a trigger FPR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lin2019") #cite(<lin2019>)], "TPR >97.2 % at per-sample FPR >= 1e-3 (BNS, rho 8-12) (Sec 4, Fig 3; stated)", "Per-sample FPR with 1/7000 resolution in Gaussian noise; rho mixture undefined.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "luo2019") #cite(<luo2019>)], "none extracted", "Not read (journal page unresolvable); no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schmitt2019") #cite(<schmitt2019>)], "none extracted", "Not read (ACM paywall); no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chauhan2020") #cite(<chauhan2020>)], "100 % accuracy at SNR 4 on a 400-sample test set (Sec 3; stated)", "Tiny balanced set; training accuracy 1.00 after one epoch; no false-alarm context.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "deighan2020") #cite(<deighan2020>)], "accuracy 0.71 (seed) to 0.79 (GA-optimised), white noise (Sec 5.3; stated)", "Architecture-search study on a white-noise toy problem.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "krastev2020") #cite(<krastev2020>)], "BNS TPR at FAP 1e-2: 0.33 / 0.63 / 0.88 at rho 8 / 10 / 12 (Fig 4; read-from-figure)", "Per-sample FAP from ~1,667 noise samples (resolution ~6e-4) in Gaussian noise; the FAP 1e-3 curves rest on 1-2 samples.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "li2020") #cite(<li2020>)], "wavelet-packet CNN (SE5) 0.947 at FPR 1e-3, rho_opt 2 (Table 3; stated)", "Not a compact-binary search: damped sinusoids in white noise, 0.03 s windows.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "santos2020") #cite(<santos2020>)], "ring-down time from score decay, e.g. GW150914 3.87 ms (LIGO ~4 ms) (Table 1; stated)", "No FAR, TPR or distance; the score-decay \"ring-down\" is not a strain measurement.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2020") #cite(<wang2020>)], "TPR at per-sample FAP 1e-3: 0.47 / 0.72 / 0.90 at rho_opt 4 / 5 / 6 (Fig 3; read-from-figure); GW150914, GW151012, GW151226 and eight O2 events flagged (Figs 4-5; stated)", "Real O1 two-detector noise but per-sample FAP of unstated noise-set size; O1/O2 scan triggers carry no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alvares2021") #cite(<alvares2021>)], "three-detector classifier ROC AUC 0.87 at 2000 Mpc (Fig 5; stated); 34 of 37 GWTC-2 BBH above threshold 0.5 (Table III; stated)", "Balanced validation at one injection distance; noise from one 500 s segment; no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dodia2021residual") #cite(<dodia2021residual>)], "detection ratio ~100 % at SNR 11 (BBH), 20 (BNS), no FAR stated (Figs 6-7; stated)", "Detection ratio without a false-alarm level.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dodia2021specgrav") #cite(<dodia2021specgrav>)], "none extracted", "Three-class accuracy on small balanced sets; per-event results not recovered.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fan2021_2d") #cite(<fan2021_2d>)], "none extracted", "Not read (ICPR paywall); no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "g2net2022_acm") #cite(<g2net2022_acm>)], "none extracted", "Not read; G2Net-style balanced AUC at best.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gunny2021") #cite(<gunny2021>)], "throughput 6.4e-5 s per second of data on 4 V100 (DeepClean); end-to-end ~1 s latency claimed (Figs 3, 9; read-from-figure)", "Inference-as-a-service systems paper; no detection performance for BBHnet.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "huerta2021") #cite(<huerta2021>)], "ensemble TPR 0.37-0.85 at SNR 10.6 across per-time-step FPR ~3e-6 to ~4e-4 (Fig 4 inset; read-from-figure); all four August 2017 BBHs found, zero false positives in the month (Abstract, Fig 2b; stated)", "Per-time-step FPR with an undefined unit; the zero-misclassification month uses a different (coincident-peak) statistic from the ROC.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "krastev2021") #cite(<krastev2021>)], "BNS TPR at FAP 1e-2: 0.29 / 0.63 / 0.89 at rho 8 / 10 / 12 (real O2 L1 noise) (Fig 3; read-from-figure); 11 of 11 GWTC-1 events classified with p > 0.995 (windows placed by hand) (Fig 4; stated)", "Per-10 s-sample FAP; the paper's FAR conversion is order-of-magnitude; real events are classified, not searched.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lin2021") #cite(<lin2021>)], "window TPR >90 % for rho_opt > 8 counting \"awareness\"; false awareness 19.6 % of noise windows (Sec III A, Fig 4; stated); 7 of 7 O2 L1 BBHs (Sec III B; stated)", "Three-state output in which awareness counts as detection; event-level false rate 47.7 %.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "verma2021") #cite(<verma2021>)], "level-1 accuracy ~99 % (99.43 % from the matrix), FAP 0.33 % per sample (Sec V, Fig 5; stated)", "Balanced synthetic single-detector set, SNR 10-20 with the test SNR unstated.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2021") #cite(<yan2021>)], "FNR ~3.7e-5 (matched filter) vs ~3.3e-5 (MNet-Shallow) at per-segment FPR 3e-4, SNR 9 (Fig 13; read-from-figure)", "Fixed-SNR single-detector 0.6 s segments of real O2 L1 noise, 40-50 Msun only; FPR per overlapping segment.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhan2021") #cite(<zhan2021>)], "accuracy 96.4 % at SNR 10 (called sensitivity; recall 98.4 %, FPR 5.6 %) (Fig 2; stated)", "Glitch-response probe on Gaussian design noise.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alhassan2022") #cite(<alhassan2022>)], "ResNet-101 accuracy 0.62 (SNR 4-5) to 0.985 (SNR > 8), single ET detector (Table 3; stated)", "Einstein Telescope single-detector STFT classification in Gaussian ET-D noise, SNR-binned balanced sets; the mock-run false positives are per 5 s window.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "aveiro2022") #cite(<aveiro2022>)], "YOLOv5 precision 0.922, recall 0.823, mAP@0.5 0.945 (BNS CQT images, SNR 10-20) (Abstract, App A; stated); GW170817 H1 at confidence 0.91; L1 only after ad hoc capping (Sec V C; stated)", "Object-detection metrics on synthetic H1 Gaussian noise; no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chaturvedi2022") #cite(<chaturvedi2022>)], "79 time-slide false positives in 5 yr (~1.3 per month); all four August 2017 BBHs found (Sec 3.1, 3.3; stated)", "Same ensemble as huerta2021 with TensorRT; time-slide counts are not independent trials and no efficiency is paired with them.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jiang2022") #cite(<jiang2022>)], "none extracted", "Not read; no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jiang2022real") #cite(<jiang2022real>)], "41 of 41 O1-O3a BBH; FAR < 1 per 2 months in O2 replay (abstract) (abstract; stated)", "Abstract-level only.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2022") #cite(<ma2022>)], "FAP at TAP 0.8: 0.0042 (single) vs 0.00185 (harmonic ensemble), Hanford, per 1 s window (Sec III.3, Fig 5; stated); 9 of 10 O1/O2 BBH (GW170818 missed) (Sec IV B; stated)", "Per-window FAP on a bespoke 20 %-signal test set in O1 noise; the \"1 per 11.24 days\" FAR is extrapolated by multiplying H and L probabilities.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "menendez2022sub") #cite(<menendez2022sub>)], "none extracted", "Not read; no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "qiu2022") #cite(<qiu2022>)], "TAP saturates at FAP 1e-3 for SNR >= 8 (BBH), >= 10 (NSBH), >= 13 (BNS), real L1 noise (Sec 3.1, Fig 4; stated)", "Per-segment FAP on quiet stretches of real L1 O2/O3b noise, single detector, four-class softmax.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "verma2022") #cite(<verma2022>)], "aligned vs precessing vs noise: diagonals ~96 % (synthetic), 90.5 % (H1 PSD), 92.3 % (L1 PSD) (Figs 5-8; read-from-figure)", "Per-detector models on Gaussian noise coloured by O3 PSDs; classification at an unstated threshold.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2022") #cite(<yan2022>)], "none extracted", "Not read; no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhang2022") #cite(<zhang2022>)], "detection ratio ~89.6 % at FAP 4.88e-4 (abstract) (abstract; stated)", "Abstract only (APS paywall); the abstract converts the FAP to about one false alarm per 18.2 h.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alhassan2023pymerger") #cite(<alhassan2023pymerger>)], "three-sub-detector ResNet accuracy 0.785 / 0.84 / 0.995 at SNR 4-5 / 5-6 / 6-7 (ET-D Gaussian) (Sec 4, Fig 5; stated)", "Einstein Telescope triangle in Gaussian noise; balanced SNR bins; no FAR curve.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "garg2024") #cite(<garg2024>)], "none extracted", "Qualitative only; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kumar2023") #cite(<kumar2023>)], "none extracted", "Not read; no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024tempfree") #cite(<ma2024tempfree>)], "TAP ~0.8 at per-sample FAP 1e-4 in most mass sub-spaces (denoiser + discriminator) (Fig 9; read-from-figure); denoised overlap > 0.9 for >= 97.5 % of samples (heaviest class), ~60 % (lightest) (Sec IV A 1, Fig 4; stated)", "Per-sample FAP on 10,000 noise samples; real-data background overlaps training epochs.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sasaoka2023_cbc") #cite(<sasaoka2023_cbc>)], "none extracted", "Not read; no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sasaoka2023attr") #cite(<sasaoka2023attr>)], "ensemble TAP at network SNR 8, FAP 1e-3 per 4 s: ~0.97 (BBH), ~0.55 (NSBH), ~0.075 (BNS), real O3 HLV noise (Fig 3; read-from-figure)", "Per-4 s-segment FAP (~one false positive per hour) with SNR computed on truncated signals.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sharma2023") #cite(<sharma2023>)], "none extracted", "Not read; no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "meijer2024") #cite(<meijer2024>)], "AUC 0.949 (aligned) / 0.940 (precessing) / 0.953 (curriculum), signal vs blip at matched SNR (Sec V A; stated)", "Balanced simulated IMBH-vs-blip set with SNR distributions forced to coincide; no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sharma2024") #cite(<sharma2024>)], "none extracted", "Not read; no metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ussipov2024") #cite(<ussipov2024>)], "source-type accuracy up to 0.96 (abstract) (abstract; stated)", "Abstract-level only.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ashton2025") #cite(<ashton2025>)], "pipeline-combination AUC: max-IFAR 0.925, LR 0.944, MLP 0.967 (O3 replay MDC) (Fig 1; stated)", "Learns on pipeline candidate lists, not strain; AUC on an injection-rich MDC split.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2025et") #cite(<ma2025et>)], "none extracted", "Not read; no numbers in the abstract.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "silver2025") #cite(<silver2025>)], "57 of 75 GWTC-3 BBH at a threshold with ~63 time-shifted false positives per year (derived) (Sec III C-D; stated)", "Real-data event recovery with thresholds tuned on the same GWTC-3 search; no injection-based sensitivity at a FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gupta2026q") #cite(<gupta2026q>)], "validation AUC 0.9209 (G2Net subset) (abstract; stated)", "Abstract-level; G2Net synthetic data with an unstated SNR distribution.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mobilia2026") #cite(<mobilia2026>)], "Sim4 TAP at per-window FAP 1e-4: CNN ~0.30 vs reweighted SNR ~0.13 vs SNR ~6e-3 (Sec VIII, Fig 13; stated)", "Simulated Gaussian noise with synthetic glitches; FAP 1e-4 rests on about one of ~12,000 noise samples.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "rai2026") #cite(<rai2026>)], "mean per-event AUC 0.915 +- 0.086 on 66 GWTC events (per 0.25 s window) (Sec 3.2; stated)", "Per-window classification of catalogue events; FPR 0.0061 per 0.25 s window is ~0.024 Hz as a rate.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "weerasinghe2026") #cite(<weerasinghe2026>)], "ROC AUC 0.999999; 99.998 % efficiency at 1 % FPR per 100 ms segment (Sec 5.1; stated)", "Synthetic post-merger damped sinusoids; saturated metrics on 1000-fold augmentations of a small waveform set.", [#pend],
)
== Suspected errors in the literature
136 suspected errors or internal inconsistencies in 74 papers, selected from the extraction notes (258 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<kim2015grb>) #"Sec 2.1 names S6/VSR2-3 data while the analysed GRBs are S5/VSR1."]
  [- #cite(<kim2015grb>) #"Sigma conversions are two-sided (FAP 1e-4 called 3.89 sigma)."]
  [- #cite(<george2018plb>) #"\"1 per 100 s\" for 1 % of overlapping 1 s windows stepped 0.2 s is a factor-5 slip."]
  [- #cite(<george2018plb>) #"Text says 100 % above SNR 10; Fig 1 reads ~99.5 % at 10."]
  [- #cite(<gabbard2018>) #"CNN above the matched filter at FAP 0.1 for rho 3-5 (Fig 3) is not possible for an optimal filter in Gaussian noise; the bank or threshold handling is suspect."]
  [- #cite(<gabbard2018>) #"Waveform count conflict: 4e5 series with 25 noise draws each implies 8000 signals, the text says 1000."]
  [- #cite(<george2018>) #"Very-high-SNR error bound given as <3 % (Fig 10 caption) and <5 % (text)."]
  [- #cite(<george2018b>) #"\"1 % = one per 100 s of noise\" is inconsistent with 1 s windows stepped by 0.2 s (one per ~20 s)."]
  [- #cite(<bresten2019>) #"Raw CNN AUC 0.50 (Fig 6) vs 0.99 (Fig 7) on the same signal and SNR range points to an unconverged baseline."]
  [- #cite(<bresten2019>) #"Training sizes in the text (20,000/10,000) disagree with Figs 8-10."]
  [- #cite(<fan2019>) #"Fig 4 calls a per-sample fraction a \"false alarm rate\"."]
  [- #cite(<fan2019>) #"Dataset size given as 3,000/2,000 and as 100,000 training sets."]
  [- #cite(<gebhard2019>) #"Results section: 89 % at one per 19.5 min; conclusion: 86 % at one per 40 min for the same setup."]
  [- #cite(<kim2019>) #"The abstract's \"about 10 %\" efficiency gain is an absolute TPR difference (60-70 % relative)."]
  [- #cite(<kim2019>) #"The 18 % sensitivity gain at ~1e-11 Hz is not reproducible from the stated ranges (21 % in radius)."]
  [- #cite(<lin2019>) #"Matched-filter TPR 0.78 at rho 8 and FPR 1e-3 while the CNN reaches ~0.985 is implausible for an adequate bank in Gaussian noise."]
  [- #cite(<lin2019>) #"\"More than 960 times faster\" is a factor-10 slip: 261 s / 0.027 s = 9,667."]
  [- #cite(<lin2019>) #"Sub-populations fall below the headline 97.2 % (Figs 4-5)."]
  [- #cite(<chauhan2020>) #"A 100 % sensitivity at SNR 4 with perfect training accuracy after one epoch points to leakage or an easy set."]
  [- #cite(<chauhan2020>) #"Lowest SNR stated as 1.5 and as 4."]
  [- #cite(<deighan2020>) #"\"11 % increase\" is relative; parameters reduced by 78 % (text) or 79 % (Fig 8)."]
  [- #cite(<jadhav2020>) #"Abstract says all GWTC-1 CBCs are recovered; GW170818 is not (10 of 11)."]
  [- #cite(<jadhav2020>) #"Most MLStat IFARs in Table I are inferred by assuming a constant background reduction, not measured."]
  [- #cite(<krastev2020>) #"\"Saturation at SNR >= 18\" is approximate: BNS at FAP 1e-3 reads ~0.99 at SNR 16 (Fig 4)."]
  [- #cite(<li2020>) #"CNN sensitivity 0.947 at FPR 1e-3 and rho 2 while the matched filter reaches ~0.05 contradicts the Neyman-Pearson optimality of matched filtering for known signals in Gaussian noise."]
  [- #cite(<santos2020>) #"The positive class is a fit to the events later scored (leakage); KS = 1 is on training patterns."]
  [- #cite(<schafer2020>) #"The PyCBC Live reference is reconstructed from another paper by an SNR-threshold assumption, not run on the same data."]
  [- #cite(<wang2020>) #"GW170817 (total mass ~2.7 Msun) is reported detected by a network trained on 10-150 Msun."]
  [- #cite(<wang2020>) #"The same quantity is called matched-filter SNR (Fig 2) and optimal SNR (Fig 3), with different values (0.64 vs 0.60 at SNR 4, FAP 0.1)."]
  [- #cite(<alvares2021>) #"Table II labels the 0.72 / 0.82 accuracies as AUC."]
  [- #cite(<alvares2021>) #"Abstract \"as much as 70 %\" improvement vs 0.72 to 0.82 in the main comparison."]
  [- #cite(<dodia2021specgrav>) #"100 % training and validation accuracy for a model that failed most real events indicates a leaky validation set."]
  [- #cite(<gunny2021>) #"The one-second detection latency is claimed without any detection result."]
  [- #cite(<huerta2021>) #"Text says FPR rises as the threshold rises (direction reversed)."]
  [- #cite(<huerta2021>) #"FPR range stated as 1e-6 to 1e-3; the figure spans ~3e-6 to ~4e-4."]
  [- #cite(<huerta2021>) #"FPR 1e-6 per 0.5 s step implies ~5 false peaks per month against the zero reported."]
  [- #cite(<krastev2021>) #"FAP 1e-3 is equated with O(10^3) false alarms per month; at the 0.3 s stride it is ~8.6e3."]
  [- #cite(<krastev2021>) #"BBH saturation SNR given as 10 and as ~12 in the same section."]
  [- #cite(<lin2021>) #"Abstract >95 % vs text >90 %."]
  [- #cite(<lin2021>) #"Event TPR at rho 2 (~43 %) is below the false event rate (47.7 %)."]
  [- #cite(<menendezvazquez2021>) #"O2 trigger rates (34-47 per day) exceed the tuned 25 per day."]
  [- #cite(<menendezvazquez2021>) #"Events with secondary masses below the stated training range are detected (GW170104, GW170809)."]
  [- #cite(<schafer2021a>) #"Headline retention 91.5 % (v2) vs 97.5 % (v1 and README); both are radius ratios (0.915^3 = 0.77 in volume)."]
  [- #cite(<schafer2021b>) #"Percentages are minimum radius ratios presented as sensitivity fractions."]
  [- #cite(<verma2021>) #"Fig 6 caption describes a per-patch ROC while the axes are noise-vs-signal."]
  [- #cite(<verma2021>) #"Patch-2 accuracy 97.3 % stated vs 97.4 % from the printed matrix."]
  [- #cite(<wei2021ensemble>) #"Training noise segments fall inside the August 5-16 2017 benchmark period."]
  [- #cite(<wei2021ensemble>) #"Summaries claiming \"a single GPU\" conflict with the 4-V100 node used."]
  [- #cite(<xia2021>) #"Abstract \"12 % higher accuracy\" is relative (0.84 vs 0.75 is 9 points absolute)."]
  [- #cite(<yan2021>) #"The claimed outperformance rests on ~37 vs ~32 missed injections out of ~1e6, within Poisson scatter."]
  [- #cite(<yan2021>) #"Matched-filter templates are selected on the test set (best of 30 draws)."]
  [- #cite(<zhan2021>) #"Fig 2 calls the accuracy \"sensitivity\"."]
  [- #cite(<alhassan2022>) #"ResNet per-class recalls (Table 3) imply accuracy ~0.77 at SNR > 8, not the 0.985 stated."]
  [- #cite(<alhassan2022>) #"Conclusion quotes an 85 % mean accuracy; Table 3 averages 0.796."]
  [- #cite(<alhassan2022>) #"Mock-run detection fractions (0.29, 0.47) disagree with Table 3 recalls (0.59, 0.57)."]
  [- #cite(<andrews2022>) #"Text says 90 % to 70 % between 3 and 4 sigma; Fig 3 reads ~0.86 and ~0.81."]
  [- #cite(<andrews2022>) #"The matched-filter benchmark TAP equals FAP (chance level), impossible for a correct matched filter on injected signals."]
  [- #cite(<aveiro2022>) #"Conclusion says GW170817 found \"in both H1 and L1\"; L1 required a post-hoc cap on spectrogram values."]
  [- #cite(<chaturvedi2022>) #"\"No misclassifications\" on August 2017 against 1.3 false positives per month on time slides."]
  [- #cite(<ma2022>) #"The coincident FAR assumes independent, exactly simultaneous H and L false triggers."]
  [- #cite(<mcisaac2022>) #"Abstract \"~11 % above 300 Msun\" while Fig 5 shows +17 % in the highest band and non-monotonic bands."]
  [- #cite(<mcisaac2022>) #"Fig 5 colourbar floor (1.04) is above its lowest band label (+2 %)."]
  [- #cite(<mlgwsc2022>) #"Text says CNN-Coinc retains >= 50 % of the leading ML distance down to 10/month on DS4; Table IV gives 621 vs 1400 Mpc (44 %)."]
  [- #cite(<mlgwsc2022>) #"MFCNN runtime ~11.5 h in the text vs 12.0-12.3 h in Table IV."]
  [- #cite(<qiu2022>) #"FAP 1e-3 per 0.2 s segment is ~1.3e4 false alarms per month, not ~1e3 as stated."]
  [- #cite(<qiu2022>) #"GWTC counts (82 BBH + 2 BNS + 2 NSBH) do not match the 72 BBH evaluated."]
  [- #cite(<qiu2022>) #"One misclassified GWTC-3 BBH has SNR 8.0 although the text says all have SNR < 7."]
  [- #cite(<verma2022>) #"Confusion-matrix rows sum to 109.2 % (Fig 5) and 101.7 % (Fig 7)."]
  [- #cite(<verma2022>) #"498 recovered injections but 214 + 206 = 420 classified."]
  [- #cite(<verma2022>) #"Sec V claims >97 % / ~95 % accuracy; Figs 5-7 give 96.2 / 90.5 / 92.3 %."]
  [- #cite(<zhang2022>) #"The first catalogue gave 4.88e-4 as a FAR in Hz; the abstract calls it a probability (~1.5e-5 Hz as a rate)."]
  [- #cite(<alhassan2023pymerger>) #"The \"FPR\" on continuous mock data is the missed-injection fraction."]
  [- #cite(<alhassan2023pymerger>) #"Text counts (594 of 722 undetected at SNR 4-5) disagree with Fig 9 (0.526)."]
  [- #cite(<andrescarcasona2023>) #"Table IV H1-V1 row is non-monotonic (26.8 > 21.1) and repeats the H1-L1-V1 values."]
  [- #cite(<andrescarcasona2023>) #"The 95 % CL zero-event FP limit is 3/N = 4.0e-4, not 2e-4."]
  [- #cite(<andrescarcasona2023>) #"Inclination and polarisation labels are swapped in Table I."]
  [- #cite(<beveridge2023>) #"The 1-per-2-months threshold sits below the background resolution and relies on a linear tail fit."]
  [- #cite(<beveridge2023>) #"The max-SNR baseline is ~0 below FAR 0.05 Hz, which says more about the simulated glitch rate than about matched filtering."]
  [- #cite(<jadhav2023>) #"The 40-80 Msun bin exceeds the 5-60 Msun training range."]
  [- #cite(<jadhav2023>) #"The FAR bound comes from 0.9 s time slides of one 8.8-day chunk, which are strongly correlated."]
  [- #cite(<ma2024tempfree>) #"\"Half a month\" of data is 12.15 days."]
  [- #cite(<ma2024tempfree>) #"FAP 1e-4 equals one false positive in 10,000 samples."]
  [- #cite(<ma2024tempfree>) #"Same PRD article number (109 043009) as the MSNRnet-1 citation in the sweep: one citation is wrong."]
  [- #cite(<nousi2022>) #"The first catalogue attributed DS1-DS4 distances (2116/1242/1241/1092) that are the Virgo-AUTh MLGWSC-1 values, not this paper's."]
  [- #cite(<sasaoka2023attr>) #"SNR is computed on the 4 s truncation, so NSBH/BNS SNRs are not comparable with full-signal SNRs elsewhere."]
  [- #cite(<tian2023>) #"Abstract names ROC and PR AUC as figures of merit but no AUC is printed."]
  [- #cite(<tian2024gnn>) #"Abstract \"zero false positives\" in February 2020 follows manual removal of 7 of 13 noise triggers."]
  [- #cite(<tian2024gnn>) #"SNR bins differ between Fig 1 (17.23 ... 6.23) and Table 1 (8.4, 10.6)."]
  [- #cite(<trovato2023>) #"\"Two false alarms per day\" is equated with 1 in 1.7e5 trials (2 per day is 1 in ~4.3e4 s)."]
  [- #cite(<trovato2023>) #"Expected maximum false alarms 29/43/55 do not follow from 0/1/2 test false alarms (Poisson 95 % gives ~22/35/46)."]
  [- #cite(<badger2024>) #"Claimed TPR >= 0.9 at 12/yr for SNR >= 12.5 conflicts with the Fig 7 contours (0.98 near SNR 15-17)."]
  [- #cite(<badger2024>) #"All FARs below 12/yr are extrapolated from one month of data."]
  [- #cite(<koloniari2024>) #"The printed FAR fit (Eq 6) gives 13.1/yr at Rs 16, not the 0.34/yr in the text."]
  [- #cite(<koloniari2024>) #"Table I GW200301_211019 FAR is 10x the Eq 6 value (80380 vs 8380/yr)."]
  [- #cite(<koloniari2024>) #"Five of eight Virgo-LIGO events said to exceed Rs 3.5; Table V has four."]
  [- #cite(<marx2024>) #"Text gives TPR 0.053 at FPR ~1e-6 and SNR 6.23; Fig 5 reads ~0.43."]
  [- #cite(<marx2024>) #"Table IV FAR floor printed as < 0.97/yr while the text says one per year."]
  [- #cite(<meijer2024>) #"Same classifier and glitch set give TN 9762 vs 9763 on two test sets."]
  [- #cite(<menendez2024>) #"Table A1 has 25 events below the 1/week FAR against the 26 in the text."]
  [- #cite(<menendez2024>) #"Table A1 floors at 0.01/yr although the time slides reach 1/152.6 yr."]
  [- #cite(<wang2023tf>) #"Conclusion says all FAPs were better than 0.1 %; Sec III A gives 0.26 % for the Hanford O3 model."]
  [- #cite(<wang2023tf>) #"Real-event counts use the union of two detectors without adjusting the false-alarm probability."]
  [- #cite(<zelenka2024>) #"Model selection on the test set biases the 1316 Mpc upward."]
  [- #cite(<zelenka2024>) #"\"Virgo-AUTh at 87 % of this value\" matches neither Virgo-AUTh variant in Fig 4 (83 % or 119 %)."]
  [- #cite(<zelenka2024>) #"Fig 4 caption and legend disagree on which lines are dashed."]
  [- #cite(<ashton2025>) #"AUC differences are reported while the 90 % permutation bands overlap."]
  [- #cite(<beveridge2025o3>) #"GWTC-3 candidate counts (90 / 79 / 63) do not reconcile across sections."]
  [- #cite(<beveridge2025o3>) #"Missed-event accounting (54 + 23 > 75) does not close."]
  [- #cite(<marx2025aframeO3>) #"Text calls 35+35 sensitivity \"similar\"; Fig 2 shows Aframe above the matched-filter pipelines there and 40-50 % below at 20+10."]
  [- #cite(<marx2025aframeO3>) #"Comparison volumes use the LVK data release, whose injection weighting differs from the authors' own set."]
  [- #cite(<mcleod2025>) #"Fig 7 caption names week 3 (the background week) as the injection week."]
  [- #cite(<mcleod2025>) #"GW170817 FAR 6.9e-13 Hz is a Gaussian-tail extrapolation from a background reaching 1.8e-8 Hz."]
  [- #cite(<nagarajan2025>) #"Table V cWB row (1364 / 1441 / 1461 Mpc at 100 / 10 / 1 per month) rises as the FAR falls and does not match MLGWSC-1 Table IV for DS4 (1407 / 1332 / 1229)."]
  [- #cite(<nagarajan2025>) #"Table V re-quotes MFCNN (1269 / 985 / 588) and PyCBC (1722 / 1607 / 1539) differently from MLGWSC-1 Table IV (1269 / 999 / 650; 1722 / 1610 / 1544)."]
  [- #cite(<nagarajan2025>) #"Headline gains use the best of three seeds; the seed mean is lower (Fig 11)."]
  [- #cite(<silver2025>) #"Thresholds were set from performance in the real search, so 57/75 is in-sample."]
  [- #cite(<silver2025>) #"\"False positives\" are defined in Sec III B as events the pipeline does not detect."]
  [- #cite(<silver2025>) #"Extrapolated FARs (~1/350,000 yr) go far beyond the ~100 yr background."]
  [- #cite(<tiki2025>) #"The same configuration is reported with ~1.5 % different volumes in Tables 3 and 4."]
  [- #cite(<tiki2025>) #"Table 3 uses threshold 0.995 while the production threshold is 0.9999."]
  [- #cite(<wang2025exotic>) #"Text says ~1000 Mpc at 10/yr; Fig 6 reads ~750 Mpc there (1000 Mpc near 300/yr)."]
  [- #cite(<wang2025exotic>) #"FAR axes are labelled in years rather than per year."]
  [- #cite(<yamamoto2025>) #"\"Comparable to PyCBC\" at 1/month hides that the method is 2.5 % below PyCBC there but above it at 10-100/month."]
  [- #cite(<chatterjee2026>) #"Abstract says about five months of O3b; the live time is 95.3 d (~3.1 months)."]
  [- #cite(<chatterjee2026>) #"Per-month and per-year FARs in Table II are not related by a constant factor."]
  [- #cite(<chatterjee2026>) #"The discussion's \"roughly a factor of two\" over GW-Whisper is 1.66 and 1.49 in distance."]
  [- #cite(<gupta2026>) #"10,000 training vs 20,000 validation waveforms is reversed from the usual split (Sec II D 2)."]
  [- #cite(<insley2026flows>) #"The 6.55 % HV gain quoted in the abstract comes from the modified sampling with the old histograms, not from the flow."]
  [- #cite(<insley2026flows>) #"Four-detector FAR range \"0.5 to 3.03e-4\" has no unit and is in reverse order."]
  [- #cite(<insley2026flows>) #"\"Three orders of magnitude\" storage reduction holds for three detectors, not two."]
  [- #cite(<mobilia2026>) #"TAP values at FAP 1e-4 are quoted from ~1 noise sample."]
  [- #cite(<rai2026>) #"Table 3 sets a per-window FPR beside Aframe's FAR < 1/yr as if like for like."]
  [- #cite(<rai2026>) #"ECE reduction given as 15 % (Sec 3.3) and 95.6 % (Table 3)."]
  [- #cite(<weerasinghe2026>) #"Headline efficiency and the FAR calibration use different thresholds (1 % vs 0.3 % FPR)."]
  [- #cite(<weerasinghe2026>) #"AUC is said to be computed to FPR 1e-3 yet reported as a full AUC."]
  [- #cite(<weerasinghe2026>) #"Uncertainty grows with SNR (slope +0.25), so the SNR labels are unusable."]
}
= Early warning <sec-early>
Early-warning models try to flag a binary neutron star or neutron star-black hole inspiral before merger, from a partial inspiral whose signal-to-noise ratio (SNR) grows with time.

== Families and lineage
=== Partial-inspiral classifiers
Baltus et al. trained one CNN per binary neutron star mass class on long windows truncated before merger #cite(<baltus2021>) #cite(<baltus2021b>) #cite(<baltus2022>); later work changed the network or the deployment target #cite(<martins2024>) #cite(<alfaidi2024>) #cite(<papigkiotis2026>) and added auxiliary-channel noise subtraction #cite(<yu2021early>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 7 models: #cite(<baltus2021>), #cite(<baltus2021b>), #cite(<yu2021early>), #cite(<baltus2022>), #cite(<alfaidi2024>), #cite(<martins2024>), #cite(<papigkiotis2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Forecasting curves
Forecasting networks report the output probability against time to merger for single loud injections #cite(<wei2021forecast>) #cite(<wei2021>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 2 models: #cite(<wei2021>), #cite(<wei2021forecast>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (3 of 9); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yu2021early") #cite(<yu2021early>)], "eff@FAR", "BNS TAR 0.38 at d_eff 40 Mpc and 0.09 at 60 Mpc at 1 false alarm per 7.1 h (0.01 per 256 s segment) (Fig 9; read-from-figure)", "101 /month; 3.91e-05 Hz", [#gr-k #"Simulated non-stationary O3-like noise with witness-channel subtraction; the per-segment fraction converts exactly to a rate because segments are disjoint."], [#pend],
  [], "eff@FAR", "NSBH TAR 0.43 at d_eff 160 Mpc at the same FAR (Fig 10; read-from-figure)", "101 /month; 3.91e-05 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "baltus2022") #cite(<baltus2022>)], "eff@FAP", "50 % TAP at partial-inspiral SNR ~15 (Gaussian O3), ~20 (real O3) at FAP 1 % per 300 s frame (Sec III A, Figs 5-6; stated)", "-", [#gr-k #"Efficiency is at a per-frame FAP while the rate on real data is measured separately; the two are not paired."], [#pend],
  [], "other", "real O3b trigger rate 277.5 / day (single), 1.71 / day with 10 consecutive triggers (Sec III A; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alfaidi2024") #cite(<alfaidi2024>)], "eff@FAR", "LSTM TAP ~0.44 vs exact-template matched filter ~0.79 at FAR ~1e-3 Hz (SNR 2-20, single detector, Gaussian) (Fig 4; read-from-figure)", "2.59e+03 /month; 0.001 Hz", [#gr-k #"A FAR in Hz of a per-timestep statistic, with an exact-template matched filter as upper bound; Gaussian noise only."], [#pend],
)
== What cannot be compared, and why
Early-warning results are quoted against partial-inspiral SNR at a per-frame false-alarm probability of about 1 %, a rate of order one per hour for frames of a minute. Only papers that convert to a rate over disjoint segments (or measure one) are graded conditional; lead times for single loud injections are not comparable.

The 6 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "baltus2021") #cite(<baltus2021>)], "heavy-BNS TAP ~0.98 at 125 Mpc, ~0.9 at 175 Mpc at FAP 1 % per frame (single detector, Gaussian) (Fig 5; read-from-figure)", "Per-frame FAP of 1 % (frames 30-80 s) in Gaussian design noise; the realistic-population test detects ~4 of ~89.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "baltus2021b") #cite(<baltus2021b>)], "light-BNS TAP ~1 to 15 Mpc, 0.2 at 40 Mpc at FAP 1 % per frame (Sec IV, Fig 4; stated)", "Conference version of baltus2021 (arXiv 2105.13664, which the first catalogue missed).", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2021") #cite(<wei2021>)], "none extracted", "Forecasting curves for single injections at SNR 30; no FAR, ROC or efficiency.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2021forecast") #cite(<wei2021forecast>)], "BNS flagged up to 30 s before merger at SNR 30-40; GW170817 10 s before merger (Fig 2-3; stated)", "Lead time for single high-SNR injections; no FAR or population efficiency.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "martins2024") #cite(<martins2024>)], "TPR at FAP 1 % per 300 s sample: GWaveNet 76.2 % vs FindCNN 66.8 % (2D: 79.4 vs 69.5) (Table 2; stated)", "Same data recipe as Baltus et al.; per-sample FAP on a balanced set.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "papigkiotis2026") #cite(<papigkiotis2026>)], "test accuracy ~90 % (ET-like), >97 % (CE-like) at low FAP (abstract) (abstract; stated)", "Abstract-level; per-sample FAP in Gaussian ET/CE noise.", [#pend],
)
== Suspected errors in the literature
13 suspected errors or internal inconsistencies in 8 papers, selected from the extraction notes (28 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<baltus2021>) #"\"100 % TAP up to 125 Mpc\" vs Fig 5 (~1.0 only to ~100 Mpc)."]
  [- #cite(<baltus2021>) #"Network numbering differs between the text and the Fig 5 legend."]
  [- #cite(<baltus2021>) #"\"Comparable to matched filtering\" on the realistic population while Fig 7 shows ~4 found and ~85 missed."]
  [- #cite(<wei2021>) #"\"Decreases the top-1 error rate by 10 %\" with no baseline error stated."]
  [- #cite(<wei2021forecast>) #"Abstract \"up to 30 s\" holds only at injected SNR 30-40; the one real event is flagged 10 s ahead."]
  [- #cite(<yu2021early>) #"Stationary-noise BNS range quoted as ~80 Mpc at TAR 0.4; Fig 9 reads TAR ~0.31 there."]
  [- #cite(<yu2021early>) #"Abstract lead times (100 s, 10 s) vs body (~87 s, 12 s)."]
  [- #cite(<baltus2022>) #"Fig 6 plateaus at 0.91-0.97 while the text says efficiency reaches 100 % at PISNR 30."]
  [- #cite(<alfaidi2024>) #"Efficiency at 1/day and 1/6 h is quoted although Fig 4 starts near 6e-5 Hz (1 per 4.6 h)."]
  [- #cite(<alfaidi2024>) #"Test-point arithmetic (256,000 vs 2,560,000) does not close."]
  [- #cite(<martins2024>) #"Text says FindCNN is ~2 ms faster on GPU; Table 3 gives ~12 ms."]
  [- #cite(<martins2024>) #"Table 1 lists five curriculum sets but four PISNR values."]
  [- #cite(<papigkiotis2026>) #"FPR is defined as a false-discovery rate."]
}
= Burst and unmodelled transients <sec-burst>
Burst searches look for short transients without a template: core-collapse supernovae (CCSN), generic sine-Gaussian and white-noise-burst morphologies, cosmic-string cusps and long magnetar-like transients. Two traditions coexist: classifiers on simulated data, and machine-learning stages added to coherent WaveBurst (cWB) on real observing-run data.

== Families and lineage
=== Core-collapse supernova classifiers
From the first CNN on cWB images of phenomenological CCSN waveforms #cite(<astone2018>) through real-noise versions #cite(<lopez2021b>) and multi-class models on numerical waveforms #cite(<chan2020>) #cite(<iess2020>) #cite(<iess2023>) #cite(<sasaoka2023_ccsn>), to equation-of-state and frequency-slope classifiers #cite(<casallaslagos2026>) #cite(<morales2024>) and contrastive models #cite(<sun2026>) #cite(<wang2026ccsn_scl>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 14 models: #cite(<astone2018>), #cite(<chan2020>), #cite(<iess2020>), #cite(<nigam2020>), #cite(<lopez2021a>), #cite(<lopez2021b>), #cite(<iess2023>), #cite(<sasaoka2023_ccsn>), #cite(<morales2024>), #cite(<nunes2024>), #cite(<pracchia2025>), #cite(<casallaslagos2026>), #cite(<sun2026>), #cite(<wang2026ccsn_scl>). Results will be placed on the shared axes of this section beside the published values.]

=== Machine learning inside cWB
Boosted trees, Gaussian mixtures and genetic programming applied to cWB summary statistics on real observing-run data #cite(<vinciguerra2017>) #cite(<cavaglia2020>) #cite(<antelis2021>) #cite(<mishra2021>) #cite(<lopez2022gmm>) #cite(<szczepanczyk2022>) #cite(<alvarez2022cwbml>) #cite(<fernandes2025>). These are the burst results reported in search-grade units.

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 8 models: #cite(<vinciguerra2017>), #cite(<cavaglia2020>), #cite(<antelis2021>), #cite(<mishra2021>), #cite(<alvarez2022cwbml>), #cite(<lopez2022gmm>), #cite(<szczepanczyk2022>), #cite(<fernandes2025>). Results will be placed on the shared axes of this section beside the published values.]

=== Unmodelled neural searches
Coherence and autoencoder networks on real data with time-slide backgrounds: MLy #cite(<skliris2024>), GWAK #cite(<raikman2024>), the Wavelet Detection Filter with a graph network #cite(<cuoco2026>), and challenge entries on short windows #cite(<ratner2026>) #cite(<yan2025deepgrav>) #cite(<moreno2022>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 7 models: #cite(<marianer2021>), #cite(<moreno2022>), #cite(<raikman2024>), #cite(<skliris2024>), #cite(<yan2025deepgrav>), #cite(<cuoco2026>), #cite(<ratner2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Long-duration and exotic transients
Minute-long transients, post-glitch CW-like transients and cosmic strings #cite(<boudart2022>) #cite(<attadio2024>) #cite(<modafferi2023>) #cite(<meijer2023cosmicstrings>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 4 models: #cite(<boudart2022>), #cite(<meijer2023cosmicstrings>), #cite(<modafferi2023>), #cite(<attadio2024>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (15 of 33); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "astone2018") #cite(<astone2018>)], "eff@FAR", "CNN 5.9 / 60.7 / 91.8 % vs cWB 1.7 / 40.8 / 86.9 % at network SNR 8 / 12 / 20 (Table II; stated)", "181 /month; 7e-05 Hz", [#gr-k #"Phenomenological CCSN in Gaussian noise; efficiency is relative to a cWB pre-selection; per-SNR, not per distance."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2020") #cite(<chan2020>)], "eff@FAP", "TAP 86 % (H+L+VK) / 68 % (HLVK) at FAP 0.1 %, magnetorotational, 50 kpc (Sec IV, Fig 6; stated)", "-", [#gr-k #"Three-class CCSN in Gaussian design noise; FAP is a per-sample misclassification fraction, one CNN per distance."], [#pend],
  [], "eff@FAP", "TAP 76 % / 55 % at FAP 10 %, neutrino-driven, 10 kpc (Sec IV, Conclusion; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2021b") #cite(<lopez2021b>)], "AUC", "0.896 (blind set, phenomenological) / 0.79 (3D simulations), real O2 noise (Fig 12, Sec VI C; stated)", "-", [#gr-k #"CCSN in real O2 noise; \"FAR_CNN\" is FP/(FP+TP) on a balanced set; efficiency averaged over the injected SNR/distance mix."], [#pend],
  [], "eff@FAP", "TPR ~0.55 at FPR 2 %; ~0.84 at FPR 20 % (blind set) (Fig 12; read-from-figure)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mishra2021") #cite(<mishra2021>)], "eff@FAR", "BBH: ~0.89 (O1) / ~0.86 (O2) ML vs ~0.61 / ~0.57 standard cWB at 1/yr; IMBH ~0.74 / ~0.79 vs ~0.65 / ~0.57 (Fig 2 top; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [#gr-k #"Non-neural (XGBoost) cWB post-processing, O1/O2 time slides; efficiency is over recovered, not injected, events."], [#pend],
  [], "events", "all 7 cWB O1/O2 BBH events recovered with lower FAR (Table II; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alvarez2022cwbml") #cite(<alvarez2022cwbml>)], "reach@FAR", "sensitive hyper-volume O3a 0.822 vs 0.676 Gpc^3 yr (ML vs standard cWB); GstLAL 1.22, PyCBC-BBH 1.2, MBTA 0.885 on the same population (Table IV; stated)", "0.164 /month; 6.34e-08 Hz", [#gr-c #"Non-neural (XGBoost) cWB post-processing on full O3 HL; hyper-volume under the GWTC-2 Power Law + Peak population is the LVK search metric, so it is comparable with the matched-filter pipelines quoted beside it. The Fig 3 efficiencies use recovered (not injected) events as the denominator."], [#pend],
  [], "eff@FAR", "BBH set: 0.90 vs 0.76 (ML vs standard) at 1/yr; 0.62 vs 0.49 at 0.01/yr (Fig 3 top; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [], [#pend],
  [], "events", "5 further GWTC-3 BBHs at FAR < 1/yr that standard cWB vetoed (Table II; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2022gmm") #cite(<lopez2022gmm>)], "eff@FAR", "Gaussian pulse: gain >20 points over cWB (GA0d1 ~0.70 vs ~0.33); WNB ~0.89-0.905 vs ~0.78-0.79 (Fig 1, Sec III D; read-from-figure)", "0.000821 /month; 3.17e-10 Hz", [#gr-k #"cWB post-processing (non-neural GMM) on 104.9 d of O3a HL; efficiency over an hrss grid, not a sensitive volume."], [#pend],
  [], "events", "GW190521 iFAR >200 yr (cWB+GMM) vs 65 yr (standard) (Table IV; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "moreno2022") #cite(<moreno2022>)], "eff@FAP", "LSTM-AE TPR 46.1 % (BBH) / 23.7 % (BNS) at single-detector FPR 0.1; 43.3 % (BBH) at dual FPR 0.01 (Tables 1-2; stated)", "-", [#gr-k #"Synthetic (ggwd-style) data, SNR uniform 5-20, FPR per 2.5 s window; AUC conditionally comparable because noise and SNR distribution are stated."], [#pend],
  [], "AUC", "LSTM-AE 0.73 (BBH) / 0.59 (BNS) single; 0.79 / 0.63 dual; supervised CNN 0.92 / 0.77 (Figs 4, 6; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "szczepanczyk2022") #cite(<szczepanczyk2022>)], "reach@FAR", "hrss50 ratio XGB/standard cWB: Gaussian pulses 0.20-0.33, SG 0.84-0.95, WNB 0.91-0.95 (HL); volume gain 1.2-27x (Table I, Sec IV B, Fig 5; stated)", "0.000821 /month; 3.17e-10 Hz", [#gr-c #"LVK O3 all-sky burst search (non-neural XGBoost on cWB); real O3 background, LVK morphologies: the reference point for burst hrss50."], [#pend],
  [], "events", "16 known CBCs at iFAR >= 1 yr (standard cWB 14), O3 HL (Sec IV A; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "raikman2024") #cite(<raikman2024>)], "reach@FAR", "hrss50 0.55-1.83e-22 Hz^-1/2 (SG), 0.70-0.89e-22 (WNB) (Table II; stated)", "0.000821 /month; 3.17e-10 Hz", [#gr-c #"GWAK on full O3 with ~10,000 yr of time slides; LVK burst morphologies, so hrss50 is comparable with cWB/MLy at the same iFAR."], [#pend],
  [], "eff@FAR", "SNR at 50 % efficiency: SG 512-1024 Hz ~8.5, BBH ~12.5, CCSN ~21 (Fig 1; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "skliris2024") #cite(<skliris2024>)], "reach@FAR", "hrss50 MLy vs cWB: SGE70Q3 1.9 vs 1.5; SGE235Q100 1.4 vs 0.9; WNB100 1.7 vs 1.2 (1e-22 Hz^-1/2) (Table I; stated)", "0.0821 /month; 3.17e-08 Hz", [#gr-c #"O2 real background (~1e3 time shifts), O2 LVK burst injection set; directly comparable with cWB on the same set."], [#pend],
  [], "eff@FAR", ">=50 % at network SNR 19, >=90 % at 27 (WNB/CCSN/BBH) (Fig 6; stated)", "0.0821 /month; 3.17e-08 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fernandes2025") #cite(<fernandes2025>)], "reach@FAR", "sensitive VT ratio ML/base, PyCBC-IMBH: 1.07 (100-200 Msun) to 1.45 (400-600 Msun) at IFAR 100 yr (Fig 5; read-from-figure)", "0.000821 /month; 3.17e-10 Hz", [#gr-c #"Classifier re-ranking of PyCBC IMBH and higher-mode searches on O3a chunks 1-4; VT ratio at IFAR is a search-level metric, but relative to its own baseline only."], [#pend],
  [], "reach@FAR", "PyCBC-HM: 0.87 to 1.29 at IFAR 100 yr (Fig 6; read-from-figure)", "0.000821 /month; 3.17e-10 Hz", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "pracchia2025") #cite(<pracchia2025>)], "reach@FAR", "distance at 50 % efficiency: 0.64 kpc (s18), 1.83 kpc (m39), 0.15 kpc (mesa20_pert) (Table I; stated)", "0.0164 /month; 6.34e-09 Hz", [#gr-k #"Single detector, Gaussian O4-design noise; threshold one background event per 5 simulated years (Gaussian only)."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cuoco2026") #cite(<cuoco2026>)], "eff@FAR", "GNN vs deterministic WDF: all classes 0.70 vs 0.27 at 1/day (simulated); 0.28 vs 0.08 (real O4b); 0 at 1/month on real O4b (Tables II-III; stated)", "30 /month; 1.16e-05 Hz", [#gr-k #"Own simulated and 2.16 d real O4b sets, mixed CBC/CCSN classes; recovered fraction, not sensitive distance."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ratner2026") #cite(<ratner2026>)], "eff@FAR", "recall 0.88 (BBH) / 0.86 (SGLF) at <=1 false alarm per year, no trigger (Table I; stated)", "0.0821 /month; 3.17e-08 Hz", [#gr-k #"CodaBench anomaly-challenge 50 ms windows of cleaned real noise; FAR 1/yr extrapolated from 50k backgrounds; PR-AUC depends on the anomaly rate."], [#pend],
  [], "AUC", "PR-AUC 0.91 (BBH) / 0.89 (SGLF) (Table I; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sun2026") #cite(<sun2026>)], "AUC", "CS-CAE 0.976 / supervised CNN 0.984 / CAE 0.916 (in-distribution); 0.995 / 0.993 / 0.979 (numerical CCSN) (Figs 2-3; stated)", "-", [#gr-k #"Simulated ET Gaussian noise with phenomenological CCSN; AUC conditionally comparable within ET CCSN studies; the distance has no stated FAR."], [#pend],
  [], "reach@FAR", "~50 % efficiency at ~120 kpc (ET), threshold not stated (Sec III B, Fig 4; stated)", "-", [], [#pend],
)
== What cannot be compared, and why
Burst papers use different waveform families (phenomenological or numerical CCSN, sine-Gaussians, white-noise bursts), quote efficiency against network SNR, distance or hrss, and often define "FAR" as a false-discovery fraction on a balanced set. Results are comparable only within a morphology at a stated FAR: hrss50 on the LVK morphologies (cWB, MLy, GWAK) or volume gains of cWB post-processing on the same observing run.

The 18 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vinciguerra2017") #cite(<vinciguerra2017>)], "cWB baseline efficiency by distance shell for wide-mass CBC: 72.3 % (45-65 Mpc) to 10.2 % (340-505 Mpc) (Table 3; stated)", "Signal-morphology classification inside cWB on recoloured S6/VSR2-3 noise; the reported efficiencies are the baseline pipeline, not the classifier.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cavaglia2020") #cite(<cavaglia2020>)], "specificity 0.962 +- 0.011, FNR 0.036 +- 0.008 (Dimmelmeier, 3.16 kpc) (Sec V, Fig 2; stated)", "Genetic-programming classifier of cWB single-detector triggers (non-neural); balanced trigger test sets, no rate.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iess2020") #cite(<iess2020>)], "signal-vs-glitch accuracy 95.4 % (1-D) / 96.3 % (2-D), Virgo O3 PSD; 7-class 87.9 % (Fig 7, Fig 8, Sec 6.2; stated)", "Accuracy is conditional on a WDF trigger chosen with knowledge of the injection time; Gaussian noise and two parametrised glitch families; no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nigam2020") #cite(<nigam2020>)], "8-class accuracy 100 % (Deep Filtering, CNN, BiLSTM); RF 97.75 % (Table II; stated)", "Eight synthetic transient classes in white noise with no noise class; accuracy only.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "antelis2021") #cite(<antelis2021>)], "background FAR at cWB rho=5 cut from 0.0297 to 1.78e-4 Hz (L1) and 0.0253 to 1.95e-4 Hz (H1); L1H1 9.76e-6 Hz to the 1/3.3 yr floor (Sec III.B, Figs 5-6; stated); CCSN he3.5 detection efficiency vs distance essentially unchanged after ML (Fig 6; stated)", "Non-neural (SVM) cWB follow-up for CCSN on 3-day O3a windows; the FARs are trigger rates at one cWB threshold, and the efficiency is unchanged, so no efficiency-at-FAR gain is shown.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2021a") #cite(<lopez2021a>)], "70 % efficiency at \"FAR\" < 5 % for SNR > 15 (abstract level) (abstract; stated)", "Conference version of lopez2021b; \"FAR\" there is a false-discovery fraction, not a rate. Full text not read.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marianer2021") #cite(<marianer2021>)], "20-class accuracy 97.3 % on regenerated O1+O2 Gravity Spy-style spectrograms (1,197 test) (Sec 2.2; stated); hrss50 for flagging: 10e-22 (WNB 100 Hz) to 40e-22 Hz^-1/2 (sweeps); no FAR attached (Table 4; stated)", "Outlier search; hrss50 is for \"flagged as outlier\" with no time-normalised false-alarm rate.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "boudart2022") #cite(<boudart2022>)], "none extracted", "No quantitative metric: qualitative recovery limit at visibility 12-16; detection statistic deferred.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iess2023") #cite(<iess2023>)], "merged per-trigger TPR 99.3 % (L1), 99.1 % (H1), 79.8 % (V1), 97.8 % (3-detector) (Table 2, Sec 5; stated)", "Trigger classification at a fixed 1 kpc on real O2 noise; noise class is whatever WDF triggers; no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "meijer2023cosmicstrings") #cite(<meijer2023cosmicstrings>)], "accuracy 0.788, TPR 0.755 at FPR 0.18 (cusp vs blip, ET) (Table I; stated)", "Balanced cusp-versus-glitch classification in simulated ET noise; no noise class or FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "modafferi2023") #cite(<modafferi2023>)], "p_det > 90 % at p_FA 1e-7 (synthetic); two-stage CNN filter ~80x faster with ~1-3 % p_det change (Sec V, Fig 3; stated)", "Long-duration (post-glitch Vela) transient CW search on F-statistic atoms; p_FA per template, no link to transient FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sasaoka2023_ccsn") #cite(<sasaoka2023_ccsn>)], "10-class accuracy 0.984 (1 kpc), 0.603 (5 kpc), 0.332 (10 kpc), real O3 noise (Sec III A, Fig 5; stated)", "Read paper is arXiv 2310.09551 (PRD), not the catalogued PoS; per-distance multi-class accuracy, no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "attadio2024") #cite(<attadio2024>)], "efficiency 0.90 at FAP 0.02 (masked-loss denoiser) (Eq 23, Fig 10; stated)", "Long (1200 s) magnetar transients, single detector, simulated O4 noise; FAP is FP over all samples per map.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "morales2024") #cite(<morales2024>)], "3-class HFF-slope accuracy 0.987 / 0.933 / 0.853 at 1 / 5 / 10 kpc (L1, real O3b) (Table 6; stated)", "Classification of one waveform per class at fixed galactic distances; no FAR or noise class.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nunes2024") #cite(<nunes2024>)], "none extracted", "Abstract-level only: Richers CCSN catalogue in aLIGO noise; no metric extracted.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2025deepgrav") #cite(<yan2025deepgrav>)], "challenge TNR 0.9708 (development) / 0.9832 (final), first of 272 teams (abstract, Fig 3; stated)", "NSF HDR A3D3 anomaly-challenge score: TNR at an undisclosed threshold and TPR; trained on both signal classes, so not anomaly detection in the unsupervised sense.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "casallaslagos2026") #cite(<casallaslagos2026>)], "5-class EOS accuracy 98.58 % (1 kpc), 52.43 % (5 kpc), real O3b noise (abstract; Table 6; stated)", "Classifies already-triggered cWB maps of five fixed waveforms by equation of state; no false alarms enter, no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2026ccsn_scl") #cite(<wang2026ccsn_scl>)], "rotational TPR ~1.0 at FPR 1e-4 (10 and 200 kpc); ~0.80 at 1200 kpc (Sec IV-B, Fig 5; stated)", "Synthetic Gaussian HLVK spectrograms; FPR is per sample over the other classes; no real noise or glitches.", [#pend],
)
== Suspected errors in the literature
43 suspected errors or internal inconsistencies in 27 papers, selected from the extraction notes (96 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<astone2018>) #"The FAR of 7e-5 Hz in Table II is not derived from the CNN false-alarm fraction of 3-4 % (Eq 9 is a dimensionless fraction)."]
  [- #cite(<cavaglia2020>) #"Table II shows efficiency falling after cleaning (about 10 % at 2 sigma, 30 % at 3 sigma) while the abstract claims improved reach; the two use different operating points."]
  [- #cite(<chan2020>) #"Abstract attributes the 52 % / 83 % TAPs to waveforms; the body attributes them to the two networks."]
  [- #cite(<chan2020>) #"Training-set size given as 1.8e5 per distance and as about 4e5 per class."]
  [- #cite(<iess2020>) #"Text says total accuracies are consistently above 90 %, but Table 1 has 83.2 % (ET, s25, 1-D)."]
  [- #cite(<nigam2020>) #"Logistic-regression accuracy 89.67 % disagrees with its own confusion matrix (89.17 %)."]
  [- #cite(<nigam2020>) #"Three models at 100 % down to SNR 5 suggests a degenerate benchmark or leakage."]
  [- #cite(<antelis2021>) #"Abstract quotes FAR reduction by 10-100x; Table IV ranges 11-1019x, with L1H1 saturated at the background floor."]
  [- #cite(<antelis2021>) #"L1H1 noise rejection given as 99.4 % (text) and 99.0 % (Table II)."]
  [- #cite(<lopez2021b>) #"Efficiency floor of ~58-66 % at SNR 1-6 (Fig 14) is incompatible with a ~5-10 % false-positive fraction."]
  [- #cite(<mishra2021>) #"The 26 % / 16 % gains are absolute efficiency differences, not relative gains."]
  [- #cite(<mishra2021>) #"Efficiency denominator excludes injections cWB never recovers."]
  [- #cite(<alvarez2022cwbml>) #"Efficiency denominator is the number of cWB-recovered injections, not all injected, so curves reach 1.0."]
  [- #cite(<alvarez2022cwbml>) #"The \"about 20 %\" gain is +18 % relative for BBH but about +27 % relative for IMBH at 1/yr (Fig 3)."]
  [- #cite(<lopez2022gmm>) #"Background test fraction given as 30 % (Sec III B) and 20 % (Sec IV)."]
  [- #cite(<moreno2022>) #"Text equates FPR 1e-6 with one false alarm per three months, which holds only for 8 s windows, not the 2.5 s windows used."]
  [- #cite(<moreno2022>) #"Dual-detector BBH-CNN TPR (25.6 % at 1e-2) is below single-detector (66 % at 1e-1) although dual AUC is higher."]
  [- #cite(<szczepanczyk2022>) #"Table I Gaussian pulse tau=1.0 ms HL volume (1.5 vs 0.11, ratio 13.6) contradicts the 2.3-4.5 range in the text; likely a typo."]
  [- #cite(<szczepanczyk2022>) #"Fig 1 caption says 10 HLV events at iFAR >= 1 yr; the text says 8."]
  [- #cite(<iess2023>) #"Abstract \"~80 % for Virgo\" is the merged model on the triple-coincident subset; single V1 models are 68-75 %."]
  [- #cite(<meijer2023cosmicstrings>) #"Matched filtering against the exact injected template is reported worse than random (Fig 16-17), which is implausible for the optimal filter."]
  [- #cite(<sasaoka2023_ccsn>) #"PoS abstract gives 96.9 % at 1 kpc against 98.4 % in the arXiv/PRD version."]
  [- #cite(<attadio2024>) #"FAP is defined as FP/(all samples), not FP/(FP+TN), which understates the false-positive rate."]
  [- #cite(<morales2024>) #"Binned-regression accuracy rises from 1 to 5 kpc (0.55 to 0.85, Table 8), implausible for an amplitude-limited task."]
  [- #cite(<raikman2024>) #"hrss50 takes only three distinct values across eight SG morphologies, suggesting a coarse amplitude grid."]
  [- #cite(<raikman2024>) #"Abstract claims three CBCs detected; none passes the paper's 1/100 yr threshold."]
  [- #cite(<skliris2024>) #"Text says MLy is 10-50 % worse in hrss than cWB; Table I gives up to +56 %."]
  [- #cite(<skliris2024>) #"The 1/yr threshold is extrapolated from time lags of days to weeks of data."]
  [- #cite(<fernandes2025>) #"Text gives up to ~70 % VT gain at IFAR 100 yr; Fig 5 reads ~45 % there (70 % matches the 1000 yr marker)."]
  [- #cite(<fernandes2025>) #"PyCBC-HM VT ratio at 100 yr lies below both 10 yr and 1000 yr in every mass bin, unexplained."]
  [- #cite(<pracchia2025>) #"Table I column headings (10/50/90 % exclusion distance) are defined only in the Fig 6 caption; values fall as the percentage rises."]
  [- #cite(<yan2025deepgrav>) #"TNR without the matching TPR or threshold is not a detection performance."]
  [- #cite(<yan2025deepgrav>) #"Augmentation counts do not close (n in {3,5,10} x 200,000 vs the stated 300,000)."]
  [- #cite(<casallaslagos2026>) #"Abstract macro AUC 0.97 at 1 kpc against 0.80 macro / 0.89 micro in Sec 7."]
  [- #cite(<casallaslagos2026>) #"Abstract 52.43 % at 5 kpc against 0.80-0.83 in Tables 7-8."]
  [- #cite(<casallaslagos2026>) #"TW1 spans 14 days, not one week, and overlaps TW2 (Table 1)."]
  [- #cite(<cuoco2026>) #"\"Similar gains on real O4\" understates the drop (0.70 -> 0.28 at 1/day)."]
  [- #cite(<cuoco2026>) #"Fig 7 AUCs below 0.5 (BNS 0.06) are coincidence-saturated, not discrimination AUCs."]
  [- #cite(<cuoco2026>) #"Simulated BH-NS count (289) exceeds the 258 injected."]
  [- #cite(<ratner2026>) #"Abstract quotes recall 0.91 (BBH) and 0.85 (SGLF); Table I gives 0.88 and 0.86 (0.91 is the PR-AUC)."]
  [- #cite(<sun2026>) #"The 120 kpc reach is quoted at an \"adopted operating threshold\" with no FPR or FAR."]
  [- #cite(<wang2026ccsn_scl>) #"Abstract says ~100 % TPR at FPR 1e-4 for both classes at 10-200 kpc; Sec IV-B says neutrino-driven performance collapses below FPR 6e-5."]
  [- #cite(<wang2026ccsn_scl>) #"Fig 7 plots FPR down to 1e-5 with 50,000 noise samples (resolution 2e-5)."]
}
= Anomaly and multi-signal detection <sec-anomaly>
Anomaly and multi-signal detectors are trained on noise (or on noise plus a few known classes) and flag what does not fit. Their false-alarm behaviour is set by the definition of normal data, which differs from paper to paper.

== Families and lineage
=== Autoencoder anomaly detectors
Recurrent or convolutional autoencoders trained on noise #cite(<raikman2023>) #cite(<fayad2024>) #cite(<cain2025>) #cite(<guo2025>) #cite(<imran2024>) #cite(<morawski2021>), scaled up to a multi-level pipeline over O3-O4 with a measured background #cite(<inguglia2026>) and to Einstein Telescope mock data #cite(<inguglia2025>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 8 models: #cite(<morawski2021>), #cite(<raikman2023>), #cite(<fayad2024>), #cite(<imran2024>), #cite(<cain2025>), #cite(<guo2025>), #cite(<inguglia2025>), #cite(<inguglia2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Foundation-model features
Pretrained audio or vision transformers used as feature extractors #cite(<chatterjee2024>) #cite(<cirfeta2026>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 2 models: #cite(<chatterjee2024>), #cite(<cirfeta2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Other approaches
Entries that do not belong to the families above.

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 1 models: #cite(<ma2025overlap>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (3 of 11); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "raikman2023") #cite(<raikman2023>)], "eff@FAR", "SNR at 50 % efficiency: BBH ~15.5, SG 512-1024 Hz ~10, WNB ~23, CCSN ~27 (Fig 13; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [#gr-k #"About 71 min of O3a H1+L1 noise; the 1 yr background is built from heavily reused time slides."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024") #cite(<chatterjee2024>)], "reach@FAR", "sensitive distance 890 Mpc (DS3) / 905 Mpc (DS4) (Fig 2a-b; read-from-figure)", "1 /month; 3.86e-07 Hz", [#gr-c #"MLGWSC-1 DS3/DS4 with the challenge evaluation code: directly comparable with the challenge entries."], [#pend],
  [], "events", "18 of 31 O3b GWTC-3 BBHs recovered (Sec 1.1, Fig 3; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "inguglia2026") #cite(<inguglia2026>)], "reach@FAR", "VT relative to LVK pipelines at FAR < 1/yr: O3a 20-100 Msun 0.20-0.54 of matched filter, 0.48-0.56 of cWB; 100-160 Msun 0.54-1.28 and 0.63-1.05 (Sec 5; stated)", "0.0821 /month; 3.17e-08 Hz", [#gr-c #"Real O3-O4 HL data with time-slide FAR, injection-calibrated, and VT against reweighted LVK sensitivity injections: search-grade, although training overlaps part of the O3a test period."], [#pend],
  [], "eff@FAR", "injection recovery at FAR < 1/yr, O3a: 0.07 / 0.39 / 0.72 / 0.92 at network SNR 10 / 15 / 25 / 40 (Table 1; stated)", "0.0821 /month; 3.17e-08 Hz", [], [#pend],
  [], "events", "47 detections at FAR < 1/yr in O3a-O4b (44 shared with cWB), none new (Sec 4, Table 3; stated)", "-", [], [#pend],
)
== What cannot be compared, and why
The anomaly literature has no shared definition of normal data, so AUCs and recalls depend on which anomalies were chosen. Only the O3-O4 pipeline with time slides and sensitive volume is search-grade.

The 8 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "morawski2021") #cite(<morawski2021>)], "none extracted", "Abstract-level: convolutional autoencoder anomaly detection; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fayad2024") #cite(<fayad2024>)], "0.89 (LSTM-VAE) vs 0.76 (AE), 10 events vs 10 noise samples (Fig 6; stated)", "n = 20 test samples, so AUC carries roughly +-0.1; no SNR distribution, no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "imran2024") #cite(<imran2024>)], "none extracted", "Abstract-level: autoencoder on Gravity Spy spectrograms; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cain2025") #cite(<cain2025>)], "ROC-AUC 0.994, AP 0.967 (102 O4 events vs 399 noise segments, H1) (Fig 5, Sec 4.4; stated); synthetic BBH SNR 8-25, aLIGO PSD: AUC 0.806 (Table 1; stated)", "Catalogue events versus random science segments with an F1-maximising threshold chosen on the test set; the authors show the O1-O4 skill partly tracks run-specific whitening (AUC 0.78 to 0.44 after uniform re-whitening).", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "guo2025") #cite(<guo2025>)], "per-class AUC vs SNR, e.g. IMRPhenomD 0.561 / 0.855 / 0.993 / 1.000 at SNR 5 / 10 / 15 / 20 (mock Gaussian noise) (Table I; stated); real 4-OGC events detected: 0.04 / 0.24 / 0.80 / 1.0 at single-detector SNR 5 / 10 / 15 / 20 at FAR ~1e-3 Hz (Fig 17; read-from-figure)", "Single-detector anomaly flagger at ~3.6 alarms per hour; the FAR is several orders above search thresholds.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "inguglia2025") #cite(<inguglia2025>)], "IMBH-forming BBH: 23 % (unsupervised) / 100 % (weakly supervised) at nominal 4.5/yr (Sec 4.2, Fig 8; stated)", "ET mock data, single channel, Gaussian noise; FAR is a nominal Gaussian-tail statement, not a background count.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2025overlap") #cite(<ma2025overlap>)], "none extracted", "Not read beyond the abstract: separation of overlapping signals for PE; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cirfeta2026") #cite(<cirfeta2026>)], "recall at 1 % exceedance: harmonic comb >0.98, scattered light 0.58, blips 0.00 at SNR ~380-430 (Sec V A, Table III; stated)", "Glitch-morphology anomaly ranking on O4a with injected SNRs of 200-430; recall at an empirical calibration-pool exceedance, not a FAR.", [#pend],
)
== Suspected errors in the literature
15 suspected errors or internal inconsistencies in 7 papers, selected from the extraction notes (35 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<raikman2023>) #"Supernova sensitivity quoted three ways (SNR 22 at 1/hour; 20-25 at 1-2/month; 50 % at ~27 at 1/yr)."]
  [- #cite(<chatterjee2024>) #"Catalogue summary \"94-98 % per class\" does not match Fig 4b (0.90-0.99)."]
  [- #cite(<chatterjee2024>) #"O3b FARs down to <1e-20 per month come from exponential extrapolation of a one-month background."]
  [- #cite(<cain2025>) #"Threshold described as validated (Sec 3) and as F1-optimised on the test set (Sec 4.4)."]
  [- #cite(<cain2025>) #"Event counts disagree (216 vs 207 vs 192)."]
  [- #cite(<cain2025>) #"Claimed chirp band to 800 Hz exceeds the Nyquist frequency of the 1024 Hz data."]
  [- #cite(<guo2025>) #"Table III caption gives 3.75 per hour for 1e-3 per second (3.6)."]
  [- #cite(<guo2025>) #"Conclusions report 1482 anomalies in 88.74 h; the body reports 270 in 546 min."]
  [- #cite(<inguglia2025>) #"Abstract 4.5/yr vs conclusions 4.6/yr; the 5-sigma threshold used is ~6.3 sigma on the fitted Gaussian."]
  [- #cite(<inguglia2025>) #"Weak-supervision injections overlap the IMBH test population."]
  [- #cite(<cirfeta2026>) #"Blip failure SNR given as ~380 (text) and ~430 (Table III)."]
  [- #cite(<cirfeta2026>) #"Version-1 catalogue counts are retained but superseded by the author."]
  [- #cite(<inguglia2026>) #"Table 3 has 46 rows against the 47 detections claimed."]
  [- #cite(<inguglia2026>) #"Gate accounting in Sec 6 (53 above threshold, 48 pass, \"only two\" rejected) does not close."]
  [- #cite(<inguglia2026>) #"Training uses 32 of the 143 O3a blocks that are also searched."]
}
= Continuous and long-duration waves <sec-cw>
Continuous-wave (CW) models search for long, nearly monochromatic signals from spinning neutron stars, or classify the candidates of a semi-coherent search. The field has a shared figure of merit, the sensitivity depth at a fixed false-alarm probability per frequency band, which makes comparison more direct than in the transient categories.

== Families and lineage
=== Deep-learning CW searches against WEAVE
Dreissigacker et al. set the benchmark of sensitivity depth at 1 % false alarm per 50 mHz against the WEAVE coherent search #cite(<dreissigacker2019>) #cite(<dreissigacker2020>); large-kernel CNNs, U-Nets and vision transformers later approached the matched-filter depth on the same style of benchmark #cite(<joshi2023>) #cite(<joshi2024large>) #cite(<joshi2025vit>) #cite(<cheung2025unet>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 9 models: #cite(<dreissigacker2019>), #cite(<dreissigacker2020>), #cite(<dominguez2023>), #cite(<duraisamy2023>), #cite(<joshi2023>), #cite(<joshi2024large>), #cite(<cheung2025unet>), #cite(<joshi2025vit>), #cite(<tenorio2025g2net_cw>). Results will be placed on the shared axes of this section beside the published values.]

=== Candidate follow-up and clustering
Networks that act on the output of a semi-coherent search: Viterbi maps #cite(<bayley2020>), Einstein\@Home candidate clusters #cite(<beheshtipour2020>) #cite(<beheshtipour2020b>), TD-Fstat distributions #cite(<morawski2020cw>), FrequencyHough candidates #cite(<dicesare2026fh>) and excess-power selection #cite(<yamamoto2021cw>) #cite(<yamamoto2022cw>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 7 models: #cite(<morawski2020cw>), #cite(<bayley2020>), #cite(<beheshtipour2020>), #cite(<beheshtipour2020b>), #cite(<yamamoto2021cw>), #cite(<yamamoto2022cw>), #cite(<dicesare2026fh>). Results will be placed on the shared axes of this section beside the published values.]

=== Long and intermittent signals
Post-merger remnant transients and intermittent backgrounds #cite(<miller2019>) #cite(<yamamoto2023>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 2 models: #cite(<miller2019>), #cite(<yamamoto2023>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (10 of 18); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dreissigacker2019") #cite(<dreissigacker2019>)], "depth@pfa", "D90 10.8 vs WEAVE 11.4 (20 Hz) and 7.7 vs 9.7 (1000 Hz), T = 1e5 s, pfa 1 % per 50 mHz (Tables IV, VI; stated)", "-", [#gr-c #"Single detector, Gaussian noise; depth at a per-band false-alarm probability against a matched-filter (WEAVE) depth on the same setup: the CW benchmark convention."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bayley2020") #cite(<bayley2020>)], "depth@pfa", "depth ~10 Hz^-1/2 at 95 % efficiency, 1 % FAP per sub-band (S6 MDC) (Abstract, Fig 10b; stated)", "-", [#gr-k #"D95 (not D90) on S6 mock data with a SOAP + CNN pipeline."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dreissigacker2020") #cite(<dreissigacker2020>)], "depth@pfa", "all-sky DNN ~7 % (20 Hz) to ~51 % (1000 Hz) less deep than WEAVE (WEAVE D90 16.0 to 13.6, T = 1e5 s) (Table IV and results; stated)", "-", [#gr-c #"Two detectors, Gaussian and realistic noise; D90 at pfa 1 % per 50 mHz against WEAVE on the same setup."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2021cw") #cite(<yamamoto2021cw>)], "depth@pfa", "D95 ~80 Hz^-1/2 at overall FAP 1 % (headline), 20-120 across the parameter scan (Sec VI, Fig 6; stated)", "-", [#gr-k #"Single-detector Gaussian data; the 95 % check skips the coherent follow-up."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2022cw") #cite(<yamamoto2022cw>)], "depth@pfa", "D95 43.9 Hz^-1/2 at FAP ~0.66 % (Gaussian); 3.62 with a unit-amplitude line at FAP ~10 % (Eqs 4.2, 4.4; stated)", "-", [#gr-k #"Single 100 Hz bin of simulated data; the line and no-line depths are at different FAPs."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "joshi2023") #cite(<joshi2023>)], "depth@pfa", "p_det 87.4-89.0 % at the matched-filter D90 (86.2 / 81.8 Hz^-1/2), pfa 1 %, targeted 10-day search (Table IV; stated)", "-", [#gr-c #"White Gaussian H1+L1, single template; p_det at the matched-filter depth is the direct comparison."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "joshi2024large") #cite(<joshi2024large>)], "depth@pfa", "all-sky p_det at WEAVE depth 67.0 / 52.8 / 47.6 / 41.5 / 38.8 % (20 / 100 / 200 / 500 / 1000 Hz); D90 29.3 to 18.3 Hz^-1/2 (Tables V-VI; stated)", "-", [#gr-c #"Simulated white Gaussian H1+L1, 10 days; WEAVE depths rescaled by sqrt(T)."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cheung2025unet") #cite(<cheung2025unet>)], "depth@pfa", "D90 29.97 (20 Hz) to 17.10 (1000 Hz) Hz^-1/2 at 1 % per 50 mHz; WEAVE 40.28 to 34.50 on a different setup (Table II; stated)", "-", [#gr-k #"O3-like two-detector data; the WEAVE reference comes from another search setup."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "joshi2025vit") #cite(<joshi2025vit>)], "depth@pfa", "p_det at the F-statistic depth: targeted 87.3-89.7 %, directed 84.8-88.7 %, all-sky 88.3 % (20 Hz) to 78.2 % (1000 Hz) (Table IV; stated)", "-", [#gr-c #"Same benchmark family as joshi2023/2024 (white Gaussian H1+L1)."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tenorio2025g2net_cw") #cite(<tenorio2025g2net_cw>)], "AUC", "G2Net CW Kaggle private AUC: 1st 0.860, 2nd 0.854, SOAP 0.604 (Fig 5; stated)", "-", [#gr-k #"Competition data with SNR ~ Gamma(5, 9) in mixed Gaussian and real O3 noise; AUC comparable across entries of this competition only."], [#pend],
)
== What cannot be compared, and why
CW results are comparable when they share the convention of sensitivity depth at a false-alarm probability per frequency band and the same data span (or are rescaled by the square root of the span, which several papers do explicitly). Candidate-clustering efficiencies and toy-model detectability thresholds are not on that axis.

The 8 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "miller2019") #cite(<miller2019>)], "50 % efficiency at h0 ~3.6e-23 (150-300 Hz) at per-map FAP ~1 % (CNN) vs ~0.01 % (FrequencyHough) (Figs 3, 6; read-from-figure)", "Long-transient maps in real O2 L1 noise; the CNN and FrequencyHough are compared at FAPs 100x apart.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "morawski2020cw") #cite(<morawski2020cw>)], "CW-vs-rest AUC 0.99 (1D and 2D CNN); TPR 96.3 % at 1 % FPR (Fig 7, Table 2; stated)", "Classifier of TD-Fstat outputs in white Gaussian noise with injected SNR 8-20.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beheshtipour2020") #cite(<beheshtipour2020>)], "cluster-identification efficiency 97 % (1137 of 1171) on Einstein@Home result images (Sec III; stated)", "Post-processing of search candidates; efficiency for loud, visible signals.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beheshtipour2020b") #cite(<beheshtipour2020b>)], "cascade efficiency 92 % above normalised amplitude 1/60 vs deterministic clustering 83 % (Sec IV-V; stated)", "Einstein@Home O2 candidate clustering; comparable only with the deterministic clustering it replaces.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dominguez2023") #cite(<dominguez2023>)], "none extracted", "Qualitative only; the abstract reports degradation on real O3 data.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "duraisamy2023") #cite(<duraisamy2023>)], "none extracted", "Not read; no abstract.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2023") #cite(<yamamoto2023>)], "minimum detectable SNR rho_90 0.7 to 2.8 vs duty cycle at FAP 5 % (Fig 4; read-from-figure)", "Toy intermittent-background model in white noise; no detector data conventions.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dicesare2026fh") #cite(<dicesare2026fh>)], "injection at h0 7.76e-26 identified below the O3 follow-up sensitivity (Sec 5; stated)", "Follow-up classifier of FrequencyHough candidates; accuracy tables not extracted.", [#pend],
)
== Suspected errors in the literature
25 suspected errors or internal inconsistencies in 14 papers, selected from the extraction notes (40 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<dreissigacker2019>) #"\"Nearly rivaling matched filtering\" is a fixed-depth comparison where matched filtering is 90 % by construction."]
  [- #cite(<miller2019>) #"500 maps of 2000 s are said to span ~11.5 days and 2000 maps ~23 days (should be ~46)."]
  [- #cite(<miller2019>) #"~1 microsecond vs 1 minute per map is ~7 orders of magnitude, not \"at least 5\"."]
  [- #cite(<miller2019>) #"64,000 noise maps are built from 2,000 unique ones."]
  [- #cite(<morawski2020cw>) #"Stated dataset total (292,500) is inconsistent with 6 bands x 13 SNRs x 7,500."]
  [- #cite(<bayley2020>) #"95 % sensitivities given as SNR 85 / 115 (Sec VI A) and 90 / 120 (Sec VII)."]
  [- #cite(<bayley2020>) #"SNR range 20-200 in Sec VI A vs 50-150 in the explanation of the high-SNR drop."]
  [- #cite(<beheshtipour2020>) #"1345 returned - 1137 correct = 208 wrong clusters, but the text reports 174 false alarms."]
  [- #cite(<beheshtipour2020b>) #"Conclusion: 80 % at 1/80 sqrt(Hz); Fig 9's lowest bin reads ~0.84."]
  [- #cite(<beheshtipour2020b>) #"132,524,538 pixels quoted for a 512 x 512 image."]
  [- #cite(<yamamoto2021cw>) #"Headline D95 ~80 differs from the worked example (~100, Fig 5) without stating which setting it refers to."]
  [- #cite(<yamamoto2022cw>) #"Abstract FAP ~0.5 % vs 0.66 % from the 20,000-event test."]
  [- #cite(<yamamoto2022cw>) #"The 8.2 % depth ratio compares FAP 10 % with FAP 0.66 %."]
  [- #cite(<yamamoto2022cw>) #"Efficiency \"one or two orders of magnitude\" vs SOAP's three orders in Table VII."]
  [- #cite(<joshi2023>) #"Matched-filter parity claimed at 88.3 % mean against 90 % by construction (~1.7 points lower)."]
  [- #cite(<joshi2023>) #"Kernel width of 313 bins is 3.62 mHz at 1/day resolution, not 3.4 mHz."]
  [- #cite(<yamamoto2023>) #"FAP 0.05 in the main text vs FAP = FDP = 0.1 in Appendix Fig 10."]
  [- #cite(<yamamoto2023>) #"Claimed parity with the optimal statistic holds only for log10 xi > -1.75 (Fig 4)."]
  [- #cite(<joshi2024large>) #"Table VI compares 10-day depths with unrescaled 1e6 s depths of the earlier work."]
  [- #cite(<joshi2024large>) #"p_fa calibration changes between validation (0.76 % per 38 mHz) and test (0.48 %)."]
  [- #cite(<joshi2024large>) #"Abstract claims high sensitivity at all frequencies for the single DNN, which reaches 30-40 % p_det at the matched-filter depth."]
  [- #cite(<cheung2025unet>) #"\"Comparable sensitivity at 20 and 200 Hz\" vs p_det 69 % and 46 % at the matched-filter depth (Table II)."]
  [- #cite(<joshi2025vit>) #"Targeted reference time and D90 (86.1 / 81.6) differ slightly from joshi2023 (86.2 / 81.8) although described as the same benchmark."]
  [- #cite(<tenorio2025g2net_cw>) #"Table 2 headers say <rho^2> but values behave as rho."]
  [- #cite(<tenorio2025g2net_cw>) #"Legend AUC order (KDL 0.789 7th, MC Digital 0.791 8th) disagrees with the ranking."]
}
= Glitch classification and data quality <sec-glitch>
Glitch classification began with Gravity Spy, whose citizen-science labels and image format became the de facto benchmark. Later work changed the backbone, the input view, the class set and the data release, which is why accuracies from different papers rarely share a test set.

== Families and lineage
=== Gravity Spy supervised classifiers
Gravity Spy introduced multi-duration Omega-scan images and a CNN trained on citizen-science labels #cite(<zevin2017>) #cite(<bahaadini2017>) #cite(<bahaadini2018>); transfer learning #cite(<george2017tl>) #cite(<george2018glitch>) #cite(<mesuga2021>), new releases and classes #cite(<soni2021>) #cite(<glanzer2023>) #cite(<zevin2024>), and new architectures #cite(<fernandes2023>) #cite(<wu2024>) #cite(<srivastava2024>) #cite(<licciardi2024>) #cite(<yan2022gan>) followed.

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 22 models: #cite(<bahaadini2017>), #cite(<george2017tl>), #cite(<zevin2017>), #cite(<bahaadini2018>), #cite(<george2018glitch>), #cite(<mesuga2021>), #cite(<soni2021>), #cite(<talpini2022>), #cite(<yan2022gan>), #cite(<biskin2023>), #cite(<fernandes2023>), #cite(<glanzer2023>), #cite(<koyama2024>), #cite(<licciardi2024>), #cite(<malz2024>), #cite(<srivastava2024>), #cite(<wu2024>), #cite(<zevin2024>), #cite(<bhandari2025>), #cite(<singh2025>), #cite(<fernandes2026>), #cite(<xie2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Unsupervised and similarity methods
Embeddings and clustering for unseen classes #cite(<bahaadini2018direct>) #cite(<coughlin2019>) #cite(<bahaadini2022>) #cite(<sakai2022>) #cite(<li2024ctsae>) #cite(<deshmukh2026>) #cite(<kim2026kagra>) #cite(<oshino2025>) #cite(<laguarta2023>) #cite(<ding2021>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 11 models: #cite(<bahaadini2018direct>), #cite(<coughlin2019>), #cite(<ding2021>), #cite(<sankarapandian2021>), #cite(<bahaadini2022>), #cite(<sakai2022>), #cite(<laguarta2023>), #cite(<li2024ctsae>), #cite(<oshino2025>), #cite(<deshmukh2026>), #cite(<kim2026kagra>). Results will be placed on the shared axes of this section beside the published values.]

=== Signal-versus-glitch vetoes
Classifiers that separate astrophysical signals from glitches for a search #cite(<alvarez2023>) #cite(<jarov2023>) #cite(<choudhary2022>) #cite(<vandyke2025>) #cite(<magee2024interp>) #cite(<arutkeerthi2024>) #cite(<shah2023>) #cite(<bini2023>) #cite(<chan2025>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 10 models: #cite(<choudhary2022>), #cite(<alvarez2023>), #cite(<bini2023>), #cite(<jarov2023>), #cite(<shah2023>), #cite(<arutkeerthi2024>), #cite(<magee2024interp>), #cite(<chan2025>), #cite(<gupta2025ae>), #cite(<vandyke2025>). Results will be placed on the shared axes of this section beside the published values.]

=== Auxiliary-channel data quality
Models that read witness channels rather than strain #cite(<essick2020>) #cite(<colgan2020>) #cite(<colgan2022>) #cite(<cavaglia2018>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 4 models: #cite(<cavaglia2018>), #cite(<colgan2020>), #cite(<essick2020>), #cite(<colgan2022>). Results will be placed on the shared axes of this section beside the published values.]

=== Early and simulated-glitch classifiers
Classifiers of simulated morphologies in Gaussian noise #cite(<powell2015>) #cite(<powell2016>) #cite(<razzano2018>) #cite(<llorensmonteagudo2018>) #cite(<boudart2022glitch>), tabular metadata models #cite(<apostol2023>) #cite(<manoharan2026>) and glitch generators #cite(<dooney2022>) #cite(<dooney2026>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 9 models: #cite(<powell2015>), #cite(<powell2016>), #cite(<llorensmonteagudo2018>), #cite(<razzano2018>), #cite(<boudart2022glitch>), #cite(<dooney2022>), #cite(<apostol2023>), #cite(<dooney2026>), #cite(<manoharan2026>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (14 of 56); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2017") #cite(<bahaadini2017>)], "GS", "merged-view CNN accuracy 96.89 % (20 classes, Gravity Spy O1, 7,730 glitches, 75/12.5/12.5 split) (Tables 2-3; stated)", "-", [#gr-k #"Gravity Spy O1 20-class set with its own split; accuracy only (no macro-F1)."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2017tl") #cite(<george2017tl>)], "GS", "top-1 98.84 % (ResNet50, Inception-V3), 22 classes, Gravity Spy O1, random 80/20 split (Table 1; stated)", "-", [#gr-k #"arXiv version of george2018glitch (PRD 97 101501(R)); same numbers."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zevin2017") #cite(<zevin2017>)], "GS", "average test accuracy 97.1 % (20 classes, Gravity Spy O1, 7,718 glitches); per-class recall mean ~0.90 (Sec 4.1, Fig 7; stated)", "-", [#gr-k #"The Gravity Spy reference; accuracy is sample-weighted."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018glitch") #cite(<george2018glitch>)], "GS", "top-1 accuracy 98.84 % (Inception-V3, ResNet50), 22 classes, Gravity Spy O1 ~8,500 images, random 80/20 split (Table 1; stated)", "-", [#gr-k #"Gravity Spy O1 22-class set with a single random split and no validation set."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "soni2021") #cite(<soni2021>)], "GS", "validation accuracy 98.8 % (expert) / 97.5 % (volunteer), 23 classes, Gravity Spy O3 (9,631 examples) (Sec 2.2-2.3; stated)", "-", [#gr-k #"Validation, not held-out test, accuracies on the O3 23-class set."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2022gan") #cite(<yan2022gan>)], "GS", "weighted F1 0.9885 (Inception-V3, GAN N=5000, no pre-training) vs 0.9880 (pre-trained baseline), Gravity Spy 1.0, 21 classes (Table 4; stated)", "-", [#gr-k #"Gravity Spy v1.0 own split, 5-run means."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bini2023") #cite(<bini2023>)], "reach@FAR", "cWB XGBoost+AE vs XGBoost: sensitivity-volume gain at IFAR 50 yr +8 to +44 % (SG), +33 % (cosmic strings) (Sec 5.2, Fig 4; stated)", "0.00164 /month; 6.34e-10 Hz", [#gr-k #"Glitch-rejection feature inside cWB on 40 d of O3b with ~380 yr of time slides; relative to the cWB XGBoost baseline."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fernandes2023") #cite(<fernandes2023>)], "GS", "macro-F1 97.18 %, accuracy 98.68 % (ResNet18 baseline), 22 classes, Gravity Spy O1+O2 held-out test (Table I; stated)", "-", [#gr-k #"One of the few Gravity Spy papers to report macro-F1; split is the authors' own."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "glanzer2023") #cite(<glanzer2023>)], "GS", "O3 model train 99.9 % / validation 98.8 % (23 classes, 9,631 samples); O1-O2 model train 98.2 % (Sec 2.3; stated)", "-", [#gr-k #"Data-release paper quoting the published Gravity Spy accuracies; no test accuracy."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "licciardi2024") #cite(<licciardi2024>)], "GS", "random-forest accuracy 91.03 % (WST + Q-transform) vs 87.41 % (Q-transform), Gravity Spy 1.1.0, 21 classes (Table II; stated)", "-", [#gr-k #"Gravity Spy 1.1.0 after the authors' own cleaning; accuracy only."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "srivastava2024") #cite(<srivastava2024>)], "GS", "accuracy 92.26 %, F1 92.13 % (24 classes: Gravity Spy O1/O2 + 2 O3a classes) (Sec 3; stated)", "-", [#gr-k #"Custom 24-class set mixing Gravity Spy images with authors' Q-transforms; F1 averaging unstated."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wu2024") #cite(<wu2024>)], "GS", "accuracy 0.941 / F1 0.931 vs retrained Gravity Spy 0.906 / 0.904 on the same split (23 classes, O3, confidence > 0.9) (Tables 2, 4; stated)", "-", [#gr-k #"Re-trains the previous Gravity Spy model on the same split, so the internal comparison is fair; split differs from other papers."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zevin2024") #cite(<zevin2024>)], "GS", "re-quoted: 97.1 % (2017, 20 classes), 98.2 % (2018, 22 classes); O3 model train 99.9 / val 99.8 % (Sec 3.2, Table 1; stated)", "-", [#gr-k #"Review quoting earlier results."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vandyke2025") #cite(<vandyke2025>)], "AUC", "CoBiTS 0.953 vs ResNet18 0.900 vs newSNR 0.945 (all scenarios, H1 O3, 4,000 test segments) (Fig 4; stated)", "-", [#gr-k #"Single-detector signal-vs-glitch discrimination with a matched-filter statistic on the same segments."], [#pend],
  [], "eff@FAP", "TPR at FPP 1e-3: 0.82 vs 0.70 vs 0.66 (Fig 4; read-from-figure)", "-", [], [#pend],
)
== What cannot be compared, and why
Gravity Spy accuracies differ in release (O1 20-class, O1 22-class, v1.0/1.1/1.2, O3 23-class), in split (random, stratified, own cleaning) and in averaging (sample-weighted accuracy versus macro-F1), and several are validation rather than test numbers. They are graded conditional at best; the one internally fair comparison is a paper that retrains the previous Gravity Spy model on its own split. Clustering scores (NMI, ARI, silhouette), generator-fidelity scores and auxiliary-channel classifiers are on different axes.

The 42 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "powell2015") #cite(<powell2015>)], "per-morphology cluster fractions on simulated SG/Gaussian/ringdown transients (PCAT/LIB/WDF-ML) (Tables 2-3; stated)", "Simulated transients in Gaussian noise; each method analyses a different subset.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "powell2016") #cite(<powell2016>)], "none extracted", "Real ER7 glitches scored against the authors' visual labels; class counts only.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2018") #cite(<bahaadini2018>)], "none extracted", "Not read (paywalled journal version).", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2018direct") #cite(<bahaadini2018direct>)], "NMI 0.598 / ARI 0.455 (DIRECT) vs autoencoder 0.545 / 0.324 on 5 held-out Gravity Spy 1.0 classes (Table 1; stated)", "Clustering of unseen classes; embedding size chosen on the evaluation classes.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cavaglia2018") #cite(<cavaglia2018>)], "genetic-programming recall 0.934, precision 0.937 (magnetometer-glitch attribution) (Table 2; stated)", "Auxiliary-channel origin attribution for one glitch class.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "llorensmonteagudo2018") #cite(<llorensmonteagudo2018>)], "dictionary-learning accuracy 96.0 % on 3,000 simulated glitches (SNR 1-400) (Sec 5.2; stated)", "Three simulated morphologies in Gaussian noise.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "razzano2018") #cite(<razzano2018>)], "accuracy 0.998 on 6 simulated glitch families + noise (Table 4; stated)", "Fully synthetic, near-saturated problem.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "coughlin2019") #cite(<coughlin2019>)], "data reduction at 50 % retention: ~0.99 (Raven Peck), ~0.99 (Water Jet, DIRECT) (Fig 3; read-from-figure)", "Similarity search; no classification or detection metric.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "colgan2020") #cite(<colgan2020>)], "auxiliary-channel glitch vs clean: AUC 0.93 (ER14), 0.91 (O3); accuracy 0.799 (O3) (Fig 6, Sec III; stated)", "Balanced glitch / glitch-free samples from auxiliary channels; accuracy depends on the 50:50 prior.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "essick2020") #cite(<essick2020>)], "iDQ glitch-detection efficiency 10-40 % at clean-time FAP 0.1-1 % (Sec V; stated)", "Auxiliary-channel data-quality statistic scored over clean-time samples.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ding2021") #cite(<ding2021>)], "none extracted", "Qualitative anomaly detection; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mesuga2021") #cite(<mesuga2021>)], "AUC 0.990 (VGG19), averaging unstated, Gravity Spy 22-class Kaggle copy (Fig 7; stated)", "AUC only; the accuracy in the Fig 9 title is not the matrix accuracy.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sankarapandian2021") #cite(<sankarapandian2021>)], "linear-probe accuracy 81.6 % on Gravity Spy latents (Table 1; stated)", "Unsupervised encoder with linear probe; split unstated.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2022") #cite(<bahaadini2022>)], "NMI 0.61 (VAT + discriminative) vs DIRECT 0.53 on 10 held-out Gravity Spy v1.2 classes (Table III; stated)", "Clustering of held-out classes.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "boudart2022glitch") #cite(<boudart2022glitch>)], "glitch / chirp / background map classification >95.5 %; chirp class 90.2 % (Sec III; stated)", "Synthetic coherence maps of long transients.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "choudhary2022") #cite(<choudhary2022>)], "+75 % relative sensitivity over chi-square vetoes at FPR 1e-2 (80-140 Msun, SNR 3-8) (Abstract, Fig 5; stated)", "BBH-vs-blip veto ROC on simulated BBH and Gravity Spy blips.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "colgan2022") #cite(<colgan2022>)], "scattered-light vs clean accuracy 97.1 % (test, 25 of 39,147 aux channels) (Sec IV A; stated)", "Balanced auxiliary-channel classification on one day of L1.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2022") #cite(<dooney2022>)], "discriminative score WGAN vs DVGAN (e.g. pulse 0.029 vs 0.009); BBH match 0.9918 vs 0.9917 (Table I; stated)", "Generator fidelity metrics.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sakai2022") #cite(<sakai2022>)], "unsupervised cluster-purity 90.9 % (36 clusters vs 22 labels, Gravity Spy O1) (Discussion; stated)", "Custom purity score on training data with C chosen by the same labels.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "talpini2022") #cite(<talpini2022>)], "none extracted", "Abstract-level; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alvarez2023") #cite(<alvarez2023>)], "GSpyNetTree signal-vs-glitch accuracy ~97 % (LM / HM / EHM, Inception-V3) (Fig 5; stated)", "Glitch classes plus injected CBC; balanced classes, no FAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "apostol2023") #cite(<apostol2023>)], "DeepWaves ensemble 10-fold accuracy 0.91 on Gravity Spy O1 metadata (22 classes) (Table 4; stated)", "Tabular metadata, not images; features include GPS time and ID.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "biskin2023") #cite(<biskin2023>)], "none extracted", "Not read.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jarov2023") #cite(<jarov2023>)], "GSpySVG GW accuracy 98.2 % (LM) / 96.2 % (HM); glitches 197/200 (Table IV; stated)", "Signal-vs-glitch on ~500 injections and 200 glitches per classifier.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "laguarta2023") #cite(<laguarta2023>)], "177 of 2,688 glitches flagged as anomalies by manual t-SNE inspection (Sec V; stated)", "Unsupervised autoencoder evaluated on its training data with no labels.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shah2023") #cite(<shah2023>)], "random-forest accuracy 0.93 (H1) / 0.94 (L1); macro recall ~0.81 / ~0.85 (Sec 5.2, Fig 4; stated)", "Six-class custom set with synthetic GWs in Gaussian noise beside real glitches.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "arutkeerthi2024") #cite(<arutkeerthi2024>)], "glitch vs merger accuracy ~96 % on 308 validation samples (Sec VII; stated)", "Small set with augmentation that can leak events across splits.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "koyama2024") #cite(<koyama2024>)], "none extracted", "Not read.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "li2024ctsae") #cite(<li2024ctsae>)], "ARI 0.409 / NMI 0.636 (CTSAE) vs DIRECT 0.214 / 0.428 on Gravity Spy O3 test (23 classes) (Table 2; stated)", "Unsupervised clustering.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "magee2024interp") #cite(<magee2024interp>)], "signal-vs-glitch TPR 0.941-0.999 at FPR 0-0.004 (simulated) (Figs 3-4; read-from-figure)", "Signal-consistency classifier on simulated glitches.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "malz2024") #cite(<malz2024>)], "conformal prediction sets: macro-F1 0.456, mean set size 4.26 of 22 at alpha 0.1 (Table II; stated)", "Set-valued uncertainty on top of Gravity Spy; not a single-label score.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bhandari2025") #cite(<bhandari2025>)], "none extracted", "Not read.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2025") #cite(<chan2025>)], "localisation recall at IoU 0.3: GW 93.7 %, Blip 94.3 %, Scattering 52.4 % (Table 3; stated)", "Object localisation on 1 s Q-transforms.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gupta2025ae") #cite(<gupta2025ae>)], "none extracted", "Abstract-level; custom 1,200-sample set.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "oshino2025") #cite(<oshino2025>)], "none extracted", "Abstract-level; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "singh2025") #cite(<singh2025>)], "none extracted", "Not read.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "deshmukh2026") #cite(<deshmukh2026>)], "none extracted", "Silhouette and t-SNE only; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2026") #cite(<dooney2026>)], "Gravity Spy accuracy on GlitchGAN samples 79.3 % vs 89.6 % on real reconstructions (n = 700) (Tables IV-V; stated)", "Generator fidelity scored by the Gravity Spy classifier; depends on injected SNR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fernandes2026") #cite(<fernandes2026>)], "Virgo O3b 7-class ResNet34 accuracy 0.983, F1 0.977 (1,679 test) (Sec IV; stated)", "Virgo merged-class taxonomy; F1 averaging unstated.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2026kagra") #cite(<kim2026kagra>)], "KAGRA O3GK clustering: DEC NMI 0.367, ConvAE+PCA ARI 0.436 (Table 3; stated)", "Custom KAGRA taxonomy.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "manoharan2026") #cite(<manoharan2026>)], "tabular Gravity Spy O3 metadata: XGBoost weighted F1 ~0.853 (Figs 4-5; read-from-figure)", "Tabular metadata including timestamps.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xie2026") #cite(<xie2026>)], "none extracted", "Abstract-level; no numbers.", [#pend],
)
== Suspected errors in the literature
60 suspected errors or internal inconsistencies in 38 papers, selected from the extraction notes (132 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<powell2015>) #"WDF-ML \">97 %\" for both sets vs 91.3 % for SG in set 2 (Table 3)."]
  [- #cite(<powell2016>) #"WDF-ML H1 class counts sum to 1829, not the 1865 transients classified."]
  [- #cite(<powell2016>) #"WDF-ML L1 overall accuracy 95 % is not reproducible from the listed misclassifications (~97 %)."]
  [- #cite(<bahaadini2017>) #"Text says Air Compressor is perfect for both classifiers; Table 4 gives 80 % for classifier 4."]
  [- #cite(<bahaadini2017>) #"Architectures optimised for best test accuracy with no error bars (~966 test samples)."]
  [- #cite(<george2017tl>) #"No validation set while the best of 100 epochs was chosen, i.e. selection on test."]
  [- #cite(<george2017tl>) #"Paired Doves training size 21 (text) vs 24 (Fig 3 caption)."]
  [- #cite(<zevin2017>) #"\"Average accuracy 97.1 %\" is the sample-weighted accuracy; the mean of the printed per-class recalls is ~0.90."]
  [- #cite(<zevin2017>) #"Fig 7 caption says training-set normalisation while titled test set."]
  [- #cite(<bahaadini2018direct>) #"k = 200 is selected from NMI/ARI on the same unknown classes used in Table 1."]
  [- #cite(<cavaglia2018>) #"Table 2 caption swaps FN and FP definitions."]
  [- #cite(<george2018glitch>) #"\"Above 98.8 %\" holds for two of five models (Table 1)."]
  [- #cite(<george2018glitch>) #"Dataset ~8,500 vs 7,932 for the same O1 release in Glanzer 2023."]
  [- #cite(<razzano2018>) #"Per-class accuracy, precision, recall and F1 are identical in every row of Table 4, which is not possible in general for a multi-class matrix."]
  [- #cite(<coughlin2019>) #"Raven Peck reduction given as 99.9 % (text), 99.0 % (caption) and 0.93-0.97 (Table I)."]
  [- #cite(<coughlin2019>) #"Raw pixels match or beat DIRECT for Raven Peck (Fig 3)."]
  [- #cite(<mesuga2021>) #"Fig 9 title prints 98.98 % accuracy; the diagonal gives ~89 % (the digits match the AUC)."]
  [- #cite(<mesuga2021>) #"Table I counts 7,966 images vs 31,868 in the text (four views each)."]
  [- #cite(<soni2021>) #"Fast Scattering count 55,279 (Sec 3.2) vs 55,211 (conclusions)."]
  [- #cite(<bahaadini2022>) #"Table III and Fig 6 give different NMIs at the same label fraction."]
  [- #cite(<bahaadini2022>) #"Pair accuracy 49.07 % at both 0.1 % and 1 % labels (chance level)."]
  [- #cite(<boudart2022glitch>) #"\"More than 95 %\" of glitches retrieved is the weaker combined class (glitch-only 99.46 %)."]
  [- #cite(<choudhary2022>) #"The 75 % is a relative gain at one bin and FPR without absolute TPRs."]
  [- #cite(<dooney2022>) #"WGAN bolded for BBH match on a 1e-4 difference with zero stated bounds."]
  [- #cite(<sakai2022>) #"Eq 1 as printed sums to a value up to 36, not a fraction."]
  [- #cite(<yan2022gan>) #"\"Comparable or exceeding transfer learning\" rests on a 0.0005 difference inside 0.003 error bars."]
  [- #cite(<yan2022gan>) #"Minority-class F1 rests on 4-9 test images."]
  [- #cite(<alvarez2023>) #"Identical 97 % for three classifiers with different class sets."]
  [- #cite(<alvarez2023>) #"LM GW accuracy 96 % (text) vs 97 % (caption)."]
  [- #cite(<apostol2023>) #"GPS time and Gravity Spy id are among the features (possible label leakage)."]
  [- #cite(<bini2023>) #"Abstract says \"up to 30 %\"; Fig 4 gives up to +44 %."]
  [- #cite(<fernandes2023>) #"Text says < 0.2 pp below fine-tuned ResNet50; Table I gives 0.47 pp."]
  [- #cite(<fernandes2023>) #"Conclusion quotes validation F1 gains while the test set shows the opposite ordering."]
  [- #cite(<glanzer2023>) #"Abstract glitch totals do not match the Table 1 sums."]
  [- #cite(<glanzer2023>) #"8,427 + 1,203 = 9,630, not 9,631."]
  [- #cite(<jarov2023>) #"Table II Paired Doves 279 is a typo for 27 (the column then sums to 9,631)."]
  [- #cite(<jarov2023>) #"Abstract \"100 % of confirmed events as true signals\" vs 19/21 labelled GW."]
  [- #cite(<jarov2023>) #"Glitch accuracy quoted as 99 %; counts give 98.5 %."]
  [- #cite(<laguarta2023>) #"Scattered Light 28 % + 72 % already makes 100 %, leaving no room for the overlap case."]
  [- #cite(<shah2023>) #"\"Mean accuracy\" is the sample-weighted accuracy; macro recall is 0.81 / 0.85."]
  [- #cite(<shah2023>) #"Modes-only results called \"quite similar\" while Koi Fish recall falls from 0.93 to 0.64."]
  [- #cite(<arutkeerthi2024>) #"Each event contributes two detectors and a shifted copy, which can straddle the split."]
  [- #cite(<li2024ctsae>) #"Table 1 split sums to 41,655 vs 41,745 stated."]
  [- #cite(<li2024ctsae>) #"Claims superiority over deployed semi-supervised methods, but VAT at 5 % labels is better (Table 2)."]
  [- #cite(<licciardi2024>) #"Text says second-order WST slightly improves on first order; Table I gives 68.65 % vs 88.11 %."]
  [- #cite(<licciardi2024>) #"\"More than one order of magnitude\" faster vs measured 1.07-3.35x."]
  [- #cite(<magee2024interp>) #"Fig 3 caption FPR 0.7 % vs the printed 0.3 %."]
  [- #cite(<magee2024interp>) #"Toy-pipeline TPR/FPR at rho 7 differ between Sec III C and the Fig 7 caption."]
  [- #cite(<srivastava2024>) #"The two added classes come from a different image pipeline, a possible shortcut feature."]
  [- #cite(<wu2024>) #"Stated split (8,439 / 1,687 / 3,538) disagrees with Table 1 sums (6,537 / 1,637 / 4,448)."]
  [- #cite(<zevin2024>) #"O3 model validation 99.8 % here vs 98.8 % in Soni 2021 / Glanzer 2023."]
  [- #cite(<zevin2024>) #"Train/validation accuracies set beside earlier test accuracies."]
  [- #cite(<chan2025>) #"FP percentages for GW (0.1 %) and Blip (0.2 %) do not follow from the counts (1.2 %, 1.9 %)."]
  [- #cite(<vandyke2025>) #"Caption says CoBiTS beats ResNet \"in all cases\"; no-glitch AUCs are 0.976 vs 0.975."]
  [- #cite(<vandyke2025>) #"Test BBH waveforms were left in the training pool."]
  [- #cite(<dooney2026>) #"Epoch chosen partly by the UMAP overlap later reported as fidelity evidence."]
  [- #cite(<kim2026kagra>) #"Silhouette scores are computed in each method's own feature space and cannot rank methods."]
  [- #cite(<manoharan2026>) #"Discussion calls DANet the best model while XGBoost leads Figs 3-4."]
  [- #cite(<manoharan2026>) #"Fig 3 box-plot medians (0.11-0.43) are inconsistent with Figs 4-6 (0.68-0.85)."]
  [- #cite(<manoharan2026>) #"Per-sample inference times of seconds to minutes on 9 features are not credible."]
}
= Denoising and signal extraction <sec-denoise>
Denoising work splits into waveform reconstruction (recover the injected signal from strain; scored by overlap or match) and noise regression (subtract noise witnessed by auxiliary channels; scored by range gain).

== Families and lineage
=== Waveform reconstruction
Recurrent denoising autoencoders #cite(<shen2017>) #cite(<shen2019>) #cite(<wei2020denoise>) #cite(<chatterjee2021>) gave way to convolutional, U-Net and transformer reconstructors on real noise #cite(<bacon2022>) #cite(<wang2022waveformer>) #cite(<dooney2025>) #cite(<chatterjee2024harm>) #cite(<chatterjee2024rec>) #cite(<lee2025>) #cite(<lin2024>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 18 models: #cite(<shen2017>), #cite(<shen2019>), #cite(<wei2020denoise>), #cite(<chatterjee2021>), #cite(<bacon2022>), #cite(<murali2022>), #cite(<ghalsasi2023>), #cite(<chatterjee2024harm>), #cite(<chatterjee2024rec>), #cite(<lin2024>), #cite(<ma2024msnr2>), #cite(<ma2024tsr>), #cite(<sakai2024>), #cite(<wang2022waveformer>), #cite(<dooney2025>), #cite(<lee2025>), #cite(<jia2026>), #cite(<kumar2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Noise regression with witness channels
DeepClean subtracts noise witnessed by auxiliary channels #cite(<ormiston2020>) #cite(<saleem2023>) #cite(<kiendrebeogo2025virgo>) #cite(<reissel2025>), with non-linear regression studies alongside #cite(<vajente2020>) #cite(<yu2021noise>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 7 models: #cite(<ormiston2020>), #cite(<vajente2020>), #cite(<yu2021noise>), #cite(<saleem2023>), #cite(<kiendrebeogo2025virgo>), #cite(<reissel2025>), #cite(<kelleter2026nnnn>). Results will be placed on the shared axes of this section beside the published values.]

=== Glitch subtraction and gap filling
Removing or bridging transient noise #cite(<mogushi2021>) #cite(<mogushi2021nnetfix>) #cite(<torresforne2020>) #cite(<pimpalkar2026>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 4 models: #cite(<torresforne2020>), #cite(<mogushi2021>), #cite(<mogushi2021nnetfix>), #cite(<pimpalkar2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Third-generation and space-based extraction
Einstein Telescope and Taiji studies #cite(<ma2024et>) #cite(<ma2024mix>) #cite(<xu2024denoise>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 3 models: #cite(<ma2024et>), #cite(<ma2024mix>), #cite(<xu2024denoise>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (13 of 32); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shen2019") #cite(<shen2019>)], "overlap", "EDRDAE 0.994 (quasi-circular) / 0.985 (eccentric) vs DRDAE 0.906 / 0.955 at MF SNR ~6.4, real LOSC noise (Table 2; stated)", "-", [#gr-k #"One SNR, one 4096 s noise stretch; whether Table 2 is a test-set mean is not stated."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ormiston2020") #cite(<ormiston2020>)], "range", "O2 H1 BNS range +~20 % (~70 to ~84 Mpc); injection SNR +21.6 % (Fig 4; read-from-figure)", "-", [#gr-k #"DeepClean noise regression on real O2 data; range gain is comparable with later DeepClean papers only."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2020denoise") #cite(<wei2020denoise>)], "overlap", ">= 0.97 for SNR >= 12 (Gaussian); GW150914 / GW170104 / GW170814 0.99, GW170608 0.73 (Figs 2-3; stated)", "-", [#gr-k #"Time- and phase-maximised overlap; real-event results are single cases."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2021") #cite(<chatterjee2021>)], "overlap", ">0.95 for >95 % of Gaussian-noise samples (chirp mass 15-50); O1/O2 events 0.967-0.995 (Fig 8; stated)", "-", [#gr-k #"Merger-centred 0.25 s windows, single detector."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "saleem2023") #cite(<saleem2023>)], "range", "GstLAL VT ratio DeepClean/raw 1.00-1.026 at FAR 1e-5 to 1e-6 Hz on ~20 d of O3 (Fig 4; read-from-figure)", "-", [#gr-k #"DeepClean 60 Hz subtraction measured through a production search; relative to LIGO's own cleaned frames."], [#pend],
  [], "PE", "P-P combined KS p 0.0011 (before) vs 0.0008 (after), 78 BBH (Fig 6; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024harm") #cite(<chatterjee2024harm>)], "overlap", "86 % of 1,000 O3b injections (SNR 8-30) with overlap > 0.9; real events 0.74-0.98 vs cWB / LALInference (Sec 3.1, Table 2; stated)", "-", [#gr-k #"Higher-mode reconstruction in real noise."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lin2024") #cite(<lin2024>)], "overlap", "BBH mean overlap ~0.75 (2 s) / ~0.88 (0.25 s) at SNR 25; real events with 0.25 s overlap > 0.5: H1 37.8 %, L1 48.8 % (Fig 3, Sec III B; read-from-figure)", "-", [#gr-k #"Noise-weighted overlap on real O2/O3 noise with known signal position."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2022waveformer") #cite(<wang2022waveformer>)], "overlap", "94.58 % of O3b injections (SNR > 6) with overlap > 0.9; GW150914 > 0.99 (Sec 3.3; stated)", "-", [#gr-k #"Overlap on real O3b noise; the headline depends on the unstated low-mass share."], [#pend],
  [], "events", "IFAR improved for 75 BBH events (custom time shifts on denoised data) (Sec 3.4; stated)", "-", [], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2025") #cite(<dooney2025>)], "overlap", "median mismatch 0.9 % (DeepExtractor, white noise, SNR 7.5-250); 0.3 % vs BayesWave 1.9 % on a subset (Table I; stated)", "-", [#gr-k #"Glitch and signal reconstruction in white noise; the BayesWave comparison uses a different (SNR >= 15) subset."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kiendrebeogo2025virgo") #cite(<kiendrebeogo2025virgo>)], "range", "Virgo O3b BNS range +1.3 Mpc (2.5 %) from 13-band DeepClean (Sec III D; stated)", "-", [#gr-k #"DeepClean on Virgo; comparable with the other DeepClean range gains."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lee2025") #cite(<lee2025>)], "overlap", "74 % of 14,399 O3a injections with overlap > 0.8 (SNR 4-25) (Sec 3.2; stated)", "-", [#gr-k #"Signal always present at a fixed position; the test SNR is weighted towards low values."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "reissel2025") #cite(<reissel2025>)], "range", "Hanford O4 BNS range +1.4 % (+4.3 % volume) (Results, Fig 8; stated)", "-", [#gr-k #"Coherence DeepClean on real O4; comparable with other DeepClean gains."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "pimpalkar2026") #cite(<pimpalkar2026>)], "reach@FAR", "IAS-HM VT ratio up to ~1.18 (q = 0.25, m1 ~300 Msun) at IFAR > 1 yr, O3b (Fig 7; read-from-figure)", "0.0821 /month; 3.17e-08 Hz", [#gr-k #"Wavelet-network re-ranking inside the IAS-HM search; relative VT."], [#pend],
)
== What cannot be compared, and why
Overlap is defined differently across papers (maximised over time and phase or not, whitened or not, normalised or not, over a full window or a short window around the peak), and the SNR distribution of the test set is often weighted towards loud signals. Noise-regression papers report range gains on particular days of data, which compare only within DeepClean-type studies.

The 19 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shen2017") #cite(<shen2017>)], "SMTDAE 0.986 vs PCA 0.814, dictionary 0.691 at MF SNR 12.9 (single example, white noise) (Fig 2; stated)", "One hand-shown example per SNR; no test-set statistics.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "torresforne2020") #cite(<torresforne2020>)], "blip residual SNR estimator ~1.2-1.7 after combined dictionaries (16 test blips) (Table I; stated)", "Self-defined estimators; no ground-truth overlap.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vajente2020") #cite(<vajente2020>)], "70 Msun BBH range 729.3 to 754.6 Mpc (+11 % volume), non-neural regression (Sec IV 3; stated)", "Main method is not a neural network; the GRU appendix has no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mogushi2021") #cite(<mogushi2021>)], "mSTFT overlap of network estimate vs extracted glitch: median 0.65 (scattered light), 0.86 (loud glitches) (Secs 3.1-3.2; stated)", "Witness-channel glitch subtraction scored in a time-frequency overlap; not a waveform overlap.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mogushi2021nnetfix") #cite(<mogushi2021nnetfix>)], "gap-filling R^2 0.81-0.83; reconstruction efficiency 0.31 to >0.95 (Secs 2-3; stated)", "Gated-data reconstruction scored by R^2 and fractional match gain.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yu2021noise") #cite(<yu2021noise>)], "~10x angular-noise ASD reduction at 10 Hz (simulated bilinear coupling) (Sec 3; stated)", "Simulated noise regression; the authors report no broadband gain on real data.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bacon2022") #cite(<bacon2022>)], "6.6 % of test signals with overlap < 0.75 (L1 O1 noise) (Sec 3.1; stated)", "The overlap of Eq 8 is not normalised by the denoised norm and is unbounded.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "murali2022") #cite(<murali2022>)], "none extracted", "Abstract-level; no numbers.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ghalsasi2023") #cite(<ghalsasi2023>)], "G2Net subset validation AUC 0.834 (EfficientNet) vs 0.833 (U-Net N2C + EfficientNet) (Table I; stated)", "Denoiser judged by a downstream AUC on G2Net data.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024rec") #cite(<chatterjee2024rec>)], "GW190412-like injection, SNR 22: 0.88 (XPHM), 0.71 (SEOBNRv4PHM), 0.87 (NRHybSur) (Sec 3.2; stated)", "Single-realisation overlaps; uncertainty intervals without a coverage test.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024et") #cite(<ma2024et>)], "early-inspiral fraction with overlap > 0.9: ~70 % to ~95 % with transformer + regularity model (ET, SNR 20-80) (Sec IV A, Fig 10; stated)", "Non-maximised overlap on loud synthetic ET BNS; test SNR up to twice the training maximum.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024mix") #cite(<ma2024mix>)], "both of two coincident BBHs separated (overlap > 0.9) in ~83 % of 1000 samples (ET) (Fig 6; read-from-figure)", "Source separation in ET noise with a hard overlap criterion.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024msnr2") #cite(<ma2024msnr2>)], "+1.3 % detection rate over MSNRnet; 0 false triggers in ~5 months of O3b (abstract) (abstract; stated)", "Abstract-level; detection rate on its own event scheme.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024tsr") #cite(<ma2024tsr>)], "false alarms -25 %, detections +5 %, cost -90 % vs MSNRnet (abstract) (abstract; stated)", "Abstract-level; relative to its own predecessor.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sakai2024") #cite(<sakai2024>)], "none extracted", "Not read.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xu2024denoise") #cite(<xu2024denoise>)], "91.98 % of Taiji MBHB test samples with overlap >= 0.99 (SNR 10-50) (Sec V A; stated)", "Space-based (Taiji) simulated noise; threshold chosen on the test data.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jia2026") #cite(<jia2026>)], "none extracted", "Not read; category unverified.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kelleter2026nnnn") #cite(<kelleter2026nnnn>)], "Newtonian-noise residual 13 % (CNN) with WF/CNN residual ratio 25-80 (synthetic ET seismic field) (Sec 5.3; stated)", "Seismic-array regression for ET; not strain data. Flagged marginal by its dossier.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kumar2026") #cite(<kumar2026>)], "none extracted", "Not read.", [#pend],
)
== Suspected errors in the literature
34 suspected errors or internal inconsistencies in 21 papers, selected from the extraction notes (79 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<shen2017>) #"Overlap is higher at the lower SNR (0.994 at 6.44 vs 0.986 at 12.9), a single-example artefact."]
  [- #cite(<shen2017>) #"Baselines differ from those re-quoted in shen2019 for the same SNR."]
  [- #cite(<shen2019>) #"Split given as 75/25; 9,861 / 2,459 is 80/20."]
  [- #cite(<shen2019>) #"Text claims lower MSE on both classes; eccentric MSE is higher for EDRDAE (0.005 vs 0.004)."]
  [- #cite(<ormiston2020>) #"Absolute ranges appear only in the figure."]
  [- #cite(<torresforne2020>) #"85/15 split of 100 glitches stated, but 16 test glitches listed."]
  [- #cite(<wei2020denoise>) #"Abstract says >= 0.99 for all four events; Fig 3 prints 0.73 for GW170608."]
  [- #cite(<wei2020denoise>) #"Conclusion gives spin-precessing overlap >= 0.97; Sec 3.3 gives a minimum of 0.93."]
  [- #cite(<chatterjee2021>) #"Text says all O1/O2 events reach >= 0.97; Fig 8 shows 0.967 and 0.968."]
  [- #cite(<chatterjee2021>) #"Training GPU given as P100 and as K40."]
  [- #cite(<mogushi2021>) #"Excess power removed: 20-70 % (abstract) vs 10-70 % (conclusions)."]
  [- #cite(<mogushi2021nnetfix>) #"Median OLR example in Sec 4 contradicts Table 9."]
  [- #cite(<bacon2022>) #"The \"~1 % of SNR > 8 signals\" figure is derived by subtracting two different fractions."]
  [- #cite(<saleem2023>) #"P-P plots called \"excellent agreement\" while both combined p-values reject calibration at p < 0.01."]
  [- #cite(<saleem2023>) #"VT ratio dips below 1 around 1e-9 Hz although an improvement is claimed across the FAR range."]
  [- #cite(<saleem2023>) #"Batch arithmetic (1993 / 32 = 62.3, not 80 batches) does not close."]
  [- #cite(<chatterjee2024harm>) #"Abstract range 0.85-0.98 vs Table 2 values 0.74, 0.79, 0.84."]
  [- #cite(<chatterjee2024harm>) #"Reconstructed SNR exceeds the reference (fractions 1.10-1.15), unexplained."]
  [- #cite(<chatterjee2024harm>) #"Waveforms simulated to 2048 Hz at a 2048 Hz sampling rate."]
  [- #cite(<chatterjee2024rec>) #"0.71 described as generalising well."]
  [- #cite(<lin2024>) #"Real-event percentages are not integer fractions of the stated totals."]
  [- #cite(<lin2024>) #"NSBH/BNS test SNR starts at 8, below the 10-35 training range."]
  [- #cite(<ma2024mix>) #"Peak-time difference direction differs between Figs 4-6 and the Fig 5 caption."]
  [- #cite(<wang2022waveformer>) #"T^2/delta with T = 30 d gives ~2.1e6 yr, not the 4e5 yr stated."]
  [- #cite(<xu2024denoise>) #"\"Detection accuracy\" is the TPR; the matrices give 99.3-99.8 % accuracy."]
  [- #cite(<xu2024denoise>) #"Introduction says merger time within 0.01 s; results give errors of hours."]
  [- #cite(<dooney2025>) #"\"0.3 % vs 1.9 %\" and the 0.9 % headline come from different test sets."]
  [- #cite(<dooney2025>) #"\">10,000x faster\" is given without a BayesWave wall time."]
  [- #cite(<kiendrebeogo2025virgo>) #"P-P described as well calibrated while the combined KS p-values are 0.0212 and 1e-4."]
  [- #cite(<kiendrebeogo2025virgo>) #"A 55-56 Hz band contribution does not match any band in the 13-band list."]
  [- #cite(<lee2025>) #"Training SNR given as 4-12 and test as 4-25."]
  [- #cite(<lee2025>) #"A median SNR of 10 cannot have 74 % below it."]
  [- #cite(<kelleter2026nnnn>) #"Abstract \"factors of 15-80\" vs 10-110 and \"up to 40\" in the captions."]
  [- #cite(<pimpalkar2026>) #"Abstract \"up to ~15 %\" vs the Fig 7 central peak near 18 %."]
}
= Parameter estimation <sec-pe>
Parameter estimation (PE) moved from point regressors on simulated data to amortised posterior estimators validated against stochastic samplers on real events.

== Families and lineage
=== Neural posterior estimation (DINGO and relatives)
Normalising flows trained on simulations #cite(<green2020>), amortised over noise with group-equivariant tricks #cite(<dax2021>), corrected by importance sampling #cite(<dax2022>), extended to binary neutron stars #cite(<dax2024>) and to transformer embeddings #cite(<kofler2025>); related flows appear for lensing, tests of GR, echoes and 3G detectors #cite(<chan2025lens>) #cite(<zhang2026>) #cite(<luo2026>) #cite(<hu2024>) #cite(<lanchares2025>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 11 models: #cite(<green2020>), #cite(<dax2021>), #cite(<dax2022>), #cite(<dax2024>), #cite(<hu2024>), #cite(<vanstraalen2024>), #cite(<chan2025lens>), #cite(<kofler2025>), #cite(<lanchares2025>), #cite(<luo2026>), #cite(<zhang2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Variational and other amortised posteriors
Conditional VAEs #cite(<gabbard2022pe>) #cite(<badanerin2024>), ratio and likelihood estimation #cite(<delaunoy2020>) #cite(<emma2026>), reduced-basis posteriors #cite(<chua2019>) and Bayesian networks #cite(<shen2019pe>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 10 models: #cite(<chua2019>), #cite(<shen2019pe>), #cite(<delaunoy2020>), #cite(<gabbard2022pe>), #cite(<mcleod2022>), #cite(<andrescarcasona2023pe>), #cite(<badanerin2024>), #cite(<jenner2024>), #cite(<papalini2025>), #cite(<emma2026>). Results will be placed on the shared axes of this section beside the published values.]

=== Sky localisation
Rapid localisation networks compared with BAYESTAR #cite(<chatterjee2019>) #cite(<chatterjee2022>) #cite(<chatterjee2023skyloc>) #cite(<kolmus2021>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 4 models: #cite(<chatterjee2019>), #cite(<kolmus2021>), #cite(<chatterjee2022>), #cite(<chatterjee2023skyloc>). Results will be placed on the shared axes of this section beside the published values.]

=== Point estimators
Regressors and classifiers that return parameter values without calibrated posteriors #cite(<marulanda2020>) #cite(<singh2020>) #cite(<soma2023>) #cite(<benedikt2025>) #cite(<khalouei2025>) #cite(<iwanaga2025>) #cite(<sakellariou2026>) #cite(<ravichandran2023>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 8 models: #cite(<marulanda2020>), #cite(<singh2020>), #cite(<ravichandran2023>), #cite(<soma2023>), #cite(<benedikt2025>), #cite(<iwanaga2025>), #cite(<khalouei2025>), #cite(<sakellariou2026>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (11 of 33); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

#tbl(columns: (auto, auto, 3.2fr, 1.05fr, 2.2fr, auto), table.header([*Model*], [*Axis*], [*Published value (location; how obtained)*], [*FAR*], [*Grade: what differs*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "delaunoy2020") #cite(<delaunoy2020>)], "PE", "coverage of 90 % intervals 89.8-93.3 % on 1000 signals (Table 1; stated)", "-", [#gr-k #"Neural ratio estimation in Gaussian noise; slightly conservative."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "green2020") #cite(<green2020>)], "PE", "P-P on 100 injections: per-parameter KS p 0.043 (phi_JL) to 0.90; agrees with dynesty on GW150914 (Fig 3; stated)", "-", [#gr-k #"Gaussian noise at the GW150914 PSD; 100 injections give low power."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2021") #cite(<dax2021>)], "PE", "combined P-P p 0.46 (1000 injections); mean JSD vs LALInference 0.0009 nat over 8 GWTC-1 events (Figs 2, 4; stated)", "-", [#gr-c #"The reference NPE result: P-P and JSD against MCMC on real events."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2022") #cite(<dax2022>)], "PE", "median IS sample efficiency 10.9 % (XPHM) / 4.4 % (SEOBNRv4PHM) on 42 events; GW150914 mean JSD 0.5e-3 nat after IS (Tables I-II; stated)", "-", [#gr-c #"Real GWTC-2/3 events against LALInference and Bilby evidences."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gabbard2022pe") #cite(<gabbard2022pe>)], "PE", "P-P p-values best 0.918 / worst 0.047 (VItamin) over 250 tests; JS divergence vs Dynesty between CPNest and ptemcee (Fig 4-5; stated)", "-", [#gr-k #"Gaussian design noise, BBH, three detectors; calibration comparable in kind to dax2021."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2024") #cite(<dax2024>)], "PE", "mean IS sample efficiency 31-48.5 % in four BNS experiments; sky area ~30 % smaller than BAYESTAR (Experiments; stated)", "-", [#gr-k #"Stationary Gaussian noise assumption; GW170817 reproduced."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "hu2024") #cite(<hu2024>)], "PE", "combined P-P p 0.78 (SNR 20-50), 0.078 (SNR 200-500) on 300 3G injections (Fig 3; stated)", "-", [#gr-k #"Simulated third-generation network; importance sampling still costs CPU hours."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2025lens") #cite(<chan2025lens>)], "PE", "P-P KS p-values 0.020 (a1) to 0.952 (q) on 1e3 lensed injections (O5 design) (Fig 2; stated)", "-", [#gr-k #"Lensed-signal NPE; calibration comparable in kind to other NPE work on the same priors."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kofler2025") #cite(<kofler2025>)], "PE", "median IS sample efficiency 4.2 % on 48 O3 events (baseline 1.4 % on 30 HLV events) (Main text; stated)", "-", [#gr-k #"Dingo-specific sample efficiency; depends on priors and detector count."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lanchares2025") #cite(<lanchares2025>)], "PE", "combined P-P p 0.54 (500 injections); JSD vs LVK ~1e-3-1e-2 on 33 events (Fig 4, Sec IV; stated)", "-", [#gr-k #"Time-frequency NPE; real-event agreement on a prior-restricted subset."], [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhang2026") #cite(<zhang2026>)], "PE", "PIT KS p 0.36-0.91 for nine ppE parameters (1000 injections) (Fig 5; stated)", "-", [#gr-k #"Gaussian design noise plus GW150914; ppE deviation parameters only."], [#pend],
)
== What cannot be compared, and why
Calibration (P-P or coverage) and divergence from a reference sampler are the only shared axes, and they require the same priors, waveform model and noise. Point regressors report mean errors on their own grids and are not comparable with posterior estimators.

The 22 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2019") #cite(<chatterjee2019>)], "sky-sector accuracy 62-85 % (SNR 20-35) and 77-91 % (SNR 50-55) (Table V; stated)", "Sky localisation as sector classification.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chua2019") #cite(<chua2019>)], "posterior mean within ~98 % of prior width; sigma overestimated up to 3x (Sec \"Example results\"; stated)", "Reduced-basis toy without detector strain.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shen2019pe") #cite(<shen2019pe>)], "GW150914 m1 38.9 vs LIGO 35.6 Msun; 5 events within 90 % intervals (Table 1; stated)", "Five-event comparison and a qualitative P-P plot.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marulanda2020") #cite(<marulanda2020>)], "mass MAPE ~5-7 % at SNR 25, ~80-90 % at SNR 5 (Figs 6, 9; read-from-figure)", "Point regression on interleaved training and validation grids.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "singh2020") #cite(<singh2020>)], "multi-label accuracy ~0.90 on a sparse grid (Sec 5.1; stated)", "Element-wise multi-label accuracy dominated by true negatives.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kolmus2021") #cite(<kolmus2021>)], "mean sky error 32 / 14 / 9.5 deg at SNR 10 / 15 / 20 (Results; stated)", "Sky localisation seeding importance sampling.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2022") #cite(<chatterjee2022>)], "90 % areas with medians close to BAYESTAR (2000 injections per class) (Fig 4; read-from-figure)", "Sky areas against BAYESTAR; no calibration number.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcleod2022") #cite(<mcleod2022>)], "mean error 10.5 % (Mc), 24.3 % (q) on simulations; 6.2 % / 8.5 % vs LALInference medians on 10 events (Sec III; stated)", "Gaussian posteriors for two parameters.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "andrescarcasona2023pe") #cite(<andrescarcasona2023pe>)], "P-P inside the 3-sigma band for 7 parameters (100 signals); deviations ~0.1 (Fig 3; read-from-figure)", "Narrow BBH prior, 100 test signals, three real events compared by eye.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2023skyloc") #cite(<chatterjee2023skyloc>)], "P-P deviates from the 95 % band at every lead time except 0 s (Fig 5; stated)", "Pre-merger BNS sky areas in Gaussian design noise vs BAYESTAR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ravichandran2023") #cite(<ravichandran2023>)], "eccentric-signal detection accuracy 0.914, TPR 0.862 (Abstract, Fig 8; stated)", "Gaussian-noise classifier.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "soma2023") #cite(<soma2023>)], "chirp mass / tidal R^2 0.95 / 0.94 (independent); classifier macro precision 0.96 at SNR 20 (Sec 3; stated)", "Validation data reused as test.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "badanerin2024") #cite(<badanerin2024>)], "~95 % of true lensing parameters inside 95 % intervals at SNR 8-40 (Fig 6; stated)", "Two lensing parameters with all others fixed to truth in the Bilby comparison.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jenner2024") #cite(<jenner2024>)], "none extracted", "Abstract-level.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vanstraalen2024") #cite(<vanstraalen2024>)], "best pre-merger 90 % sky area 363 deg^2 (70 Hz cut), 141 deg^2 (100 Hz) (Sec VI; stated)", "Pre-merger BNS NPE in Gaussian design noise.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "benedikt2025") #cite(<benedikt2025>)], "MAE m1 5.44 Msun, chi_eff 0.03 at SNR 10 (ET noise) (Table 2; stated)", "Point estimates on an ET grid; MC-dropout widths are not calibrated.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iwanaga2025") #cite(<iwanaga2025>)], "none extracted", "Noise-scatter intervals on one simulated event; no posterior.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "khalouei2025") #cite(<khalouei2025>)], "eccentricity MAE 0.042-0.049 (SNR 10-20), 0.018-0.025 (SNR 20-60) (Table 1; stated)", "Point regression in Gaussian O4 noise.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "papalini2025") #cite(<papalini2025>)], "none extracted", "Abstract-level.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "emma2026") #cite(<emma2026>)], "JSD to the Whittle posterior below the 10/N threshold in Gaussian noise (Sec V; stated)", "Likelihood-estimation method compared with Whittle, not with other SBI.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "luo2026") #cite(<luo2026>)], "combined P-P p 0.154 (20 parameters, 1000 simulations) (Fig 3; stated)", "Echo search; Bayes factors from an unstated evidence estimate.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sakellariou2026") #cite(<sakellariou2026>)], "MAE m1 2.28 Msun, dL 40.6 Mpc on a discrete synthetic grid (Table 2; stated)", "Grid-split regression with min-max normalised strain.", [#pend],
)
== Suspected errors in the literature
25 suspected errors or internal inconsistencies in 19 papers, selected from the extraction notes (92 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<chatterjee2019>) #"Abstract \">90 % for all cases\" vs 62-91 % exact-sector accuracy."]
  [- #cite(<shen2019pe>) #"Training noise starts at the GPS time of GW150914 (leakage)."]
  [- #cite(<shen2019pe>) #"The \"GW190521\" row mixes GW190521_074359 masses with the SNR of GW190521."]
  [- #cite(<delaunoy2020>) #"The coverage table is called Table 5 in the text."]
  [- #cite(<green2020>) #"KS \"confirms\" calibration while phi_JL has p = 0.043 and no multiple-testing correction is applied."]
  [- #cite(<singh2020>) #"\"Four detections\" with seven events listed."]
  [- #cite(<dax2021>) #"The O(day) MCMC baseline is cited, not measured."]
  [- #cite(<kolmus2021>) #"Outliers removed from the importance-sampling results without a count."]
  [- #cite(<andrescarcasona2023pe>) #"Spin \"magnitude\" prior U(-1, 1) is a signed component."]
  [- #cite(<chatterjee2023skyloc>) #"\"A few milliseconds\" inference vs 1.2 s per event including KDE."]
  [- #cite(<chatterjee2023skyloc>) #"Lead times 14 s (Sec 3) vs 15 s (figures); SNR range 8-40 vs 9-40."]
  [- #cite(<ravichandran2023>) #"\"FPR 0.138\" in the abstract is the false-negative rate; the matrix gives FPR 0.028."]
  [- #cite(<badanerin2024>) #"Table I saving column (79.7 %) does not follow from its time columns (44 %)."]
  [- #cite(<hu2024>) #"\"Seconds\" applies to flow sampling only."]
  [- #cite(<benedikt2025>) #"Abstract chi_eff MAE ~1e-3 vs Table 2 0.03."]
  [- #cite(<benedikt2025>) #"MC-dropout sigma is 1.5-2x smaller than the actual error."]
  [- #cite(<chan2025lens>) #"Calibration called good while a1 p = 0.020 and theta_jn p = 0.056 over 17 parameters."]
  [- #cite(<khalouei2025>) #"A large train/validation MSE gap (0.003 vs 0.11) is not discussed."]
  [- #cite(<kofler2025>) #"The 1.4 % to 4.2 % headline compares 30 three-detector events with 48 events including two-detector ones."]
  [- #cite(<lanchares2025>) #"Abstract says all three-detector GWTC events; only 33 that fit the priors were used."]
  [- #cite(<lanchares2025>) #"JSD heat-map values (up to 69) have no units and exceed ln 2."]
  [- #cite(<sakellariou2026>) #"Baseline flow CRPS 3.3e14 and p-value 1.3e-75 indicate a diverged baseline."]
  [- #cite(<sakellariou2026>) #"The total loss averages MAEs in different units."]
  [- #cite(<zhang2026>) #"Posterior widths for dchi3-dchi7 (1.71-1.83) equal the [-1, 1] prior width, so \"consistent\" means uninformative."]
  [- #cite(<zhang2026>) #"\"Over 10 hours\" per MCMC event holds for two of nine parameters."]
}
= Space-based detectors <sec-space>
Space-based detector studies use simulated LISA, Taiji or TianQin time-delay-interferometry (TDI) data and are outside gravyflow's present detector set.

== Families and lineage
=== Massive black hole binaries and EMRIs
Detection, inference and extraction of massive black hole binaries and extreme-mass-ratio inspirals in simulated LISA, Taiji and TianQin data #cite(<ruan2023>) #cite(<ruan2024>) #cite(<ruan2023pe>) #cite(<zhao2023>) #cite(<zhang2022emri>) #cite(<yun2023>) #cite(<liu2023>) #cite(<houba2024mbh>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 9 models: #cite(<caramete2020>), #cite(<zhang2022emri>), #cite(<liu2023>), #cite(<ruan2023>), #cite(<ruan2023pe>), #cite(<yun2023>), #cite(<zhao2023>), #cite(<houba2024mbh>), #cite(<ruan2024>). Results will be placed on the shared axes of this section beside the published values.]

=== Instrumental artefacts and separation
Glitches, gaps and overlapping sources in TDI data #cite(<houba2024glitch>) #cite(<houba2025separation>) #cite(<xu2026ssl_lisa>), and quantum-network feasibility studies #cite(<isfan2025quantum>) #cite(<isfan2026qnn>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 5 models: #cite(<houba2024glitch>), #cite(<houba2025separation>), #cite(<isfan2025quantum>), #cite(<isfan2026qnn>), #cite(<xu2026ssl_lisa>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (0 of 14); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

== What cannot be compared, and why
All space-based results use simulated data with per-sample false-alarm fractions; none has a rate-based FAR, and the detectors are not in gravyflow's present scope.

The 14 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "caramete2020") #cite(<caramete2020>)], "4-class mass-ratio accuracy 95.57 % (Sec 3.4; stated)", "Noiseless simulated space-band signals; cloning before the split leaks samples.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhang2022emri") #cite(<zhang2022emri>)], "TianQin EMRI TAP ~0.88-0.92 at FAP 1 % (SNR 50-120); ~0.75 claimed for an astrophysical population (Sec V A, Fig 3; stated)", "Per-3-month-sample FAP in Gaussian TianQin noise.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "liu2023") #cite(<liu2023>)], "AUC 0.85-0.87 across TDI generations (LISA/Taiji MBHB, SNR 30-50) (Fig 4; read-from-figure)", "Space-based synthetic Gaussian noise; AUC at an unspecified SNR mix.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ruan2023") #cite(<ruan2023>)], "TPR at per-sample FPR 1e-3: 0.997 (z = 1) to 0.627 (z = 16) (Sec V A; stated); 15 of 15 Sangria (LDC-2) mergers, no false alarms (Sec V B; stated)", "LISA; FPR resolved to ~3e-4 by 3,000 negatives per redshift.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ruan2023pe") #cite(<ruan2023pe>)], "P-P within 3-sigma bands (1000 signals); >4 orders of magnitude prior-volume reduction for SNR > 100 (Figs 2-3; stated)", "Simulated LISA MBHB PE.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yun2023") #cite(<yun2023>)], "Taiji EMRI TPR 94.2 % at 1 % FPR (SNR 50-100) (Abstract, Sec IV; stated)", "6,000 samples in total; TPR at 1 % rests on a few tens of noise samples.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhao2023") #cite(<zhao2023>)], "TPR at 1 % FPR: EMRI 98.2-99.7 %, MBHB 99.99-100 % (SNR 30-50) (Sec 2.5; stated); MBHB extraction overlap > 0.99 for all test samples (SNR 50) (Sec 2.4; stated)", "LISA long-wavelength synthetic data; per-sample FPR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "houba2024glitch") #cite(<houba2024glitch>)], "LISA anomaly detection 99.99915 % of anomalous segments; glitch localisation accuracy 92.1 % (Secs III-IV; stated)", "LISA TDI simulations with an own 25-class taxonomy.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "houba2024mbh") #cite(<houba2024mbh>)], ">= 95 % of m1 = 3e5 Msun mergers at 15 Gpc flagged one month before merger (Fig 8; read-from-figure)", "LISA pre-merger detection without a merger-free false-positive rate.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ruan2024") #cite(<ruan2024>)], "TPR > 0.9 at per-segment FPR 0.01 for SNR >= 25; detection 53.5 h before merger (median) (Sec IV, Fig 6; stated)", "Pre-merger LISA MBHB classifier; per-segment FPR.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "houba2025separation") #cite(<houba2025separation>)], "MBHB median match 0.994 with an overlapping glitch (SNR 50); > 0.95 above SNR ~15 (Figs 8, 10; read-from-figure)", "LISA source separation on simulated TDI.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "isfan2025quantum") #cite(<isfan2025quantum>)], "98.4 % of Sangria blind windows labelled GW (no negative class); 5 of 6 mergers (Fig 10, Fig 14; stated)", "Quantum NN on LISA Sangria; \"accuracy\" without negatives is a recall.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "isfan2026qnn") #cite(<isfan2026qnn>)], "hardware accuracy 18.7 % (ibm_kyoto) vs 100 % on simulator (Sec 3.1; stated)", "Hardware-feasibility study; no detection performance.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xu2026ssl_lisa") #cite(<xu2026ssl_lisa>)], "94.8 / 97.3 / 98.4 % of MBHB extractions above 0.9 at SNR 30 / 40 / 50 (Taiji) (Sec IV A; stated)", "Self-supervised extraction on simulated Taiji data.", [#pend],
)
== Suspected errors in the literature
19 suspected errors or internal inconsistencies in 12 papers, selected from the extraction notes (63 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<caramete2020>) #"Class D alone carries added noise, a confound."]
  [- #cite(<caramete2020>) #"Per-class percentages in the text are precisions, not the recalls described."]
  [- #cite(<zhang2022emri>) #"Astrophysical-population TAP \"about 75 %\" at FAP 1 % vs ~0.56 read from Fig 3."]
  [- #cite(<zhang2022emri>) #"TAP below FAP at high masses in Fig 4(b)."]
  [- #cite(<liu2023>) #"Text says AUC rises monotonically with epochs; Fig 4 is non-monotonic."]
  [- #cite(<liu2023>) #"Time-cost reduction \"over 70 %\" vs ~59-63 % in Fig 9."]
  [- #cite(<liu2023>) #"Test SNR given as 30-50 and as \"to 20\"."]
  [- #cite(<ruan2023>) #"All 15 Sangria mergers recovered although the lowest-SNR ones sit where TPR is 0.33-0.60 (Fig 5)."]
  [- #cite(<ruan2023>) #"TPR at FPR 1e-3 rests on 3 false positives of 3,000."]
  [- #cite(<yun2023>) #"Inset said to zoom TPR 0-0.01; the axes show FPR 0-0.1."]
  [- #cite(<zhao2023>) #"EMRI TPR 99.7 % at 1 % FPR vs ~0.991 read from the Fig 5a ROC."]
  [- #cite(<zhao2023>) #"Abstract \"at least 95 % similarity\" vs 92 % > 0.95 for EMRI."]
  [- #cite(<houba2024glitch>) #"99.99915 % on <= 20,000 anomalous samples is finer than the test-set resolution."]
  [- #cite(<houba2024glitch>) #"Glitches labelled as bursts: 0.065 % stated vs 27 / 19,228 = 0.14 % from Fig 9."]
  [- #cite(<houba2024mbh>) #"No false-positive rate is reported although 20,000 merger-free samples are described."]
  [- #cite(<houba2025separation>) #"Hallucination area 6.88e-5 (text) vs 6.47e-5 (Fig 11)."]
  [- #cite(<isfan2025quantum>) #"Window length and step differ between Sec 3.2 and Table 2."]
  [- #cite(<isfan2026qnn>) #"Abstract gives 20 % accuracy and different cloud costs from the body."]
  [- #cite(<xu2026ssl_lisa>) #"Overlap thresholds differ by class (0.9 vs 0.8) and were set after the fact."]
}
= Other: alerts, generators, lensing, backgrounds <sec-other>
Models that do not fit the categories above: classifiers of public-alert products, generative models of signals and glitches, lensing and stochastic-background studies, a hardware study and a review.

== Families and lineage
=== Alert-product classifiers
GWSkyNet and its successors classify public-alert sky maps rather than strain #cite(<cabero2020>) #cite(<abbott2021>) #cite(<chan2024>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 3 models: #cite(<cabero2020>), #cite(<abbott2021>), #cite(<chan2024>). Results will be placed on the shared axes of this section beside the published values.]

=== Generative models
GANs for bursts, blips and Gravity Spy images #cite(<mcginn2021>) #cite(<lopez2022gan>) #cite(<powell2022>) #cite(<dooney2024>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 4 models: #cite(<mcginn2021>), #cite(<lopez2022gan>), #cite(<powell2022>), #cite(<dooney2024>). Results will be placed on the shared axes of this section beside the published values.]

=== Lensing, backgrounds and miscellany
Lensing identification #cite(<kim2020lens>) #cite(<kim2022lens>), stochastic backgrounds #cite(<utina2021>) #cite(<einsle2025>), equation-of-state inference from CCSN #cite(<edwards2021>), space-based extraction #cite(<xu2024>), FPGA acceleration #cite(<que2021>) and a review #cite(<cuoco2020>).

#callout("Our results (to be added)")[gravyflow reproduction: #pend for 8 models: #cite(<kim2020lens>), #cite(<cuoco2020>), #cite(<edwards2021>), #cite(<que2021>), #cite(<utina2021>), #cite(<kim2022lens>), #cite(<xu2024>), #cite(<einsle2025>). Results will be placed on the shared axes of this section beside the published values.]

== Comparison on the shared axes
Rows are the models graded comparable or conditionally comparable (0 of 15); each axis entry is one row. FAR is converted to per month (30 d) and to Hz where the paper states a rate.

== What cannot be compared, and why
These models do not share axes with each other or with the detection categories.

The 15 models below have no shared axis; their headline metric is listed with the reason.

#tbl(columns: (auto, 2.6fr, 2.4fr, auto), table.header([*Model*], [*Headline metric (location; how)*], [*Why not comparable*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cabero2020") #cite(<cabero2020>)], "GWSkyNet test accuracy 93.5 % (413 candidates); O3 retractions 10 of 22 (Sec 4; stated)", "Classifier of alert sky maps, not strain.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2020lens") #cite(<kim2020lens>)], "lensed classification 96.7-98.3 % (optimal SNR 10-50); 62-68 % at SNR 12-13 (Fig 5, Sec 4.3; stated)", "Balanced simulated lensing classification.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "abbott2021") #cite(<abbott2021>)], "GWSkyNet-Multi hierarchical accuracy 93.4 % (427 test events); 36 of 40 O3a alerts (Sec 3-4; stated)", "Alert-product classifier.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cuoco2020") #cite(<cuoco2020>)], "none extracted", "Review article; numbers are secondary.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "edwards2021") #cite(<edwards2021>)], "18-way EoS top-1 accuracy 0.64-0.72, top-5 0.91-0.97 (noise-free) (Table II; stated)", "Noise-free CCSN waveform classification.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcginn2021") #cite(<mcginn2021>)], "network SNR ~7.3-7.6 for the GAN-trained CNN at FAP 1e-3 (5 burst classes) (Fig 11; read-from-figure)", "Generator paper; detection test in Gaussian noise with per-sample FAP.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "que2021") #cite(<que2021>)], "LSTM autoencoder AUC 0.763 (SNR distribution unstated); FPGA latency 0.867 us (Fig 9, Table IV; stated)", "Hardware-acceleration study.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "utina2021") #cite(<utina2021>)], "none extracted", "Abstract-level stochastic-background study.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2022lens") #cite(<kim2022lens>)], "learner AUC > 0.99 (simulated); 1 of 46 GWTC events classified lensed (Fig 5, Sec 3; stated)", "Lensing search; \"ROC\" uses a set-level false-alarm probability.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2022gan") #cite(<lopez2022gan>)], "Gravity Spy labels > 70 % of 1000 GAN blips as Blip (Sec IV B; stated)", "Generator fidelity.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "powell2022") #cite(<powell2022>)], "real-data CNN classifies GAN glitches with 99.0 % mean accuracy (22 classes) (Fig 5; stated)", "Generator fidelity.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2024") #cite(<chan2024>)], "GWSkyNet II detection probability 92.5 % (fine-tuned) vs 68.3 % at FAP 20 % among O4 MDC candidates (Sec 3; stated)", "Post-trigger alert classifier; 96 noise transients in the test set.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2024") #cite(<dooney2024>)], "downstream CNN AUC 0.802 (cDVGAN simplex) vs 0.770 best baseline (SNR 1-16) (Table I; stated)", "Generator judged by a downstream classifier on a private set.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xu2024") #cite(<xu2024>)], "fraction with overlap >= 0.9: 1.0 (ideal) to 0.56 (4x OMS noise) for LISA/Taiji MBHB (Tables II-V; stated)", "Space-based extraction robustness study.", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "einsle2025") #cite(<einsle2025>)], "BBH background Omega ~1e-9 at 25 Hz reaches log10 BF 3 with 23.7 d (A+ Gaussian) (Fig 3; stated)", "Stochastic-background task.", [#pend],
)
== Suspected errors in the literature
11 suspected errors or internal inconsistencies in 8 papers, selected from the extraction notes (33 notes for this section in the catalogue). Each is a reading of the paper to be checked, not a verdict.

#{ set text(size: 8.2pt); set par(leading: 0.5em)
  [- #cite(<cabero2020>) #"The 93.5 % headline uses a simulated real class; the real retraction test is 10/22."]
  [- #cite(<kim2020lens>) #"Named VGG-19 but the appendix lists 10 conv layers."]
  [- #cite(<abbott2021>) #"Fig 7(c) BBH matrix duplicates the glitch panel."]
  [- #cite(<abbott2021>) #"F1 in Table 1 not reproducible from Fig 7."]
  [- #cite(<abbott2021>) #"36/40 vs 6 + 29 = 35 correct."]
  [- #cite(<que2021>) #"Same design latency 0.40 us (Table III) vs 0.867 us (Table IV)."]
  [- #cite(<lopez2022gan>) #"~500 Blips in the text vs 736 in Fig 10 at the same SNR."]
  [- #cite(<lopez2022gan>) #"Pearson coefficients printed as percentages."]
  [- #cite(<chan2024>) #"Baseline beats fine-tuned in both detector-count subsets while losing overall."]
  [- #cite(<dooney2024>) #"The catalogue baseline 0.759 is not the strongest baseline (0.770)."]
  [- #cite(<einsle2025>) #"MSE 0.01 on log spectra is a ~26 % factor, not \"about 3 %\"."]
}
= Code and reproducibility <sec-code>
106 of the 313 models have an official public repository (third-party reimplementations, empty repositories and data-only tooling are not counted), and 29 of those release trained weights (2 more release partial weights). Licences were read from the repositories; a missing licence means none was found, which does not grant reuse. The per-section counts are in Table 4 and the repositories in Table 5.

*Table 4.* Code and weights by section.

#tbl(columns: (1fr, auto, auto, auto), table.header([*Section*], [*Models*], [*With code*], [*With weights*]),
  "Compact-binary detection", "92", "30", "10",
  "Early warning", "9", "2", "0",
  "Burst and unmodelled transients", "33", "9", "3",
  "Anomaly and multi-signal detection", "11", "5", "1",
  "Continuous and long-duration waves", "18", "4", "0",
  "Glitch classification and data quality", "56", "19", "7",
  "Denoising and signal extraction", "32", "10", "1",
  "Parameter estimation", "33", "18", "4",
  "Space-based detectors", "14", "3", "0",
  "Other: alerts, generators, lensing, backgrounds", "15", "6", "3",
)

*Table 5.* Official repositories (first listed per model).

#tbl(columns: (auto, 2.4fr, auto, auto, auto), table.header([*Model*], [*Repository*], [*Licence*], [*Last commit*], [*Weights*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "abbott2021") #cite(<abbott2021>)], [#link("https://github.com/GWML/GWSkyNet")[#"github.com/GWML/GWSkyNet"]], "MIT", "2021", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alhassan2023pymerger") #cite(<alhassan2023pymerger>)], [#link("https://github.com/wathela/PyMerger")[#"github.com/wathela/PyMerger"]], "NOASSERTION (LICENSE file present, SPDX not recognised)", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "andrews2022") #cite(<andrews2022>)], [#link("https://github.com/mbandrews/gw-analysis")[#"github.com/mbandrews/gw-analysis"]], "none found", "2021", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "apostol2023") #cite(<apostol2023>)], [#link("https://github.com/DS4AI-UPB/ML4GW")[#"github.com/DS4AI-UPB/ML4GW"]], "none found", "2023", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "arutkeerthi2024") #cite(<arutkeerthi2024>)], [#link("https://github.com/Arut123/Glitch-veto-GW-using-chirp")[#"github.com/Arut123/Glitch-veto-GW-using-chirp"]], "none found", "2025", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "aveiro2022") #cite(<aveiro2022>)], [#link("https://doi.org/10.5281/zenodo.6222936")[#"doi.org/10.5281/zenodo.6222936"]], "Zenodo record: \"Other (Open)\"; upstream YOLOv5 repo is AGPL-3.0 (from memory, unverified)", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "badger2024") #cite(<badger2024>)], [#link("https://github.com/Rahul-Srinivasan/GW_DictionaryLearning")[#"github.com/Rahul-Srinivasan/GW_DictionaryLearning"]], "none found", "2025", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2018") #cite(<bahaadini2018>)], [#link("https://github.com/Gravity-Spy/GravitySpy")[#"github.com/Gravity-Spy/GravitySpy"]], "GPL-3.0", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bayley2020") #cite(<bayley2020>)], [#link("https://github.com/jcbayley/soapcw")[#"github.com/jcbayley/soapcw"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beheshtipour2020") #cite(<beheshtipour2020>)], [#link("https://github.com/matterport/Mask_RCNN")[#"github.com/matterport/Mask_RCNN"]], "NOASSERTION", "2024", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beheshtipour2020b") #cite(<beheshtipour2020b>)], [#link("https://github.com/matterport/Mask_RCNN")[#"github.com/matterport/Mask_RCNN"]], "NOASSERTION", "2024", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "benedikt2025") #cite(<benedikt2025>)], [#link("https://github.com/GraviBERT/GraviBERT")[#"github.com/GraviBERT/GraviBERT"] #"(+1)"], "MIT", "2026", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beveridge2025o3") #cite(<beveridge2025o3>)], [#link("https://github.com/damonbeveridge/new_BBH_O3_candidate-UWA")[#"github.com/damonbeveridge/new_BBH_O3_candidate-UWA"]], "none found", "2025", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cabero2020") #cite(<cabero2020>)], [#link("https://github.com/GWML/GWSkyNet")[#"github.com/GWML/GWSkyNet"]], "MIT", "2021", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cain2025") #cite(<cain2025>)], [#link("https://github.com/jericho-cain/cwt-lstm-ae-grav-wav")[#"github.com/jericho-cain/cwt-lstm-ae-grav-wav"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cavaglia2018") #cite(<cavaglia2018>)], [#link("https://github.com/kstaats/karoo_gp")[#"github.com/kstaats/karoo_gp"]], "other (non-standard licence listed by GitHub)", "2022", "n/a",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2024") #cite(<chan2024>)], [#link("https://github.com/nayyer-raza/GWSkyNet-Multi")[#"github.com/nayyer-raza/GWSkyNet-Multi"]], "MIT", "2025", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2025lens") #cite(<chan2025lens>)], [#link("https://github.com/dingo-lensing/dingo-lensing")[#"github.com/dingo-lensing/dingo-lensing"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2022") #cite(<chatterjee2022>)], [#link("https://github.com/chayanchatterjee/GW-SkyLocator")[#"github.com/chayanchatterjee/GW-SkyLocator"]], "GPL-3.0", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2023skyloc") #cite(<chatterjee2023skyloc>)], [#link("https://github.com/chayanchatterjee/GW-SkyLocator")[#"github.com/chayanchatterjee/GW-SkyLocator"]], "GPL-3.0", "2024", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024") #cite(<chatterjee2024>)], [#link("https://github.com/ondrzel/ml-gw-search/tree/main")[#"github.com/ondrzel/ml-gw-search/tree/main"]], "Apache-2.0", "2023", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024harm") #cite(<chatterjee2024harm>)], [#link("https://github.com/chayanchatterjee/AWaRe")[#"github.com/chayanchatterjee/AWaRe"]], "GPL-3.0", "2025", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024rec") #cite(<chatterjee2024rec>)], [#link("https://github.com/chayanchatterjee/AWaRe")[#"github.com/chayanchatterjee/AWaRe"]], "GPL-3.0", "2025", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2026") #cite(<chatterjee2026>)], [#link("https://github.com/chayanchatterjee/castor")[#"github.com/chayanchatterjee/castor"]], "Apache-2.0", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cheung2025unet") #cite(<cheung2025unet>)], [#link("https://github.com/damondmc/cwunet")[#"github.com/damondmc/cwunet"]], "none found", "2025", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chua2019") #cite(<chua2019>)], [#link("https://github.com/vallis/truebayes")[#"github.com/vallis/truebayes"]], "MIT", "2019", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cirfeta2026") #cite(<cirfeta2026>)], [#link("https://github.com/lucacirfeta/dante-gravi-signal-ml")[#"github.com/lucacirfeta/dante-gravi-signal-ml"]], "GPL-3.0", "2026", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cuoco2026") #cite(<cuoco2026>)], [#link("https://github.com/elenacuoco/p4TSA")[#"github.com/elenacuoco/p4TSA"] #"(+1)"], "GPL-3.0", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2021") #cite(<dax2021>)], [#link("https://github.com/dingo-gw/dingo")[#"github.com/dingo-gw/dingo"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2022") #cite(<dax2022>)], [#link("https://github.com/dingo-gw/dingo")[#"github.com/dingo-gw/dingo"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2024") #cite(<dax2024>)], [#link("https://github.com/dingo-gw/dingo")[#"github.com/dingo-gw/dingo"]], "MIT", "2026", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ding2021") #cite(<ding2021>)], [#link("https://github.com/JulianZDing/UniMAP")[#"github.com/JulianZDing/UniMAP"]], "none found", "2021", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dodia2021specgrav") #cite(<dodia2021specgrav>)], [#link("https://github.com/HrithikaDodia/SpecGrav")[#"github.com/HrithikaDodia/SpecGrav"]], "none found", "2021", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2024") #cite(<dooney2024>)], [#link("https://git.ligo.org/tom.dooney/cdvgan_paper")[#"git.ligo.org/tom.dooney/cdvgan_paper"]], "none found", "-", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2025") #cite(<dooney2025>)], [#link("https://git.ligo.org/tom.dooney/deepextractor.git")[#"git.ligo.org/tom.dooney/deepextractor.git"]], "MIT", "-", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2026") #cite(<dooney2026>)], [#link("https://github.com/tomdooney95/glitchgan")[#"github.com/tomdooney95/glitchgan"] #"(+2)"], "none found", "2026", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "emma2026") #cite(<emma2026>)], [#link("https://github.com/MattiaEmma2022/sbilby")[#"github.com/MattiaEmma2022/sbilby"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "essick2020") #cite(<essick2020>)], [#link("https://git.ligo.org/reed.essick/iDQ")[#"git.ligo.org/reed.essick/iDQ"]], "none found", "-", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fernandes2026") #cite(<fernandes2026>)], [#link("https://github.com/tttiago/glitchgram")[#"github.com/tttiago/glitchgram"]], "none found", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gabbard2022pe") #cite(<gabbard2022pe>)], [#link("https://github.com/hagabbar/VItamin")[#"github.com/hagabbar/VItamin"]], "MIT", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018glitch") #cite(<george2018glitch>)], [#link("https://github.com/Gravity-Spy/GravitySpy")[#"github.com/Gravity-Spy/GravitySpy"]], "GPL-3.0", "2024", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "glanzer2023") #cite(<glanzer2023>)], [#link("https://zenodo.org/records/5649212")[#"zenodo.org/records/5649212"] #"(+1)"], "unknown (Zenodo)", "2021", "n/a",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "green2020") #cite(<green2020>)], [#link("https://github.com/stephengreen/lfi-gw")[#"github.com/stephengreen/lfi-gw"] #"(+2)"], "MIT", "2021", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gunny2021") #cite(<gunny2021>)], [#link("https://github.com/fastmachinelearning/gw-iaas")[#"github.com/fastmachinelearning/gw-iaas"] #"(+1)"], "MIT", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gupta2026") #cite(<gupta2026>)], [#link("https://github.com/ML4GW/aframe")[#"github.com/ML4GW/aframe"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "hu2024") #cite(<hu2024>)], [#link("https://github.com/MarinerQ/river")[#"github.com/MarinerQ/river"]], "none found", "2025", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "huerta2021") #cite(<huerta2021>)], [#link("https://doi.org/10.26311/ZWFW-3N68")[#"doi.org/10.26311/ZWFW-3N68"]], "unknown", "2021", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iess2020") #cite(<iess2020>)], [#link("https://wdf.readthedocs.io/")[#"wdf.readthedocs.io/"]], "unknown", "-", "n/a",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iess2023") #cite(<iess2023>)], [#link("https://wdf.readthedocs.io/")[#"wdf.readthedocs.io/"]], "unknown", "-", "n/a",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "inguglia2026") #cite(<inguglia2026>)], [#link("https://github.com/ginguglia/MADGRAV")[#"github.com/ginguglia/MADGRAV"]], "MIT", "2026", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "insley2026flows") #cite(<insley2026flows>)], [#link("https://github.com/gwastro/pycbc")[#"github.com/gwastro/pycbc"]], "GPL-3.0", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jadhav2020") #cite(<jadhav2020>)], [#link("https://github.com/shreejit-92/MLStat-1")[#"github.com/shreejit-92/MLStat-1"]], "none stated", "2020", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kelleter2026nnnn") #cite(<kelleter2026nnnn>)], [#link("https://github.com/lc316353/Newtonian-Noise-Simulation")[#"github.com/lc316353/Newtonian-Noise-Simulation"] #"(+1)"], "none stated (no LICENSE file)", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kiendrebeogo2025virgo") #cite(<kiendrebeogo2025virgo>)], [#link("https://github.com/weizmannk/Virgo-DeepClean")[#"github.com/weizmannk/Virgo-DeepClean"]], "AGPL-3.0", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kofler2025") #cite(<kofler2025>)], [#link("https://github.com/dingo-gw/dingo-T1")[#"github.com/dingo-gw/dingo-T1"] #"(+2)"], "MIT", "2026", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kolmus2021") #cite(<kolmus2021>)], [#link("https://github.com/akolmus/swiftsky")[#"github.com/akolmus/swiftsky"]], "none found", "2021", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "koloniari2024") #cite(<koloniari2024>)], [#link("https://github.com/vivinousi/gw-detection-deep-learning")[#"github.com/vivinousi/gw-detection-deep-learning"]], "Apache-2.0", "2025", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lanchares2025") #cite(<lanchares2025>)], [#link("https://github.com/Daniel-Lanchares/dtempest")[#"github.com/Daniel-Lanchares/dtempest"]], "none found", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "li2024ctsae") #cite(<li2024ctsae>)], [#link("https://github.com/Zod-L/CTSAE")[#"github.com/Zod-L/CTSAE"]], "Apache-2.0", "2024", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "liu2023") #cite(<liu2023>)], [#link("https://github.com/dingo-gw/dingo")[#"github.com/dingo-gw/dingo"] #"(+1)"], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "luo2026") #cite(<luo2026>)], [#link("https://github.com/dingo-gw/dingo")[#"github.com/dingo-gw/dingo"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024mix") #cite(<ma2024mix>)], [#link("https://github.com/z2062358453/gravitational-wave-separation")[#"github.com/z2062358453/gravitational-wave-separation"]], "none found", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "malz2024") #cite(<malz2024>)], [#link("https://doi.org/10.5281/zenodo.14066270")[#"doi.org/10.5281/zenodo.14066270"]], "CC BY 4.0", "2024", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "manoharan2026") #cite(<manoharan2026>)], [#link("https://github.com/rudhresh1997/glitch-tabular-prd")[#"github.com/rudhresh1997/glitch-tabular-prd"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "martins2024") #cite(<martins2024>)], [#link("https://github.com/anaismartins/deploying-custom-nn-in-fpga")[#"github.com/anaismartins/deploying-custom-nn-in-fpga"]], "MIT", "2025", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marx2024") #cite(<marx2024>)], [#link("https://github.com/ML4GW/aframe")[#"github.com/ML4GW/aframe"] #"(+2)"], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marx2025aframeO3") #cite(<marx2025aframeO3>)], [#link("https://github.com/ML4GW/aframe")[#"github.com/ML4GW/aframe"]], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcginn2021") #cite(<mcginn2021>)], [#link("https://github.com/jmcginn/McGANn")[#"github.com/jmcginn/McGANn"]], "none found", "2021", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcisaac2022") #cite(<mcisaac2022>)], [#link("https://github.com/connor-mcisaac/chisqnet")[#"github.com/connor-mcisaac/chisqnet"] #"(+1)"], "GPL-3.0", "2022", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcleod2025") #cite(<mcleod2025>)], [#link("https://github.com/alistair-mcleod/infernus")[#"github.com/alistair-mcleod/infernus"] #"(+1)"], "MIT", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], [#link("https://github.com/gwastro/ml-mock-data-challenge-1")[#"github.com/gwastro/ml-mock-data-challenge-1"]], "Apache-2.0", "2022", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "morales2024") #cite(<morales2024>)], [#link("resnet50-sngw-hff, datagen-sngw-phen, datagen-sngw-genrel (full URLs and owner not in the extracted text)")[#"resnet50-sngw-hff, datagen-sngw-phen, datagen-sngw-genrel (f"]], "GPL-3.0 (per paper)", "unchecked", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "moreno2022") #cite(<moreno2022>)], [#link("https://github.com/eric-moreno/Anomaly-Detection-Autoencoder")[#"github.com/eric-moreno/Anomaly-Detection-Autoencoder"] #"(+1)"], "none (no licence file; all rights reserved by default)", "2022", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nagarajan2025") #cite(<nagarajan2025>)], [#link("https://github.com/nnarenraju/sage")[#"github.com/nnarenraju/sage"]], "GPL-3.0", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nousi2022") #cite(<nousi2022>)], [#link("https://github.com/vivinousi/gw-detection-deep-learning")[#"github.com/vivinousi/gw-detection-deep-learning"] #"(+1)"], "Apache-2.0", "2025", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ormiston2020") #cite(<ormiston2020>)], [#link("https://github.com/rormiston/DeepClean")[#"github.com/rormiston/DeepClean"] #"(+3)"], "GPL-3.0", "2018", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "papalini2025") #cite(<papalini2025>)], [#link("https://github.com/luciapapalini/kenn-gw-transformer")[#"github.com/luciapapalini/kenn-gw-transformer"]], "MIT", "-", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "pracchia2025") #cite(<pracchia2025>)], [#link("https://git.ligo.org/maxime.fays/gwpyxel")[#"git.ligo.org/maxime.fays/gwpyxel"]], "none shown", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "que2021") #cite(<que2021>)], [#link("https://github.com/walkieq/RNN_HLS")[#"github.com/walkieq/RNN_HLS"]], "Apache-2.0", "2024", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "raikman2023") #cite(<raikman2023>)], [#link("https://github.com/ML4GW/gwak")[#"github.com/ML4GW/gwak"]], "MIT", "2026", "partial",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "raikman2024") #cite(<raikman2024>)], [#link("https://github.com/ML4GW/gwak")[#"github.com/ML4GW/gwak"]], "MIT", "2026", "partial",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "reissel2025") #cite(<reissel2025>)], [#link("https://github.com/ML4GW/DeepClean")[#"github.com/ML4GW/DeepClean"] #"(+1)"], "none stated", "2023", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "saleem2023") #cite(<saleem2023>)], [#link("https://github.com/ML4GW/DeepClean")[#"github.com/ML4GW/DeepClean"] #"(+2)"], "none declared (no LICENSE file; GitHub licence field null)", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2020") #cite(<schafer2020>)], [#link("https://github.com/gwastro/bns-machine-learning-search")[#"github.com/gwastro/bns-machine-learning-search"]], "none declared (no LICENSE file; GitHub licence field null)", "2020", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2021a") #cite(<schafer2021a>)], [#link("https://github.com/gwastro/ml-training-strategies")[#"github.com/gwastro/ml-training-strategies"]], "GPL-3.0", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2021b") #cite(<schafer2021b>)], [#link("https://github.com/gwastro/ml-training-strategies")[#"github.com/gwastro/ml-training-strategies"]], "GPL-3.0", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "singh2020") #cite(<singh2020>)], [#link("https://github.com/SSingh087/DL-estimating-parameters-of-GWs")[#"github.com/SSingh087/DL-estimating-parameters-of-GWs"]], "MIT", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "skliris2024") #cite(<skliris2024>)], [#link("https://github.com/VasSkliris/mly-methods-paper")[#"github.com/VasSkliris/mly-methods-paper"] #"(+3)"], "none listed", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "soni2021") #cite(<soni2021>)], [#link("https://github.com/Gravity-Spy/GravitySpy")[#"github.com/Gravity-Spy/GravitySpy"]], "GPL-3.0", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "srivastava2024") #cite(<srivastava2024>)], [#link("https://www.kaggle.com/code/divyansh050/vitb32-ligo/notebook")[#"kaggle.com/code/divyansh050/vitb32-ligo/notebook"]], "none found", "-", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tian2023") #cite(<tian2023>)], [#link("https://github.com/mtian8/Higher_Order_GW_Spatiotemporal_GNN")[#"github.com/mtian8/Higher_Order_GW_Spatiotemporal_GNN"]], "none found", "2024", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tian2024gnn") #cite(<tian2024gnn>)], [#link("https://github.com/mtian8/gw_spatiotemporal_gnn")[#"github.com/mtian8/gw_spatiotemporal_gnn"]], "MIT", "2024", "unverified",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tiki2025") #cite(<tiki2025>)], [#link("https://github.com/victoria-tiki/AttenGW")[#"github.com/victoria-tiki/AttenGW"] #"(+1)"], "MIT", "2026", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2020") #cite(<wang2020>)], [#link("https://github.com/WuShichao/mfcnn_catalog")[#"github.com/WuShichao/mfcnn_catalog"] #"(+1)"], "none listed", "2020", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2022waveformer") #cite(<wang2022waveformer>)], [#link("https://github.com/AI-HPC-Research-Team/LIGO_noise_suppression")[#"github.com/AI-HPC-Research-Team/LIGO_noise_suppression"]], "Apache-2.0", "2024", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "weerasinghe2026") #cite(<weerasinghe2026>)], [#link("https://github.com/sathnidu9/postmerger-gw-eos-inference")[#"github.com/sathnidu9/postmerger-gw-eos-inference"]], "MIT", "2025", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wu2024") #cite(<wu2024>)], [#link("https://github.com/Gravity-Spy/gravityspy-ligo-pipeline")[#"github.com/Gravity-Spy/gravityspy-ligo-pipeline"]], "GPL-3.0", "2025", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xu2026ssl_lisa") #cite(<xu2026ssl_lisa>)], [#link("https://github.com/TriangleDataCenter/Triangle-Simulator")[#"github.com/TriangleDataCenter/Triangle-Simulator"] #"(+1)"], "GPL-3.0", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2025") #cite(<yamamoto2025>)], [#link("https://github.com/tsyamamoto21/gw-hybridmfcnn-stellarmassbbh")[#"github.com/tsyamamoto21/gw-hybridmfcnn-stellarmassbbh"]], "none declared", "2025", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2022gan") #cite(<yan2022gan>)], [#link("https://github.com/tkarras/progressive_growing_of_gans")[#"github.com/tkarras/progressive_growing_of_gans"]], "NOASSERTION (NVIDIA research licence)", "2022", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2025deepgrav") #cite(<yan2025deepgrav>)], [#link("https://github.com/yan123yan/DeepGrav")[#"github.com/yan123yan/DeepGrav"]], "MIT", "2026", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yu2021early") #cite(<yu2021early>)], [#link("https://github.com/hangyu45")[#"github.com/hangyu45"] #"(+1)"], "none for relevant repos (account has GPL-3.0 repos for other papers)", "2026", "no",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zelenka2024") #cite(<zelenka2024>)], [#link("https://github.com/ondrzel/ml-gw-search")[#"github.com/ondrzel/ml-gw-search"]], "Apache-2.0", "2023", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zevin2017") #cite(<zevin2017>)], [#link("https://github.com/Gravity-Spy/GravitySpy")[#"github.com/Gravity-Spy/GravitySpy"] #"(+3)"], "GPL-3.0", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zevin2024") #cite(<zevin2024>)], [#link("https://github.com/Gravity-Spy/GravitySpy")[#"github.com/Gravity-Spy/GravitySpy"] #"(+2)"], "GPL-3.0", "2024", "yes",
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhao2023") #cite(<zhao2023>)], [#link("https://github.com/AI-HPC-Research-Team/Space_signal_detection_all4")[#"github.com/AI-HPC-Research-Team/Space_signal_detection_all4"]], "MIT", "2023", "no",
)
= Reproduction programme in gravyflow <sec-repro>
The original catalogue set an itinerary of sixteen steps, ordered so that shared library features are built once and then reused. The added models are placed on the same steps. Effort follows the original scale: S is model code and configuration on the existing data path (days), M one new library feature or substantial data work (one to two weeks), L several new features, an external pipeline or dataset, or a new physics domain; for added models it is estimated from the one-off efforts of their adaptation tags. Every model's reproduction is pending.

*Table 6.* Itinerary.

#tbl(columns: (auto, 1.6fr, 1.4fr, auto, auto, 2.4fr), table.header([*Step*], [*Title*], [*Shared adaptations*], [*Orig.*], [*Added*], [*Why (first catalogue)*]),
  "0", "Retrieve the unread papers", "x-retrieve", "11", "30", "Nine entries have no architecture at all; their adaptations cannot be stated until the text is read. Cheap for the owner (institutional access), and it unblocks later steps.",
  "1", "Close the shipped families", "n-real, n-sim-glitch, wf-subst", "4", "1", "George-Huerta (both nets) and Gabbard are shipped; MLy is shipped without its incoherent and single-detector WNB noise classes. IncoherentGenerator now exists, so MLy's types 2/3 and George-Huerta's real-noise follow-up are the cheapest completions of what is already there.",
  "2", "1D CNN ports on the current data path", "wf-subst, t-multiclass, det-hlv, in-window, t-ensemble", "11", "7", "Whitened-strain 1D CNNs that need only model code, a declared approximant substitution and at most a multi-class head or longer window. The most cited early literature lives here.",
  "3", "Search-grade evaluation: sensitive distance and continuous search", "e-far, e-sensitivity, n-real", "1", "3", "The post-2021 literature reports sensitive distance vs FAR on continuous data with time slides; the validator has FAR and time slides but not sensitive distance or a streamed search. Building this once makes every later CBC entry comparable to MLGWSC-1 and to PyCBC.",
  "4", "MLGWSC-1 benchmark and its entries", "n-mlgwsc, wf-xphm, n-psd-aug, t-custom-layer", "6", "1", "One benchmark covers AresGW, CNN-Coinc, TPI FSU Jena, MFCNN and is the common yardstick of Aframe, CASTOR, GW-Whisper, Sage and Yamamoto 2025. DS1 is reachable now (non-spinning PhenomD); DS2-DS4 need XPHM, PSD variation and real O3a noise.",
  "5", "Per-timestep outputs (WaveNet family)", "t-sequence, n-real, t-ensemble", "3", "3", "Gebhard 2019 and the Huerta/Wei WaveNet ensembles emit a score per time step on real noise; one dense-target feature serves all of them and the U-Net segmentation models of step 9.",
  "6", "Matched-filter front ends", "in-mf-series", "6", "2", "MatchedFilterLayer and TemplateBank exist; exposing per-template SNR series and SNR maps unlocks MFCNN, Beveridge, McLeod (BNS), Yamamoto 2025, Mobilia and Yan 2021.",
  "7", "Burst, anomaly and autoencoder models", "t-ae, wf-pheno-burst, in-pearson, t-recurrent", "6", "5", "Extends MLy: noise-only autoencoders (Moreno, GWAK), generalised-burst training (McGinn), weak supervision (Ratner) and synthetic transient classification (Nigam).",
  "8", "Denoising and waveform extraction", "t-ae, e-overlap, t-recurrent", "8", "7", "Strain-in, clean-waveform-out models trained against WHITENED_INJECTIONS and scored by overlap.",
  "9", "Time-frequency images and pretrained backbones", "in-qtransform, in-stft, in-wavelet, in-pretrained, t-sequence", "6", "5", "Q-transform/CQT/CWT images and ImageNet backbones serve the ResNet-50 O2/O3 searches, the spectrogram early-warning nets and, in step 10, all of Gravity Spy.",
  "10", "Glitch classification (Gravity Spy family)", "n-glitch, in-qtransform, t-multiclass, e-multiclass, n-external", "17", "16", "Twenty-odd glitch papers share one dataset (Gravity Spy) and one input (multi-duration Omega scans). Either a Zenodo image loader or a Q-transform over Gravity Spy times.",
  "11", "Early warning and long BNS windows", "in-window, in-multirate, e-early, wf-subst", "6", "3", "BNS inspirals need 10-300 s windows, multi-rate inputs, partial-inspiral SNR labels and time-before-merger metrics.",
  "12", "Core-collapse supernovae and catalogue waveforms", "wf-catalogue, wf-pheno-burst, t-multiclass", "7", "5", "Supernova detectors need numerical waveforms from files (or Astone's phenomenological model), distance scaling and 3-class heads.",
  "13", "Exotic training: Bayesian, GAN, VAE, transformers, foundation models", "t-generative, t-recurrent, in-pretrained", "7", "7", "Each needs a custom train step or heavy pretrained weights; worth doing after the data and evaluation foundations exist.",
  "14", "Auxiliary-channel and pipeline-coupled models", "in-aux, in-pipeline-triggers, t-nonneural", "18", "18", "DeepClean, iDQ, EMU and cWB-coupled classifiers need non-public channels or an external pipeline; they are reference entries until gravyflow reads auxiliary data.",
  "15", "Out of core scope: space-based, CW, long transients, skymaps, PE", "det-new, wf-cw, e-pe", "21", "62", "Recorded for completeness; each needs a new physics domain.",
)

*Table 7.* Shared adaptations: state in gravyflow (first catalogue) and how many of the 313 models need each.

#tbl(columns: (auto, 1fr, 3fr, auto, auto), table.header([*Tag*], [*Feature*], [*State in gravyflow*], [*Effort once*], [*Models*]),
  "in-window", "Window length", "Have: any onsource length, fixed CBC buffer B(W)=2^ceil(log2 2W). Gap: windows of 10-300 s are unmeasured for memory and generation cost.", "S", "25",
  "in-multirate", "Multi-rate input", "Have: one sample rate per dataset, one resampler. Gap: a window cut into segments at different rates (Schafer 2020, Nagarajan 2025).", "M", "2",
  "in-stft", "STFT spectrogram", "Have: gf.spectrogram / SPECTROGRAM_ONSOURCE (|STFT|^2 of whitened data, Hann frames). Gap: per-paper window, overlap, log scaling, band crop, image resize.", "S", "20",
  "in-qtransform", "Q-transform / Omega-scan images", "Gap: no Q-transform in gravyflow; Gravity Spy-style multi-duration (0.5/1/2/4 s) images, CQT, colour maps and resizing to backbone inputs.", "M", "39",
  "in-wavelet", "Wavelet transforms", "Gap: wavelet packet, CWT (Morlet), scattering transform, cWB-like WDF time-frequency maps.", "M", "14",
  "in-freqdomain", "Frequency-domain input", "Gap: real/imaginary whitened rfft as model input (DINGO, CW nets); PSD-as-input channels.", "S", "14",
  "in-mf-series", "Matched-filter front end", "Have: MatchedFilter, MatchedFilterLayer (returns network-SNR logits), TemplateBank. Gap: per-template SNR time series and template-by-time SNR maps as model inputs, top-k template selection, learnable template layer (MFCNN).", "M", "12",
  "in-pearson", "Cross-detector correlation", "Have: ROLLING_PEARSON_ONSOURCE (circular shift; lag convention not pinned). Gap: frequency-domain correlation features.", "S", "1",
  "in-aux", "Auxiliary witness channels", "Gap: gravyflow reads strain only; no auxiliary-channel acquisition (needs LocalFrames on a LIGO cluster, non-public channels).", "L", "15",
  "in-pipeline-triggers", "External pipeline triggers", "Gap: cWB, Omicron, PyCBC or BAYESTAR products as inputs (cWB summary statistics, reconstructed waveforms, skymaps).", "L", "29",
  "in-pretrained", "Pretrained backbones", "Gap: ImageNet / audio pretrained weights (keras.applications under the JAX backend, Whisper, YOLO) and their input normalisation.", "M", "27",
  "det-hlv", "H1/L1/V1 network", "Have: H1, L1, V1 for synthetic and real noise. Gap: transient (glitch/event) mode is H1/L1 only; zero-filled missing detectors.", "S", "16",
  "det-new", "New detectors", "Gap: KAGRA, Einstein Telescope, LISA/TianQin/Taiji responses and PSDs (TDI for space).", "L", "32",
  "wf-subst", "Approximant substitution", "Have: ripple IMRPhenomD, XAS, Pv2, TaylorF2, D_NRTidalv2. Gap: SEOBNR/EOB, SpinTaylorT4, PhenomPNRT and surrogates are absent; substitute and declare the departure (as the George-Huerta example does) or bridge to LALSimulation.", "S", "31",
  "wf-xphm", "IMRPhenomXPHM / higher modes", "Gap: XPHM deliberately not offered (ripple loses LAL parity at equal masses with spin); MLGWSC-1, Aframe-era and O3 searches use it.", "M", "17",
  "wf-ecc", "Eccentric / beyond-GR waveforms", "Gap: CBCGenerator refuses eccentricity; no ppE/beyond-GR models.", "L", "5",
  "wf-catalogue", "Waveform-from-file injection", "Gap: injecting numerical waveforms from a catalogue (CCSN simulations, NR, Richers 2017) with sky projection and SNR/HRSS scaling.", "M", "10",
  "wf-pheno-burst", "Extra burst families", "Have: sine-Gaussian, chirplet, ringdown, periodic, WNB, IncoherentGenerator. Gap: Gaussian pulse, cosmic-string cusp, phenomenological CCSN (Astone), scattered-light / whistle shapes, minute-long chirps, magnetar spin-down.", "M", "15",
  "wf-cw", "Continuous waves", "Gap: CW signals with Doppler and spin-down over days (LALSuite/PyFstat).", "L", "17",
  "n-real", "Real GWOSC noise", "Have: REAL and PSEUDO_REAL noise O1-O3, flags and vetoes, split by GPS. Gap: real noise is read sequentially (not index-addressed); detectors are always two footprints apart (no coincident mode for training on coincident noise).", "S", "71",
  "n-glitch", "Gravity Spy glitches", "Have: TransientDataObtainer with Gravity Spy classes (GlitchType) H1/L1 O1-O3. Gap: glitch-labelled examples mixed as a noise class at set ratios; multi-class labels through ComposedDataset (outside the batch contract).", "S", "47",
  "n-sim-glitch", "Simulated glitches", "Gap: single-detector sine-Gaussian/Gaussian/ringdown/scattered-light glitches labelled noise (IncoherentGenerator or a per-detector injection labelled noise).", "S", "14",
  "n-psd-aug", "PSD augmentation", "Gap: recolouring with sampled PSDs (DINGO, Sage, MLGWSC-1 DS2/DS3); PSEUDO_REAL is the nearest relative.", "M", "4",
  "n-mlgwsc", "MLGWSC-1 datasets", "Gap: the challenge's four datasets (DS1-DS4) and its injection/evaluation contract; DS2-DS4 use XPHM with precession and higher modes.", "M", "7",
  "n-external", "External datasets", "Gap: a loader for a published dataset (Gravity Spy Zenodo images, Codabench GWAK, ET MDC, LDC, Richers catalogue).", "M", "12",
  "t-multiclass", "Multi-class training", "Have: ComposedDataset pools and POOL_LABEL. Gap: >2-class heads through the recipe and the batch contract.", "S", "47",
  "t-regression", "Regression targets", "Have: mass regression (George-Huerta predictor), WaveformParameters labels. Gap: SNR, chirp-mass, time-to-merger and sky targets in the recipe.", "S", "15",
  "t-sequence", "Per-timestep / dense targets", "Gap: per-sample or per-pixel labels (WaveNet-style per-timestep classification, U-Net masks, bounding boxes).", "M", "21",
  "t-ae", "Autoencoder / reconstruction", "Have: WHITENED_INJECTIONS as a clean target. Gap: noise-only reconstruction training and an anomaly-score validator path.", "M", "31",
  "t-curriculum", "Curricula and schedules", "Have: gf.Curriculum (SNR or any Distribution, by epoch). Gap: step/trigger-based curricula, curricula on frequency cutoff or mass, LR schedules beyond Keras.", "S", "9",
  "t-ensemble", "Ensembles", "Gap: training and scoring N independently seeded members, voting and coincidence rules.", "S", "12",
  "t-custom-layer", "Custom layers", "Gap: layers Keras 3 lacks or the examples do not use: DAIN, GroupNorm (present in Keras), periodic conv, SE/shrinkage, quadratic layer, inception/residual blocks.", "S", "12",
  "t-recurrent", "Recurrent / attention nets", "Have: Keras 3 LSTM/GRU/MultiHeadAttention run on JAX. Gap: none in the library; only example code and memory measurement for long sequences.", "S", "28",
  "t-generative", "GAN / VAE / flow / Bayesian training", "Gap: custom train steps (WGAN-GP, VAE ELBO, flipout Bayesian layers, normalising flows) under Keras 3 JAX.", "L", "35",
  "t-unsupervised", "Unsupervised / similarity", "Gap: clustering, contrastive pairs, IIC, UMAP/KDE outlier scoring.", "M", "13",
  "t-nonneural", "Non-neural models", "Gap: trees, GMMs, genetic programming, logistic regression: outside Keras; would need a scikit-learn/XGBoost adapter to the validator.", "M", "26",
  "e-far", "FAR and efficiency", "Have: Validator: exact FAR in Hz with Garwood intervals, efficiency by SNR bin, ROC/AUC, time slides on multi-detector real noise (num_time_slides, cluster_seconds). Gap: streamed continuous-data search with clustering over long stretches.", "S", "22",
  "e-sensitivity", "Sensitive distance / volume", "Gap: sensitive distance or volume vs FAR over a population (MLGWSC-1 metric), hrss50 for bursts.", "M", "23",
  "e-multiclass", "Multi-class evaluation", "Gap: confusion matrices, per-class accuracy/F1, NMI/ARI for clustering.", "S", "13",
  "e-overlap", "Waveform overlap", "Gap: match/overlap of reconstructed vs injected waveform (the matched-filter code has the pieces).", "S", "12",
  "e-events", "Real events", "Have: score_real_events (confident GWTC events, test split). Gap: catalogue masses on event records; O4 events.", "S", "17",
  "e-early", "Early-warning metrics", "Gap: detection time before merger, partial-inspiral SNR labels.", "M", "10",
  "e-pe", "PE diagnostics", "Gap: P-P plots, JSD against samplers, sky-area metrics.", "L", "23",
  "x-retrieve", "Full text needed", "The paper was not read (paywall or unextractable PDF); the owner or an institutional copy is needed before any adaptation can be stated.", "-", "42",
)

*Table 8.* Per-model index: section, comparability, adaptation effort, itinerary step and reproduction status.

#tbl(columns: (auto, auto, auto, auto, auto, auto, auto, auto), table.header([*Model*], [*Year*], [*Section*], [*Origin*], [*Grade*], [*Effort*], [*Step*], [*gravyflow*]),
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "abbott2021") #cite(<abbott2021>)], "2021", "other", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alfaidi2024") #cite(<alfaidi2024>)], "2024", "early", "added", [#gr-k], "M", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alhassan2022") #cite(<alhassan2022>)], "2022", "cbc", "original", [#gr-n], "M", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alhassan2023pymerger") #cite(<alhassan2023pymerger>)], "2023", "cbc", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alvares2021") #cite(<alvares2021>)], "2021", "cbc", "added", [#gr-n], "M", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alvarez2022cwbml") #cite(<alvarez2022cwbml>)], "2022", "burst", "added", [#gr-c], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "alvarez2023") #cite(<alvarez2023>)], "2023", "glitch", "original", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "andrescarcasona2023") #cite(<andrescarcasona2023>)], "2023", "cbc", "original", [#gr-k], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "andrescarcasona2023pe") #cite(<andrescarcasona2023pe>)], "2023", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "andrews2022") #cite(<andrews2022>)], "2022", "cbc", "original", [#gr-k], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "antelis2021") #cite(<antelis2021>)], "2021", "burst", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "apostol2023") #cite(<apostol2023>)], "2023", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "arutkeerthi2024") #cite(<arutkeerthi2024>)], "2024", "glitch", "added", [#gr-n], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ashton2025") #cite(<ashton2025>)], "2025", "cbc", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "astone2018") #cite(<astone2018>)], "2018", "burst", "original", [#gr-k], "M", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "attadio2024") #cite(<attadio2024>)], "2024", "burst", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "aveiro2022") #cite(<aveiro2022>)], "2022", "cbc", "original", [#gr-n], "L", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bacon2022") #cite(<bacon2022>)], "2022", "denoise", "original", [#gr-n], "S", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "badanerin2024") #cite(<badanerin2024>)], "2024", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "badger2024") #cite(<badger2024>)], "2024", "cbc", "added", [#gr-k], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2017") #cite(<bahaadini2017>)], "2017", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2018") #cite(<bahaadini2018>)], "2018", "glitch", "original", [#gr-n], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2018direct") #cite(<bahaadini2018direct>)], "2018", "glitch", "original", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bahaadini2022") #cite(<bahaadini2022>)], "2022", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "baltus2021") #cite(<baltus2021>)], "2021", "early", "original", [#gr-n], "M", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "baltus2021b") #cite(<baltus2021b>)], "2021", "early", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "baltus2022") #cite(<baltus2022>)], "2022", "early", "original", [#gr-k], "M", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bayley2020") #cite(<bayley2020>)], "2020", "cw", "original", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beheshtipour2020") #cite(<beheshtipour2020>)], "2020", "cw", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beheshtipour2020b") #cite(<beheshtipour2020b>)], "2020", "cw", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "benedikt2025") #cite(<benedikt2025>)], "2025", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beveridge2023") #cite(<beveridge2023>)], "2023", "cbc", "original", [#gr-k], "M", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "beveridge2025o3") #cite(<beveridge2025o3>)], "2025", "cbc", "added", [#gr-c], "M", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bhandari2025") #cite(<bhandari2025>)], "2025", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bini2023") #cite(<bini2023>)], "2023", "glitch", "original", [#gr-k], "M", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "biskin2023") #cite(<biskin2023>)], "2023", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "boudart2022") #cite(<boudart2022>)], "2022", "burst", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "boudart2022glitch") #cite(<boudart2022glitch>)], "2022", "glitch", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "bresten2019") #cite(<bresten2019>)], "2019", "cbc", "original", [#gr-k], "M", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cabero2020") #cite(<cabero2020>)], "2020", "other", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cain2025") #cite(<cain2025>)], "2025", "anomaly", "added", [#gr-n], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "caramete2020") #cite(<caramete2020>)], "2020", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "casallaslagos2026") #cite(<casallaslagos2026>)], "2026", "burst", "added", [#gr-n], "L", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cavaglia2018") #cite(<cavaglia2018>)], "2018", "glitch", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cavaglia2020") #cite(<cavaglia2020>)], "2020", "burst", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2020") #cite(<chan2020>)], "2020", "burst", "original", [#gr-k], "M", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2024") #cite(<chan2024>)], "2024", "other", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2025") #cite(<chan2025>)], "2025", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chan2025lens") #cite(<chan2025lens>)], "2025", "pe", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2019") #cite(<chatterjee2019>)], "2019", "pe", "added", [#gr-n], "S", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2021") #cite(<chatterjee2021>)], "2021", "denoise", "original", [#gr-k], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2022") #cite(<chatterjee2022>)], "2022", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2023skyloc") #cite(<chatterjee2023skyloc>)], "2023", "pe", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024") #cite(<chatterjee2024>)], "2024", "anomaly", "original", [#gr-c], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024harm") #cite(<chatterjee2024harm>)], "2024", "denoise", "added", [#gr-k], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2024rec") #cite(<chatterjee2024rec>)], "2024", "denoise", "added", [#gr-n], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chatterjee2026") #cite(<chatterjee2026>)], "2026", "cbc", "original", [#gr-c], "M", "4", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chaturvedi2022") #cite(<chaturvedi2022>)], "2022", "cbc", "added", [#gr-n], "M", "5", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chauhan2020") #cite(<chauhan2020>)], "2020", "cbc", "added", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cheung2025unet") #cite(<cheung2025unet>)], "2025", "cw", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "choudhary2022") #cite(<choudhary2022>)], "2022", "glitch", "added", [#gr-n], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "chua2019") #cite(<chua2019>)], "2019", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cirfeta2026") #cite(<cirfeta2026>)], "2026", "anomaly", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "colgan2020") #cite(<colgan2020>)], "2020", "glitch", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "colgan2022") #cite(<colgan2022>)], "2022", "glitch", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "coughlin2019") #cite(<coughlin2019>)], "2019", "glitch", "original", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cuoco2020") #cite(<cuoco2020>)], "2021", "other", "original", [#gr-n], "-", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "cuoco2026") #cite(<cuoco2026>)], "2026", "burst", "original", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2021") #cite(<dax2021>)], "2021", "pe", "original", [#gr-c], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2022") #cite(<dax2022>)], "2022", "pe", "added", [#gr-c], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dax2024") #cite(<dax2024>)], "2024", "pe", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "deighan2020") #cite(<deighan2020>)], "2020", "cbc", "added", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "delaunoy2020") #cite(<delaunoy2020>)], "2020", "pe", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "deshmukh2026") #cite(<deshmukh2026>)], "2026", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dicesare2026fh") #cite(<dicesare2026fh>)], "2026", "cw", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ding2021") #cite(<ding2021>)], "2021", "glitch", "added", [#gr-n], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dodia2021residual") #cite(<dodia2021residual>)], "2021", "cbc", "added", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dodia2021specgrav") #cite(<dodia2021specgrav>)], "2021", "cbc", "added", [#gr-n], "S", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dominguez2023") #cite(<dominguez2023>)], "2023", "cw", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2022") #cite(<dooney2022>)], "2022", "glitch", "added", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2024") #cite(<dooney2024>)], "2024", "other", "original", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2025") #cite(<dooney2025>)], "2025", "denoise", "original", [#gr-k], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dooney2026") #cite(<dooney2026>)], "2026", "glitch", "added", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dreissigacker2019") #cite(<dreissigacker2019>)], "2019", "cw", "original", [#gr-c], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "dreissigacker2020") #cite(<dreissigacker2020>)], "2020", "cw", "original", [#gr-c], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "duraisamy2023") #cite(<duraisamy2023>)], "2023", "cw", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "edwards2021") #cite(<edwards2021>)], "2021", "other", "original", [#gr-n], "M", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "einsle2025") #cite(<einsle2025>)], "2025", "other", "added", [#gr-n], "M", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "emma2026") #cite(<emma2026>)], "2026", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "essick2020") #cite(<essick2020>)], "2020", "glitch", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fan2019") #cite(<fan2019>)], "2019", "cbc", "original", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fan2021_2d") #cite(<fan2021_2d>)], "2021", "cbc", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fayad2024") #cite(<fayad2024>)], "2024", "anomaly", "original", [#gr-n], "M", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fernandes2023") #cite(<fernandes2023>)], "2023", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fernandes2025") #cite(<fernandes2025>)], "2025", "burst", "added", [#gr-c], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "fernandes2026") #cite(<fernandes2026>)], "2026", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "g2net2022_acm") #cite(<g2net2022_acm>)], "2021", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gabbard2018") #cite(<gabbard2018>)], "2018", "cbc", "original", [#gr-k], "-", "1", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gabbard2022pe") #cite(<gabbard2022pe>)], "2022", "pe", "original", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "garg2024") #cite(<garg2024>)], "2023", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gebhard2019") #cite(<gebhard2019>)], "2019", "cbc", "original", [#gr-k], "M", "5", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2017tl") #cite(<george2017tl>)], "2017", "glitch", "added", [#gr-k], "L", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018") #cite(<george2018>)], "2018", "cbc", "original", [#gr-n], "-", "1", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018b") #cite(<george2018b>)], "2018", "cbc", "original", [#gr-n], "S", "1", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018glitch") #cite(<george2018glitch>)], "2018", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "george2018plb") #cite(<george2018plb>)], "2017", "cbc", "added", [#gr-n], "S", "1", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ghalsasi2023") #cite(<ghalsasi2023>)], "2023", "denoise", "added", [#gr-n], "L", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "glanzer2023") #cite(<glanzer2023>)], "2023", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "green2020") #cite(<green2020>)], "2020", "pe", "original", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gunny2021") #cite(<gunny2021>)], "2021", "cbc", "original", [#gr-n], "-", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "guo2025") #cite(<guo2025>)], "2025", "anomaly", "added", [#gr-n], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gupta2025ae") #cite(<gupta2025ae>)], "2025", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gupta2026") #cite(<gupta2026>)], "2026", "cbc", "added", [#gr-c], "M", "3", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "gupta2026q") #cite(<gupta2026q>)], "2026", "cbc", "added", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "houba2024glitch") #cite(<houba2024glitch>)], "2024", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "houba2024mbh") #cite(<houba2024mbh>)], "2024", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "houba2025separation") #cite(<houba2025separation>)], "2025", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "hu2024") #cite(<hu2024>)], "2024", "pe", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "huerta2021") #cite(<huerta2021>)], "2021", "cbc", "original", [#gr-n], "M", "5", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iess2020") #cite(<iess2020>)], "2020", "burst", "original", [#gr-n], "M", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iess2023") #cite(<iess2023>)], "2023", "burst", "original", [#gr-n], "M", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "imran2024") #cite(<imran2024>)], "2024", "anomaly", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "inguglia2025") #cite(<inguglia2025>)], "2025", "anomaly", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "inguglia2026") #cite(<inguglia2026>)], "2026", "anomaly", "added", [#gr-c], "L", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "insley2026flows") #cite(<insley2026flows>)], "2026", "cbc", "added", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "isfan2025quantum") #cite(<isfan2025quantum>)], "2025", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "isfan2026qnn") #cite(<isfan2026qnn>)], "2026", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "iwanaga2025") #cite(<iwanaga2025>)], "2025", "pe", "added", [#gr-n], "M", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jadhav2020") #cite(<jadhav2020>)], "2020", "cbc", "added", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jadhav2023") #cite(<jadhav2023>)], "2023", "cbc", "original", [#gr-k], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jarov2023") #cite(<jarov2023>)], "2023", "glitch", "original", [#gr-n], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jenner2024") #cite(<jenner2024>)], "2024", "pe", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jia2026") #cite(<jia2026>)], "2026", "denoise", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jiang2022") #cite(<jiang2022>)], "2022", "cbc", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "jiang2022real") #cite(<jiang2022real>)], "2022", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "joshi2023") #cite(<joshi2023>)], "2023", "cw", "added", [#gr-c], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "joshi2024large") #cite(<joshi2024large>)], "2024", "cw", "added", [#gr-c], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "joshi2025vit") #cite(<joshi2025vit>)], "2025", "cw", "added", [#gr-c], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kelleter2026nnnn") #cite(<kelleter2026nnnn>)], "2026", "denoise", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "khalouei2025") #cite(<khalouei2025>)], "2025", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kiendrebeogo2025virgo") #cite(<kiendrebeogo2025virgo>)], "2025", "denoise", "added", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2015grb") #cite(<kim2015grb>)], "2015", "cbc", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2019") #cite(<kim2019>)], "2019", "cbc", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2020lens") #cite(<kim2020lens>)], "2020", "other", "added", [#gr-n], "M", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2022lens") #cite(<kim2022lens>)], "2022", "other", "added", [#gr-n], "M", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kim2026kagra") #cite(<kim2026kagra>)], "2026", "glitch", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kofler2025") #cite(<kofler2025>)], "2025", "pe", "original", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kolmus2021") #cite(<kolmus2021>)], "2021", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "koloniari2024") #cite(<koloniari2024>)], "2024", "cbc", "original", [#gr-k], "L", "4", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "koyama2024") #cite(<koyama2024>)], "2024", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "krastev2020") #cite(<krastev2020>)], "2020", "cbc", "original", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "krastev2021") #cite(<krastev2021>)], "2021", "cbc", "original", [#gr-n], "M", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kumar2023") #cite(<kumar2023>)], "2023", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "kumar2026") #cite(<kumar2026>)], "2026", "denoise", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "laguarta2023") #cite(<laguarta2023>)], "2023", "glitch", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lanchares2025") #cite(<lanchares2025>)], "2025", "pe", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lee2025") #cite(<lee2025>)], "2025", "denoise", "added", [#gr-k], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "li2020") #cite(<li2020>)], "2020", "cbc", "original", [#gr-n], "M", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "li2024ctsae") #cite(<li2024ctsae>)], "2024", "glitch", "added", [#gr-n], "L", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "licciardi2024") #cite(<licciardi2024>)], "2024", "glitch", "original", [#gr-k], "M", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lin2019") #cite(<lin2019>)], "2019", "cbc", "original", [#gr-n], "M", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lin2021") #cite(<lin2021>)], "2021", "cbc", "original", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lin2024") #cite(<lin2024>)], "2024", "denoise", "added", [#gr-k], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "liu2023") #cite(<liu2023>)], "2023", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "llorensmonteagudo2018") #cite(<llorensmonteagudo2018>)], "2018", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2021a") #cite(<lopez2021a>)], "2021", "burst", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2021b") #cite(<lopez2021b>)], "2021", "burst", "original", [#gr-k], "L", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2022gan") #cite(<lopez2022gan>)], "2022", "other", "added", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "lopez2022gmm") #cite(<lopez2022gmm>)], "2022", "burst", "original", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "luo2019") #cite(<luo2019>)], "2019", "cbc", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "luo2026") #cite(<luo2026>)], "2026", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2022") #cite(<ma2022>)], "2022", "cbc", "original", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024et") #cite(<ma2024et>)], "2024", "denoise", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024mix") #cite(<ma2024mix>)], "2024", "denoise", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024msnr2") #cite(<ma2024msnr2>)], "2024", "denoise", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024tempfree") #cite(<ma2024tempfree>)], "2023", "cbc", "added", [#gr-n], "L", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2024tsr") #cite(<ma2024tsr>)], "2024", "denoise", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2025et") #cite(<ma2025et>)], "2025", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ma2025overlap") #cite(<ma2025overlap>)], "2025", "anomaly", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "magee2024interp") #cite(<magee2024interp>)], "2024", "glitch", "added", [#gr-n], "M", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "malz2024") #cite(<malz2024>)], "2024", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "manoharan2026") #cite(<manoharan2026>)], "2026", "glitch", "added", [#gr-n], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marianer2021") #cite(<marianer2021>)], "2021", "burst", "original", [#gr-n], "L", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "martins2024") #cite(<martins2024>)], "2024", "early", "added", [#gr-n], "M", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marulanda2020") #cite(<marulanda2020>)], "2020", "pe", "added", [#gr-n], "S", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marx2024") #cite(<marx2024>)], "2024", "cbc", "original", [#gr-c], "M", "4", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "marx2025aframeO3") #cite(<marx2025aframeO3>)], "2025", "cbc", "added", [#gr-c], "M", "3", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcginn2021") #cite(<mcginn2021>)], "2021", "other", "original", [#gr-n], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcisaac2022") #cite(<mcisaac2022>)], "2022", "cbc", "added", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcleod2022") #cite(<mcleod2022>)], "2022", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mcleod2025") #cite(<mcleod2025>)], "2025", "cbc", "original", [#gr-c], "L", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "meijer2023cosmicstrings") #cite(<meijer2023cosmicstrings>)], "2023", "burst", "added", [#gr-n], "L", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "meijer2024") #cite(<meijer2024>)], "2024", "cbc", "added", [#gr-n], "M", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "menendez2022sub") #cite(<menendez2022sub>)], "2022", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "menendez2024") #cite(<menendez2024>)], "2024", "cbc", "original", [#gr-k], "M", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "menendezvazquez2021") #cite(<menendezvazquez2021>)], "2021", "cbc", "original", [#gr-k], "M", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mesuga2021") #cite(<mesuga2021>)], "2021", "glitch", "added", [#gr-n], "L", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "miller2019") #cite(<miller2019>)], "2019", "cw", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mishra2021") #cite(<mishra2021>)], "2021", "burst", "added", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mlgwsc2022") #cite(<mlgwsc2022>)], "2022", "cbc", "original", [#gr-c], "L", "4", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mobilia2026") #cite(<mobilia2026>)], "2026", "cbc", "original", [#gr-n], "M", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "modafferi2023") #cite(<modafferi2023>)], "2023", "burst", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mogushi2021") #cite(<mogushi2021>)], "2021", "denoise", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "mogushi2021nnetfix") #cite(<mogushi2021nnetfix>)], "2021", "denoise", "original", [#gr-n], "S", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "morales2024") #cite(<morales2024>)], "2024", "burst", "added", [#gr-n], "L", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "morawski2020cw") #cite(<morawski2020cw>)], "2019", "cw", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "morawski2021") #cite(<morawski2021>)], "2021", "anomaly", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "moreno2022") #cite(<moreno2022>)], "2022", "burst", "original", [#gr-k], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "murali2022") #cite(<murali2022>)], "2022", "denoise", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nagarajan2025") #cite(<nagarajan2025>)], "2025", "cbc", "original", [#gr-c], "L", "4", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nigam2020") #cite(<nigam2020>)], "2020", "burst", "original", [#gr-n], "S", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nousi2022") #cite(<nousi2022>)], "2023", "cbc", "original", [#gr-c], "M", "4", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "nunes2024") #cite(<nunes2024>)], "2024", "burst", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ormiston2020") #cite(<ormiston2020>)], "2020", "denoise", "original", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "oshino2025") #cite(<oshino2025>)], "2025", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "papalini2025") #cite(<papalini2025>)], "2025", "pe", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "papigkiotis2026") #cite(<papigkiotis2026>)], "2026", "early", "added", [#gr-n], "L", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "pimpalkar2026") #cite(<pimpalkar2026>)], "2026", "denoise", "added", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "powell2015") #cite(<powell2015>)], "2015", "glitch", "original", [#gr-n], "M", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "powell2016") #cite(<powell2016>)], "2016", "glitch", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "powell2022") #cite(<powell2022>)], "2022", "other", "added", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "pracchia2025") #cite(<pracchia2025>)], "2025", "burst", "original", [#gr-k], "M", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "qiu2022") #cite(<qiu2022>)], "2022", "cbc", "original", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "que2021") #cite(<que2021>)], "2021", "other", "added", [#gr-n], "M", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "rai2026") #cite(<rai2026>)], "2026", "cbc", "added", [#gr-n], "S", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "raikman2023") #cite(<raikman2023>)], "2023", "anomaly", "original", [#gr-k], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "raikman2024") #cite(<raikman2024>)], "2024", "burst", "original", [#gr-c], "L", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ratner2026") #cite(<ratner2026>)], "2026", "burst", "original", [#gr-k], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ravichandran2023") #cite(<ravichandran2023>)], "2023", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "razzano2018") #cite(<razzano2018>)], "2018", "glitch", "original", [#gr-n], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "rebei2018") #cite(<rebei2018>)], "2018", "cbc", "added", [#gr-n], "L", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "reissel2025") #cite(<reissel2025>)], "2025", "denoise", "added", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ruan2023") #cite(<ruan2023>)], "2023", "space", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ruan2023pe") #cite(<ruan2023pe>)], "2023", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ruan2024") #cite(<ruan2024>)], "2024", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sakai2022") #cite(<sakai2022>)], "2022", "glitch", "original", [#gr-n], "M", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sakai2024") #cite(<sakai2024>)], "2024", "denoise", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sakellariou2026") #cite(<sakellariou2026>)], "2026", "pe", "added", [#gr-n], "S", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "saleem2023") #cite(<saleem2023>)], "2023", "denoise", "original", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sankarapandian2021") #cite(<sankarapandian2021>)], "2021", "glitch", "added", [#gr-n], "L", "13", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "santos2020") #cite(<santos2020>)], "2020", "cbc", "added", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sasaoka2023_cbc") #cite(<sasaoka2023_cbc>)], "2023", "cbc", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sasaoka2023_ccsn") #cite(<sasaoka2023_ccsn>)], "2023", "burst", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sasaoka2023attr") #cite(<sasaoka2023attr>)], "2023", "cbc", "added", [#gr-n], "M", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2020") #cite(<schafer2020>)], "2020", "cbc", "original", [#gr-c], "L", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2021a") #cite(<schafer2021a>)], "2021", "cbc", "original", [#gr-k], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schafer2021b") #cite(<schafer2021b>)], "2021", "cbc", "original", [#gr-k], "M", "3", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "schmitt2019") #cite(<schmitt2019>)], "2019", "cbc", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shah2023") #cite(<shah2023>)], "2023", "glitch", "added", [#gr-n], "L", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sharma2023") #cite(<sharma2023>)], "2023", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sharma2024") #cite(<sharma2024>)], "2024", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shen2017") #cite(<shen2017>)], "2017", "denoise", "original", [#gr-n], "S", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shen2019") #cite(<shen2019>)], "2019", "denoise", "original", [#gr-k], "S", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "shen2019pe") #cite(<shen2019pe>)], "2019", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "silver2025") #cite(<silver2025>)], "2025", "cbc", "original", [#gr-n], "M", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "singh2020") #cite(<singh2020>)], "2020", "pe", "added", [#gr-n], "S", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "singh2025") #cite(<singh2025>)], "2025", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "skliris2024") #cite(<skliris2024>)], "2024", "burst", "original", [#gr-c], "S", "1", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "soma2023") #cite(<soma2023>)], "2023", "pe", "added", [#gr-n], "S", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "soni2021") #cite(<soni2021>)], "2021", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "srivastava2024") #cite(<srivastava2024>)], "2024", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "sun2026") #cite(<sun2026>)], "2026", "burst", "added", [#gr-k], "L", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "szczepanczyk2022") #cite(<szczepanczyk2022>)], "2022", "burst", "original", [#gr-c], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "talpini2022") #cite(<talpini2022>)], "2022", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tenorio2025g2net_cw") #cite(<tenorio2025g2net_cw>)], "2025", "cw", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tian2023") #cite(<tian2023>)], "2023", "cbc", "added", [#gr-k], "M", "5", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tian2024gnn") #cite(<tian2024gnn>)], "2023", "cbc", "added", [#gr-k], "M", "5", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "tiki2025") #cite(<tiki2025>)], "2025", "cbc", "added", [#gr-k], "M", "3", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "torresforne2020") #cite(<torresforne2020>)], "2020", "denoise", "added", [#gr-n], "M", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "trovato2023") #cite(<trovato2023>)], "2023", "cbc", "original", [#gr-k], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "ussipov2024") #cite(<ussipov2024>)], "2024", "cbc", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "utina2021") #cite(<utina2021>)], "2021", "other", "added", [#gr-n], "S", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vajente2020") #cite(<vajente2020>)], "2020", "denoise", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vandyke2025") #cite(<vandyke2025>)], "2025", "glitch", "added", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vanstraalen2024") #cite(<vanstraalen2024>)], "2024", "pe", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "verma2021") #cite(<verma2021>)], "2021", "cbc", "original", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "verma2022") #cite(<verma2022>)], "2022", "cbc", "original", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "vinciguerra2017") #cite(<vinciguerra2017>)], "2017", "burst", "added", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2020") #cite(<wang2020>)], "2020", "cbc", "original", [#gr-n], "M", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2022waveformer") #cite(<wang2022waveformer>)], "2024", "denoise", "original", [#gr-k], "L", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2023tf") #cite(<wang2023tf>)], "2024", "cbc", "original", [#gr-k], "M", "9", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2025exotic") #cite(<wang2025exotic>)], "2025", "cbc", "original", [#gr-k], "M", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wang2026ccsn_scl") #cite(<wang2026ccsn_scl>)], "2026", "burst", "added", [#gr-n], "L", "12", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "weerasinghe2026") #cite(<weerasinghe2026>)], "2026", "cbc", "added", [#gr-n], "M", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2020denoise") #cite(<wei2020denoise>)], "2020", "denoise", "original", [#gr-k], "S", "8", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2021") #cite(<wei2021>)], "2021", "early", "original", [#gr-n], "L", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2021ensemble") #cite(<wei2021ensemble>)], "2021", "cbc", "original", [#gr-k], "M", "5", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wei2021forecast") #cite(<wei2021forecast>)], "2021", "early", "original", [#gr-n], "M", "11", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "wu2024") #cite(<wu2024>)], "2024", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xia2021") #cite(<xia2021>)], "2021", "cbc", "original", [#gr-k], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xie2026") #cite(<xie2026>)], "2026", "glitch", "added", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xu2024") #cite(<xu2024>)], "2024", "other", "original", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xu2024denoise") #cite(<xu2024denoise>)], "2024", "denoise", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "xu2026ssl_lisa") #cite(<xu2026ssl_lisa>)], "2026", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2021cw") #cite(<yamamoto2021cw>)], "2020", "cw", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2022cw") #cite(<yamamoto2022cw>)], "2022", "cw", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2023") #cite(<yamamoto2023>)], "2023", "cw", "original", [#gr-n], "S", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yamamoto2025") #cite(<yamamoto2025>)], "2025", "cbc", "original", [#gr-c], "M", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2021") #cite(<yan2021>)], "2021", "cbc", "original", [#gr-n], "M", "6", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2022") #cite(<yan2022>)], "2022", "cbc", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2022gan") #cite(<yan2022gan>)], "2022", "glitch", "added", [#gr-k], "L", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yan2025deepgrav") #cite(<yan2025deepgrav>)], "2025", "burst", "added", [#gr-n], "M", "7", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yu2021early") #cite(<yu2021early>)], "2021", "early", "original", [#gr-k], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yu2021noise") #cite(<yu2021noise>)], "2021", "denoise", "original", [#gr-n], "L", "14", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "yun2023") #cite(<yun2023>)], "2023", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zelenka2024") #cite(<zelenka2024>)], "2024", "cbc", "added", [#gr-c], "M", "4", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zevin2017") #cite(<zevin2017>)], "2017", "glitch", "original", [#gr-k], "M", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zevin2024") #cite(<zevin2024>)], "2024", "glitch", "original", [#gr-k], "S", "10", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhan2021") #cite(<zhan2021>)], "2021", "cbc", "added", [#gr-n], "S", "2", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhang2022") #cite(<zhang2022>)], "2022", "cbc", "original", [#gr-n], "-", "0", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhang2022emri") #cite(<zhang2022emri>)], "2022", "space", "added", [#gr-n], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhang2026") #cite(<zhang2026>)], "2026", "pe", "added", [#gr-k], "L", "15", [#pend],
  [#text(font: "DejaVu Sans Mono", size: 6.2pt, "zhao2023") #cite(<zhao2023>)], "2023", "space", "original", [#gr-n], "L", "15", [#pend],
)
= Open questions <sec-open>
*Which benchmark contract should gravyflow's validator reproduce first?* MLGWSC-1 is the only cross-paper detection contract with published code; the LVK injection campaigns are the production-grade alternative. Reproducing both would let every reproduced detector be placed on the comparable rows of Section @sec-cbc.

*Per-window false-alarm probabilities.* Most detection papers report them. A rate needs the window stride, the clustering rule and the background duration, which many papers omit; our reproductions can supply the rate for the paper's own network, but the paper's numbers stay as reported.

*Gravity Spy release and split.* Glitch accuracies differ by release and split. A fixed gravyflow split of one release (with macro-F1 as well as accuracy) would make the reproduced classifiers comparable among themselves.

*Entries to resolve.* 42 entries were read at abstract level or not at all (none has an arXiv version); they need institutional access. The sweep left open whether george2018plb should merge with george2018b, and it found that ma2024tempfree and the MSNRnet-1 citation share a journal article number, so one citation is wrong. Two marginal entries are kept and flagged: kelleter2026nnnn (seismic-array Newtonian-noise regression) and jia2026 (data type unverified).

*Suspected errors.* The highlighted inconsistencies are the synthesiser's reading of the extraction notes. Before any is cited outside this review it should be checked against the paper, and where it matters, raised with the authors.

*Out-of-scope domains.* Space-based detectors, continuous waves and full parameter estimation need new detector responses, waveform families or diagnostics in gravyflow. Whether they enter the reproduction programme is a scope decision.

#pagebreak()
#bibliography("refs.yml", title: "References", style: "ieee")
