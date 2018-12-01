/api/query/exp
==============
.. index:: HTTP /api/query/exp
This endpoint allows for querying data using expressions. The query is broken up into different sections.

Two set operations (or Joins) are allowed. The union of all time series ore the intersection.

For example we can compute "a + b" with a group by on the host field. Both metrics queried alone would emit a time series per host, e.g. maybe one for "web01", "web02" and "web03". Lets say metric "a" has values for all 3 hosts but metric "b" is missing "web03". 

With the intersection operator, the expression will effectively add "a.web01 + b.web01" and "a.web02 + b.web02" but will skip emitting anything for "web03". Be aware of this if you see fewer outputs that you expected or you see errors about no series available after intersection.

With the union operator the expression will add the ``web01`` and ``web02`` series but for metric "b", it will substitute the metric's fill policy value for the results.

.. NOTE:: Supported as of version 2.3

Verbs
-----

* POST

Requests
--------

The various sections implemented include:

"time"
^^^^^^

The time section is required and is a single JSON object. This affects the time range and optional reductions for all metrics requested.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "start", "Integer", "Required", "The start time for the query. This may be relative, absolute human readable or absolute Unix Epoch.", "", "1h-ago, 2015/05/05-00:00:00"
   "aggregator", "String", "Required", "The global aggregation function to use for all metrics. It may be overridden on a per metric basis.", "", "sum"
   "end", "Integer", "Optional", "The end time for the query. If left out, the end is *now*", "now", "1h-ago, 2015/05/05-00:00:00"
   "downsampler", "Object", "Optional", "Reduces the number of data points returned. The format is defined below", "None", "See below"
   "rate", "Boolean", "Optional", "Whether or not to calculate all metrics as rates, i.e. value per second. This is computed before expressions.", "false", "true"
   
E.g.

