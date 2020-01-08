mkmetric
========
.. index:: CLI mkmetric
mkmetric is a shortcut to the ``uid assign metrics <metric>`` command where you can provide multiple metric names in a single call and UIDs will be assigned or retrieved. If any of the metrics already exist, the assigned UID will be returned.

Parameters
^^^^^^^^^^
.. code-block :: bash

  mkmetric metric [metrics]
  
Simply supply one or more space separate metric names in the call.

Example

.. code-block :: bash
  
  mkmetric sys.cpu.user sys.cpu.nice sys.cpu.idle
  
Response
^^^^^^^^

The response is the literal "metrics" followed by the name of the metric and a Java formatted byte array representing the UID assigned or retrieved for each metric, one per line.

Example

.. code-block :: bash

  metrics sys.cpu.user: [0, 0, -58]
  metrics sys.cpu.nice: [0, 0, -57]
  metrics sys.cpu.idle: [0, 0, -59]