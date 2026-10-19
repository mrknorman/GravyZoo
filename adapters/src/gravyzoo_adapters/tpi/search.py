"""
The TPI FSU Jena search as an ``ExternalSearch``: the authors' whitening, slicing,
network, statistic and clustering (``apply.py``), over a whole segment held in memory
rather than a challenge file. One class per release of the weights (``RELEASES``),
each published under its own entry point.

Runs in the TPI environment (PyTorch and PyCBC, from ``osx-arm64.lock``).
"""

import numpy as np
import torch
from pycbc.psd import interpolate, inverse_spectrum_truncation
from pycbc.types import TimeSeries

from .._common import cluster, window_times, windows
from . import (
    BATCH_SIZE, CLUSTER_SECONDS, DETECTORS, EDGE_SECONDS, FILTER_SECONDS, LOW_FREQUENCY_CUTOFF_HERTZ,
    PEAK_OFFSET_SECONDS, PSD_SECONDS, RELEASES, STEP_SAMPLES, THRESHOLD, VAR_SECONDS, WINDOW_SAMPLES,
)


def network(batch_norm):
    """The authors' network (``get_base_network`` for two detectors), its layers in
    their order so their state dictionaries load; with or without the opening batch
    normalisation of the original submission."""
    nn = torch.nn
    d = len(DETECTORS)
    return nn.Sequential(*([nn.BatchNorm1d(d)] if batch_norm else []),
        nn.Conv1d(d, 8 * d, 33), nn.ELU(),
        nn.Conv1d(8 * d, 8 * d, 32), nn.ELU(),
        nn.Conv1d(8 * d, 8 * d, 17), nn.ELU(),
        nn.Conv1d(8 * d, 8 * d, 16), nn.MaxPool1d(4), nn.ELU(),
        nn.Conv1d(8 * d, 8 * d, 17), nn.ELU(),
        nn.Conv1d(8 * d, 16 * d, 16), nn.ELU(),
        nn.Conv1d(16 * d, 16 * d, 9), nn.ELU(),
        nn.Conv1d(16 * d, 16 * d, 8), nn.MaxPool1d(3), nn.ELU(),
        nn.Conv1d(16 * d, 16 * d, 9), nn.ELU(),
        nn.Conv1d(16 * d, 32 * d, 8), nn.ELU(),
        nn.Conv1d(32 * d, 32 * d, 9), nn.ELU(),
        nn.Conv1d(32 * d, 32 * d, 8), nn.MaxPool1d(2), nn.ELU(),
        nn.Flatten(),
        nn.Linear(1856 * d, 64 * d), nn.Dropout(p=0.5), nn.ELU(),
        nn.Linear(64 * d, 64 * d), nn.Dropout(p=0.5), nn.ELU(),
        nn.Linear(64 * d, 2),
    )


def whiten(strain, sample_rate_hertz):
    """One detector's strain whitened as the authors' ``whiten`` does it (float64),
    the corrupted ``FILTER_SECONDS / 2`` cut from each end."""
    series = TimeSeries(strain, delta_t=1.0 / sample_rate_hertz)
    filter_samples = int(FILTER_SECONDS * series.sample_rate)
    psd = interpolate(series.psd(PSD_SECONDS), series.delta_f)
    psd = inverse_spectrum_truncation(psd, max_filter_len=filter_samples,
                                      low_frequency_cutoff=LOW_FREQUENCY_CUTOFF_HERTZ, trunc_method="hann")
    white = (series.to_frequencyseries() * (1.0 / psd) ** 0.5).to_timeseries().numpy()
    return white[filter_samples // 2:len(series) - filter_samples // 2]


class _TPI:
    """One release of the TPI search; a subclass names its ``release``."""

    release = None

    def prepare(self, fetch):
        weights, _, batch_norm = RELEASES[self.release]
        model = network(batch_norm)
        model.load_state_dict(torch.load(fetch(weights), map_location="cpu"))
        self.model = model.to(dtype=torch.float32).eval()

    def _windows(self, segment):
        white = np.stack([whiten(segment[d], segment.sample_rate_hertz) for d in DETECTORS])
        return windows(white, WINDOW_SAMPLES, STEP_SAMPLES)

    def preprocess(self, segment):
        """The windows the network reads: (windows, detectors, samples), float32."""
        return np.ascontiguousarray(self._windows(segment), dtype=np.float32)

    def search(self, segment):
        found = self._windows(segment)
        # Each batch contiguous, as the authors' loader stacks it: the batch
        # normalisation's kernel rounds differently over a strided view.
        with torch.no_grad():
            outputs = [self.model(torch.from_numpy(np.ascontiguousarray(found[i:i + BATCH_SIZE], dtype=np.float32)))
                       for i in range(0, len(found), BATCH_SIZE)]
        outputs = torch.cat(outputs).numpy() if outputs else np.zeros((0, 2), np.float32)
        stats = outputs[:, 0] - outputs[:, 1]
        times = window_times(segment.t0 + EDGE_SECONDS, STEP_SAMPLES * (1.0 / segment.sample_rate_hertz),
                             len(found), PEAK_OFFSET_SECONDS)
        above = stats > THRESHOLD
        return cluster(times[above], stats[above], CLUSTER_SECONDS, VAR_SECONDS)


class Original(_TPI):
    """The original submission (``mlgwsc-1/best_state_dict.pt``)."""
    release = "original"


class R1(_TPI):
    """Corrected run R1 (``R1_0021.pt``), the authors' final algorithm."""
    release = "r1"


class R2(_TPI):
    release = "r2"


class R3(_TPI):
    release = "r3"


class R4(_TPI):
    release = "r4"


class R5(_TPI):
    release = "r5"


class R6(_TPI):
    release = "r6"
