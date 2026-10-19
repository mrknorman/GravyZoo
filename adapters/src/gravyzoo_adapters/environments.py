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
ADAPTER_VERSION = "0.1.0"

_LOCKS = Path(__file__).with_name("locks")

#: PyTorch 1.13.1 (CPU) and PyCBC 2.0.6 on Python 3.10, numpy 1.23, LALSuite of late
#: 2022: the releases current when the TPI and AresGW searches were published.
PYTORCH_1_13 = Environment(_LOCKS / "pytorch-1.13.1-pycbc-2.0.6.osx-arm64.lock",
                           "8436bd63394596ec95618897742649d0a3b825459e5542950ffe157a546058d9", "torch==1.13.1")
