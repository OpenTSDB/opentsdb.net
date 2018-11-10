Query Details and Stats
=======================
.. index:: stats
With version 2.2 of OpenTSDB a number of details are now available around queries as we focus on improving flexibility and performance. Query details include who made the request (via headers and socket), what the response was (HTTP status codes and/or exceptions) and timing around the various processes the TSD takes. 

Each HTTP query can include some of these details such as the original query and the timing information using the  ``showSummary`` and ``showQuery`` parameters. Other details can be found in the ``/api/stats/query`` output including headers, status and exceptions. And full details (minus the actual result data) can be logged to disk via the logging config. This page details the various query sections and the information found therein.

Query
^^^^^

This section is a serialization of the query given by the user. In the logs and stats page this will be the full query with timing and global options. When returned with the query results, only the sub query (metric and filters) are returned with the associated result set for identification purposes (e.g. if you request the same metric twice with two different aggregators, you need to know which data set corresponds to which aggregator).

For the fields and what they mean, see :doc:`../../api_http/query/index`. Some notes about the fields:

* The ``tags`` map should have the same number of entries as the ``filters`` array has ``group_by`` entries. This is due to backwards compatibility with 2.1 and 1.0. Old style queries are converted into filtered queries and function the same way.
* A number of extra fields may be shown here with their default values such as ``null``. 
* You can copy and paste the query into a POST client to execute and find out what data was returned.

Example
-------

.. code-block :: javascript

  {
  	"start": "1455531250181",
  	"end": null,
  	"timezone": null,
  	"options": null,
  	"padding": false,
  	"queries": [{
  		"aggregator": "zimsum",
  		"metric": "tsd.connectionmgr.bytes.written",
  		"tsuids": null,
  		"downsample": "1m-avg",
  		"rate": true,
  		"filters": [{
  			"tagk": "colo",
  			"filter": "*",
  			"group_by": true,
  			"type": "wildcard"
  		}, {
  			"tagk": "env",
  			"filter": "prod",
  			"group_by": true,
  			"type": "literal_or"
  		}, {
  			"tagk": "role",
  			"filter": "frontend",
  			"group_by": true,
  			"type": "literal_or"
  		}],
  		"rateOptions": {
  			"counter": true,
  			"counterMax": 9223372036854775807,
  			"resetValue": 1,
  			"dropResets": false
  		},
  		"tags": {
  			"role": "literal_or(frontend)",
  			"env": "literal_or(prod)",
  			"colo": "wildcard(*)"
  		}
  	}, {
  		"aggregator": "zimsum",
  		"metric": "tsd.hbase.rpcs.cumulative_bytes_received",
  		"tsuids": null,
  		"downsample": "1m-avg",
  		"rate": true,
  		"filters": [{
  			"tagk": "colo",
  			"filter": "*",
  			"group_by": true,
  			"type": "wildcard"
  		}, {
  			"tagk": "env",
  			"filter": "prod",
  			"group_by": true,
  			"type": "literal_or"
  		}, {
  			"tagk": "role",
  			"filter": "frontend",
  			"group_by": true,
  			"type": "literal_or"
  		}],
  		"rateOptions": {
  			"counter": true,
  			"counterMax": 9223372036854775807,
  			"resetValue": 1,
  			"dropResets": false
  		},
  		"tags": {
  			"role": "literal_or(frontend)",
  			"env": "literal_or(prod)",
  			"colo": "wildcard(*)"
  		}
  	}],
  	"delete": false,
  	"noAnnotations": false,
  	"globalAnnotations": false,
  	"showTSUIDs": false,
  	"msResolution": false,
  	"showQuery": false,
  	"showStats": false,
  	"showSummary": false
  }

Exception
^^^^^^^^^

If the query failed, this field will include the message string and the first line of the stack trace for pinpointing. If the query was successful, this field will be null.

Example
-------

.. code-block :: javascript

 "exception": "No such name for 'metrics': 'nosuchmetric' net.opentsdb.uid.UniqueId$1GetIdCB.call(UniqueId.java:315)"

User
^^^^

