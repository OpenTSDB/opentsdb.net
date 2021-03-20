Rollup Configuration
====================

A rollup configuration is a complex object best defined in YAML. It is usually passed to a storage node in the ``rollups.config`` suffix.

.. WARNING::

  Do not change the aggregation ID mappings or table values after writing data or it will become unreadable.

Configurations
^^^^^^^^^^^^^^

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
 
   "aggregationIds", "Map", "Required", "A map of strings keyed on an aggregation function to a number representing their encoding the storage layer or system. See the example for the layout.", "", "SUM: 0"
   "intervals", "List", "Required", "A list of one or more intervals defining tables and the amount of data per row to store in those tables.", "", ""

Interval Configuration
----------------------

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
 
   "table", "String", "Required", "The table for the rolled up data.", "", "tsdb-rollup-1h"
   "preAggregationTable", "String", "Optional", "A table for storing pre-aggregated data.", "", "tsdb-1h-preagg"
   "interval", "Duration", "Required", "A duration reflecting how the interval of data stored in each rollup/summary.", "", "1h"
   "rowSpan", "Duration", "Required", "How many intervals are stored in a row. E.g. there could be 24 1 hour records in a row", "", "1d"
   "defaultInterval", "Boolean", "Optional", "Used to define the *raw* data table where non-rolledup or aggregated data is stored. The interval and row span are ignored.", "false", "true"


.. NOTE::

  The default interval must be defined, particularly when enabling the fallback feature.

Example
^^^^^^^

.. code-block:: yaml

  tsd.storage.rollups.config:
    aggregationIds:
      SUM: 0
      COUNT: 1
      MIN: 2
      MAX: 3
      AVG: 5
      FIRST: 6
      LAST: 7

    intervals:
      - table: tsdb
        preAggregationTable: tsdb
        interval: 1m
        rowSpan: 1h
        defaultInterval: true

      - table: tsdb-rollup-1h
        preAggregationTable: tsdb-rollup-1h
        interval: 1h
        rowSpan: 1d