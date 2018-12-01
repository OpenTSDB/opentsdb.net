/api/stats/query
================
.. index:: HTTP /api/stats/query
This endpoint can be used for tracking and troubleshooting queries executed against a TSD. It maintains an unbounded list of currently executing queries as well as a list of up to 256 completed queries (rotating the oldest queries out of memory). Information about each query includes the original query, request headers, response code, timing and an exception if thrown. (v2.2)

Verbs
-----

* GET

Requests
--------

No parameters available.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/stats/query
   
Response
--------
   
The response includes two arrays. ``completed`` lists the 256 most recent queries that have finished execution, whether successfully or with an error. The ``running`` array contains a list of queries currently executing. If this list is growing, the TSD is under heavy load. Note that the running list will not contain an exception, response code or timing details.

For information on the various sections and data from the stats endpoint, see :doc:`../../user_guide/query/stats`.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
  	"completed": [{
  		"query": {
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
  		},
  		"exception": "null",
  		"executed": 1,
  		"user": null,
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
  		},
  		"numRunningQueries": 0,
  		"httpResponse": {
  			"code": 200,
  			"reasonPhrase": "OK"
  		},
  		"queryStartTimestamp": 1455552844368,
  		"queryCompletedTimestamp": 1455552844621,
  		"sentToClient": true,
  		"stats": {
  			"avgAggregationTime": 2.11416,
  			"avgHBaseTime": 200.267711,
  			"avgQueryScanTime": 242.037174,
  			"avgScannerTime": 200.474122,
  			"avgScannerUidToStringTime": 0.0,
  			"avgSerializationTime": 2.124153,
  			"emittedDPs": 716,
  			"maxAggregationTime": 2.093369,
  			"maxHBaseTime": 241.708782,
  			"maxQueryScanTime": 240.637231,
  			"maxScannerUidtoStringTime": 0.0,
  			"maxSerializationTime": 2.103411,
  			"maxUidToStringTime": 0.059345,
  			"processingPreWriteTime": 253.050907,
  			"successfulScan": 40,
  			"totalTime": 256.568992,
  			"uidPairsResolved": 0
  		}
  	}],
  	"running": []
  }
