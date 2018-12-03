rollup
======
.. index:: Telnet rollup
Attempts to write a rolled up and/or pre-aggregated data point to storage. Note that UTF-8 characters may not be handled properly by the Telnet style API so use the :doc:`../api_http/rollup` method instead or use the Java API directly. Also see the :doc:`../user_guide/rollup` documentation for more information. This endpoint behaves in a similar manner to the :doc:`put` API.

Request
^^^^^^^

The command format is:

::
  
  rollup <rollup spec> <metric> <timestamp> <value> <tagk_1>=<tagv_1>[ <tagk_n>=<tagv_n>]


In this case the rollup spec is one of:

* ``<interval>:<aggregator>`` for a *raw* or *non-pre-aggregated* **rollup** over the interval.
* ``<group_by_aggregator>`` for a *raw* **pre-aggregated** value that has not been rolled up over time.
* ``<interval>:<aggregator>:<group_by_aggregator>`` for a *rolled up* *pre-aggregated* value.

Note:

* Because fields are space delimited, metrics and tag values may not contain spaces.
* The timestamp must be a positive Unix epoch timestamp. E.g. ``1479496100`` to represent ``Fri, 18 Nov 2016 19:08:20 GMT``
* The value must be a number. It may be an integer (maximum and minimum values of Java's ``long`` data type), a floating point value or scientific notation (in the format ``[-]<#>.<#>[e|E][-]<#>``).
* At least one tag pair must be present. Additional tag pairs can be added with spaces in between.

Examples
--------

::
  
  rollup 1h:SUM sys.if.bytes.out 1479412800 1.3E3 host=web01 interface=eth0
  rollup SUM sys.procs.running 1479496100 42 colo=lga
  rollup 1h:SUM:SUM sys.procs.running 1479412800 24 colo=lga

Response
^^^^^^^^

A successful request will not return a response. Only on error will the socket return a line of data. Some examples appear below:

Example Requests and Responses
------------------------------

::
  
  rollup
  rollup: illegal argument: not enough arguments (need least 5, got 1)

::
  
  rollup SUM metric.foo notatime 42 host=web01
  rollup: invalid value: Invalid character 'n' in notatime

The following will be returned if ``tsd.core.auto_create_metrics`` are disabled.
::
  
  rollup SUM new.metric 1479496160 1.3e3 host=web01
  rollup: unknown metric: No such name for 'metrics': 'new.metric'
