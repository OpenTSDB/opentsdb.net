put
===
.. index:: Telnet put
Attempts to write a data point to storage. Note that UTF-8 characters may not be handled properly by the Telnet style API so use the :doc:`../api_http/put` method instead or use the Java API directly.

.. NOTE::
  Because the socket is read and written to asynchronously, responses may be garbled. It's best to treat this similar to a UDP socket in that you may not always know if the data made it in. If you require truly synchronous writes with guarantees of the data making it to storage, please use the HTTP or Java APIs.


Request
^^^^^^^

The command format is:

::
  
  put <metric> <timestamp> <value> <tagk_1>=<tagv_1>[ <tagk_n>=<tagv_n>]


Note:

* Because fields are space delimited, metrics and tag values may not contain spaces.
* The timestamp must be a positive Unix epoch timestamp. E.g. ``1479496100`` to represent ``Fri, 18 Nov 2016 19:08:20 GMT``
* The value must be a number. It may be an integer (maximum and minimum values of Java's ``long`` data type), a floating point value or scientific notation (in the format ``[-]<#>.<#>[e|E][-]<#>``).
* At least one tag pair must be present. Additional tag pairs can be added with spaces in between.

Examples
--------

::
  
  put sys.if.bytes.out 1479496100 1.3E3 host=web01 interface=eth0
  put sys.procs.running 1479496100 42 host=web01

Response
^^^^^^^^

A successful request will not return a response. Only on error will the socket return a line of data. Some examples appear below:

Example Requests and Responses
------------------------------

::
  
  put
  put: illegal argument: not enough arguments (need least 4, got 1)

::
  
  put metric.foo notatime 42 host=web01
  put: invalid value: Invalid character 'n' in notatime

The following will be returned if ``tsd.core.auto_create_metrics`` are disabled.
::
  
  put new.metric 1479496160 1.3e3 host=web01
  put: unknown metric: No such name for 'metrics': 'new.metric'
