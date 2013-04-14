JSON Serializer
===============

The default OpenTSDB serializer parses and returns JSON formatted data.

Serializer Name
---------------

``json``

Serializer Options
------------------

The following options are supported via query string:

.. csv-table::
   :header: "Parameter", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 55, 10, 15
   
   "jsonp", "String", "Optional", "Wraps the response in a JavaScript function name passed to the parameter.", "``empty``", "jsonp=callback"
   
JSONP
-----

The JSON formatter can wrap responses in a JavaScript function using the ``jsonp`` query string parameter. Supply the name of the function you wish to use and the result will be wrapped.

Example Request
^^^^^^^^^^^^^^^
::

  http://localhost:4242/api/version?jsonp=callback

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  callback({
      "timestamp": "1362712695",
      "host": "DF81QBM1",
      "repo": "/c/temp/a/opentsdb/build",
      "full_revision": "11c5eefd79f0c800b703ebd29c10e7f924c01572",
      "short_revision": "11c5eef",
      "user": "df81qbm1_/clarsen",
      "repo_status": "MODIFIED",
      "version": "2.0.0"
  })
  
api/put
-------

Each data point for the JSON serializer requires the following fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "metric", "String", "Required", "The name of the metric you are storing", "", "", "W", "sys.cpu.nice"
   "timestamp", "Integer", "Required", "A Unix epoch style timestamp in seconds or milliseconds. The timestamp must not contain non-numeric characters.", "", "", "W", "1365465600"
   "value", "Integer, Float, String", "Required", "The value to record for this data point. It may be quoted or not quoted and must conform to the OpenTSDB value rules: :doc:`../../user_guide/writing`", "", "", "W", "42.5"
   "tags", "Map", "Required", "A map of tag name/tag value pairs. At least one pair must be supplied.", "", "", "W", "{""host"":""web01""}"
   
Example Single Data Point Put
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can supply a single data point in a request:

.. code-block :: javascript

  {
      "metric": "sys.cpu.nice",
      "timestamp": 1346846400,
      "value": 18,
      "tags": {
         "host": "web01",
         "dc": "lga"
      }
  }
  
Example Multiple Data Point Put
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Multiple data points must be encased in an array:

.. code-block :: javascript

  [
      {
          "metric": "sys.cpu.nice",
          "timestamp": 1346846400,
          "value": 18,
          "tags": {
             "host": "web01",
             "dc": "lga"
          }
      },
      {
          "metric": "sys.cpu.nice",
          "timestamp": 1346846400,
          "value": 9,
          "tags": {
             "host": "web02",
             "dc": "lga"
          }
      }
  ]
  
api/query
---------

Requests
^^^^^^^^

Instead of using the query string method, you can build a query as a JSON object and pass it along with a POST request. A request consists of one or more sub queries along with overall query fields. Top level fields include:

.. csv-table::
  :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
  :widths: 10, 10, 5, 50, 10, 15
   
  "start", "String, Integer", "Required", "The start time for the query. This can be a relative or absolute timestamp. See :doc:`../../user_guide/query/index` for details.", "", "1h-ago"
  "end", "String, Integer", "Optional", "An end time for the query. If not supplied, the TSD will assume the local system time on the server. This may be a relative or absolute timestamp. See :doc:`../../user_guide/query/index` for details.", "*current time*", "1s-ago"
  "padding", "Boolean", "Optional", "Whether or not the response should include one data point to either side of the requested time range. This is used for some graphing methods that require extra data for proper display.", "false", "true"
  "queries", "Array", "Required", "A list of one or more sub queries describing the timeseries data to retrieve", "", "*See Below*"
   
Each query can retrieve one or sets of timeseries data, performing aggregation or grouping calculations on each set. Fields for each sub query include:

