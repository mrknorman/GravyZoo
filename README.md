# GravyZoo

A catalogue of machine-learning models for gravitational-wave detector data from the literature, and a programme to
reproduce them on [gravyflow](https://github.com/mrknorman/gravyflow).

For each model the catalogue records its architecture, inputs, training data and procedure, the results its paper
reports (each number cited to its table or figure), whether code and weights are available, and what gravyflow needs
to reproduce it. Reproduced models and their trained weights will be published here, and gravyflow will load them on
request.

Work in progress.

## Contents

- `catalogue/catalogue.json`: 318 models (catalogue version 4, October 2026, including the author's own PhD thesis models). Each entry records the architecture,
  inputs, training data and procedure, every performance number its paper reports with its conditions and location
  (3,206 metrics, 682 of them read from figures with an uncertainty), a comparability grade on shared axes,
  official code and weights where they exist (106 and 29 models), suspected errors in the literature, and the
  reproduction plan for gravyflow (marked pending until done).
- `review/gravyflow-model-zoo-review.pdf` (and its Typst source and bibliography): a work-in-progress literature
  review built from the catalogue, 53 pages, with comparison tables per category and a placeholder for each
  reproduction.

Descriptions are written in our own words; the papers are cited, not reproduced.

## Licence

- **Catalogue data, metrics and text** (the catalogue, the review and other documentation): licensed under
  [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
  You may share and adapt them, including commercially, if you credit GravyZoo, link the licence and say what you
  changed.
- **Code and model definitions:** licensed under the Apache License 2.0 (see `LICENSE`), the same as gravyflow.
- The papers the catalogue describes keep their own copyright and are not included here; every value is cited to
  its source.