.. code-block:: javascript
  
  "time":{ "start":"1h-ago", "end":"10m-ago", "downsampler":{"interval":"15m","aggregator":"max"}

**Downsampler**

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "interval", "String", "Required", "A downsampling interval, i.e. what time span to rollup raw values into. The format is ``<#><unit>``, e.g. ``15m``", "", "1h"
   "aggregator", "String", "Required", "The aggregation function to use for reducing the data points", "", "avg"
   "fillPolicy", "Object", "Optional", "A policy to use for filling buckets that are missing data points", "None", "See Below"

**Fill Policies**

These are used to replace "missing" values, i.e. when a data point was expected but couldn't be found in storage.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "policy", "String", "Required", "The name of a policy to use. The values are listed in the table below", "", "zero"
   "value", "Double", "Optional", "For scalar fills, an optional value that can be used during substitution", "NaN", "42"
   
.. csv-table::
   :header: "Name", "Description"
   :widths: 25, 75
   
   "nan", "Emits a NaN if all values in the aggregation function were NaN or ""missing"". For aggregators, NaNs are treated as ""sentinel"" values that cause the function to skip over the values. Note that if a series emits a NaN in an expression, the NaN is infectious and will cause the output of that expression to be NaN. At serialization the NaN will be emitted."
   "null", "Emits a Null at serialization time. During computation the values are treated as NaNs."
   "zero", "Emits a zero when the value is missing"
   "scalar", "Emits a user defined value when a data point is missing. Must specify the value with ``value``. The value can be an integer or floating point."
   
Note that if you try to supply a value that is incompatible with the type the query will throw an exception. E.g. supplying a value with the NaN that isn't NaN will throw an error.
   
E.g.

.. code-block:: javascript
  
  {"policy":"scalar","value":"1"}

"filters"
^^^^^^^^^

Filters are for selecting various time series based on the tag keys and values. At least one filter must be specified (for now) with at least an aggregation function supplied. Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "id", "String", "Required", "A unique ID for the filter. Cannot be the same as any metric or expression ID", "", "f1"
   "tags", "Array", "Optional", "A list of filters on tag values", "None", "See below"

E.g.

.. code-block:: javascript
  
  "filters":[
    "id":"f1",
    "tags":[
      {
        "type":"wildcard",
        "tagk":"host",
        "filter":"*",
        "groupBy":true
      },
      {
        "type":"literal_or",
        "tagk":"colo",
        "filter":"lga",
        "groupBy":false
      }
     ]
    ]

**Filter Fields**

Within the "tags" field you can have one or more filter. The list of filters can be found via the :doc:`../config/filters` endpoint.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "type", "String", "Required", "The name of the filter from the API", "", "regexp"
   "tagk", "String", "Required", "The tag key name such as *host* or *colo* that we filter on", "", "host"
   "filter", "String", "Required", "The value to filter on. This depends on the filter in use. See the API for details", "", "web.\*mysite.com"
   "groupBy", "Boolean", "Optional", "Whether or not to group results by the tag values matching this filter. E.g. grouping by host will return one result per host. Not grouping by host would aggregate (using the aggregation function) all results for the metric into one series", "false", "true"

"metrics"
^^^^^^^^^

The metrics list determines which metrics are included in the expression. There must be at least one metric.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "id", "String", "Required", "A unique ID for the metric. This MUST be a simple string, no punctuation or spaces", "", "cpunice"
   "filter", "String", "Required", "The filter to use when fetching this metric. It must match a filter in the filters array", "", "f1"
   "metric", "String", "Required", "The name of a metric in OpenTSDB", "", "system.cpu.nice"
   "aggregator", "String", "Optional", "An optional aggregation function to overload the global function in ``time`` for just this metric", "``time``'s aggregator", "count"
   "fillPolicy", "Object", "Optional", "If downsampling is not used, this can be included to determine what to emit in calculations. It will also override the downsampling policy", "zero fill", "See above"

E.g.

.. code-block:: javascript
  
  {"id":"cpunice", "filter":"f1", "metric":"system.cpu.nice"}
  

"expressions"
^^^^^^^^^^^^^

A list of one or more expressions over the metrics. The variables in an expression **MUST** refer to either a metric ID field or an expression ID field. Nested expressions are supported but exceptions will be thrown if a self reference or circular dependency is detected. So far only basic operations are supported such as addition, subtraction, multiplication, division, modulo 

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "id", "String", "Required", "A unique ID for the expression", "", "cpubusy"
   "expr", "String", "Required", "The expression to execute", "", "a + b / 1024"
   "join", "Object", "Optional", "The set operation or ""join"" to perform for series across sets.", "union", "See below"
   "fillPolicy", "Object", "Optional", "An optional fill policy for the expression when it is used in a nested expression and doesn't have a value", "NaN", "See above"

E.g.

.. code-block:: javascript
  
  {
    "id": "cpubusy",
    "expr": "(((a + b + c + d + e + f + g) - g) / (a + b + c + d + e + f + g)) * 100",
    "join": {
        "operator": "intersection",
        "useQueryTags": true,
        "includeAggTags": false
    }
  }


**Joins**

The join object controls how the various time series for a given metric are merged within an expression. The two basic operations supported at this time are the union and intersection operators. Additional flags control join behavior.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "operator", "String", "Required", "The operator to use, either union or intersection", "", "intersection"
   "useQueryTags", "Boolean", "Optional", "Whether or not to use just the tags explicitly defined in the filters when computing the join keys", "false", "true"
   "includeAggTags", "Boolean", "Optional", "Whether or not to include the tag keys that were aggregated out of a series in the join key", "true", "false"

"outputs"
^^^^^^^^^

These determine the output behavior and allow you to eliminate some expressions from the results or include the raw metrics. By default, if this section is missing, all expressions and only the expressions will be serialized. The field is a list of one or more output objects. More fields will be added later with flags to affect the output.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "id", "String", "Required", "The ID of the metric or expression", "", "e"
   "alias", "String", "Optional", "An optional descriptive name for series", "", "System Busy"

E.g.

.. code-block:: javascript
  
  {"id":"e", "alias":"System Busy"}

.. NOTE:: The ``id`` field for all objects can not contain spaces, special characters or periods at this time.

**Complete Example**

.. code-block:: javascript
 
 {
    "time": {
        "start": "1y-ago",
        "aggregator":"sum"
    },
    "filters": [
        {
            "tags": [
                {
                    "type": "wildcard",
                    "tagk": "host",
                    "filter": "web*",
                    "groupBy": true
                }
            ],
            "id": "f1"
        }
    ],
    "metrics": [
        {
            "id": "a",
            "metric": "sys.cpu.user",
            "filter": "f1",
            "fillPolicy":{"policy":"nan"}
        },
        {
            "id": "b",
            "metric": "sys.cpu.iowait",
            "filter": "f1",
            "fillPolicy":{"policy":"nan"}
        }
    ],
    "expressions": [
        {
            "id": "e",
            "expr": "a + b"
        },
        {
          "id":"e2",
          "expr": "e * 2"
        },
        {
          "id":"e3",
          "expr": "e2 * 2"
        },
        {
          "id":"e4",
          "expr": "e3 * 2"
        },
        {
          "id":"e5",
          "expr": "e4 + e2"
        }
     ],
     "outputs":[
       {"id":"e5", "alias":"Mega expression"},
       {"id":"a", "alias":"CPU User"}
     ]
  }


Response
--------
   
The output will contain a list of objects in the ``outputs`` array with the results in an array of arrays representing each time series followed by meta data for each series and the query overall. Also included is the original query and some summary statistics. The fields include:

.. csv-table::
  :header: "Name", "Description"
  :widths: 20, 80
  
  "id", "The expression ID the output matches"
  "dps", "The array of results. Each sub array starts with the timestamp in ms as the first (offset 0) value. The remaining values are the results for each series when a group by was applied."
  "dpsMeta", "Meta data around the query including the first and last timestamps, number of result ""sets"", or sub arrays, and the number of series represented."
  "datapoints", "The total number of data points returned to the user after aggregation"
  "meta", "Data about each time series in the result set. The fields are below"

The meta section contains ordered information about each time series in the output arrays. The first element in the array will always have a ``metrics`` value of ``timestamp`` and no other data.

.. csv-table::
  :header: "Name", "Description"
  :widths: 20, 80
  
  "index", "The index in the data point arrays that the meta refers to"
  "metrics", "The different metric names included in the expression"
  "commonTags", "Tag keys and values that were common across all time series that were aggregated in the resulting series"
  "aggregatedTags", "Tag keys that appeared in all series in the resulting series but had different values"
  "dps", "The number of data points emitted"
  "rawDps", "The number of raw values wrapped into the result"

Example Responses
^^^^^^^^^^^^^^^^^

.. code-block:: javascript

  {
    "outputs": [
        {
            "id": "Mega expression",
            "dps": [
                [
                    1431561600000,
                    1010,
                    1030
                ],
                [
                    1431561660000,
                    "NaN",
                    "NaN"
                ],
                [
                    1431561720000,
                    "NaN",
                    "NaN"
                ],
                [
                    1431561780000,
                    1120,
                    1140
                ]
            ],
            "dpsMeta": {
                "firstTimestamp": 1431561600000,
                "lastTimestamp": 1431561780000,
                "setCount": 4,
                "series": 2
            },
            "meta": [
                {
                    "index": 0,
                    "metrics": [
                        "timestamp"
                    ]
                },
                {
                    "index": 1,
                    "metrics": [
                        "sys.cpu",
                        "sys.iowait"
                    ],
                    "commonTags": {
                        "host": "web01"
                    },
                    "aggregatedTags": []
                },
                {
                    "index": 2,
                    "metrics": [
                        "sys.cpu",
                        "sys.iowait"
                    ],
                    "commonTags": {
                        "host": "web02"
                    },
                    "aggregatedTags": []
                }
            ]
        },
        {
            "id": "sys.cpu",
            "dps": [
                [
                    1431561600000,
                    1,
                    2
                ],
                [
                    1431561660000,
                    3,
                    0
                ],
                [
                    1431561720000,
                    5,
                    0
                ],
                [
                    1431561780000,
                    7,
                    8
                ]
            ],
            "dpsMeta": {
                "firstTimestamp": 1431561600000,
                "lastTimestamp": 1431561780000,
                "setCount": 4,
                "series": 2
            },
            "meta": [
                {
                    "index": 0,
                    "metrics": [
                        "timestamp"
                    ]
                },
                {
                    "index": 1,
                    "metrics": [
                        "sys.cpu"
                    ],
                    "commonTags": {
                        "host": "web01"
                    },
                    "aggregatedTags": []
                },
                {
                    "index": 2,
                    "metrics": [
                        "sys.cpu"
                    ],
                    "commonTags": {
                        "host": "web02"
                    },
                    "aggregatedTags": []
                }
            ]
        }
    ],
    "statsSummary": {
        "datapoints": 0,
        "rawDatapoints": 0,
        "aggregationTime": 0,
        "serializationTime": 33,
        "storageTime": 77,
        "timeTotal": 148.63
    },
    "query": {
        "name": null,
        "time": {
            "start": "1y-ago",
            "end": null,
            "timezone": null,
            "downsampler": null,
            "aggregator": "sum"
        },
        "filters": [
            {
                "id": "f1",
                "tags": [
                    {
                        "tagk": "host",
                        "filter": "web*",
                        "group_by": true,
                        "type": "wildcard"
                    }
                ]
            }
        ],
        "metrics": [
            {
                "metric": "sys.cpu",
                "id": "a",
                "filter": "f1",
                "aggregator": null,
                "fillPolicy": {
                    "policy": "nan",
                    "value": "NaN"
                },
                "timeOffset": null
            },
            {
                "metric": "sys.iowait",
                "id": "b",
                "filter": "f1",
                "aggregator": null,
                "fillPolicy": {
                    "policy": "nan",
                    "value": "NaN"
                },
                "timeOffset": null
            }
        ],
        "expressions": [
            {
                "id": "e",
                "expr": "a + b"
            },
            {
                "id": "e2",
                "expr": "e * 2"
            },
            {
                "id": "e3",
                "expr": "e2 * 2"
            },
            {
                "id": "e4",
                "expr": "e3 * 2"
            },
            {
                "id": "e5",
                "expr": "e4 + e2"
            }
        ],
        "outputs": [
            {
                "id": "e5",
                "alias": "Woot!"
            },
            {
                "id": "a",
                "alias": "Woot!2"
            }
        ]
     }
  }