For future use, this field can be used to extract user information from queries and help debug who is using a TSD the most. It's fairly easy to modify the TSD code to extract the user from an HTTP header.

RequestHeaders
^^^^^^^^^^^^^^

This is a map of the headers sent with the HTTP request. In a mediocre effort at security, the ``Cookie`` header field is obfuscated with asterisks in the case that it contains user identifiable or secure information. Each request is different so lookup the headers in the HTTP RFCs or your web browser or clients documentation.


Example
-------

.. code-block :: javascript

  "requestHeaders": {
      "Accept-Language": "en-US,en;q=0.8",
      "Host": "tsdhost:4242",
      "Content-Length": "440",
      "Referer": "http://tsdhost:8080/dashboard/db/tsdfrontend",
      "Accept-Encoding": "gzip, deflate",
      "X-Forwarded-For": "192.168.0.2",
      "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36",
      "Origin": "http://tsdhost:8080",
      "Content-Type": "application/json;charset=UTF-8",
      "Accept": "application/json, text/plain, */*"
  }


HttpResponse
^^^^^^^^^^^^

This field contains the numeric HTTP response code and a textual representation of that code.

Example
-------

.. code-block :: javascript

	"httpResponse": {
		"code": 200,
		"reasonPhrase": "OK"
	}

Other Fields
^^^^^^^^^^^^

The output for log files and the stats page include other fields with single values as listed below:

.. csv-table::
   :header: "Metric", "Type", "Description"
   :widths: 20, 20, 60
   
   "executed", "Counter", "If the same query was executed multiple times (same times, same agent, etc) then this integer counter will increment. Use this to find out when a client may want to start caching results."
   "numRunningQueries", "Gauge", "How many queries were executing at the time the query was made (note that for the stats page this will always be up-to-date)"
   "queryStartTimestamp", "Timestamp (ms)", "The timestamp (Unix epoch in milliseconds) when the query was received and started processing."
   "queryCompletedTimestamp", "Timestamp (ms)", "The timestamp (Unix epoch in milliseconds) when the query was finished and sent to the client."
   "sentToClient", "boolean", "Whether or not the query was successfully sent to the client. It may be blocked due to a socket exception or full write buffer."
   
Stats
^^^^^

A number of statistics are available around each query and more will be added over time. Various levels of detail are measured including:

* **Global** - Metrics pertaining to the entire query including max and average timings of each sub query.
* **Per-Sub Query** - Metrics pertaining to a single sub query (if multiple are present) including max and average timings of scanner.
* **Per-Scanner** - Metrics around each individual scanner (useful when salting is enabled)

Global stats are printed to the standard log, stats page. The full global, sub query and scanner details are available in the query log and via the query API when ``showSummary`` is present. Timing stats at a lower level are aggregated into max and average values at the upper level. Counters at each lower level are also aggregated at each upper level so you'll see the same counter metrics at each level. A table of stats and sections appears below.

.. NOTE ::

  All timings in the table below are in milliseconds. Also note that times can be inflated by JVM GCs so make sure to enable GC logging if something seems off.

