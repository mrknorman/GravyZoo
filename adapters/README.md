# GravyZoo adapters

Published gravitational-wave searches with released weights, run as their authors published them through
[gravyflow](https://github.com/mrknorman/gravyflow)'s external-model runner (`gravyflow.ExternalRunner`). Each
adapter is an `ExternalSearch` (`prepare`, `preprocess`, `search`) published under the entry-point group
`gravyflow.external`, and runs in an environment of its own, beside the framework its model needs.

| Model | Package | Entry points (cards) | Input | Original code and weights | Licence |
|---|---|---|---|---|---|
| TPI FSU Jena (Zelenka, Brügmann and Ohme) | `gravyzoo_adapters.tpi` | `tpi-original`, `tpi-r1` to `tpi-r6` | H1, L1 at 2048 Hz | [ondrzel/ml-gw-search](https://github.com/ondrzel/ml-gw-search) | Apache-2.0 |
| AresGW model 1 (Nousi et al.) | `gravyzoo_adapters.aresgw` | `aresgw-model1` | H1, L1 at 2048 Hz | [vivinousi/gw-detection-deep-learning](https://github.com/vivinousi/gw-detection-deep-learning) | Apache-2.0 |
| AttenGW (Tiki and Huerta) | `gravyzoo_adapters.attengw` | `attengw-seed1` to `attengw-seed4` | L1, H1 at 4096 Hz | [victoria-tiki/AttenGW](https://github.com/victoria-tiki/AttenGW) | MIT |

Each model's subpackage holds its adapter (`search.py`), its cards for gravyflow (`card.py`: input and output
contracts as published, weights pinned by sha256 at the authors' commit, the rows the authors published), and a
`NOTICE` crediting the original authors; code copied from the authors' repositories is in its `published/`,
unchanged. The weights are never copied here: gravyflow fetches them from the authors' repositories. Each card pins
the sha256 of the lock file its environment is built from (`locks/`, named in `environments.py`).

A statistic is reported as its authors publish it, never rescored. AttenGW's reports list trigger times only; its
adapter gives each trigger the largest smoothed maximum among the windows merged into it (see its `search.py`).

## Running a model

```shell
# The model's environment, from its lock (conda-forge, osx-arm64).
micromamba create -p <prefix> --file src/gravyzoo_adapters/locks/pytorch-1.13.1-pycbc-2.0.6.osx-arm64.lock
# The adapters, installed beside it rather than into it, so the lock stays exact.
<prefix>/bin/python -m pip install --no-deps --no-build-isolation --target <site> .
```

```python
import gravyflow as gf
from gravyzoo_adapters.tpi import card

runner = gf.ExternalRunner(card.R1, gf.AdapterEnvironment("<prefix>/bin/python", card.LOCK, ("<site>",)),
                           deadline_seconds=600)
result = runner.search(gf.SearchSegment(strain, ("H1", "L1"), t0, 2048.0))  # result.triggers
```

## Oracles

`oracles/` checks each adapter against its authors' own code on one segment of coloured Gaussian noise from
gravyflow with four injections (`make_segment.py`): the input the adapter's network reads equals the input the
authors' code feeds theirs, and the adapter's triggers equal those of the authors' entry point
(`authors_<model>.py`, run in the model's environment on a checkout of the authors' repository; `compare.py`, run
with gravyflow).
