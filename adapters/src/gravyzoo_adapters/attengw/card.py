"""
AttenGW's cards, one per seeded copy, for gravyflow's external-model runner (imported
where gravyflow is, never in the AttenGW environment): ``SEED1`` to ``SEED4``, in
``CARDS`` by name; ``ENVIRONMENT`` is the environment they run in, and ``LOCK`` its
lock file.
"""

import gravyflow as gf
from gravyflow.src.dataset.store.files import RemoteFile
from gravyflow.src.external.card import HIGHER

from ..environments import ADAPTER_VERSION, PYTORCH_2_14 as ENVIRONMENT
from . import (
    BAND_HERTZ, CHECKPOINTS, COMMIT, CONTEXT_SECONDS, DETECTORS, EDGE_SAMPLES, MERGE_SECONDS,
    MERGER_OFFSET_SECONDS, MERGER_RANGE_SECONDS, OFFSETS, PSD_FLOOR, PSD_OUTBAND, PSD_SECONDS, REPOSITORY, SAMPLE_RATE_HERTZ, SMOOTH_SAMPLES, THRESHOLD, WINDOW_SAMPLES,
)

LOCK = ENVIRONMENT.lock

#: Each checkpoint's sha256 and size, as the author publishes it at ``COMMIT``.
_PINS = {
    "seed1": ("b5f4981759893fefe0e9d7178261098855cb491aa4c50d76d33a0e731ece005d", 1531631),
    "seed2": ("89b69377be46a9be77b99d4fd3f4df8c18c0f14486fbed00b48f727c2c71ec6a", 1528129),
    "seed3": ("a451dc5aba470db3c4b0e2e6ac7e2dccfa999235a3c9b0751dfe0116a28d7ae4", 1521507),
    "seed4": ("d8597ede484616502592c90cb489069a1d4d12bb02d41feabb7a1ae482b376d1", 1529275),
}

_WHITENING = (
    f"PSD of the whole segment per detector (SciPy Welch, mean removed, {PSD_SECONDS:g} s Hann segments, half "
    f"overlapping, median), interpolated linearly, floored at {PSD_FLOOR:g}, {PSD_OUTBAND:g} outside "
    f"{BAND_HERTZ[0]:g} to {BAND_HERTZ[1]:g} Hz; each window whitened in a {CONTEXT_SECONDS:g} s context centred on "
    f"it (shifted to fit the segment) by dividing its FFT by the ASD, times sqrt(2 dt); windows start after a "
    f"{EDGE_SAMPLES}-sample edge, on each of the offsets {list(OFFSETS)}'s {WINDOW_SAMPLES}-sample grids")

_OUTPUT = gf.OutputContract(
    f"smoothed_max: a window's per-sample sigmoid score, smoothed by a {SMOOTH_SAMPLES + 1}-sample moving average, "
    f"at its maximum; a trigger carries the largest among the windows merged into it (the author's reports give "
    f"trigger times only); it is timed at the maximum's sample, merged triggers at the latest",
    signal_column=0, direction=HIGHER, threshold=THRESHOLD, cluster_seconds=MERGE_SECONDS,
    time_offset_seconds=0.0,
    # The merger 0 to 0.25 s after the trigger sample, as the author's training targets place it.
    merger_offset_seconds=MERGER_OFFSET_SECONDS, merger_range_seconds=MERGER_RANGE_SECONDS)

_TRAINING = (
    "As the author declares it (arXiv:2512.12513; checkpoints/*/config.yaml): real O3b H1 and L1 noise, "
    "December 2019 to January 2020, with IMRPhenom binary black hole (aligned and precessing) and NSBH "
    "injections, 800,000 training and 50,000 validation samples, noise-only samples with probability 0.65, an "
    "SNR curriculum from [10, 25] to [3, 10]; held-out test data from 28 January to 29 February 2020.")

_PUBLISHED = (
    gf.PublishedRow("tiki2025 (arXiv:2512.12513), abstract and Sec. 3", "O3b, H1 and L1 (10,000 BBH injections)",
                    "median sensitive volume of the four copies at the smoothed_max threshold 0.9999", 5.4, "Gpc^3"),
    gf.PublishedRow("tiki2025 (arXiv:2512.12513), abstract and Sec. 3", "O3b, H1 and L1 (shifted-noise background)",
                    "median false-alarm rate of the four copies at the smoothed_max threshold 0.9999", 20.5,
                    "per year"),
)


def _card(seed):
    weights, path = CHECKPOINTS[seed]
    sha256, size = _PINS[seed]
    file = RemoteFile(weights, f"https://raw.githubusercontent.com/{REPOSITORY}/{COMMIT}/{path}", sha256, size,
                      licence="MIT", redistributable=True)
    return gf.ExternalCard(
        name=f"attengw-{seed}", adapter=f"attengw-{seed}", adapter_version=ADAPTER_VERSION,
        environment_lock=ENVIRONMENT.sha256,
        input=gf.InputContract(
            SAMPLE_RATE_HERTZ, DETECTORS, window_seconds=WINDOW_SAMPLES / SAMPLE_RATE_HERTZ,
            stride_seconds=(OFFSETS[1] - OFFSETS[0]) / SAMPLE_RATE_HERTZ, whitening=_WHITENING,
            context_seconds=CONTEXT_SECONDS - WINDOW_SAMPLES / SAMPLE_RATE_HERTZ,
            band_pass_hertz=BAND_HERTZ,
            normalisation="each detector's whitened window centred, both divided by their shared RMS (+1e-8), "
                          "cast to float32 and centred again"),
        output=_OUTPUT,
        weights=(gf.Weights(file, format="lightning-checkpoint", framework=ENVIRONMENT.framework),),
        training_data=_TRAINING,
        published=_PUBLISHED,
    )


#: Every AttenGW card, by name.
CARDS = {card.name: card for card in map(_card, CHECKPOINTS)}

SEED1, SEED2, SEED3, SEED4 = CARDS.values()
