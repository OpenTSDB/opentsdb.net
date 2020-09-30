Ratio
=====
.. index:: ratio
For each time series in a set of time series, computes the ratio of that time series against the sum of all time series for the group matching the metric. For example, if you want to know the percentage of traffic each host is handling for a cluster in a data center, you can use the ratio to show that percentage over time. The output can be a percentage (e.g. 20.5) or a ratio (e.g. 0.205).

Fields for the ratio config include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "dataSource", "String", "Required", "The TimeSeriesDataSource node ID to match and compute a ratio on.", "null", "m1"
   "as", "String", "Required", "The metric name to substitute for the output of the node.", "null", "host_traffic_ratio"
   "asPercent", "boolean", "Optional", "Whether or not to convert the ratio to a percentage (simply multyping it by 100).", "false", "true"
   "infectiousNan", "boolean", "Optional", "Whether or not NaNs from the source data should infect each timestamp when aggregating values. E.g. if one value out of 20 are ``NaN`` for a timestamp and this is true, the timestamp will return a ``NaN``. If all values for the timestamp are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"
   "interpolatorConfig", "List", "Required *for now*", "A list of interpolator configs for the downsampler to deal with empty buckets.", "null", "See :doc:`interpolator`"

Example:

.. code-block:: javascript

    {
    	"start": "1h-ago",
    	"executionGraph": [{
    			"id": "m1",
    			"type": "TimeSeriesDataSource",
    			"metric": {
    				"type": "MetricLiteral",
    				"metric": "sys.if.in"
    			}
    		},
    		{
    			"id": "ds1",
    			"type": "downsample",
    			"aggregator": "sum",
    			"interval": "1m",
    			"runAll": false,
    			"fill": true,
    			"interpolatorConfigs": [{
    				"dataType": "numeric",
    				"fillPolicy": "NAN",
    				"realFillPolicy": "NONE"
    			}],
    			"sources": ["m1"]
    		},
    		{
				"id": "ratio",
				"type":"ratio",
			    "dataSource":"m1",
				"as":"colo_ratio",
			    "asPercentage":true,
				"sources": ["ds1"]
			}
    	]
    }
  
  An implementation note: The node adds a Group By node to the execution graph that sums all time series for the given data source ID. It then replaces itself with an expression node that divides each time series with the group by result using a cross join. If `asPercentage` is set to true, an extra expression node is added to multiply the ratio by 100.