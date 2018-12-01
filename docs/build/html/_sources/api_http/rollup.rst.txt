/api/rollup
===========
.. index:: HTTP /api/rollup
This endpoint allows for storing rolled up and/or pre-aggregated data in OpenTSDB over HTTP. For details on rollups and pre-aggs, please see the user guide: :doc:`../../user_guide/rollups`.

Also see the :doc:`put` documentation for notes and common parameters that are shared with the ``/api/rollup`` endpoint. This page lays out the differences between the two.

Verbs
-----

* POST

Requests
--------

Rollup and pre-aggregate values are extensions of the ``put`` object with three additional fields. For completeness, all fields are listed below:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "metric", "String", "Required", "The name of the metric you are storing", "", "", "W", "sys.cpu.nice"
   "timestamp", "Integer", "Required", "A Unix epoch style timestamp in seconds or milliseconds. The timestamp must not contain non-numeric characters.", "", "", "W", "1365465600"
   "value", "Integer, Float, String", "Required", "The value to record for this data point. It may be quoted or not quoted and must conform to the OpenTSDB value rules: :doc:`../../user_guide/writing`", "", "", "W", "42.5"
   "tags", "Map", "Required", "A map of tag name/tag value pairs. At least one pair must be supplied.", "", "", "W", "{""host"":""web01""}"
   "interval", "String", "Optional\*", "A time interval reflecting what timespan the **rollup** value represents. The interval consists of ``<amount><unit>`` similar to a downsampler or relative query timestamp. E.g. ``6h`` for 5 hours of data, ``30m`` for 30 minutes of data.", "", "", "W", "1h"
   "aggregator", "String", "Optional\*", "An aggregation function used to generate the **rollup** value. Must match a supplied TSDB aggregator.", "", "", "W", "SUM"
   "groupByAggregator", "String", "Optional\*", "An aggregation function used to generate the **pre-aggregate** value. Must match a supplied TSDB aggregator.", "", "W", "COUNT"

While the aggregators and interval are marked as optional above, at least one of the combinations documented below must be satisfied for data to be recorded.

.. csv-table::
   :header: "interval", "aggregator", "groupByAggregator", "Description"
   :widths: 10, 10, 10, 70
   
   "Set", "Set", "Empty", "Data represents a *raw* or *non-pre-aggregated* **rollup** over the interval."
   "Empty", "Empty", "Set", "Data represents a *raw* **pre-aggregated** value that has not been rolled up over time."
   "Set", "Set", "Set", "Data represents a *rolled up* *pre-aggregated* value."

Example Single Data Point Put
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can supply a single data point in a request:

.. code-block :: javascript

  {
      "metric": "sys.cpu.nice",
      "timestamp": 1346846400,
      "value": 18,
      "tags": {
         "host": "web01",
         "dc": "lga"
      },
      "interval": "1h",
      "aggregator": "SUM",
      "groupByAggregator": "SUM"
  }
  
Example Multiple Data Point Put
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Multiple data points must be encased in an array:

.. code-block :: javascript

  [
      {
          "metric": "sys.cpu.nice",
          "timestamp": 1346846400,
          "value": 18,
          "tags": {
             "host": "web01",
             "dc": "lga"
          },
          "interval": "1h",
          "aggregator": "SUM",
          "groupByAggregator": "SUM"
      },
      {
          "metric": "sys.cpu.nice",
          "timestamp": 1346846400,
          "value": 9,
          "tags": {
             "host": "web02",
             "dc": "lga"
          },
          "interval": "1h",
          "aggregator": "SUM",
          "groupByAggregator": "SUM"
      }
  ]

Response
--------

Responses are handled in the same was as for the :doc:`put` endpoint.