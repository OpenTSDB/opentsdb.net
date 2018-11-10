Telnet Style API
================
.. index:: Telnet API
The original way of interacting with OpenTSDB was through a Telnet style API. A user or application simply had to open a socket to the TSD and start sending ASCII string commands and expect a response. This documentation lists the various commands provided by OpenTSDB.

Each command must be sent as a series of strings with a **new line** character terminating the request.

.. NOTE:: 
  Connections will be closed after a period of inactivity, typically 5 minutes.

If a command is sent to the API that is not supported or recognized, a response similar to the following will be shown:

::

  unknown command: nosuchcommand.  Try `help'.

At any time the connection can be closed by issuing the ``exit`` command.

.. toctree::
  :maxdepth: 1
  
  put
  rollup
  histogram
  stats
  version
  help
  dropcaches
  diediedie