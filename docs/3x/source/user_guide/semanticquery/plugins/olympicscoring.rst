EGADS: Olympic Scoring
======================
.. index:: olympicscoring
The rate node is a bit complex with a number of flags and the following main features:

* Turning a monotonically increasing counter into a rate (e.g. TSDB 1x and 2x metrics that mostly reported counters at a given timestamp)
* Converting a stored rate back into a "count" over time.
* Compute the first derivative.
* Compute just the delta of values, ignoring time. (NOTE: We may push this into a separate node before a prod release).

Depending on the configuration of the node, the location in the execution graph should change. 

Fields for the rate config include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "interval", "String", "Optional", "A TSDB style duration to use when computing the rate. Defaults to per second.", "1s", "1m"
   "counter", "boolean", "Optional", "Whether or not the underlying series is a monotonically increasing counter and we should expect to handle resets.", "false", "true"
   "dropResets", "Boolean", "Optional", "Whether or not to drop values when resets occur and reset them to zero.", "false", "true"
   "counterMax", "Integer", "Optional", "The value at which we expect the counter to reset. The default is a 64 bit signed maximum integer value.", "Long.MAX_VALUE", "32000"
   "resetValue", "Integer", "Optional", "A value that, when exceeded, we reset to 0.", "0", "42"
   "dataInterval", "String", "Optional", "A TSDB style duration defining the expected reporting interval of the underlying data, used when converting a rate to a count via the ``rateToCount`` flag.", "null", "10s"
   "rateToCount", "Boolean", "Optional", "Whether or not to convert the rate to a count over the interval. For the best results, also set ``dataInterval``.", "false", "true"
   "deltaOnly", "Boolean", "Optional", "Whether or not to compute only the delta between values instead of the derivative.", "false", "true"
   
Counter To Rate
---------------

Some systems, such as network gear or previous OpenTSDB instances, report monotonically increasing counters over time. E.g. at T0, a metric may have a value of 5. At T1, it may become 10. At T2 it may stay at 10. The value will always stay the same or increase unless a *reset* occurs due to integer roll-over or a restart. 

For this use case, the ``rate`` node should immediately follow the data source node so that other functions can work on the rate data. Also make sure to set the ``counter`` flag to ``true``.

As an input example take:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "1", "3", "3", "6"
   "TS2", "1", "2", "N/A", "4"

The results with a configuration of ``interval=1s`` would be:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "NaN", "0.2", "0", "0.3"
   "TS2", "NaN", "0.1", "N/A", "0.1"

Note that the first value may be NaN'd if no previous value was found for the given query time span. The storage engine should try to pad and return an extra value before the first in order to calculate a proper rate but this may not always happen.

TODO - more docs on the counter flags from the old TSD docs.

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
    			"id": "rate1",
    			"type": "rate",
    			"interval": "1s",
    			"counter": true,
    			"dropResets": true,
    			"sources": ["m1"]
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
    			"sources": ["rate1"]
    		}
    	]
    }
  
Rate to Count
-------------
  
Similar to the counter to rate, the rate to count node should be the first node after the data source. This setting will take the 

The two important settings are the ``interval`` that reflects the interval of the rate stored and the ``dataInterval`` wherein you should set it to the reporting interval of the data source. E.g. if the source reports every 10 seconds, set the ``dataInterval`` to ``10s`` or if the source comes in every minute, set it to ``1m``. If you leave the ``dataInterval`` empty and the time series has missing values, you may see artifically inflated counts as the TSD will compute the time delta from the preivous existing value to the current value and multiple bny the interval to compute the count.

As an example, assume the following values.

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "1", "3", "2", "1"
   "TS2", "1", "2", "N/A", "2"
   
Lets assume ``interval=1s`` and ``dataInterval=10s``. The results would be:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "10", "30", "20", "10"
   "TS2", "10", "20", "N/A", "20"

If ``dataInterval`` was not set, TS2 would have the following values:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS2", "10", "20", "N/A", "40"

The value at ``T + 30s`` would subtract the time from ``T + 10s`` to get a value of ``20s`` then multiply that by the interval of ``1s``.

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
    			"id": "rate1",
    			"type": "rate",
    			"interval": "1s",
    			"counter": true,
    			"dropResets": true,
    			"sources": ["m1"]
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
    			"sources": ["rate1"]
    		}
    	]
    }

First Derivative or Rate
------------------------

If you aren't dealing with a monotonically increasing counter and just want to view the rate of change of any metric, then the rate node can be used in any locating in the execution graph. Just leave out the counter and other flags.

For example with an ``interval=1s`` and an input of: 

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "1", "3", "2", "1"
   "TS2", "1", "2", "N/A", "2"

The results would be:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "NaN", "0.2", "-0.1", "-0.1"
   "TS2", "NaN", "0.1", "N/A", "0"

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
    			"interval": "10s",
    			"sources": ["ds1"]
    		}
    	]
    }

Delta
-----

For cases where you just want the difference between values, set the the ``deltaOnly`` flag to true nad all other flags to false. The interval can be ignored. For an example input:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "1", "3", "2", "1"
   "TS2", "1", "2", "N/A", "2"

The results would be:

.. csv-table::
   :header: "Series", "T0", "T + 10s", "T + 20s", "T + 30s"
   
   "TS1", "NaN", "2", "-1", "-1"
   "TS2", "NaN", "1", "N/A", "0"

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
    		}
    	]
    }
