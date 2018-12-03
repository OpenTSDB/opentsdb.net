/api/query/graph
================
.. index:: HTTP /api/query/graph
This new 3.0 endpoint is a low-level querying API that supports a new DSL for building a directed acyclic query graph to fetch and analyze data from various sources. The DSL supports YAML or JSON queries.

Yes, we know this DSL is incredibly verbose and extremely ugly. It's a direct mapping to the semantic query that executes on the TSD framework and idealy we will be adding other languages such as TSL, PromQL, possibly InfluxQL and SQL for easier interaction.

Verbs
-----

* POST

Requests
--------

The query object or document includes the following fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "start", "String/Integer", "Required", "The start time for the query. This may be relative, absolute human readable or absolute Unix Epoch.", "", "1h-ago, 2015/05/05-00:00:00"
   "end", "String/Integer", "Optional", "The end time for the query. If left out, the end is *now*", "now", "1h-ago, 2015/05/05-00:00:00"
   "timeZone", "String", "Optional", "An optional Java Timezone ID string. Defaults to UTC", "UTC", "America/Denver"
   "mode", "String", "Optional", "A query execution mode such as a single query, validation or streaming query.", "SINGLE", "VALIDATE"
   "executionGraph", "Array", "Required", "A list of query node definitions that build the execution graph. Must include at least one data source.", "", "See TODO"
   "filters", "Array", "Optional", "An optional list of filter sets with IDs that can be referenced by data sources. Useful if there are multiple sources sharing the sa me filters.", "", "See TODO"
   "serdesConfigs", "Array", "Optional", "An array of serialization configurations that allow for formatting variations and output filtering. If this list is null or empty then only the terminal nodes of the execution graph will be serialized.", "", "See TODO"
   "logLevel", "String", "Optional", "An optional log level that can provide details and warnings about the underlying execution of the query. Note that at ``DEBUG`` or ``TRACE`` levels it may impact query performance and return a lot of information.", "ERROR", "TRACE"

Details about each field follow.

mode
^^^^

The query mode is important as it determines how the query is executed. Possible values include:

* **SINGLE** - Similar to the 1.x and 2.x wherein the query is executed and all sources must respond before results are serialized and returned to the user.
* **VALIDATE** - The query is simply parsed and the execution graph configured with a response of OK or an error if parsing fails. This is good for validating things like expression queries or complex merges in that it will make sure the query parses and could be executed.

There are also parameters we're working on that allow for streaming queries using either follow-up HTTP calls or websockets.

executionGraph
^^^^^^^^^^^^^^

The execution graph consists of one or more query node objects. Each object specifies either a data source or an operation on the data. Data flows from the sources through the nodes linked to them. Fields common to every query node include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25

   "id", "String", "Required", "A unique ID for the graph, i.e. no other node in the graph array can have the same ID. This can either be a descriptive name for the node such as ``downsample_metric1`` wherein the ``type`` field is the ID or name of a query node in the Registry, or it can be the ID of a node in the Registry and the ``type`` field can be missing.", "null", "m1"
   "type", "String", "Optional", "The ID or name of a query node in the Registry. If there is only one node in the list of the given type and the ``id`` is the name in the Registry, this field may be omitted.", "null", "timeseriesdatasource"
   "sources", "List", "Optional", "A list of ``id`` s that should pass data into this node. This is how the graph is formed. *Note* that data source nodes cannot have sources.", "null", "[""m1"", ""m2""]"

Each node type has additional fields to be set, some required and others optional. For details on query nodes, see :doc:`../../user_guide/querynodes/index`

.. Note:: The ID for each node must be alpha-numeric with the addition of periods, underscores and dashes. It cannot contain punctuation or spaces.

filters
^^^^^^^

Data sources accept a filter in their node config. But if a query contains multiple data sources (e.g. many different metrics) that share the same filters, you can reduce the query payload size by providing a single (or more) named filters and each data source can reference the name. This field is an array of objects with the following fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25

   "id", "String", "Required", "A unique ID for the filter within the filter list. This ID must be referenced by the ``filterId`` field of data sources.", "null", "f1"
   "filter", "Object", "Required", "A filter definition, the same as that passed in a data source query node.", "null", "See Example Query"

Example:

.. code-block:: javascript

  [{
  "id": "f1",
  "filter": {
    "type": "Chain",
    "filters": [{
        "type": "TagValueLiteralOr",
        "filter": "web01",
        "tagKey": "host"
      },
      {
        "type": "TagValueLiteralOr",
        "filter": "PHX",
        "tagKey": "dc"
      }
    ]
  }
  }]

serdesConfigs
^^^^^^^^^^^^^

This section controls how data is serialized in the response. For now it controls filtering and later we'll have more options. If no config is given, then only the terminal nodes of the graph are serialized. This is an array of zero or one (for now) objects with the following fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25

   "id", "String", "Required", "For now must be the literal ``JsonV3QuerySerdes``", "null", "JsonV3QuerySerdes"
   "filter", "List", "Required", "A list of query node ``id`` s that should be serialized.", "null", "[""groupby"", ""m1""]"

