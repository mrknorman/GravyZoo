"""
What the adapters share, in their own environments: the triggers a search returns,
the windows it slides over a segment, and the clustering the published searches
apply. Standard library and numpy only.
"""

from collections import namedtuple

import numpy as np

#: A search's triggers, as ``gravyflow.external`` reads them: time, stat and var.
Triggers = namedtuple("Triggers", ("time", "stat", "var"))


def windows(strain, length, step):
    """
    The windows of ``length`` samples of ``strain`` (detectors, samples), one every
    ``step`` samples from the first, while a whole window fits: an array (windows,
    detectors, length) viewing ``strain``.
    """
    view = np.lib.stride_tricks.sliding_window_view(strain, length, axis=-1)[:, ::step]
    return view.transpose(1, 0, 2)


def window_times(start, step_seconds, count, offset):
    """
    The time of each of ``count`` windows: ``start`` advanced by ``step_seconds``
    once per window, as a running float64 sum (as the published loops keep it), plus
    ``offset``.
    """
    steps = np.full(count, step_seconds, dtype=np.float64)
    steps[0] = start
    return np.cumsum(steps) + offset if count else np.zeros(0)


def cluster(times, stats, window_seconds, var):
    """
    The published clustering: triggers in time order, each one more than
    ``window_seconds`` after the one before it starts a new cluster; a cluster is
    reported at its largest statistic (its first, on a tie), with timing tolerance
    ``var``.
    """
    times = np.asarray(times, dtype=np.float64)
    stats = np.asarray(stats)
    if not len(times):
        return Triggers(np.zeros(0), np.zeros(0), np.zeros(0))
    starts = np.flatnonzero(np.diff(times) > window_seconds) + 1
    peaks = np.array([part[np.argmax(stats[part])] for part in np.split(np.arange(len(times)), starts)])
    return Triggers(times[peaks], stats[peaks].astype(np.float64), np.full(len(peaks), float(var)))
