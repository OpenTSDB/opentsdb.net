Moving Average
==============
.. index:: movingaverage
Computes a moving (or sliding / tumbling) average over a time series. The average can be computed on either a fixed number of values or a time range. This function supports:

* Simple moving average.
* Simple weighted moving average.
* Moving median.
* Exponential moving average with configurable alpha and initial value.

Windows can be based on the number of samples or over time (Note we generally recommend time based windows).

Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "samples", "Integer", "Optional", "The positive number of non-NaN values to maintain for each moving window. Must be greater than zero when used. Note that if this is null, ``interval`` must be set.", "null", "5"
   "interval", "String", "Optional", "A TSDB style duration defining the width of the window in time. If this is null ``samples`` must be set to a positive value.", "null", "15m"
   "alpha", "Float", "Optional", "The coefficient of weighting decrease, between 0 and 1. A higher alpha value discounts ealier values faster. If not set, an alpha is computed based on the number of samples in the window", "null", "0.25"
   "avgInitial", "Boolean", "Optional", "When ``exponential`` is set and this parameter is true, the entire window is run through to compute a straight average to use as the first exponential weight.", "false", "true"
   "median", "Boolean", "Optional", "When set to true, computes a moving median instead of a moving average. I.e. values are sorted for a window then the median is chosen. Note that if this is true, all other settings are ignored.", "false", "true"
   "weighted", "Boolean", "Optional", "Whether or not to compute a linear weighted moving averagle. When set to true (by itself), then more recent values in the sample window will have a greater effect on the average than ealier values.", "false", "true"
   "exponential", "Boolean", "Optional", "Whether or not to compute the exponentially weighted average over the window.", "false", "true"
   "infectiousNaN", "Boolean", "Optional", "Whether or not NaNs from the source data should infect the final aggregation. E.g. if one value out of 20 are ``NaN`` in the source this is true, the aggregation will return a ``NaN``. If all values in the source are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"

Moving Average Example
----------------------

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
    			"id": "mva1",
    			"type": "movingaverage",
    			"interval": "5m",
    			"sources": ["ds1"]
    		}
    	]
    }
    
Weighted Moving Average Example
-------------------------------

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
    			"id": "mva1",
    			"type": "movingaverage",
    			"interval": "5m",
    			"weighted": true,
    			"sources": ["ds1"]
    		}
    	]
    }

Exponential Weighted Moving Average Example
-------------------------------------------

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
    			"id": "mva1",
    			"type": "movingaverage",
    			"interval": "5m",
    			"exponential": true,
    			"sources": ["ds1"]
    		}
    	]
    }