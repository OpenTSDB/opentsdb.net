TopN
====
.. index:: topn
Filters and sorts the time series by the total aggregation (over time) value and returns the top or bottom series based on that aggregation. E.g. find the top 10 hosts using the most memory or the 5 coldest regions over a day.

Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "aggregator", "String", "Required", "The aggregation function to use to compute the sorting value.", "null", "sum"
   "top", "Boolean", "Optional", "Whether or not to return the highest results (True) or lowest results (False).", "false", "true"
   "count", "Integer", "Required", "The number of results to return.", "null", "10"
   "infectiousNan", "Boolean", "Optional", "Whether or not NaNs from the source data should infect the final aggregation. E.g. if one value out of 20 are ``NaN`` in the source this is true, the aggregation will return a ``NaN``. If all values in the source are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"

Example:

.. code-block:: javascript
  
  {
    "aggregator": "avg",
    "top": "true",
    "count": "10"
  }
