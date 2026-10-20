"""
A released model inside gravyflow's validator, end to end: AttenGW (seed 1) in its own
environment, validated in stream mode on a short stretch of gravyflow's coloured noise
at 4096 Hz, and the validator's scores checked against the adapter's direct output on
the same strain.

Run with gravyflow's environment, its cache pointed at a temporary root that holds the
weights (``gf.fetch(card.SEED1.weights[0].file)`` puts them there):

    ZOO_ATTENGW_PYTHON=<prefix>/bin/python KERAS_BACKEND=jax GRAVYFLOW_CACHE_DIR=<root> PYTHONPATH=src \
        python -m pytest tests/test_validator_smoke.py

It is skipped when the AttenGW environment (``ZOO_ATTENGW_PYTHON``, its interpreter,
built from its lock) or the weights are absent. The adapters are installed into a
temporary directory (``pip install --target``), never into the environment.
"""

import os
import subprocess
import sys
from pathlib import Path

import numpy as np
import pytest

gf = pytest.importorskip("gravyflow")

from gravyflow.src.dataset.store.files import RemoteFileMissing, cached  # noqa: E402
from gravyflow.src.model.examples.base import ValidationDatasetConfig, validation_dataset_args  # noqa: E402
from gravyflow.src.validate import ValidationConfig, Validator  # noqa: E402

from gravyzoo_adapters.attengw import MERGE_SECONDS, THRESHOLD, card  # noqa: E402

PYTHON = Path(os.environ.get("ZOO_ATTENGW_PYTHON", "")).expanduser()
ADAPTERS = Path(__file__).resolve().parents[1]


def merged(time, stat, tolerance_seconds):
    """The published merging of window maxima at or above the threshold: within the
    tolerance of the one before, one trigger, at the latest, with the largest score."""
    triggers = []
    for t, s in sorted((t, s) for t, s in zip(time, stat) if s >= THRESHOLD):
        if triggers and t - triggers[-1][0] <= tolerance_seconds + 1e-9:
            triggers[-1] = (t, max(s, triggers[-1][1]))
        else:
            triggers.append((t, s))
    return np.array([t for t, _ in triggers]), np.array([s for _, s in triggers])


class Spy(gf.ExternalRunner):
    calls = []

    def scores(self, segments):
        found = super().scores(segments)
        type(self).calls.append(list(zip(segments, found)))
        return found


@pytest.fixture(scope="module")
def runner(tmp_path_factory):
    if not PYTHON.is_file():
        pytest.skip(f"No AttenGW environment's interpreter at ZOO_ATTENGW_PYTHON ({str(PYTHON)!r}).")
    try:
        cached(card.SEED1.weights[0].file)
    except RemoteFileMissing:
        pytest.skip("AttenGW seed 1's weights are not in gravyflow's cache.")
    site = tmp_path_factory.mktemp("site")
    subprocess.run([str(PYTHON), "-m", "pip", "install", "--quiet", "--no-deps", "--no-build-isolation",
                    "--no-cache-dir", "--target", str(site), str(ADAPTERS)], check=True)
    scratch = tmp_path_factory.mktemp("scratch")
    return Spy(card.SEED1, gf.AdapterEnvironment(PYTHON, card.LOCK, (site,)), 900, scratch)


def test_attengw_in_the_validator_scores_as_its_adapter_does(runner, tmp_path):
    args = validation_dataset_args(config=ValidationDatasetConfig(
        sample_rate_hertz=card.SAMPLE_RATE_HERTZ, ifos=[gf.IFO.H1, gf.IFO.L1]))
    # Eight windows of background on the stride's grid (about 19 s of strain), eight
    # injections and two of the volume set, in a 48 s stream.
    config = ValidationConfig(num_examples=8, batch_size=4, snr_range=(20.0, 40.0), volume_num_injections=2,
                              stream_segment_seconds=48.0)
    Spy.calls.clear()
    v = Validator.validate(runner, "attengw-seed1", args, config, tmp_path / "validation.h5")
    assert v.model_sha256 == card.SEED1.fingerprint and float(v.noise_streams["stride_seconds"]) == 0.25
    assert [len(call) for call in Spy.calls] == [1, 4, 4, 2]
    background, injections = Spy.calls[0], [pair for call in Spy.calls[1:3] for pair in call]
    assert v.efficiency_data["scores"].shape == (8,)

    # The background: the validator's scores are the adapter's, window for window, on the
    # stream's strain (detectors in the card's order), and the published search's triggers
    # on that strain are its windows at or above the threshold, merged as published.
    stats = []
    for segment, scored in background:
        assert segment.detectors == card.DETECTORS
        (again,) = gf.ExternalRunner.scores(runner, [segment])
        np.testing.assert_array_equal(again.stat, scored.stat)
        published = runner.search(segment).triggers
        time, stat = merged(scored.time, scored.stat, MERGE_SECONDS)
        np.testing.assert_allclose(published.time, time, rtol=0, atol=1e-9)
        np.testing.assert_array_equal(published.stat, stat)
        stats.append(scored.stat)
    np.testing.assert_array_equal(v.far_scores, np.concatenate(stats))

    # The injections: each stretch's scores, and the published search's triggers there.
    triggered = 0
    for segment, scored in injections:
        published = runner.search(segment).triggers
        time, stat = merged(scored.time, scored.stat, MERGE_SECONDS)
        np.testing.assert_allclose(published.time, time, rtol=0, atol=1e-9)
        np.testing.assert_array_equal(published.stat, stat)
        triggered += len(published.time) > 0
    print(f"AttenGW seed 1: {v.far_scores.size} background windows (max {v.far_scores.max():.6f}); injection "
          f"scores {np.round(v.efficiency_data['scores'], 6).tolist()} at SNRs "
          f"{np.round(v.efficiency_data['snrs'], 1).tolist()}; {triggered} of 8 stretches with published triggers",
          file=sys.stderr)