.. csv-table::
  :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
  :widths: 10, 10, 5, 50, 10, 15
  
  "aggregator", "String", "Required", "The name of an aggregation function to use. See :doc:`../aggregators`", "", "sum"
  "metric", "String", "Required", "The name of a metric stored in the system", "", "sys.cpu.0"
  "rate", "Boolean", "Optional", "Whether or not the data should be converted into deltas before returning. This is useful if the metric is a continously incrementing counter and you want to view the rate of change between data points.", "false", "true"
  "downsample", "String", "Optional", "An optional downsampling function to reduce the amount of data returned. See `/q <http://opentsdb.net/http-api.html#/q>`_", "", "5m-avg"
  "tags", "Map", "Optional", "To drill down to specific timeseries or group results by tag, supply one or more map values in the same format as the query string. See `/q <http://opentsdb.net/http-api.html#/q>`_. Note that if no tags are specified, all metrics in the system will be aggregated into the results.", "", "*See Below*"

Additionally, the JSON serializer allows some query string parameters that modify the output but have no effect on the data retrieved.

.. csv-table::
  :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
  :widths: 10, 10, 5, 50, 10, 15
  
  "arrays", "Boolean", "Optional", "Returns the data points formatted as an array of arrays instead of a map of key/value pairs. Each array consists of the timestamp followed by the value.", "", "asarrays=true"

Example JSON Request
^^^^^^^^^^^^^^^^^^^^

.. code-block :: javascript

  {
      "start": 1356998400,
      "end": 1356998460,
      "queries": [
          {
              "aggregator": "sum",
              "metric": "sys.cpu.0",
              "rate": "true",
              "tags": {
                  "host": "*",
                  "dc": "lga"
              }
          }
      ]
  }
  
Response
^^^^^^^^

Query responses are arrays of result sets, with one result set per timeseries or aggregated set. If none of the queries returned data, the response will be an empty array, e.g. ``[]``. Fields returned in the response include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20
  
  "metric", "String", "Name of the metric retreived", "sys.cpu.0"
  "tags", "Map", "A list of tags only returned when the results are for a single timeseries. If results are aggregated, this value may be null or an empty map", """tags"":{""host"":""web01""}"
  "aggregated_tags", "Array", "If more than one timeseries were included in the result set, i.e. they were aggregated, this will display a list of tag names that were found in common across all time series.", """aggregated_tags"":[""host""]"
  "dps", "Map, Array", "Retrieved data points after being processed by the aggregators. Each data point consists of a timestamp and a value, the format determined by query string parameters.", "*See Below*"
  
Example Aggregated Default Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block :: javascript

  [
      {
          "metric": "tsd.hbase.puts",
          "tags": {},
          "aggregated_tags": [
              "host"
          ],
          "dps": {
              "1365966001": 25595461080,
              "1365966061": 25595542522,
              "1365966062": 25595543979,
  ...
              "1365973801": 25717417859
          }
      }
  ]

Example Aggregated Array Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block :: javascript

  [
      {
          "metric": "tsd.hbase.puts",
          "tags": {},
          "aggregated_tags": [
              "host"
          ],
          "dps": [
              [
                  1365966001,
                  25595461080
              ],
              [
                  1365966061,
                  25595542522
              ],
  ...
              [
                  1365974221,
                  25722266376
              ]
          ]
      }
  ]
  
Example Multi-Set Response
^^^^^^^^^^^^^^^^^^^^^^^^^^

For the following example, two TSDs were running and the query was: ``http://localhost:4242/api/query?start=1h-ago&m=sum:tsd.hbase.puts{host=*}``

.. code-block :: javascript

  [
      {
          "metric": "tsd.hbase.puts",
          "tags": {
              "host": "tsdb-1.mysite.com"
          },
          "aggregated_tags": [],
          "dps": {
              "1365966001": 3758788892,
              "1365966061": 3758804070,
  ...
              "1365974281": 3778141673
          }
      },
      {
          "metric": "tsd.hbase.puts",
          "tags": {
              "host": "tsdb-2.mysite.com"
          },
          "aggregated_tags": [],
          "dps": {
              "1365966001": 3902179270,
              "1365966062": 3902197769,
  ...
              "1365974281": 3922266478
          }
      }
  ]

