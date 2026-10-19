"""
The TPI FSU Jena search's cards, one per release of its weights, for gravyflow's
external-model runner (imported where gravyflow is, never in the TPI environment).

``ORIGINAL`` is the original submission; ``R1`` to ``R6`` the corrected runs, R1 the
authors' final algorithm. ``CARDS`` holds them all by name; ``ENVIRONMENT`` is the
environment they run in, and ``LOCK`` its lock file.
"""

import gravyflow as gf
from gravyflow.src.dataset.store.files import RemoteFile
from gravyflow.src.external.card import HIGHER

from ..environments import ADAPTER_VERSION, PYTORCH_1_13 as ENVIRONMENT
from . import (
    CLUSTER_SECONDS, COMMIT, DETECTORS, EDGE_SECONDS, FILTER_SECONDS, LOW_FREQUENCY_CUTOFF_HERTZ,
    PEAK_OFFSET_SECONDS, PSD_SECONDS, RELEASES, REPOSITORY, SAMPLE_RATE_HERTZ, STEP_SAMPLES, THRESHOLD,
    WINDOW_SAMPLES,
)

LOCK = ENVIRONMENT.lock

#: Each weights file's sha256 and size, as the authors publish it at ``COMMIT``.
_PINS = {
    "original": ("6b4d733ccdc32726a3959f05c45d818ad238b9a587c49ce6ccd66c095c3eb7a2", 2551996),
    "r1": ("c56c3b62eb34b9cc1c0fac1a411fee54de95961b9127eea8c5a184d4a9d3cf39", 2550347),
    "r2": ("0a83a81458851b73ee41e0bd27743284b41bd21cbb82a4490286e7856b31bc61", 2550347),
    "r3": ("a70b6c99db1911f50e68c0ae8c87f7952792b502896afffb70f39ccd5fc9e0eb", 2550347),
    "r4": ("aeb9c47f4e76311ace8908ff1ca80e907e54a6d0819378210e97c5838e072a48", 2550347),
    "r5": ("1e36fc5eec2ee7a5584b3f53ec982b7c795201bdc47cb24a7c92985237af4227", 2550347),
    "r6": ("7f50540558e6755dee6c506f1b7a73c44826aa22092b2f826db95fc5b67a5d6b", 2550347),
}

_WHITENING = (
    f"PyCBC: Welch PSD of the whole segment ({PSD_SECONDS:g} s Hann segments, half overlapping, median), "
    f"interpolated to the segment's resolution, inverse spectrum truncated to {FILTER_SECONDS:g} s (Hann), "
    f"zero at and below {LOW_FREQUENCY_CUTOFF_HERTZ:g} Hz; divided by the ASD in the frequency domain, "
    f"{EDGE_SECONDS:g} s cut from each end")

_OUTPUT = gf.OutputContract(
    "output 0 minus output 1 of the network (the authors' unbounded softmax replacement; no softmax)",
    signal_column=0, direction=HIGHER, threshold=THRESHOLD,
    cluster_seconds=CLUSTER_SECONDS, time_offset_seconds=PEAK_OFFSET_SECONDS)

_TRAINING = (
    "As the authors declare it (arXiv:2402.07492; repository README): the MLGWSC-1 challenge's real O3a H1 "
    "and L1 noise file, whitened and sliced, with PyCBC IMRPhenomXPHM binary black hole injections (precessing, "
    "with higher modes; the paper's Table I), component masses 10 to 50 solar masses, spin magnitudes up to 0.99 "
    "with isotropic directions, network SNR 7 to 20; the corrected runs train on noise and signal 1:3, and each run's "
    "epoch was chosen by its sensitive distance on the challenge's dataset 4 test data.")

_PUBLISHED = {
    "original": tuple(
        gf.PublishedRow("Schafer et al. 2023 (arXiv:2209.11146), Table IV", "MLGWSC-1 dataset 1, H1 and L1",
                        "sensitive distance", value, "Mpc", far_per_month=far)
        for far, value in ((100.0, 2634.8), (10.0, 2472.31), (1.0, 2362.51))),
    "r1": (gf.PublishedRow("zelenka2024 (arXiv:2402.07492), Sec. IV", "MLGWSC-1 dataset 4 (real O3a noise), H1 and L1",
                           "sensitive distance", 1316.0, "Mpc", far_per_month=1.0),),
}


def _card(release):
    weights, path, batch_norm = RELEASES[release]
    sha256, size = _PINS[release]
    file = RemoteFile(weights, f"https://raw.githubusercontent.com/{REPOSITORY}/{COMMIT}/{path}", sha256, size,
                      licence="Apache-2.0", redistributable=True)
    return gf.ExternalCard(
        name=f"tpi-{release}", adapter=f"tpi-{release}", adapter_version=ADAPTER_VERSION,
        environment_lock=ENVIRONMENT.sha256,
        input=gf.InputContract(
            SAMPLE_RATE_HERTZ, DETECTORS, window_seconds=WINDOW_SAMPLES / SAMPLE_RATE_HERTZ,
            stride_seconds=STEP_SAMPLES / SAMPLE_RATE_HERTZ, whitening=_WHITENING, context_seconds=2 * EDGE_SECONDS,
            normalisation=("a batch normalisation, the network's first layer (in the weights)" if batch_norm
                           else "none")),
        output=_OUTPUT,
        weights=(gf.Weights(file, format="torch-state-dict", framework=ENVIRONMENT.framework),),
        training_data=_TRAINING,
        published=_PUBLISHED.get(release, ()),
    )


#: Every TPI card, by name.
CARDS = {card.name: card for card in map(_card, RELEASES)}

ORIGINAL, R1, R2, R3, R4, R5, R6 = CARDS.values()
