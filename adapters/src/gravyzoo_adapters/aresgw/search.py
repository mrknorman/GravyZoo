"""
AresGW model 1 as an ``ExternalSearch``: the authors' model (``CropWhitenNet`` around
``DAIN_Layer`` and ``ResNet54Double``, from ``published``) run in deploy mode over the
slices ``test.py`` reads, with its times, threshold and clustering, over a whole
segment held in memory rather than a challenge file.

Runs in the AresGW environment (PyTorch, from its lock).
"""

import numpy as np
import torch

from .._common import cluster
from . import (
    BATCH_SIZE, CLUSTER_SECONDS, CROP_SECONDS, DETECTORS, PEAK_OFFSET_SECONDS, SLICE_SECONDS,
    SLICE_STEP_SECONDS, THRESHOLD, VAR_SECONDS, WEIGHTS,
)
from .published.dain import DAIN_Layer
from .published.resnet import ResNet54Double
from .published.whiten import CropWhitenNet


class AresGW:
    """AresGW model 1 (``improved_d4_model``)."""

    def prepare(self, fetch):
        model = CropWhitenNet(ResNet54Double(), DAIN_Layer(input_dim=len(DETECTORS)))
        model.deploy = True
        model.load_state_dict(torch.load(fetch(WEIGHTS), map_location="cpu"))
        self.model = model.to(dtype=torch.float32).eval()

    def _slices(self, segment):
        """The slices ``test.py``'s slicer reads (slices, detectors, samples), float64,
        and the time it gives each."""
        dt = 1.0 / segment.sample_rate_hertz
        length, step = int(SLICE_SECONDS * segment.sample_rate_hertz), int(SLICE_STEP_SECONDS / dt)
        count = max((segment.strain.shape[1] - length) // step, 0)
        starts = np.arange(count) * step
        strain = np.stack([segment[d] for d in DETECTORS])
        slices = np.stack([strain[:, start:start + length] for start in starts]) if count else \
            np.zeros((0, len(DETECTORS), length))
        return slices, segment.t0 + starts * dt + PEAK_OFFSET_SECONDS

    def _batches(self, segment):
        """Each batch of slices through the model, as ``get_triggers`` runs it: the
        model's outputs and their times, and the windows its DAIN layer read."""
        slices, times = self._slices(segment)
        read = []
        hook = self.model.norm.register_forward_pre_hook(lambda module, inputs: read.append(inputs[0]))
        try:
            with torch.no_grad():
                for i in range(0, len(slices), BATCH_SIZE):
                    outputs, added = self.model(torch.from_numpy(np.ascontiguousarray(slices[i:i + BATCH_SIZE])))
                    batch = torch.from_numpy(times[i:i + BATCH_SIZE])
                    batch = batch.repeat_interleave(added.size(0) // batch.size(0)) + added
                    yield outputs[:, 0], batch + CROP_SECONDS, read.pop()
        finally:
            hook.remove()

    def preprocess(self, segment):
        """The whitened, cropped windows the model's DAIN layer reads: (windows,
        detectors, samples), float32."""
        found = [windows.numpy() for _, _, windows in self._batches(segment)]
        return np.concatenate(found) if found else np.zeros((0, len(DETECTORS), 2048), np.float32)

    def search(self, segment):
        stats, times = [], []
        for outputs, batch_times, _ in self._batches(segment):
            above = outputs > THRESHOLD
            stats.append(outputs[above].numpy())
            times.append(batch_times[above].numpy())
        return cluster(np.concatenate(times) if times else [], np.concatenate(stats) if stats else [],
                       CLUSTER_SECONDS, VAR_SECONDS)
