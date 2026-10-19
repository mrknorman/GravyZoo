"""
The AresGW authors' own network and whitening modules, copied from
github.com/vivinousi/gw-detection-deep-learning at commit
35ff988741adb6a01a02031b24847904da9a3c6d (Apache-2.0), so their state dictionary
loads as published:

- ``whiten.py``: ``modules/whiten.py``, unchanged (``CropWhitenNet``: the per-slice
  PSD, the whitening and cropping of each window, the network's deploy times);
- ``dain.py``: ``modules/dain.py``, unchanged (the DAIN input normalisation, which the
  authors adapted from github.com/passalis/dain);
- ``resnet.py``: ``modules/resnet.py`` with its ``ResNet54`` (the earlier challenge
  model, which AresGW model 1 does not use) removed; ``ResBlock`` and
  ``ResNet54Double`` unchanged.
"""
