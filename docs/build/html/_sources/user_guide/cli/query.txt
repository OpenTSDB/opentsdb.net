query
=====
.. index:: CLI Query
The query command line tool is meant to be a quick debugging tool for extracting data from OpenTSDB. The HTTP API will usually be much quicker when querying data as it incorprates caches and open connections to storage. Results are printed to stdout in a text format with one data point per line.

Note that a query may return data points before and after the timespan requested. These are used in downsampling and graphing.

Parameters
^^^^^^^^^^
.. code-block :: bash

  query [Gnuplot opts] START-DATE [END-DATE] <aggregator> [rate] [counter,max,reset] [downsample N FUNC] <metric> [<tagk=tagv>] [...<tagk=tagv>] [...queries]

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 15, 5, 40, 5, 35
   
   "Gnuplot opts", "Strings", "Optional values used to generate Gnuplot scripts and graphs. Note that the actual graph PNG will not be generated, only the files (written to the temp directory)", "", "+wxh=1286x836"
   "START-DATE", "String or Integer", "Starting time for the query. This may be an absolute or relative time. See :doc:`../query/dates` for details", "", "1h-ago"
   "END-DATE", "String or Integer", "Optional end time for the query. If not provided, the current time is used. This may be an absolute or relative time. See :doc:`../query/dates` for details", "Current timestamp", "2014/01/01-00:00:00"
   "aggregator", "String", "A function to use when multiple timeseries are included in the results", "", "sum"
   "rate", "String", "The literal ``rate`` if the timeseries represents a counter and the results should be returned as delta per second", "", "rate"
   "counter", "String", "Optional literal ``counter`` that indicates the underlying data is a monotonically increasong counter that may roll over", "", "counter"
   "max", "Integer", "A positive integer representing the maximum value for the counter", "Java Long.MaxValue", "65535"
   "resetValue", "Integer", "An optional value that, when exceeded, will cause the aggregator to return a 0 instead of the calculated rate. Useful when data sources are frequently reset to avoid spurious spikes.", "", "65000"
   "downsample N FUNC", "String", "Optional downsampling specifier to group data into larger time spans and reduce the amount of data returned. Format is the literal ``downsample`` followed by a timespan in milliseconds and an aggregation function name", "", "downsample 300000 avg"
   "metric", "String", "Required name of a metric to query for", "", "sys.cpu.user"
   "tagk=tagv", "String", "Optional pairs of tag names and tag values", "", "host=web01"
   "additional queries", "String", "Optional additional queries to execute. Each query must follow the same format starting with an aggregator. All queries share the same start and end times.", "", "sum tsd.hbase.rpcs type=scan"

For more details on querying, please see :doc:`../query/index`.

Example:

.. code-block :: bash

  query 1h-ago now sum tsd.hbase.rpcs type=put sum tsd.hbase.rpcs type=scan

Output Format
^^^^^^^^^^^^^

Data is printed to stdout with one data point per line. If one or more Gnuplot options were specified, then scripts and data files for each query will be written to the configured temporary directory.

..

  <metric> <timestamp> <value> {<tagk=tagv>[,..<tagkN=tagvN>]}

Where:

  * **metric** Is the name of the metric queried
  * **timestamp** Is the absolute timestamp of the data point in seconds or milliseconds
  * **value** Is the data point value
  * **tagk=tagv** Is a list of common tag name and value pairs for all timeseries represented in the query
  
Example:

.. code-block :: bash

  tsd.hbase.rpcs 1393376401000 28067146491 {type=put, fqdn=tsdb-data-1}
  tsd.hbase.rpcs 1393376461000 28067526510 {type=put, fqdn=tsdb-data-1}
  tsd.hbase.rpcs 1393376521000 28067826659 {type=put, fqdn=tsdb-data-1}
  tsd.hbase.rpcs 1393376581000 28068126093 {type=put, fqdn=tsdb-data-1}

  