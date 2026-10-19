"""
The oracles: a card's adapter, run through gravyflow's external-model runner on the
oracle's segment, against the authors' own code on the same samples
(``authors_<model>.py``).

1. Input: the adapter's ``preprocess`` equals the input the authors' code feeds their
   network, bitwise, or within the tolerance the card's module states.
2. Triggers: the adapter's triggers equal those of the authors' entry point: the same
   count, the times exactly, the statistic to float32 precision (``STAT_ULPS`` units in
   the last place of float32 at the statistic's magnitude), the tolerances exactly.

Each oracle prints one line, ``<card> <ORACLE> PASS ...`` or ``... FAIL ...``; the
exit status is the number that failed. Run with gravyflow's environment, its cache
pointed at a temporary root (the weights are fetched there from the authors' source):

    python compare.py <card module> <environment python> <adapter site> <segment.npz> <authors' directory> <card>...
"""

import argparse
import importlib
import sys
import tempfile
import time
from pathlib import Path

import numpy as np

import gravyflow as gf

#: How far the adapter's statistic may sit from the authors', in float32 units in the
#: last place at the statistic's magnitude.
STAT_ULPS = 4

#: Seconds each runner call may take.
DEADLINE_SECONDS = 480


def compare_input(name, ours, theirs, tolerance):
    if ours.shape != theirs.shape or ours.dtype != theirs.dtype:
        return f"{name} INPUT FAIL: shape {ours.shape} {ours.dtype}, the authors' {theirs.shape} {theirs.dtype}"
    difference = float(np.max(np.abs(ours.astype(np.float64) - theirs.astype(np.float64)))) if ours.size else 0.0
    scale = float(np.max(np.abs(theirs))) if theirs.size else 0.0
    if np.array_equal(ours, theirs):
        return f"{name} INPUT PASS: bitwise equal, {ours.shape} {ours.dtype}"
    verdict = "PASS" if difference <= tolerance * scale else "FAIL"
    return (f"{name} INPUT {verdict}: {ours.shape} {ours.dtype}, max |difference| {difference:.3g} = "
            f"{difference / scale:.3g} of the largest |value| (tolerance {tolerance:g})")


def compare_triggers(name, ours, theirs):
    count = len(theirs.time)
    if len(ours.time) != count:
        return (f"{name} TRIGGERS FAIL: {len(ours.time)} triggers, the authors' {count}; ours at "
                f"{np.round(ours.time, 4).tolist()}, theirs at {np.round(theirs.time, 4).tolist()}")
    ulp = np.spacing(np.abs(theirs.stat).astype(np.float32)).astype(np.float64)
    stat = np.abs(ours.stat - theirs.stat)
    checks = {"times": np.array_equal(ours.time, theirs.time), "var": np.array_equal(ours.var, theirs.var),
              "stat": bool(np.all(stat <= STAT_ULPS * ulp))}
    verdict = "PASS" if all(checks.values()) else "FAIL"
    failed = [check for check, ok in checks.items() if not ok]
    return (f"{name} TRIGGERS {verdict}: {count} triggers, times {'exact' if checks['times'] else 'DIFFER'}, "
            f"max |stat difference| {float(stat.max()) if count else 0.0:.3g} "
            f"({float((stat / ulp).max()) if count else 0.0:.2g} float32 ulps), var "
            f"{'exact' if checks['var'] else 'DIFFERS'}" + (f"; failed: {failed}" if failed else ""))


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("module", help="The cards' module, e.g. gravyzoo_adapters.tpi.card.")
    parser.add_argument("python", type=Path, help="The model environment's interpreter.")
    parser.add_argument("site", type=Path, help="Where the adapters are installed (pip install --target).")
    parser.add_argument("segment", type=Path)
    parser.add_argument("authors", type=Path)
    parser.add_argument("cards", nargs="+", help="The cards' names in the module, e.g. R1.")
    args = parser.parse_args()
    module = importlib.import_module(args.module)
    tolerance = getattr(module, "INPUT_TOLERANCE", 0.0)

    with np.load(args.segment) as arrays:
        strains = dict(zip(arrays["detectors"].tolist(), arrays["strain"]))
        t0, rate = float(arrays["t0"]), float(arrays["sample_rate_hertz"])
    lines = []
    for card in (getattr(module, name) for name in args.cards):
        # The detectors in the order the card's model stacks them.
        segment = gf.SearchSegment(np.stack([strains[d] for d in card.input.detectors]), card.input.detectors,
                                   t0, rate)
        with tempfile.TemporaryDirectory(prefix="oracle-") as scratch:
            runner = gf.ExternalRunner(card, gf.AdapterEnvironment(args.python, module.LOCK, (args.site,)),
                                       DEADLINE_SECONDS, scratch)
            lines.append(compare_input(card.name, runner.preprocess(segment),
                                       np.load(args.authors / f"{card.name}.input.npy"), tolerance))
            started = time.monotonic()
            result = runner.search(segment)
            wall = time.monotonic() - started
            lines.append(compare_triggers(card.name, result.triggers,
                                          gf.Triggers.read(args.authors / f"{card.name}.triggers.hdf")))
        lines.append(f"{card.name} SEARCH WALL {wall:.1f} s for {segment.duration_seconds:g} s of strain "
                     f"(runner, one process: start, weights, search); fingerprint {card.fingerprint}")
        print("\n".join(lines[-3:]), flush=True)
    return sum(" FAIL" in line for line in lines)


if __name__ == "__main__":
    sys.exit(main())
