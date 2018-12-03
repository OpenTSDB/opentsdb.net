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

Example:

.. code-block:: javascript
  
  {
    "aggregator": "avg",
    "windowSize": "15m"
  }