Example:

.. code-block:: javascript

  [{
	"id": "JsonV3QuerySerdes",
	"filter": ["groupby", "m1"]
  }]

Query Example
^^^^^^^^^^^^^

**Complete Example** (can be used to query data from the built-in mock in-memory store.)

.. code-block:: javascript
 
 {
  "start": "1h-ago",
  "executionGraph": [{
      "id": "m1",
      "type": "timeseriesdatasource",
      "metric": {
        "type": "MetricLiteral",
        "metric": "sys.if.in"
      },
      "fetchLast": false,
      "filter": {
        "type": "Chain",
        "filters": [{
            "type": "TagValueLiteralOr",
            "filter": "web01",
            "tagKey": "host"
          },
          {
            "type": "TagValueLiteralOr",
            "filter": "PHX",
            "tagKey": "dc"
          }
        ]
      }
    },
    {
      "id": "downsample",
      "aggregator": "sum",
      "interval": "1m",
      "fill": true,
      "interpolatorConfigs": [{
        "dataType": "numeric",
        "fillPolicy": "NAN",
        "realFillPolicy": "NONE"
      }],
      "sources": ["m1"]
    },
    {
      "id": "groupby",
      "aggregator": "sum",
      "tagKeys": ["host"],
      "interpolatorConfigs": [{
        "dataType": "numeric",
        "fillPolicy": "NAN",
        "realFillPolicy": "NONE"
      }],
      "sources": ["downsample"]
    },
    {
      "id": "summarizer",
      "type": "summarizer",
      "summaries": ["sum", "first", "last"],
      "sources": ["groupby"]
    }
  ],
  "logLevel": "DEBUG"
  }

Response
--------
   
The 3.x output is a fair bit different than the older results and is now dependent on the types of data returned. For example, if a ``downsample`` node is present, data serialized after that node will be given in an array of values without timestamps. Instead the timestamp information is provided as a separate field and timestamps must be calculated by the caller if required. This helps to reduce the data transfer from the server to the client.

The response is now an object with various top-level fields including the ``results`` that return the actual data fetched by the query and ``logs`` that may include information about the query execution. We'll add additional fields on request such as the original query, resulting query plan, trace information, etc. This is now easier to parse out than the old style.

The top-level fields are:

results
^^^^^^^

An array of data results from the query. This may be empty if the query didn't find any data. For each result type you should see fields like these:

.. csv-table::
  :header: "Name", "Description"
  :widths: 20, 80
  
  "source", "The ID of the node followed by a colon and the ID of the data source the data came from. E.g. ``downsample:m1``."
  "data", "An array of data objects, usually individual time series."

For details see __TODO__

logs
^^^^

The logs are simply an array of strings with a timestamp, log level, node ID and message. These are similar to Log4J log lines.

Example Responses
^^^^^^^^^^^^^^^^^

For the summarizer query above you'd see something like:

.. code-block:: javascript

  {
    "results": [
        {
            "source": "summarizer:m1",
            "data": [
                {
                    "metric": "sys.if.in",
                    "tags": {
                        "host": "web01"
                    },
                    "aggregateTags": [],
                    "NumericSummaryType": {
                        "aggregations": [
                            "sum",
                            "first",
                            "last"
                        ],
                        "data": [
                            {
                                "1543780740": [
                                    1889,
                                    60,
                                    60
                                ]
                            }
                        ]
                    }
                }
            ]
        }
    ],
    "log": [
        "20:58:09,959 DEBUG  [m1] - [MockDataStore@400064818] DONE with filtering. net.opentsdb.storage.MockDataStore$LocalNode@5c204b19  Results: 1"
    ]
  }

With a downsampler in-line you'd see:

.. code-block:: javascript
  
  {
    "results": [
        {
            "source": "groupby:m1",
            "timeSpecification": {
                "start": 1543781400,
                "end": 1543784940,
                "intervalISO": "PT1M",
                "interval": "1m",
                "timeZone": "UTC",
                "units": "Minutes"
            },
            "data": [
                {
                    "metric": "sys.if.in",
                    "tags": {
                        "host": "web01"
                    },
                    "aggregateTags": [],
                    "NumericType": [
                        12,
                        13,
                        14,
                        15,
                        16,
                        17,
                        18,
                        19,
                        20,
                        21,
                        22,
                        23,
                        24,
                        25,
                        26,
                        27,
                        28,
                        29,
                        30,
                        31,
                        32,
                        33,
                        34,
                        35,
                        36,
                        37,
                        38,
                        39,
                        40,
                        41,
                        42,
                        43,
                        44,
                        45,
                        46,
                        47,
                        48,
                        49,
                        50,
                        51,
                        52,
                        53,
                        54,
                        55,
                        56,
                        57,
                        58,
                        59,
                        60,
                        61,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                        12
                    ]
                }
            ]
        }
    ],
    "log": [
        "21:09:11,274 DEBUG  [m1] - [MockDataStore@400064818] DONE with filtering. net.opentsdb.storage.MockDataStore$LocalNode@232af29  Results: 1"
    ]
  }