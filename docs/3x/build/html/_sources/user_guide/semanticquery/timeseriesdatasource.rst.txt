TimeSeriesDataSource
====================
.. index:: timeseriesdatasource
The most important node in OpenTSDB as every query must have one or more data sources, this type of node will retreive data and pass it through the execution graph.

There can be a number of time series data sources configured for a TSD system. 

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
   "timeShiftInterval", "String", "Optional", "An optional duration by which the data will be looked for in the past and timestamps shifted to align with the ""current"" time. See the Time Shift section below.", "null", "1d"

Time Shift
----------
When analyzing time series it's often useful to compare a time range of data against the same time range maybe a day ago or a week ago. Using the ``timeShiftInterval`` setting you can issue one query and fetch data for multiple periods offset by a given interval. The data returned is shifted to the same time range given in the original query so that the data can be plotted on the same graph or used in expressions where data will be aligned for the same time but shifted by an interval.

An example query for three days of data: 

.. code-block:: javascript

    {
    	"start": "1h-ago",
    	"executionGraph": [{
    		"id": "m0",
    		"type": "TimeSeriesDataSource",
    		"metric": {
    			"type": "MetricLiteral",
    			"metric": "sys.if.in"
    		}
    	}, {
    		"id": "m0-1d",
    		"type": "TimeSeriesDataSource",
    		"metric": {
    			"type": "MetricLiteral",
    			"metric": "sys.if.in"
    		},
    		"timeShiftInterval": "1d"
    	}, {
    		"id": "m0-1d",
    		"type": "TimeSeriesDataSource",
    		"metric": {
    			"type": "MetricLiteral",
    			"metric": "sys.if.in"
    		},
    		"timeShiftInterval": "2d"
    	}]
    }

The response will have three data source sets, ``m0, m0-1d and m0-2d``.
