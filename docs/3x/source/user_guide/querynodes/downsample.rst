Downsample
==========
.. index:: downsample
Normalizes and/or reduces the resolution of the source data. For example, if data comes in every second and you want to plot a week of data, that would be too many data points for most graph libraries to handle. Instead, downsample the data to emit a value every hour and it will be much more legible.

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

The time specification in a v3 query output has the following fields:

.. csv-table::
  :header: "Name", "Description"
  :widths: 20, 80
  
  "start", "The first timestamp in Unix Epoch seconds (or milliseconds if requested)."
  "end", "The last timestamp in Unix Epoch seconds (or milliseconds if requested)."
  "intervalISO", "The interval of the downsample in ISO format."
  "interval", "The interval as a TSDB duration."
  "timeZone", "The timezone of the downsampler."
  "units", "The units of the downsample interval."

Example:

.. code-block:: javascript
  
  "timeSpecification": {
    "start": 1537903080,
    "end": 1537906620,
    "intervalISO": "PT1M",
    "interval": "1m",
    "timeZone": "UTC",
    "units": "Minutes"
  }

.. Note:: When representing data in a plot or with a timestamp, if the ``timeZone`` is NOT equal to UTC, make sure to use a library to add the interval to the start for each bucket. This make sure the results will line up with daylight savings changes, etc.