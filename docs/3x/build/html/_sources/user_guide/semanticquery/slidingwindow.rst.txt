Sliding Window
==============
.. index:: slidingwindow
Computes an aggregated value sliding over a single time series over time. E.g. with a configuration to sum 2 minute windows and a 5 values spaced at one minute intervals, values 1 and 2 are summed, then 2 and 3, then 3 and 4, etc. This can be used to smooth volatile time series.

Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "aggregator", "String", "Required", "The aggregation function to use on each window.", "null", "sum"
   "windowSize", "String", "Required", "A TSDB style duration for the window.", "null", "15m"
   "infectiousNan", "Boolean", "Optional", "Whether or not NaNs from the source data should infect each bucket when aggregating values. E.g. if one value out of 20 are ``NaN`` in a bucket and this is true, the bucket will return a ``NaN``. If all values in a bucket are ``NaN`` then the result will be ``NaN`` regardless..", "false", "true"
   
Note that interpolation is not required here. If a "window" is missing data, it's simply skipped.

This node can also be used to compute a cumulative sum (or any accumulation) by setting the window size to the query width. 

While this node will compute a basic moving average, see the :doc:`movingaverage` notes for a more configurable average computation, especially if you need to compute over a number of values instead of time.

Assume a config of ``aggregator=sum``, ``window=30s`` and an input set:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s", "T + 40s", "T + 50s", "T + 60s"
   
   "TS1", "1", "3", "2", "1", "4", "2", "5"
   "TS2", "1", "2", "N/A", "2", "1", "1", "3"

The result would be:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s", "T + 40s", "T + 50s", "T + 60s"
   
   "TS1", "1", "4", "6", "6", "7", "7", "11"
   "TS2", "1", "3", "3", "4", "3", "4", "5"

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
    			"id": "sw1",
    			"type": "SlidingWindow",
    		   "aggregator": "avg",
             "windowSize": "15m"
    			"sources": ["ds1"]
    		}
    	]
    }
