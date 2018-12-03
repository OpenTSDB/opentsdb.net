/api/stats/jmx
==============
.. index:: HTTP /api/stats/jvm
This endpoint scrapes the running JVM's JMX for information and statistics, dumping it to a JSON output.

.. NOTE ::

  The information printed will change depending on the JVM you are running the TSD under. In particular, the pools and GC sections will differ quite a bit.

Verbs
-----

* GET

Requests
--------

Via a query parameter you can filter the output returned from the JMX store.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "qry", "String", "Optional", "A JMX query to filter the results", "", "qry", "", "qry=org.glassfish.jersey:*"

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/stats/jmx
   
Response
--------
   
The response is an object with a ``beans`` array of JMX beans including their properties and reported measurements.

Example Response
^^^^^^^^^^^^^^^^

.. code-block :: javascript 

  {
	"beans": [{
			"domain": "org.glassfish.jersey",
			"properties": {
				"method": "OPTIONS->apply(ContainerRequestContext)#99389942",
				"type": "App_36f7fd7b",
				"subType": "Resources",
				"executionTimes": "RequestTimes",
				"resource": "org.glassfish.jersey.server.wadl.processor.OptionsMethodProcessor$PlainTextOptionsInflector",
				"detail": "methods"
			},
			"modelerType": "org.glassfish.jersey.server.internal.monitoring.jmx.ExecutionStatisticsDynamicBean",
			"MinTime[ms]_total": 0,
			"MaxTime[ms]_total": 0,
			"AverageTime[ms]_total": 0,
			"RequestRate[requestsPerSeconds]_total": 0,
			"RequestCount_total": 0,
			"MinTime[ms]_1m": -1,
			"MaxTime[ms]_1m": -1,
			"AverageTime[ms]_1m": -1,
			"RequestRate[requestsPerSeconds]_1m": 0,
			"RequestCount_1m": 0,
			"MinTime[ms]_1h": -1,
			"MaxTime[ms]_1h": -1,
			"AverageTime[ms]_1h": -1,
			"RequestRate[requestsPerSeconds]_1h": 0,
			"RequestCount_1h": 0,
			"MinTime[ms]_1s": -1,
			"MaxTime[ms]_1s": -1,
			"AverageTime[ms]_1s": -1,
			"RequestRate[requestsPerSeconds]_1s": 0,
			"RequestCount_1s": 0,
			"MinTime[ms]_15s": -1,
			"MaxTime[ms]_15s": -1,
			"AverageTime[ms]_15s": -1,
			"RequestRate[requestsPerSeconds]_15s": 0,
			"RequestCount_15s": 0,
			"MinTime[ms]_15m": -1,
			"MaxTime[ms]_15m": -1,
			"AverageTime[ms]_15m": -1,
			"RequestRate[requestsPerSeconds]_15m": 0,
			"RequestCount_15m": 0
		},
		{
			"domain": "org.glassfish.jersey",
			"properties": {
				"method": "OPTIONS->PlainTextOptionsInflector.apply(ContainerRequestContext)#99389942",
				"type": "App_36f7fd7b",
				"subType": "Uris",
				"executionTimes": "RequestTimes",
				"resource": "\"/api/stats/jmx\"",
				"detail": "methods"
			},
			"modelerType": "org.glassfish.jersey.server.internal.monitoring.jmx.ExecutionStatisticsDynamicBean",
			"MinTime[ms]_total": 0,
			"MaxTime[ms]_total": 0,
			"AverageTime[ms]_total": 0,
			"RequestRate[requestsPerSeconds]_total": 0,
			"RequestCount_total": 0,
			"MinTime[ms]_1m": -1,
			"MaxTime[ms]_1m": -1,
			"AverageTime[ms]_1m": -1,
			"RequestRate[requestsPerSeconds]_1m": 0,
			"RequestCount_1m": 0,
			"MinTime[ms]_1h": -1,
			"MaxTime[ms]_1h": -1,
			"AverageTime[ms]_1h": -1,
			"RequestRate[requestsPerSeconds]_1h": 0,
			"RequestCount_1h": 0,
			"MinTime[ms]_1s": -1,
			"MaxTime[ms]_1s": -1,
			"AverageTime[ms]_1s": -1,
			"RequestRate[requestsPerSeconds]_1s": 0,
			"RequestCount_1s": 0,
			"MinTime[ms]_15s": -1,
			"MaxTime[ms]_15s": -1,
			"AverageTime[ms]_15s": -1,
			"RequestRate[requestsPerSeconds]_15s": 0,
			"RequestCount_15s": 0,
			"MinTime[ms]_15m": -1,
			"MaxTime[ms]_15m": -1,
			"AverageTime[ms]_15m": -1,
			"RequestRate[requestsPerSeconds]_15m": 0,
			"RequestCount_15m": 0
		}
	 ]
  }