.. csv-table::
   :header: "Metric", "Type", "Section", "Description"
   :widths: 20, 10, 20, 50
   
   "compactionTime", "Float", "Scanner", "Cumulative time spent running each row through the compaction code to create a single column and manage duplicate values."
   "hbaseTime", "Float", "Scanner", "Cumulative time spent waiting on HBase to return data. (Includes AsyncHBase deserialization time)."
   "scannerId", "String", "Scanner", "Details about the scanner including the table, start and end keys as well as filters used."
   "scannerTime", "Float", "Scanner", "The total time from initialization of the scanner to when the scanner completed and closed."
   "scannerUidToStringTime", "Float", "Scanner", "Cumulative time spent resolving UIDs from row keys to strings for use with regex and wildcard filters. If neither filter is used this value should be zero."
   "successfulScan", "Integer", "Scanner, Query, Global", "How many scanners completed successfully. Per query, this should be equal to the number of salting buckets, or ``1`` if salting is disabled."
   "uidPairsResolved", "Integer", "Scanner", "Total number of row key UIDs resolved to tag values when a regex or wildcard filter is used. If neither filter is used this value should be zero."
   "aggregationTime", "Float", "Query", "Cumulative time spent aggregating data points including downsampling, multi-series aggregation and rate calculations."
   "groupByTime", "Float", "Query", "Cumulative time spent sorting scanner results into groups for future aggregation."
   "queryScanTime", "Float", "Query", "Total time spent waiting on the scanners to return results. This includes the ``groupByTime``."
   "saltScannerMergeTime", "Float", "Query", "Total time spent merging the salt scanner results into a single set prior to group by operations."
   "serializationTime", "Float", "Query", "Total time spent serializing the query results. This includes ``aggregationTime`` and ``uidToStringTime``."
   "uidToStringTime", "Float", "Query", "Cumulative time spent resolving UIDs to strings for serialization."
   "emittedDPs", "Integer", "Query, Global", "The total number of data points serialized in the output. Note that this may include NaNs or Nulls if the query specified such."
   "queryIndex", "Integer", "Query", "The index of the sub query in the original user supplied query list."
   "processingPreWriteTime", "Float", "Global", "Total time spent processing, fetching data and serializing results for the query until it is written over the wire. This value is sent in the API summary results and used as an estimate of the total time spent processing by the TSD. However it does not include the amount of time it took to send the value over the wire."
   "totalTime", "Float", "Global", "Total time spent on the query including writing to the socket. This is only found in the log files and stats API."

Example
-------

