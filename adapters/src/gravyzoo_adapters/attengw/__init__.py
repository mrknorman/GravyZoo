"""
AttenGW of Victoria Tiki and Eliu Huerta (github.com/victoria-tiki/AttenGW, MIT): an
early-fusion temporal convolutional network that scores every sample of 1 s windows
of whitened L1 and H1 strain at 4096 Hz. Four copies were trained from different
seeds (``checkpoints/train_job_*``, the same configuration each), and the paper
reports each.

The numbers below are the published search's, from the author's inference entry
point ``inference/infer.py``, the training configuration stored with each checkpoint
(``config.yaml``, one for all four), the example inference configuration
(``configs/inference_example.yaml``) and the test-data path of ``downloader.py``, at
commit 4ffe6ab. They are the one home of both the adapter (``search``) and the card
(``card``).
"""

#: The repository and commit the search and its weights are published at.
REPOSITORY, COMMIT = "victoria-tiki/AttenGW", "4ffe6ab68869c4a86650ee2ecb0dc50f9334a2ee"

#: Each seeded copy's checkpoint, by its card's name for it, and where the author
#: publishes it.
CHECKPOINTS = {
    f"seed{index}": (f"attengw/{job}.ckpt", f"checkpoints/train_job_{job}/{name}")
    for index, (job, name) in enumerate((
        ("21247765", "model_attenGW-epoch=60-val_loss=0.01753.ckpt"),
        ("21287149", "model_attenGW-epoch=51-val_loss=0.01707.ckpt"),
        ("21364665", "model_attenGW-epoch=34-val_loss=0.01723.ckpt"),
        ("21372515", "model_attenGW-epoch=54-val_loss=0.01722.ckpt"),
    ), start=1)
}

#: The rate it reads strain at, and the detectors in the order it stacks them.
SAMPLE_RATE_HERTZ, DETECTORS = 4096.0, ("L1", "H1")

#: The PSD the test data carry (``downloader.estimate_psd``, test path): a Welch
#: estimate of the whole segment, its mean removed, in 4 s Hann segments at half
#: overlap, median average.
PSD_SECONDS = 4.0

#: The PSD as whitening reads it (``GWDataset._make_band_limited_psd``): interpolated
#: linearly (held at its end values outside its grid), floored at 1e-48, and 1e40
#: outside 25 to 450 Hz.
BAND_HERTZ, PSD_FLOOR, PSD_OUTBAND = (25.0, 450.0), 1e-48, 1e40

#: Windows (``score_file``): 4096 samples, starting after a 2048-sample edge, at every
#: start of each offset's 4096-sample grid (one every 1024 samples); each whitened in
#: an 8 s context centred on it (shifted to fit the segment), centred per detector,
#: both scaled by their shared RMS, cast to float32 and centred again in time.
WINDOW_SAMPLES, EDGE_SAMPLES, CONTEXT_SECONDS = 4096, 2048, 8.0
STRIDE_SAMPLES, OFFSETS = 4096, (0, 1024, 2048, 3072)

#: Windows per batch through the network.
BATCH_SIZE = 32

#: The trigger (``smoothed_max``, at the paper's preselected threshold): a window's
#: per-sample score smoothed by a 65-sample moving average (64, made odd), its
#: maximum; a window at or above 0.9999 triggers at that sample; trigger samples within
#: 0.25 s chain into one, kept at its latest sample. A trigger counts within 0.5 s of an
#: event (``classification.event_tolerance_s``).
SMOOTH_SAMPLES, THRESHOLD, MERGE_SECONDS, VAR_SECONDS = 64, 0.9999, 0.25, 0.5
