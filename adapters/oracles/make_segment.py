"""
The oracles' segment: 128 s of H1 and L1 coloured Gaussian noise from gravyflow (its
default O3 curves), with four IMRPhenomD binary black holes injected at network SNRs
of 12 to 30, written twice:

- ``segment-<rate>.npz``: the strain (detectors, samples) as float64, the detectors,
  the first sample's GPS time, the rate and the injections' merger times, which the
  oracle runs through gravyflow's runner;
- ``segment-<rate>.hdf``: the same samples in the authors' input file (a group per
  detector, one dataset ``"0"`` with ``start_time`` and ``delta_t``), which their own
  code reads.

Run with gravyflow's environment, its cache pointed at a temporary root:

    python make_segment.py <output directory> [--rate 2048]
"""

import argparse
import hashlib
from pathlib import Path

import h5py
import numpy as np

import gravyflow as gf
from gravyflow.src.dataset.features.waveforms.cbc import _generate_cbc_window
from gravyflow.src.dataset.noise import noise as gf_noise

DETECTORS = ("H1", "L1")
T0, DURATION_SECONDS, SEED = 1_300_000_000.0, 128, 20261019

#: Each injection: its merger's offset into the segment (s), its masses (solar masses)
#: and its network SNR.
INJECTIONS = ((20.3, 30.0, 25.0, 25.0), (45.7, 20.0, 15.0, 20.0), (80.1, 40.0, 35.0, 30.0),
              (105.5, 12.0, 10.0, 12.0))

#: The waveforms' length (s), merger at its centre, and their lower frequency (Hz).
WAVEFORM_SECONDS, MIN_FREQUENCY_HERTZ = 8.0, 20.0


def segment(rate):
    """The noise and the injected strain, (detectors, samples) float64, and the mergers' GPS times."""
    ifos = [gf.IFO[d] for d in DETECTORS]
    noise = gf_noise.colored_noise_batcher(1, DURATION_SECONDS, 0.0, DURATION_SECONDS, ifos, rate)
    strain = np.asarray(noise(gf.SeedTree(SEED).direct(0))[gf.ReturnVariables.ONSOURCE], np.float64)[0]
    strain = strain[:, :int(DURATION_SECONDS * rate)].copy()

    offsets, mass_1, mass_2, snrs = (np.array(column) for column in zip(*INJECTIONS))
    count = len(INJECTIONS)
    polarisations = _generate_cbc_window(
        count, rate, WAVEFORM_SECONDS, MIN_FREQUENCY_HERTZ, mass_1_msun=mass_1, mass_2_msun=mass_2,
        inclination_radians=np.full(count, 0.4), distance_mpc=np.full(count, 1000.0),
        reference_orbital_phase_in=np.zeros(count), spin_1_in=np.zeros((count, 3)), spin_2_in=np.zeros((count, 3)))
    rng = np.random.default_rng(SEED)
    projected = gf.Network(ifos).project_wave(
        polarisations, rate, right_ascension=list(rng.uniform(0, 2 * np.pi, count)),
        declination=list(np.arcsin(rng.uniform(-1, 1, count))), polarization=list(rng.uniform(0, np.pi, count)))
    scaled = np.asarray(gf.scale_to_snr(projected, np.repeat(strain[None], count, axis=0), snrs, rate,
                                        lower_frequency_cutoff=MIN_FREQUENCY_HERTZ), np.float64)

    samples = scaled.shape[-1]
    mergers = []
    for waveform, offset in zip(scaled, offsets):
        merger = int(round(offset * rate))
        start = merger - samples // 2
        strain[:, start:start + samples] += waveform
        mergers.append(T0 + merger / rate)
    return strain, np.array(mergers)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("output", type=Path)
    parser.add_argument("--rate", type=float, default=2048.0)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    strain, mergers = segment(args.rate)
    name = f"segment-{int(args.rate)}"
    npz = args.output / f"{name}.npz"
    np.savez(npz, strain=strain, detectors=np.array(DETECTORS), t0=T0, sample_rate_hertz=args.rate,
             mergers=mergers)
    with h5py.File(args.output / f"{name}.hdf", "w") as handle:
        for row, detector in zip(strain, DETECTORS):
            dataset = handle.create_group(detector).create_dataset("0", data=row)
            dataset.attrs["start_time"] = T0
            dataset.attrs["delta_t"] = 1.0 / args.rate
    print(f"{name}: {strain.shape[1]} samples per detector at {args.rate:g} Hz from GPS {T0:.1f}, "
          f"mergers at {', '.join(f'{t:.4f}' for t in mergers)}; strain sha256 "
          f"{hashlib.sha256(np.ascontiguousarray(strain).tobytes()).hexdigest()}")


if __name__ == "__main__":
    main()
