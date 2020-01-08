TimeSeriesDataSource
====================
.. index:: timeseriesdatasource
Arguably the most important node in OpenTSDB, this type of node will retreive data and pass it through the execution graph.

There can be many types of time series data sources in the system including caching sources that will pull from a cache before trying to query a data store, routing sources to pick from various data stores and direct storage sources.

Fields common for all ata sources include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "metric", "Object", "Required", "A metric filter object (see below) that determines which metric(s) to fetch.", "null", "See :doc:`filters`"
   "fetchLast", "Boolean", "Optional", "Whether or not to just fetch the last possible value for the metric(s) if the underlying store supports such an operation.", "false", "true"
   "filter", "Object", "Optional", "A filter object to narrow down the choice of data.", "null", "See :doc:`filters`"
   "filterId", "String", "Optional", "An ID of a named filter in the containing query. If this field is not null and not empty then it would override the ``filter`` field.", "null", "f1"
   "sourceId", "String", "Optional", "The ID of a data source loaded in the Registry. If null, then the default data source is used.", "null", "AWS"
   "types", "List", "Optional", "A list of data types to filter out the response from the source. E.g. if the query only wants annotations it could specify that type here. By default all types are returned.", "null", "[""Annotations""]"
   "timeShiftInterval", "String", "Optional", "A duration used when previous or next intervals are set to determine the amount of time shifted.", "null", "1d"
   "previousIntervals", "Integer", "Optional", "The number of previous (earlier) periods of data to fetch. E.g. if the shift interval is set to ``1d`` then and this value is set to 2, the original query, the query shifted to the previous day and the data shifted to 2 days ago will be fetched", "0", "2"
   "nextIntervals", "Integer", "Optional", "The number of later or future periods of data to fetch.", "0", "2"

Time Shift
^^^^^^^^^^
When analyzing time series it's often useful to compare a time range of data against the same time maybe a day ago or a week ago. Using the ``timeShiftInterval`` and ``previousIntervals`` settings you can issue one query and fetch data for multiple periods offset by a given interval. The data returned is shifted to the same time range given in the original query so that the data can be plotted on the same graph or used in expressions.

An example query may look like: 

.. code-block:: javascript

    {
    	"start": "1h-ago",
    	"executionGraph": [{
    		"id": "m0",
    		"type": "TimeSeriesDataSource",
    		"metric": {
    			"type": "MetricLiteral",
    			"metric": "sys.if.in"
    		},
    		"timeShiftInterval":"1h",
    		"previousIntervals":2,
    		"filter":{
    			"type":"chain",
    			"filters":[
    				{
    					"type":"TagValueLiteralOr",
    					"filter":"PHX",
    					"tagKey":"dc"
    				},
    				{
    					"type":"TagValueLiteralOr",
    					"filter":"web01",
    					"tagKey":"host"
    				}
    		    ]
    		}
    	}
    	]
    }

For this query, we'll fetch the data from 1 hour ago until now, the data from 2 hours ago to 1 hour ago, and 3 hours ago to 2 hours ago. The result will look like:

.. code-block:: javascript

    {
        "results": [
            {
                "source": "m0-time-shift:m0-previous-PT2H",
                "data": [
                    {
                        "NumericType": {
                            "1553634000": 0,
                            "1553634060": 1,
                            ...
                            "1553636520": 42
                        },
                        "metric": "sys.if.in",
                        "tags": {
                            "host": "web01",
                            "dc": "PHX"
                        },
                        "aggregateTags": []
                    }
                ]
            },
            {
                "source": "m0-time-shift:m0-previous-PT1H",
                "data": [
                    {
                        "NumericType": {
                            "1553632980": 43,
                            "1553633040": 44,
                            ...
                            "1553636520": 43
                        },
                        "metric": "sys.if.in",
                        "tags": {
                            "host": "web01",
                            "dc": "PHX"
                        },
                        "aggregateTags": []
                    }
                ]
            },
            {
                "source": "m0:m0",
                "data": [
                    {
                        "NumericType": {
                            "1553632980": 44,
                            "1553633040": 45,
                            ...
                            "1553636520": 44
                        },
                        "metric": "sys.if.in",
                        "tags": {
                            "host": "web01",
                            "dc": "PHX"
                        },
                        "aggregateTags": []
                    }
                ]
            }
        ],
        "log": []
    }

Note that the original source is named ``m0:m0`` and the time shifted data comes from a node named ``m0-time-shift``, just the metric name appended with ``-time-shift`` (and this can be different of course when piped through another node). The data sources are always named in the format ``<metric ID>-<previous|next>-<ISO offset>`` such as ``m0-previous-PT1H``.

HACluster
^^^^^^^^^

This is a source that takes one or more downstream sources, sends the same query to each, then merge the results before sending them upstream. Use it when you write the same data to multiple clusters for high availability.

TODO - talk about the config.

Fields that can be set at query time include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25

   "dataSources", "List", "Optional", "A means of overriding the configured data sources by, for example, selecting a subset of sources or different sources entirely.", "null", "[""s1"", ""s2""]"
   "dataSourceConfigs", "List", "Optional", "An optional list of complete data source config nodes to execute downstream. This allows for custom configurations per source, e.g. maybe disable caching on one.", "null", "TODO"
   "mergeAggregator", "String", "Optional", "An optional override of the configured aggregator", "null", "max"
   "primaryTimeout", "String", "Optional", "An optional override of the configured primary timeout (i.e. how long to wait for the primary source when a secondary source has responded). In the TSDB duration format.", "null", "10s"
   "secondaryTimeout", "String", "Optional", "An optional override of the configured secondary timeout (i.e. how long to wait for at least one secondary source when the primary source has responded). In the TSDB duration format.", "null", "5s"