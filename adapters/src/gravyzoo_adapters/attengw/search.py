"""
AttenGW as an ``ExternalSearch``: the test-data PSD of the author's downloader, the
whitening, windows and normalisation of the inference entry point
(``inference/infer.py``, ``score_file``), the author's network (``published``), and
the ``smoothed_max`` trigger at the paper's threshold, over a whole segment held in
memory rather than a downloaded file. One class per seeded copy (``CHECKPOINTS``).

The author's reports give each trigger's time only. The statistic this adapter gives
a trigger is the largest smoothed maximum among the windows merged into it: every
trigger has one at or above the threshold, so ranking by it keeps the published
triggers of every threshold above this one, as far as their merging allows.

Runs in the AttenGW environment (PyTorch and SciPy, from its lock).
"""

import numpy as np
import scipy.interpolate
import torch
from scipy.signal import welch

from .._common import Triggers
from . import (
    BAND_HERTZ, BATCH_SIZE, CHECKPOINTS, CONTEXT_SECONDS, DETECTORS, EDGE_SAMPLES, MERGE_SECONDS, OFFSETS,
    PSD_FLOOR, PSD_OUTBAND, PSD_SECONDS, SMOOTH_SAMPLES, STRIDE_SAMPLES, THRESHOLD, VAR_SECONDS, WINDOW_SAMPLES,
)
from .published.model_tcn_earlyfusion import full_module


def psd(strain, rate):
    """The PSD the downloader stores with test data: its frequencies and values."""
    strain = strain - np.mean(strain)
    length = min(int(PSD_SECONDS * rate), len(strain))
    return welch(strain, fs=rate, window="hann", nperseg=length, noverlap=length // 2, detrend="constant",
                 scaling="density", average="median")


def band_limited(frequencies, values):
    """The PSD as whitening reads it: a function of frequency."""
    interpolated = scipy.interpolate.interp1d(frequencies, values, bounds_error=False,
                                              fill_value=(values[0], values[-1]))

    def read(f):
        f = np.asarray(f)
        out = np.maximum(interpolated(f), PSD_FLOOR)
        outside = (f < BAND_HERTZ[0]) | (f > BAND_HERTZ[1])
        return np.where(outside, PSD_OUTBAND, out) if outside.any() else out

    return read


def whiten(strain, read_psd, dt):
    """``whiten.whiten`` of the author's data generator."""
    hf = np.fft.rfft(strain)
    values = np.maximum(read_psd(np.fft.rfftfreq(len(strain), dt)), PSD_FLOOR)
    return np.fft.irfft(hf / np.sqrt(values) * (1.0 / np.sqrt(1.0 / (dt * 2))), n=len(strain))


def window_starts(length):
    """Every window start of every offset's grid, after the edge (``all_window_starts``)."""
    last = length - 2 * EDGE_SAMPLES - WINDOW_SAMPLES
    if last < 0:
        return np.array([], dtype=int)
    starts = {start for offset in OFFSETS if offset <= last for start in range(offset, last + 1, STRIDE_SAMPLES)}
    return np.asarray(sorted(starts), dtype=int)


def context_start(start, end, length, context):
    """Where a window's whitening context starts, or None (``choose_context_start``)."""
    earliest, latest = end + EDGE_SAMPLES - context, start - EDGE_SAMPLES
    if earliest > latest or length < context:
        return None
    centred = int(round(0.5 * (start + end - context)))
    chosen = max(0, min(max(earliest, min(centred, latest)), length - context))
    return chosen if earliest <= chosen <= latest else None


def normalise(windows):
    """Each detector's window centred, both scaled by their shared RMS, as float32
    (``normalize_window``)."""
    windows = [np.asarray(w, dtype=np.float64).copy() for w in windows]
    for w in windows:
        w -= np.mean(w)
    scale = np.sqrt(0.5 * sum(np.var(w) for w in windows)) + 1e-8
    return [(w / scale).astype(np.float32) for w in windows]


