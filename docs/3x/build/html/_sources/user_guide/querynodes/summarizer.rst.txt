Summarizer
==========
.. index:: summarizer
Computes one or more aggreagtion summaries over a time series for the full query width. E.g. the serializer can print the individual values for a time series but by adding a summarizer, it can also emmit the max, min and average.

Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "summaries", "List", "Required", "A list of one or more aggregation functions to compute on the time series.", "null", "[""max"", ""min"", ""avg""]"
   "infectiousNan", "Boolean", "Optional", "Whether or not NaNs from the source data should infect the final aggregation. E.g. if one value out of 20 are ``NaN`` in the source this is true, the aggregation will return a ``NaN``. If all values in the source are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"

Example:

.. code-block:: javascript
  
  {
    "summaries": ["avg", "max", "min"]
  }
