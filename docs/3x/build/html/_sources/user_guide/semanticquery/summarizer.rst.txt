Summarizer
==========
.. index:: summarizer
Computes one or more aggreagtion summaries over a time series for the full query width. E.g. the serializer can print the individual values for a time series but by adding a summarizer, it can also emmit the max, min and average.

.. NOTE::

    This is a much more efficient means of computing statistics about a time series than trying to setup a number of separate graphs to compute the same value as it will compute all stats from the same input series.
    
This is most useful as the last node in a graph when a UI is plotting the time series and then the summary values in a legend.

Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "summaries", "List", "Required", "A list of one or more aggregation functions to compute on the time series.", "null", "[""max"", ""min"", ""avg""]"
   "infectiousNan", "Boolean", "Optional", "Whether or not NaNs from the source data should infect the final aggregation. E.g. if one value out of 20 are ``NaN`` in the source this is true, the aggregation will return a ``NaN``. If all values in the source are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"

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
    			"id": "rate1",
    			"type": "rate",
    			"interval": "1s",
    			"deltaOnly": true,
    			"sources": ["ds1"]
    		},
    		{
    			"id": "summarizer",
    			"type": "summarizer",
    			"summaries": ["avg", "max", "min"]
    			"sources": ["rate1"]
    		}
    	]
    }