def smoothed_maximum(prediction):
    """A window's ``smoothed_max``: its peak sample and score."""
    values = np.asarray(prediction, dtype=float)
    width = SMOOTH_SAMPLES + 1 - SMOOTH_SAMPLES % 2
    if len(values) < width:
        width = len(values) if len(values) % 2 else max(1, len(values) - 1)
    smoothed = values if width <= 1 else np.convolve(values, np.ones(width) / width, mode="same")
    peak = int(np.argmax(smoothed))
    return peak, float(smoothed[peak])


class _AttenGW:
    """One seeded copy of AttenGW; a subclass names its ``seed``."""

    seed = None

    def prepare(self, fetch):
        weights, _ = CHECKPOINTS[self.seed]
        checkpoint = torch.load(fetch(weights), map_location="cpu", weights_only=True)
        model = full_module()
        model.load_state_dict({key[len("model."):]: value for key, value in checkpoint["state_dict"].items()},
                              strict=True)
        self.model = model.eval()

    def _batches(self, segment):
        """Each batch of windows the network reads, (windows, samples, detectors)
        float32, and the samples their scores start at."""
        rate = segment.sample_rate_hertz
        strain = [segment[d] for d in DETECTORS]
        psds = [band_limited(*psd(s, rate)) for s in strain]
        context = int(round(CONTEXT_SECONDS * rate))
        length = len(strain[0])
        starts = window_starts(length)
        for i in range(0, len(starts), BATCH_SIZE):
            windows, firsts = [], []
            for start in starts[i:i + BATCH_SIZE]:
                first = EDGE_SAMPLES + int(start)
                begin = context_start(first, first + WINDOW_SAMPLES, length, context)
                if begin is None:
                    continue
                local = first - begin
                white = [whiten(s[begin:begin + context], p, 1.0 / rate)[local:local + WINDOW_SAMPLES]
                         for s, p in zip(strain, psds)]
                if any(len(w) != WINDOW_SAMPLES for w in white):
                    continue
                windows.append(normalise(white))
                firsts.append(first)
            if windows:
                inputs = np.stack([np.stack([w[d] for w in windows]) for d in range(len(DETECTORS))],
                                  axis=-1).astype(np.float32)
                inputs -= inputs.mean(axis=1, keepdims=True)
                yield inputs, firsts

    def preprocess(self, segment):
        """The windows the network reads: (windows, samples, detectors), float32."""
        found = [inputs for inputs, _ in self._batches(segment)]
        return np.concatenate(found) if found else np.zeros((0, WINDOW_SAMPLES, len(DETECTORS)), np.float32)

    def search(self, segment):
        found = []
        for inputs, firsts in self._batches(segment):
            with torch.inference_mode():
                scores = self.model(torch.from_numpy(inputs)).numpy().reshape(len(inputs), -1)
            for prediction, first in zip(scores, firsts):
                peak, score = smoothed_maximum(prediction)
                if score >= THRESHOLD:
                    found.append((first + peak, score))
        return merge(found, int(round(MERGE_SECONDS * segment.sample_rate_hertz)), segment)


def merge(found, tolerance, segment):
    """Trigger samples in order, each within ``tolerance`` of the one before it joining
    its trigger, which is kept at its latest sample (``merge_trigger_samples``) with the
    largest score among them."""
    triggers = []
    for sample, score in sorted(found, key=lambda item: item[0]):
        if triggers and sample - triggers[-1][0] <= tolerance:
            triggers[-1] = (sample, max(score, triggers[-1][1]))
        else:
            triggers.append((sample, score))
    times = np.array([segment.t0 + sample / segment.sample_rate_hertz for sample, _ in triggers])
    return Triggers(times, np.array([score for _, score in triggers]), np.full(len(triggers), VAR_SECONDS))


class Seed1(_AttenGW):
    """``train_job_21247765``."""
    seed = "seed1"


class Seed2(_AttenGW):
    """``train_job_21287149``."""
    seed = "seed2"


class Seed3(_AttenGW):
    """``train_job_21364665``."""
    seed = "seed3"


class Seed4(_AttenGW):
    """``train_job_21372515``."""
    seed = "seed4"
