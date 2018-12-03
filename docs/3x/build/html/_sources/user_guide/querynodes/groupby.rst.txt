GroupBy
=======
.. index:: groupby
Merges groups of time series based on the tag keys of those series using an aggregation function.

.. Note:: In 1.x and 2.x the tags to group one were specified in filters. Now the tags to group on must be explicitly supplied in the group by config.

.. Note:: In previous versions of OpenTSDB, common tags (keys and values present in all series in the group) and aggregated tags (keys with different values for one or more series in the group) were computed and serialized. Now, by default, 3.0 will ignore common tags and simply place tag keys that were specified in the ``tagKeys`` list in the ``aggregatedTags`` fields. Set ``mergeIds`` to mimic the previous behavior.

Fields for the group by config include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "aggregator", "String", "Required", "The ID of a registered aggregation function in the Registry to use when merging multiple series into a single value.", "null", "sum"
   "infectiousNan", "boolean", "Optional", "Whether or not NaNs from the source data should infect each timestamp when aggregating values. E.g. if one value out of 20 are ``NaN`` for a timestamp and this is true, the timestamp will return a ``NaN``. If all values for the timestamp are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"
   "mergeIds", "Boolean", "Optional", "Set to true to compute the common and aggregated tags the way previous versions of OpenTSDB did.", "false", "true"
   "fullMerge", "boolean", "Optional", "Set to true to compute the common, aggregated and disjoint tags.", "false", "true"
   "interpolatorConfig", "List", "Required *for now*", "A list of interpolator configs for the downsampler to deal with empty buckets.", "null", "See :doc:`interpolator`"

Example:

.. code-block:: javascript
  
  {
    "id": "downsample",
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