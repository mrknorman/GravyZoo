"""
The AresGW authors' own entry point on the oracle's segment file, run unchanged as
``python test.py <segment> <triggers> --weights <weights>`` (in this process, by
``runpy``), with the input to its DAIN layer recorded on the way:

- ``aresgw-model1.input.npy``: the whitened, cropped windows their model's DAIN layer
  reads, every batch in order;
- ``aresgw-model1.triggers.hdf``: the triggers ``test.py`` writes.

Run in the AresGW environment, with the authors' repository checked out at the
card's commit (nothing in it is changed):

    python authors_aresgw.py <checkout> <segment.hdf> <output directory>
"""

import argparse
import runpy
import sys
from pathlib import Path

import numpy as np
import torch


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("checkout", type=Path)
    parser.add_argument("segment", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    checkout = args.checkout.absolute()
    sys.path.insert(0, str(checkout))
    from modules import dain  # the authors' module, which test.py imports by the same name

    read = []
    forward = dain.DAIN_Layer.forward

    def recording(self, x):
        read.append(x.detach().clone())
        return forward(self, x)

    dain.DAIN_Layer.forward = recording
    triggers = args.output / "aresgw-model1.triggers.hdf"
    sys.argv = ["test.py", str(args.segment.absolute()), str(triggers.absolute()), "--weights",
                str(checkout / "trained_models/improved_d4_model/weights.pt")]
    runpy.run_path(str(checkout / "test.py"), run_name="__main__")
    np.save(args.output / "aresgw-model1.input.npy", torch.cat(read).numpy())
    print(f"aresgw-model1: the authors' input ({sum(len(x) for x in read)} windows) and triggers written")


if __name__ == "__main__":
    main()
