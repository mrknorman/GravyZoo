"""
AresGW model 1's card, for gravyflow's external-model runner (imported where
gravyflow is, never in the AresGW environment): ``MODEL1``, in ``CARDS`` by name;
``ENVIRONMENT`` is the environment it runs in, and ``LOCK`` its lock file.
"""

import gravyflow as gf
from gravyflow.src.dataset.store.files import RemoteFile
from gravyflow.src.external.card import HIGHER

from ..environments import ADAPTER_VERSION, PYTORCH_1_13 as ENVIRONMENT
from . import (
    CLUSTER_SECONDS, COMMIT, CROP_SECONDS, DETECTORS, PEAK_OFFSET_SECONDS, REPOSITORY, SAMPLE_RATE_HERTZ,
    SLICE_SECONDS, SLICE_STEP_SECONDS, STEP_SAMPLES, THRESHOLD, WEIGHTS, WEIGHTS_PATH, WINDOW_SAMPLES,
)

LOCK = ENVIRONMENT.lock

_WEIGHTS = RemoteFile(WEIGHTS, f"https://raw.githubusercontent.com/{REPOSITORY}/{COMMIT}/{WEIGHTS_PATH}",
                      "dc3f62e067533773d9cf6df0deaf46edb5536690468f18bf00bb92388b8e4f63", 5412113,
                      licence="Apache-2.0", redistributable=True)

_WHITENING = (
    f"inside the model, per {SLICE_SECONDS:g} s slice (one every int({SLICE_STEP_SECONDS:g} s x rate) samples; "
    f"(samples - slice) // step slices): mean Welch PSD of the slice (0.625 s Hann segments, half overlapping), "
    f"interpolated to 1281 bins, inverse spectrum truncated to 0.5 s, zero below 15 Hz; windows of 1.25 s every "
    f"{STEP_SAMPLES} samples, each divided by the ASD in the frequency domain and cropped by {CROP_SECONDS:g} s at "
    f"each end; window k of a slice is timed at the slice's start + {PEAK_OFFSET_SECONDS:g} s + float32(0.1 k) + "
    f"{CROP_SECONDS:g} s")

MODEL1 = gf.ExternalCard(
    name="aresgw-model1", adapter="aresgw-model1", adapter_version=ADAPTER_VERSION,
    environment_lock=ENVIRONMENT.sha256,
    input=gf.InputContract(
        SAMPLE_RATE_HERTZ, DETECTORS, window_seconds=WINDOW_SAMPLES / SAMPLE_RATE_HERTZ,
        stride_seconds=STEP_SAMPLES / SAMPLE_RATE_HERTZ, whitening=_WHITENING, context_seconds=2 * CROP_SECONDS,
        normalisation="DAIN (deep adaptive input normalisation), a learned layer in the weights"),
    output=gf.OutputContract(
        "softmax probability of the signal class (output 0)", signal_column=0, direction=HIGHER,
        threshold=THRESHOLD, cluster_seconds=CLUSTER_SECONDS,
        # Window k of a slice starts k x 204 samples in and is timed at 0.725 s + float32(0.1 k) - k x 204 / 2048
        # from its start: 0.725 s, drifting by up to 0.02 s over a slice's 51 windows.
        time_offset_seconds=PEAK_OFFSET_SECONDS + CROP_SECONDS),
    weights=(gf.Weights(_WEIGHTS, format="torch-state-dict", framework=ENVIRONMENT.framework),),
    training_data=(
        "As the authors declare it (arXiv:2211.01520): real O3a H1 and L1 noise (12 days, GWTC-2 events removed), "
        "IMRPhenomXPHM binary black holes of 7 to 50 solar masses with isotropic spins and higher modes, 40% L1 "
        "noise swap augmentation and an SNR curriculum; the MLGWSC-1 challenge's dataset 4 training setup."),
    published=tuple(
        gf.PublishedRow("nousi2022 (arXiv:2211.01520), Fig. 10", "MLGWSC-1 dataset 4 (real O3a noise), H1 and L1, "
                        "one-month test set", "sensitive distance", value, "Mpc", far_per_month=far,
                        reading_error=error)
        for far, value, error in ((100.0, 1815.0, 25.0), (10.0, 1630.0, 20.0), (1.0, 1575.0, 20.0))),
)

#: Every AresGW card, by name.
CARDS = {MODEL1.name: MODEL1}
