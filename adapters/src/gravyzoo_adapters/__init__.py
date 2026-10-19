"""
Published gravitational-wave searches with released weights, as gravyflow runs them.

Each model has a subpackage holding

- ``search``: its adapter, an ``ExternalSearch`` (``prepare``, ``preprocess``,
  ``search``) published under the entry-point group ``gravyflow.external``. It runs in
  the model's own environment, beside the model's framework, and imports nothing of
  gravyflow's;
- ``card``: its ``ExternalCard`` for gravyflow (the input and output contracts as
  published, the weights pinned by sha256 at the authors' source, the licence, the
  rows the authors published), imported only where gravyflow is;
- the lock file of its environment, whose sha256 the card pins, and a ``NOTICE``
  crediting the original authors.

Importing this package imports neither side.
"""
