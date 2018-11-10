histogram
=========

**Available with OpenTSDB 2.4**

.. index:: Telnet histogram
Attempts to write a histogram data point to storage. Note that UTF-8 characters may not be handled properly by the Telnet style API so use the :doc:`../api_http/histogram` method instead or use the Java API directly.

.. NOTE::
  Because the socket is read and written to asynchronously, responses may be garbled. It's best to treat this similar to a UDP socket in that you may not always know if the data made it in. If you require truly synchronous writes with guarantees of the data making it to storage, please use the HTTP or Java APIs.

.. WARNING:: Histograms as implemented in 2.4 do not support derivative computations at query time (e.g. rates). When writing histograms, they should come from each source at regular intervals and must reflect *only the measurements for that particular interval*. E.g. If the source wants to report latency histograms every 5 minutes, then the source should create a new histogram object every 5 minutes, populate it with measurements, write it to TSDB and create a new, empty histogram for the next 5 minute interval. 

Request
^^^^^^^

The command format is:

::
  
  put <metric> <timestamp> [<id>] <value> <tagk_1>=<tagv_1>[ <tagk_n>=<tagv_n>]


Note:

* Because fields are space delimited, metrics and tag values may not contain spaces.
* The timestamp must be a positive Unix epoch timestamp. E.g. ``1479496100`` to represent ``Fri, 18 Nov 2016 19:08:20 GMT``
* For implementations other than the built-in simple bucket histogram, the ID must be a numeric value between 0 and 255 matching the identifier of a mapped histogram codec as defined in the ``tsd.core.histograms.config`` setting.
* The value must either be a simple bucket histogram (defined below) or the base 64 encoded binary data encoding the given histogram type. **Note:** The histogram ID is required when sending binary data.
* At least one tag pair must be present. Additional tag pairs can be added with spaces in between.

**Value Encoding:**

For the simple bucketed histogram implementation, the value is a semicoln separated list of key/value pairs separated by an equals sign. All values (the right side of the equals operator) must be signed integers. Left side values are either the key characters ``u`` or ``o``, signed integers or signed float point values. Numerics represent the bucket lower and upper bounds separated by a comma. Key/values may appear in any order. Left side key descriptors are:

.. csv-table::
   :header: "Key", "Data Type", "Description", "Example"
   :widths: 15, 15, 50, 30
   
   "u", "Character", "The underflow count of the histogram. This field is optional and defaults to 0.", "u=0"
   "o", "Character", "The overflow count of the histogram. This field is optional and defaults to 0.", "o=42"
   "0,1.75", "String", "The comma separated bucket lower bound (left of the comma) and upper bound (right of the comma). The upper and lower bounds of consecutive buckets must overlap. I.e. we may have two buckets ``0,1.75=12`` and ``1.75,3.5=16``.", "0,1.75=12"

Examples
--------

::
  
  put sys.if.bytes.out 1479496100 u=0:o=1:0,1.5=42:1.5,5.75=24 host=web01 interface=eth0
  put sys.procs.running 1479496100 1 AgMIGoAAAAADAAAAAAAAAAAAAAAAAPA/AAAAAABARUAAAAAAAADwPwAAAAAAADhAAAAAAABARUA= host=web01

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
  
  put new.metric 1479496160 u=0:o=1:0,1.5=42:1.5,5.75=24 host=web01
  put: unknown metric: No such name for 'metrics': 'new.metric'
