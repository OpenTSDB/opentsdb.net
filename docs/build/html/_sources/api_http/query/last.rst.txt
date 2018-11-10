/api/query/last
===============
.. index:: HTTP /api/query/last
This endpoint (2.1 and later) provides support for accessing the latest value of individual time series. It provides an optimization over a regular query when only the last data point is required. Locating the last point can be done with the timestamp of the meta data counter or by scanning backwards from the current system time.

.. NOTE:: In order for this endpoint to function with metric string queries by scanning for matching time series, the meta data table must exist and have been populated with counters or TSMeta objects using one of the methods specified in :doc:`../../user_guide/metadata`. You must set either ``tsd.core.meta.enable_tsuid_tracking`` or ``tsd.core.meta.enable_realtime_ts``. Queries with a backscan parameter will skip the meta table.

Similar to the standard query endpoint, there are two methods to use in selecting which time series should return data:

* **Metric Query** - Similar to a regular metric query, you can send a metric name and optionally a set of tag pairs. If the real-time meta has been enabled, the TSD will scan the meta data table to see if any time series match the query. For each time series that matches, it will scan for the latest data point and return it. However if meta is disabled, then the TSD will attempt a lookup for the exact set of metric and tags provided as long as a backscan value is given (as of 2.1.1).
* **TSUID Query** - If you know the TSUIDs for the time series that you want to access data for, simply provide a list of TSUIDs.

Additionally there are two ways to find the last data point for each time series located:

* **Counter Method** - If no backscan value is given and meta is enabled, the default is to lookup the data point counter in the meta data table for each time series. This counter records the time when the latest data point was written by a TSD. The endpoint looks up the timestamp and "gets" the proper data row, fetching the last point in the row. This will work most of the time, however please be aware that if you backfill older data (via an import or simply putting a data point with an old timestamp) the counter column timestamp may not be accurate. This method is best used for continuously updated data.

* **Back Scan** - Alternatively you can specify a number of hours to scan back in time starting at the current system time of the TSD where the query is being executed. For example, if you specify a back scan time of 24 hours, the TSD will first look for data in the row with the current hour. If that row is empty, it will look for data one hour before that. It will keep doing that until it finds a data point or it exceeds the hour limit. This method is useful if you often write data points out of order in time. Also note that the larger the backscan value, the longer it may take for queries to complete as they may scan further back in time for data.

All queries will return results only for time series that matched the query and for which a data point was found. The results are a list of individual data points per time series. Aggregation cannot be performed on individual data points as the timestamps may not align and the TSD will only return a single point so interpolation is impossible.

Verbs
-----

* GET
* POST

Requests
--------

Common parameters include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "queries", "Array", "Required", "A list of one or more queries used to determine which time series to fetch the last data point for.", "", "timeseries | tsuids", "", ""
   "resolveNames", "Boolean", "Optional", "Whether or not to resolve the TSUIDs of results to their metric and tag names.", "false", "resolve", "", "true"
   "backScan", "Integer", "Optional", "A number of hours to search in the past for data. If set to 0 then the timestamp of the meta data counter for the time series is used.", "0", "back_scan", "", "24"

Note that you can mix multiple metric and TSUID queries in one request.

Metric Query String Format
^^^^^^^^^^^^^^^^^^^^^^^^^^

The full specification for a metric query string sub query is as follows:

::

  timeseries=<metric_name>[{<tag_name1>=<tag_value1>[,...<tag_nameN>=<tag_valueN>]}]
  
It is similar to a regular metric query but does not allow for aggregations, rates, down sampling or grouping operators. Note that if you supply a backscan value to avoid the meta table, then you must supply all of the tags and values to match the exact time series you are looking for. Backscan does not currently filter on the metric and tags given but will look for the specific series.

TSUID Query String Format
^^^^^^^^^^^^^^^^^^^^^^^^^

TSUID queries are simpler than Metric queries. Simply pass a list of one or more hexadecimal encoded TSUIDs separated by commas:

::

  tsuids=<tsuid1>[,...<tsuidN>]

Example Query String Requests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  http://localhost:4242/api/query/last?timeseries=proc.stat.cpu{host=foo,type=idle}&timeseries=proc.stat.mem{host=foo,type=idle}
  http://localhost:4242/api/query/last?tsuids=000001000002000003,000001000002000004&back_scan=24&resolve=true

Example Content Request
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block :: javascript

  {
      "queries": [
          {
              "metric": "sys.cpu.0",
              "tags": {
                  "host": "web01",
                  "dc": "lga"
              }
          }, 
          {
              "tsuids": [
                  "000001000002000042",
                  "000001000002000043"
                ]
              }
          }
      ],
      "resolveNames":true,
      "backScan":24
  }
   
Response
--------
   
The output will be an array of 0 or more data points depending on the data that was found. If a data point for a particular time series was not located within the time specified, it will not appear in the output. Output fields depend on whether or not the ``resolve`` flag was set.

.. csv-table::
  :header: "Name", "Description"
  :widths: 20, 80
  
  "metric", "Name of the metric for the time series. Only returned if ``resolve`` was set to true."
  "tags", "A list of tags for the time series. Only returned if ``resolve`` was set to true."
  "timestamp", "A Unix epoch timestamp, in milliseconds, when the data point was written"
  "value", "The value of the data point enclosed in quotation marks as a string"
  "tsuid", "The hexadecimal TSUID for the time series"

Unless there was an error with the query, you will generally receive a ``200`` status with content. However if your query couldn't find any data, it will return an empty result set. In the case of the JSON serializer, the result will be an empty array:

.. code-block :: javascript  

  []

Example Responses
^^^^^^^^^^^^^^^^^

.. code-block:: javascript

  [
      {
          "timestamp": 1377118201000,
          "value": "1976558550",
          "tsuid": "0023E3000002000008000006000001"
      },
      {
          "timestamp": 1377118201000,
          "value": "1654587485",
          "tsuid": "0023E3000002000008000006001656"
      }
  ]
  
.. code-block:: javascript

  [
      {
          "metric": "tsd.hbase.rpcs",
          "timestamp": 1377186301000,
          "value": "2723265185",
          "tags": {
              "type": "put",
              "host": "tsd1"
          },
          "tsuid": "0023E3000002000008000006000001"
      },
      {
          "metric": "tsd.hbase.rpcs",
          "timestamp": 1377186301000,
          "value": "580720",
          "tags": {
              "type": "put",
              "host": "tsd2"
          },
          "tsuid": "0023E3000002000008000006017438"
      }
  ]