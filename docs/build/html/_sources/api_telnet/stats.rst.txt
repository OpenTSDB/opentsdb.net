stats
=====
.. index:: Telnet stats
This command is similar to the HTTP :doc:`../api_http/stats/index` endpoint in that it will return a list of the TSD stats, one per line, in the ``put`` format. This command does not modify TSD in any way.

Request
^^^^^^^

The command format is:

::
  
  stats

Response
^^^^^^^^

A set of time series with data about the running TSD.

Example
-------

::
  
  tsd.hbase.rpcs 1479600574 0 type=increment host=web01
  tsd.hbase.rpcs 1479600574 0 type=delete host=web01
  tsd.hbase.rpcs 1479600574 1 type=get host=web01
  tsd.hbase.rpcs 1479600574 0 type=put host=web01
  tsd.hbase.rpcs 1479600574 0 type=append host=web01
  tsd.hbase.rpcs 1479600574 0 type=rowLock host=web01
  tsd.hbase.rpcs 1479600574 0 type=openScanner host=web01
  tsd.hbase.rpcs 1479600574 0 type=scan host=web01
  tsd.hbase.rpcs.batched 1479600574 0 host=web01
 