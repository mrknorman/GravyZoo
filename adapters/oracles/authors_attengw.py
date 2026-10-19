"""
The AttenGW author's own code on the oracle's 4096 Hz segment, for each seeded copy
named:

1. The test file, written by the author's downloader from the segment's samples
   (``download_and_save_window``, test path: raw strain and its PSD).
2. The author's inference entry point (``inference/infer.py``, ``main``) on that file,
   with the example inference configuration (``configs/inference_example.yaml``; only
   its paths, the CPU and, as it needs training noise, no ASD-mismatch diagnostic
   changed), recording on the way the input its network reads and what
   ``score_file`` returns.

Written for each copy:

- ``attengw-<seed>.input.npy``: the windows the author's network read, in order;
- ``attengw-<seed>.triggers.hdf``: the triggers of the author's report for the
  smoothed_max operating point at 0.9999 (each at the GPS time of its reported sample
  index, as the report computes it), each with the statistic the adapter defines (the
  largest smoothed maximum among the windows merged into it), computed from the
  author's own scores with the author's ``moving_average_same`` and merging rule.

Run in the AttenGW environment, with the author's repository checked out at the
card's commit (nothing in it is changed):

    python authors_attengw.py <checkout> <segment-4096.npz> <output directory> seed1 ...
"""

import argparse
import importlib.util
import re
import sys
from pathlib import Path

import h5py
import numpy as np
import torch
import yaml

CHECKPOINTS = {
    "seed1": "checkpoints/train_job_21247765/model_attenGW-epoch=60-val_loss=0.01753.ckpt",
    "seed2": "checkpoints/train_job_21287149/model_attenGW-epoch=51-val_loss=0.01707.ckpt",
    "seed3": "checkpoints/train_job_21364665/model_attenGW-epoch=34-val_loss=0.01723.ckpt",
    "seed4": "checkpoints/train_job_21372515/model_attenGW-epoch=54-val_loss=0.01722.ckpt",
}

#: The operating point the cards give, and its report.
METHOD, THRESHOLD, REPORT = "smoothed_max", 0.9999, "smoothed_max_threshold_0p9999.txt"


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def test_file(checkout, segment, directory):
    """The author's downloader's test file for the segment's samples."""
    downloader = load("downloader", checkout / "downloader.py")
    with np.load(segment) as arrays:
        strain = dict(zip(arrays["detectors"].tolist(), arrays["strain"]))
        start, rate = float(arrays["t0"]), float(arrays["sample_rate_hertz"])
    end = start + len(next(iter(strain.values()))) / rate
    directory.mkdir(parents=True, exist_ok=True)
    assert downloader.download_and_save_window(
        ["H1", "L1"], start, end, rate, "noise", str(directory), whiten=False, qc_policy="flag_only",
        dataset_split="test", preloaded_data=strain)
    return start, rate


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("checkout", type=Path)
    parser.add_argument("segment", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("seeds", nargs="+", choices=sorted(CHECKPOINTS))
    args = parser.parse_args()
    checkout = args.checkout.absolute()
    sys.path.insert(0, str(checkout))
    start, rate = test_file(checkout, args.segment, args.output / "test-file")

    infer = load("infer", checkout / "inference/infer.py")
    from models import model_tcn_earlyfusion  # the author's module, which infer imports by the same name

    read, scored = [], []
    forward, score_file = model_tcn_earlyfusion.full_module.forward, infer.score_file

    def recording_forward(self, x):
        read.append(x.detach().clone())
        return forward(self, x)

    def recording_score_file(*arguments, **keywords):
        scored.append(score_file(*arguments, **keywords))
        return scored[-1]

    model_tcn_earlyfusion.full_module.forward = recording_forward
    infer.score_file = recording_score_file
    config = yaml.safe_load((checkout / "configs/inference_example.yaml").read_text())
    config["inference"]["device"] = "cpu"
    config["asd_mismatch"]["enabled"] = False

    for seed in args.seeds:
        read.clear()
        scored.clear()
        reports = args.output / f"reports-{seed}"
        config["paths"].update(input_dir=str(args.output / "test-file"), output_dir=str(reports),
                               checkpoint_dir=None, checkpoint=str(checkout / CHECKPOINTS[seed]))
        config_path = args.output / f"inference-{seed}.yaml"
        config_path.write_text(yaml.safe_dump(config))
        sys.argv = ["infer.py", "--config", str(config_path)]
        infer.main()

        name = f"attengw-{seed}"
        np.save(args.output / f"{name}.input.npy", torch.cat(read).numpy())
        samples = [int(s) for s in re.findall(r"sample index: (\d+)", (reports / REPORT).read_text())]
        edge = yaml.safe_load(((checkout / CHECKPOINTS[seed]).parent / "config.yaml").read_text())["training"]["edge_buffer"]
        triggers = config["triggers"]
        stats = statistics(infer, *scored[0], samples, int(triggers["smoothed_max"]["smooth_samples"]),
                           int(round(float(triggers["merge_tolerance_s"]) * rate)), int(edge))
        with h5py.File(args.output / f"{name}.triggers.hdf", "w") as handle:
            handle.create_dataset("time", data=np.array([start + sample / rate for sample in samples]))
            handle.create_dataset("stat", data=np.array(stats, dtype=np.float64))
            handle.create_dataset("var", data=np.full(len(samples), float(config["classification"]["event_tolerance_s"])))
        print(f"{name}: the author's input ({sum(len(x) for x in read)} windows) and {len(samples)} triggers written")


def statistics(infer, predictions, starts, samples, smooth, tolerance, edge):
    """Each reported trigger's statistic: the largest smoothed maximum among the
    windows whose trigger samples the author's merging joins into it."""
    found = []
    for prediction, start in zip(predictions, starts):
        smoothed = infer.moving_average_same(np.asarray(prediction, dtype=float).reshape(-1), smooth)
        peak = int(np.argmax(smoothed))
        if float(smoothed[peak]) >= THRESHOLD:
            found.append((edge + int(start) + peak, float(smoothed[peak])))
    merged = []
    for sample, score in sorted(found, key=lambda item: item[0]):
        group = [score] if not merged or sample - merged[-1][0] > tolerance else merged.pop()[1] + [score]
        merged.append((sample, group))
    assert [sample for sample, _ in merged] == samples, "the merging disagrees with the author's report"
    return [max(group) for _, group in merged]


if __name__ == "__main__":
    main()
