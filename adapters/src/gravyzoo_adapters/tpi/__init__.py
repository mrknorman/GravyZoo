"""
The TPI FSU Jena search of Ondřej Zelenka, Bernd Brügmann and Frank Ohme
(github.com/ondrzel/ml-gw-search, Apache-2.0): a coherent two-detector CNN over 1 s
windows of whitened H1 and L1 strain at 2048 Hz.

Two releases of its weights: the original submission (``mlgwsc-1/best_state_dict.pt``,
whose network opens with a batch normalisation of its input) and the six corrected
runs R1 to R6 (``correction/state_dicts``, the same network without it), R1 the
authors' final algorithm (arXiv:2402.07492).

The numbers below are the published search's, each from the authors' ``apply.py``
(``mlgwsc-1/apply.py`` at commit a33ba6b; ``correction/apply.py`` differs from it
only by the batch normalisation). They are the one home of both the adapter
(``search``) and the card (``card``).
"""

#: The repository and commit the search and its weights are published at.
REPOSITORY, COMMIT = "ondrzel/ml-gw-search", "a33ba6be5069bc823c95cff073b506cfddb24421"

#: The rate it reads strain at, and the detectors it stacks, in order.
SAMPLE_RATE_HERTZ, DETECTORS = 2048.0, ("H1", "L1")

#: Whitening (``whiten``): a Welch PSD of the whole segment in 0.5 s segments (PyCBC's
#: ``TimeSeries.psd``: half-overlapping Hann windows, median average), interpolated to
#: the segment's resolution, its inverse truncated to 0.25 s with a Hann taper, no
#: power at or below 20 Hz; the segment divided by the ASD in the frequency domain,
#: and the 0.125 s the filter corrupts cut from each end.
PSD_SECONDS, FILTER_SECONDS, LOW_FREQUENCY_CUTOFF_HERTZ = 0.5, 0.25, 20.0

#: What the whitening cuts from each end of the segment, as the slicer counts it.
EDGE_SECONDS = 0.125

#: Windows of 2048 samples (1 s), one every int(0.1 s x 2048) = 204 samples.
WINDOW_SAMPLES, STEP_SAMPLES = 2048, 204

#: A window's trigger time is its start plus 0.6 s (the slicer's ``peak_offset``).
PEAK_OFFSET_SECONDS = 0.6

#: The statistic (the default of ``apply.py``, its "unbounded softmax replacement"):
#: the network's output 0 less its output 1, no softmax; a window above -8 is a
#: trigger; triggers within 0.35 s chain into one cluster, reported at its maximum
#: with a timing tolerance of 0.2 s.
THRESHOLD, CLUSTER_SECONDS, VAR_SECONDS = -8.0, 0.35, 0.2

#: Windows per batch through the network, as ``evaluate_slices`` batches them.
BATCH_SIZE = 512

#: Each release's weights file, by the name its card gives it, and where the authors
#: publish it; and whether its network opens with a batch normalisation.
RELEASES = {
    "original": ("tpi/best_state_dict.pt", "mlgwsc-1/best_state_dict.pt", True),
    **{f"r{run}": (f"tpi/{name}", f"correction/state_dicts/{name}", False)
       for run, name in enumerate(("R1_0021.pt", "R2_0150.pt", "R3_0036.pt", "R4_0038.pt", "R5_0193.pt",
                                   "R6_0026.pt"), start=1)},
}
