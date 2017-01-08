version
=======
.. index:: Telnet version
This command is similar to the HTTP :doc:`../api_http/version` endpoint in that it will return information about the currently running version of OpenTSDB. This command does not modify TSD in any way.

Request
^^^^^^^

The command format is:

::
  
  version

Response
^^^^^^^^

A set of lines with version information.

Example
-------

::
  
  net.opentsdb.tools BuildData built at revision a7a0980 (MODIFIED)
  Built on 2016/11/03 19:35:50 +0000 by clarsen@tsdvm:/Users/clarsen/Documents/opentsdb/opentsdb_dev
 