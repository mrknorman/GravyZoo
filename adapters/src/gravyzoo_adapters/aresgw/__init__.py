"""
AresGW model 1 of Paraskevi Nousi, Alexandra E. Koloniari, Nikolaos Passalis,
Panagiotis Iosif, Nikolaos Stergioulas and Anastasios Tefas
(github.com/vivinousi/gw-detection-deep-learning, Apache-2.0): a 54-layer residual
network behind a learned DAIN normalisation, over 1 s windows of H1 and L1 strain at
2048 Hz whitened inside the model.

The numbers below are the published search's, from the authors' entry point
``test.py`` and its ``utils/eval_utils.py`` at commit 35ff988 (its weights
``trained_models/improved_d4_model/weights.pt``). They are the one home of both the
adapter (``search``) and the card (``card``).
"""

#: The repository and commit the search and its weights are published at.
REPOSITORY, COMMIT = "vivinousi/gw-detection-deep-learning", "35ff988741adb6a01a02031b24847904da9a3c6d"

#: The weights file, by the name its card gives it, and where the authors publish it.
WEIGHTS, WEIGHTS_PATH = "aresgw/weights.pt", "trained_models/improved_d4_model/weights.pt"

#: The rate it reads strain at, and the detectors in the order its slicer stacks them
#: (the input file's groups, in order).
SAMPLE_RATE_HERTZ, DETECTORS = 2048.0, ("H1", "L1")

#: The slicer (``Slicer``, unwhitened): slices of int(6.25 x 2048) = 12800 samples,
#: one every int(5.1 / dt) = 10444 samples, as many as (samples - 12800) // 10444 (the
#: last slice that would fit is not read).
SLICE_SECONDS, SLICE_STEP_SECONDS = 6.25, 5.1

#: The time the slicer gives a slice: its start plus 0.6 s (``peak_offset``).
PEAK_OFFSET_SECONDS = 0.6

#: Where the merger sits from a window's trigger time, as the authors' training data
#: place it: ``utils/dataset.py`` line 395 draws each injection's time uniformly in 0.5
#: to 0.7 s plus 0.125 s, and lines 451-462 add the waveform (its merger 1 s into its
#: 1.25 s, ``utils/waveform_gen.py`` lines 46-48) with its merger that far into the 1.25 s
#: segment the model reads (``modules/whiten.py`` lines 141-145), which it whitens and
#: crops by 0.125 s at each end: the merger lies 0.5 to 0.7 s into the 1 s window. The
#: trigger time is that window's start plus 0.6 s (and the float32 drift, at most 0.02
#: s), so the merger is 0.1 s either side of it, the range's centre 0.
MERGER_OFFSET_SECONDS, MERGER_RANGE_SECONDS = 0.0, (-0.1, 0.1)

#: Inside the model (``CropWhitenNet``): the slice's PSD (mean Welch of 0.625 s Hann
#: segments at half overlap, interpolated to 1281 bins, inverse spectrum truncated to
#: 0.5 s, nothing below 15 Hz); windows of 2560 samples (1.25 s) every 204 samples,
#: each divided by the ASD in the frequency domain and cropped by 256 samples at each
#: end to 2048 (1 s); 51 windows per slice, the k-th given the slice's time plus
#: float32(0.1 k) and then 0.125 s.
WINDOW_SAMPLES, STEP_SAMPLES, CROP_SECONDS = 2048, 204, 0.125

#: The statistic: the softmax probability of the signal class (output 0); a window
#: above 0.5 is a trigger; triggers within 0.35 s chain into one cluster, reported at
#: its maximum with a timing tolerance of 0.5 s.
THRESHOLD, CLUSTER_SECONDS, VAR_SECONDS = 0.5, 0.35, 0.5

#: Slices per batch through the model, as ``test.py`` batches them.
BATCH_SIZE = 32
