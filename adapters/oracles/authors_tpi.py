"""
The TPI authors' own code on the oracle's segment file, for each release named:

- ``<card>.input.npy``: the windows their slicer feeds their network, as their
  ``worker`` and ``evaluate_slices`` make them (``TorchSegmentSlicer``, batched by
  512, cast to float32);
- ``<card>.triggers.hdf``: the triggers of their entry point (``apply.py``, run as a
  script with its defaults, on the CPU, with no worker processes).

Run in the TPI environment, with the authors' repository checked out at the card's
commit (nothing in it is changed):

    python authors_tpi.py <checkout> <segment.hdf> <output directory> original r1 ...
"""

import argparse
import importlib.util
import subprocess
import sys
from pathlib import Path

import h5py
import numpy as np
import torch

#: The authors' script for each release.
SCRIPTS = {"original": "mlgwsc-1/apply.py", **{f"r{run}": "correction/apply.py" for run in range(1, 7)}}

#: Each release's weights, in the checkout.
WEIGHTS = {"original": "mlgwsc-1/best_state_dict.pt",
           **{f"r{run}": f"correction/state_dicts/{name}" for run, name in enumerate(
               ("R1_0021.pt", "R2_0150.pt", "R3_0036.pt", "R4_0038.pt", "R5_0193.pt", "R6_0026.pt"), start=1)}}


def load(script):
    """The authors' ``apply.py`` as a module."""
    spec = importlib.util.spec_from_file_location("authors_apply", script)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def model_input(apply, segment):
    """The batches ``evaluate_slices`` feeds the network, as ``get_triggers`` sets up their slicer."""
    with h5py.File(segment, "r") as handle:
        slicer = apply.TorchSegmentSlicer(handle, "0", step_size=0.1, low_frequency_cutoff=20.0, white=False,
                                          whitened_file=None, detectors=["H1", "L1"])
    loader = torch.utils.data.DataLoader(slicer, batch_size=512, shuffle=False)
    return torch.cat([batch.to(dtype=apply.dtype) for batch, _ in loader]).numpy()


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("checkout", type=Path)
    parser.add_argument("segment", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("releases", nargs="+", choices=sorted(SCRIPTS))
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    for release in args.releases:
        script = args.checkout / SCRIPTS[release]
        np.save(args.output / f"tpi-{release}.input.npy", model_input(load(script), args.segment))
        triggers = args.output / f"tpi-{release}.triggers.hdf"
        subprocess.run([sys.executable, str(script), str(args.segment.absolute()), str(triggers.absolute()),
                        "--weights", str((args.checkout / WEIGHTS[release]).absolute()), "--device", "cpu",
                        "--num-workers", "0", "--force"], cwd=args.output, check=True, stdin=subprocess.DEVNULL)
        print(f"tpi-{release}: the authors' input and triggers written")


if __name__ == "__main__":
    main()
