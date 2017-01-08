help
====
.. index:: Telnet help
Returns a list of the commands supported via the Telnet style API. This command does not modify TSD in any way.

Request
^^^^^^^

The command format is:

::
  
  help

Response
^^^^^^^^

A space separated list of commands supported.

Example
-------

::
  
  available commands: put stats dropcaches version exit help diediedie
 