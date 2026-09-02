Downsample
==========
.. index:: downsample
Normalizes and/or reduces the resolution of the source data. For example, if data comes in every second and you want to plot a week of data, that would be too many data points for most graph libraries to handle. Instead, downsample the data to emit a value every hour and it will be much more legible as well as making the query faster as there is less data to serialize and less data to work on upstream of the downsample node.

The 3.0 downsampler offers some new features including auto downsampling, infectious NaNs as well as interpolation and fill policies.

Fields for the downsample config include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "interval", "String", "Required", "The new resolution (or size of buckets) to convert the data to. Formated as a TSDB duration. May also be ``0all`` if ``runAll`` is set to true in which case the full query timespan is aggregated into a single value. May also be ``auto`` for automatic downsampling based on the query span.", "null", "1m"
   "aggregator", "String", "Required", "The ID of a registered aggregation function in the Registry to use when merging multiple values into a downsample bucket.", "null", "sum"
   "infectiousNan", "boolean", "Optional", "Whether or not NaNs from the source data should infect each bucket when aggregating values. E.g. if one value out of 20 are ``NaN`` in a bucket and this is true, the bucket will return a ``NaN``. If all values in a bucket are ``NaN`` then the result will be ``NaN`` regardless..", "false", "true"
   "runAll", "Boolean", "Optional", "Whether or not to merge all of the values for the query span into a single resulting bucket.", "false", "true"
   "fill", "boolean", "Optional", "Whether or not to fill empty buckets with values based on the ``interpolatorConfig``. If false, then empty buckets return ``null`` or ``NaN``.", "false", "true"
   "minInterval", "String", "Optional", "**NOTE** This is temporary, we'll clean it out and use ``reportingInterval`` instead. An optional minimum interval to use when ``auto`` is set as the primary ``interval``. This is useful for metrics that may be reported on a ``5m`` interval to avoid extraneous fills when downsampling would be set to ``1m`` with auto based on the query interval.", "null", "5m"
   "reportingInterval", "String", "Optional", "When known, the reporting interval of the metric coming through and is used by some query nodes to compute more accurate values, e.g. the rate to count functon.", "null", "5m"
   "timeZone", "String", "Optional", "An optional Java time zone ID that, when given, switches the downsampling to calendar mode where bucket boundaries are computed based on the time zone, e.g. accounting for daylight savings and offsets from UTC.", "null", "America/Denver"
   "interpolatorConfig", "List", "Required *for now*", "A list of interpolator configs for the downsampler to deal with empty buckets.", "null", "See :doc:`interpolator`"

.. Note:: When a downsample node is present in a query graph and the output is the standard V3 serializer, a ``timeSpecification`` will be present in the output and the values will be serialized in an array without timestamps.

Example:

.. code-block:: javascript
  
  {
    "id": "cpu_ds",
    "type": "downsample",
    "aggregator": "sum",
    "interval": "5m",
    "fill": true,
    "interpolatorConfigs": [{
      "dataType": "numeric",
      "fillPolicy": "NAN",
      "realFillPolicy": "NONE"
    }],
    "sources": ["m1"]
  }

timeSpecification
-----------------

When downsampling is present, a time specifications will be serialized in the output of the query, saving time and bytes over the wire as the query no longer needs to serialize timestamps. The time specification in a v3 query output has the following fields:

.. csv-table::
  :header: "Name", "Description"
  :widths: 20, 80
  
  "start", "The first timestamp in Unix Epoch seconds (or milliseconds if requested)."
  "end", "The last timestamp in Unix Epoch seconds (or milliseconds if requested)."
  "intervalISO", "The interval of the downsample in ISO format."
  "interval", "The interval as a TSDB duration."
  "timeZone", "The timezone of the downsampler."
  "units", "The units of the downsample interval."

.. NOTE:: 

    When representing data in a plot or with a timestamp, if the ``timeZone`` is NOT equal to UTC, make sure to use a library to add the interval to the start for each bucket. This make sure the results will line up with daylight savings changes, etc.
    
Auto Intervals
--------------

When ``auto`` is used in the interval and configured in the TSD, the TSD will take the start and end time of the query and compute a downsample that would return at most about 800 data points for the query range. A stepping configuration is used to determine the final resolution. By default, this stepping config is:

* < 12h use ``1m``
* >= 12h and < 3d use ``15m``
* >= 3d and < 1w use ``1h``
* >= 1w and < 1 month use ``6h``
* >= 1 month < 1 year use ``1d``
* >= 1 year use ``1w``

To override this configuration, use the ``tsd.query.downsample.auto.config`` property. An example looks like:

.. code-block:: javascript

    # ---------- DOWNSAMPLE ----------
    tsd.query.downsample.auto.config:
      75d: 1d
      2n: 4h
      1n: 2h
      1w: 1h
      2d: 10m
      1d: 5m
      0: 1m
      
Where the configuration is a map where the key is the query interval and the value is the downsample interval to use. E.g. for queries from 1 second to 4 hours, use ``1m`` as the interval. For 1 day to 2 days, use ``5m`` as the interval. Anything greater than or equal to 75 days will use ``1d`` as the interval.

Example
-------

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
    		}
    	]
    }
  