.. code-block :: javascript

  {
  	"statsSummary": {
  		"avgAggregationTime": 3.784976,
  		"avgHBaseTime": 8.530751,
  		"avgQueryScanTime": 10.964149,
  		"avgScannerTime": 8.588306,
  		"avgScannerUidToStringTime": 0.0,
  		"avgSerializationTime": 3.809661,
  		"emittedDPs": 1256,
  		"maxAggregationTime": 3.759478,
  		"maxHBaseTime": 9.904215,
  		"maxQueryScanTime": 10.320964,
  		"maxScannerUidtoStringTime": 0.0,
  		"maxSerializationTime": 3.779712,
  		"maxUidToStringTime": 0.197926,
  		"processingPreWriteTime": 20.170205,
  		"queryIdx_00": {
  			"aggregationTime": 3.784976,
  			"avgHBaseTime": 8.849337,
  			"avgScannerTime": 8.908597,
  			"avgScannerUidToStringTime": 0.0,
  			"emittedDPs": 628,
  			"groupByTime": 0.0,
  			"maxHBaseTime": 9.904215,
  			"maxScannerUidtoStringTime": 0.0,
  			"queryIndex": 0,
  			"queryScanTime": 10.964149,
  			"saltScannerMergeTime": 0.128234,
  			"scannerStats": {
  				"scannerIdx_00": {
  					"compactionTime": 0.048703,
  					"hbaseTime": 8.844783,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[0, 0, 2, 88, 86, -63, -25, -16], stop_key=[0, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.899045,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_01": {
  					"compactionTime": 0.066892,
  					"hbaseTime": 8.240165,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[1, 0, 2, 88, 86, -63, -25, -16], stop_key=[1, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.314855,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_02": {
  					"compactionTime": 0.01298,
  					"hbaseTime": 8.462203,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[2, 0, 2, 88, 86, -63, -25, -16], stop_key=[2, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.478315,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_03": {
  					"compactionTime": 0.036998,
  					"hbaseTime": 9.862741,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[3, 0, 2, 88, 86, -63, -25, -16], stop_key=[3, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.904215,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_04": {
  					"compactionTime": 0.058698,
  					"hbaseTime": 9.523481,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[4, 0, 2, 88, 86, -63, -25, -16], stop_key=[4, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.587324,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_05": {
  					"compactionTime": 0.041017,
  					"hbaseTime": 9.757787,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[5, 0, 2, 88, 86, -63, -25, -16], stop_key=[5, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.802395,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_06": {
  					"compactionTime": 0.062371,
  					"hbaseTime": 9.332585,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[6, 0, 2, 88, 86, -63, -25, -16], stop_key=[6, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.40264,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_07": {
  					"compactionTime": 0.063974,
  					"hbaseTime": 8.195105,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[7, 0, 2, 88, 86, -63, -25, -16], stop_key=[7, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.265713,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_08": {
  					"compactionTime": 0.062196,
  					"hbaseTime": 8.21871,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[8, 0, 2, 88, 86, -63, -25, -16], stop_key=[8, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.287582,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_09": {
  					"compactionTime": 0.051666,
  					"hbaseTime": 7.790636,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[9, 0, 2, 88, 86, -63, -25, -16], stop_key=[9, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 7.849597,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_10": {
  					"compactionTime": 0.036429,
  					"hbaseTime": 7.6472,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[10, 0, 2, 88, 86, -63, -25, -16], stop_key=[10, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 7.689386,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_11": {
  					"compactionTime": 0.044493,
  					"hbaseTime": 7.897932,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[11, 0, 2, 88, 86, -63, -25, -16], stop_key=[11, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 7.94793,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_12": {
  					"compactionTime": 0.025362,
  					"hbaseTime": 9.30409,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[12, 0, 2, 88, 86, -63, -25, -16], stop_key=[12, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.332411,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_13": {
  					"compactionTime": 0.057429,
  					"hbaseTime": 9.215958,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[13, 0, 2, 88, 86, -63, -25, -16], stop_key=[13, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.278104,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_14": {
  					"compactionTime": 0.102855,
  					"hbaseTime": 9.598685,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[14, 0, 2, 88, 86, -63, -25, -16], stop_key=[14, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.712258,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_15": {
  					"compactionTime": 0.0727,
  					"hbaseTime": 9.273193,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[15, 0, 2, 88, 86, -63, -25, -16], stop_key=[15, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.35403,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_16": {
  					"compactionTime": 0.025867,
  					"hbaseTime": 9.011146,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[16, 0, 2, 88, 86, -63, -25, -16], stop_key=[16, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.039663,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_17": {
  					"compactionTime": 0.066071,
  					"hbaseTime": 9.175692,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[17, 0, 2, 88, 86, -63, -25, -16], stop_key=[17, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 9.24738,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_18": {
  					"compactionTime": 0.090249,
  					"hbaseTime": 8.730833,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[18, 0, 2, 88, 86, -63, -25, -16], stop_key=[18, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.831461,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_19": {
  					"compactionTime": 0.039327,
  					"hbaseTime": 8.903825,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[19, 0, 2, 88, 86, -63, -25, -16], stop_key=[19, 0, 2, 88, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.947639,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				}
  			},
  			"serializationTime": 3.809661,
  			"successfulScan": 20,
  			"uidPairsResolved": 0,
  			"uidToStringTime": 0.197926
  		},
  		"queryIdx_01": {
  			"aggregationTime": 3.73398,
  			"avgHBaseTime": 8.212164,
  			"avgScannerTime": 8.268015,
  			"avgScannerUidToStringTime": 0.0,
  			"emittedDPs": 628,
  			"groupByTime": 0.0,
  			"maxHBaseTime": 8.986041,
  			"maxScannerUidtoStringTime": 0.0,
  			"queryIndex": 1,
  			"queryScanTime": 9.67778,
  			"saltScannerMergeTime": 0.095797,
  			"scannerStats": {
  				"scannerIdx_00": {
  					"compactionTime": 0.054894,
  					"hbaseTime": 8.708179,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[0, 0, 2, 76, 86, -63, -25, -16], stop_key=[0, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.770252,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_01": {
  					"compactionTime": 0.055956,
  					"hbaseTime": 8.666615,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[1, 0, 2, 76, 86, -63, -25, -16], stop_key=[1, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.730629,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_02": {
  					"compactionTime": 0.011224,
  					"hbaseTime": 8.474637,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[2, 0, 2, 76, 86, -63, -25, -16], stop_key=[2, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.487582,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_03": {
  					"compactionTime": 0.081926,
  					"hbaseTime": 8.894951,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[3, 0, 2, 76, 86, -63, -25, -16], stop_key=[3, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.986041,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_04": {
  					"compactionTime": 0.01882,
  					"hbaseTime": 8.209866,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[4, 0, 2, 76, 86, -63, -25, -16], stop_key=[4, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.231502,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_05": {
  					"compactionTime": 0.056902,
  					"hbaseTime": 8.709846,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[5, 0, 2, 76, 86, -63, -25, -16], stop_key=[5, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.772216,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_06": {
  					"compactionTime": 0.131424,
  					"hbaseTime": 8.033916,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[6, 0, 2, 76, 86, -63, -25, -16], stop_key=[6, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.181117,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_07": {
  					"compactionTime": 0.022517,
  					"hbaseTime": 8.006976,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[7, 0, 2, 76, 86, -63, -25, -16], stop_key=[7, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.032073,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_08": {
  					"compactionTime": 0.011527,
  					"hbaseTime": 8.591358,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[8, 0, 2, 76, 86, -63, -25, -16], stop_key=[8, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.604491,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_09": {
  					"compactionTime": 0.162222,
  					"hbaseTime": 8.25452,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[9, 0, 2, 76, 86, -63, -25, -16], stop_key=[9, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.435525,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_10": {
  					"compactionTime": 0.033886,
  					"hbaseTime": 7.973254,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[10, 0, 2, 76, 86, -63, -25, -16], stop_key=[10, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.011236,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_11": {
  					"compactionTime": 0.039491,
  					"hbaseTime": 7.959601,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[11, 0, 2, 76, 86, -63, -25, -16], stop_key=[11, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.003249,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_12": {
  					"compactionTime": 0.107793,
  					"hbaseTime": 8.177353,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[12, 0, 2, 76, 86, -63, -25, -16], stop_key=[12, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.298284,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_13": {
  					"compactionTime": 0.020697,
  					"hbaseTime": 8.124243,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[13, 0, 2, 76, 86, -63, -25, -16], stop_key=[13, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.147879,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_14": {
  					"compactionTime": 0.033261,
  					"hbaseTime": 8.145149,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[14, 0, 2, 76, 86, -63, -25, -16], stop_key=[14, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.182331,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_15": {
  					"compactionTime": 0.057804,
  					"hbaseTime": 8.17854,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[15, 0, 2, 76, 86, -63, -25, -16], stop_key=[15, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.243458,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_16": {
  					"compactionTime": 0.01212,
  					"hbaseTime": 8.070582,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[16, 0, 2, 76, 86, -63, -25, -16], stop_key=[16, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 8.084813,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_17": {
  					"compactionTime": 0.036777,
  					"hbaseTime": 7.919167,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[17, 0, 2, 76, 86, -63, -25, -16], stop_key=[17, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 7.959645,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_18": {
  					"compactionTime": 0.048097,
  					"hbaseTime": 7.87351,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[18, 0, 2, 76, 86, -63, -25, -16], stop_key=[18, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 7.926318,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				},
  				"scannerIdx_19": {
  					"compactionTime": 0.0,
  					"hbaseTime": 7.271033,
  					"scannerId": "Scanner(table=\"tsdb\", start_key=[19, 0, 2, 76, 86, -63, -25, -16], stop_key=[19, 0, 2, 76, 86, -62, 4, 16], columns={\"t\"}, populate_blockcache=true, max_num_rows=128, max_num_kvs=4096, region=null, filter=KeyRegexpFilter(\"(?s)^.{8}(?:.{7})*\\Q\u0000\u0000\u0005\\E(?:\\Q\u0000\u0000\u00006\\E)(?:.{7})*$\", ISO-8859-1), scanner_id=0x0000000000000000)",
  					"scannerTime": 7.271664,
  					"scannerUidToStringTime": 0.0,
  					"successfulScan": 1,
  					"uidPairsResolved": 0
  				}
  			},
  			"serializationTime": 3.749764,
  			"successfulScan": 20,
  			"uidPairsResolved": 0,
  			"uidToStringTime": 0.162088
  		},
  		"successfulScan": 40,
  		"uidPairsResolved": 0
  	}
  }