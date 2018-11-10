/api/query/gexp
===============
.. index:: HTTP /api/query/gexp
Graphite is an excellent storage system for time series data with a number of built in functions to manipulate the data. To support transitions from Graphite to OpenTSDB, the ``/api/query/gexp`` endpoint supports URI queries *similar* but not *identical* to Graphite`s expressions. Graphite functions are generally formatted as ``func(<series>[, param1][, paramN])`` with the ability to nest functions. TSD`s implementation follows the same pattern but uses an ``m`` style query (e.g. ``sum:proc.stat.cpu{host=foo,type=idle}``) in place of the ``<series>``. Nested functions are supported.

TSDB implements a subset of Graphite functions though we hope to add more in the future. For a list of Graphite functions and descriptions, see the `Documentation <http://graphite.readthedocs.org/en/latest/functions.html>`_. TSD supported functions appear below.

.. NOTE:: Supported as of version 2.3

Verbs
-----

* GET

Requests
--------

Queries can only be executed via GET using the URI at this time. (In the future, the :doc:`exp` endpoint will support more flexibility.) This is an extension of the main :doc:`index` endpoint so parameters in the request table are also supported here. Additional parameters include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Example"
   :widths: 10, 5, 5, 55, 25
   
   "exp", "String", "Required", "The Graphite style expression to execute. The first parameter of a function must either be another function or a URI formatted **Sub Query**", "scale(sum:if.bytes_in{host=*},1024)"

Example Query String Requests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  http://localhost:4242/api/query/gexp?start=1h-ago&exp=scale(sum:if.bytes_in{host=*},1024)

Response
--------

The output is identical to :doc:`index`.

Functions
---------

Functions that accept a single metric query will operate across each time series result. E.g. if a query includes a group by on host such as ``scale(sum:if.bytes_in{host=*},1024)``, and multiple hosts exist with that metric, then a series for each host will be emitted and the function applied. For functions that take multiple metrics, a union is performed across each metric and the function is executed across each resulting series with matching tags. E.g with the query ``sum(sum:if.bytes_in{host=*},sum:if.bytes_out{host=*})``, assume two hosts exist, ``web01`` and ``web02``. In this case, the output will be ``if.bytes_in{host=web01} + if.bytes_out{host=web01}`` and ``if.bytes_in{host=web02} + if.bytes_out{host=web02}``. Missing series in any metric result set will be filled with the default fill value of the function.

Currently supported expressions include:

absolute(<metric>)
^^^^^^^^^^^^^^^^^^

Emits the results as absolute values, converting negative values to positive.

diffSeries(<metric>[,<metricN>])
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Returns the difference of all series in the list. Performs a UNION across tags in each metric result sets, defaulting to a fill value of zero. A maximum of 26 series are supported at this time.

divideSeries(<metric>[,<metricN>])
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Returns the quotient of all series in the list. Performs a UNION across tags in each metric result sets, defaulting to a fill value of zero. A maximum of 26 series are supported at this time.

highestCurrent(<metric>,<n>)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sorts all resulting time series by their most recent value and emits ``n`` number of series with the highest values. ``n`` must be a positive integer value.

highestMax(<metric>,<n>)
^^^^^^^^^^^^^^^^^^^^^^^^

Sorts all resulting time series by the maximum value for the time span and emits ``n`` number of series with the highest values. ``n`` must be a positive integer value.

movingAverage(<metric>,<window>)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Emits a sliding window moving average for each data point and series in the metric. The ``window`` parameter may either be a positive integer that reflects the number of data points to maintain in the window (non-timed) or a time span specified by an integer followed by time unit such as ```60s``` or ```60m``` or ```24h```. Timed windows must be in single quotes.

multiplySeries(<metric>[,<metricN>])
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Returns the product of all series in the list. Performs a UNION across tags in each metric result sets, defaulting to a fill value of zero. A maximum of 26 series are supported at this time.

scale(<metric>,<factor>)
^^^^^^^^^^^^^^^^^^^^^^^^

Multiplies each series by the factor where the factor can be a positive or negative floating point or integer value.

sumSeries(<metric>[,<metricN>])
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Returns the sum of all series in the list. Performs a UNION across tags in each metric result sets, defaulting to a fill value of zero. A maximum of 26 series are supported at this time.