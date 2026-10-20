"""
The environments the adapters run in, which their cards pin: each built from a lock
file in ``locks/`` (conda-forge, explicit URLs with md5s, for one platform) by

    micromamba create -p <prefix> --file <lock>

Standard library only: the cards import it beside gravyflow.
"""

from pathlib import Path
from typing import NamedTuple


class Environment(NamedTuple):
    """An adapter environment: its lock file, the lock's sha256 (a card's
    ``environment_lock``) and the framework release that reads the weights."""

    lock: Path
    sha256: str
    framework: str


#: The adapters distribution's version (``pyproject.toml``'s), which every card pins.
ADAPTER_VERSION = "0.2.0"

_LOCKS = Path(__file__).with_name("locks")

#: PyTorch 1.13.1 (CPU) and PyCBC 2.0.6 on Python 3.10, numpy 1.23, LALSuite of late
#: 2022: the releases current when the TPI and AresGW searches were published.
PYTORCH_1_13 = Environment(_LOCKS / "pytorch-1.13.1-pycbc-2.0.6.osx-arm64.lock",
                           "8436bd63394596ec95618897742649d0a3b825459e5542950ffe157a546058d9", "torch==1.13.1")

#: PyTorch 2.14.1 (CPU), PyTorch Lightning 2.6.6, SciPy 1.18.1 and numpy 2.5.4 on
#: Python 3.12, with GWpy and GWOSC for the author's downloader: current releases at
#: AttenGW's publication, whose requirements pin none.
PYTORCH_2_14 = Environment(_LOCKS / "pytorch-2.14.1-lightning-2.6.6.osx-arm64.lock",
                           "f29f8cdf99ecb06a0593e384088aabf95c9e73e206f63c3515388a1632973058", "torch==2.14.1")
