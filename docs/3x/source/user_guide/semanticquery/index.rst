Semantic Query (Version 3)
==========================
.. index:: semanticquery
OpenTSDB 3 has a new query syntax that finally allows for manipulating the time series data with various transforms, operators, etc. The new syntax is designed to allow the querant to provide a query *graph* that links one or more time series data sources with transformation nodes that are finally serialized.

.. NOTE::

  The query syntax is verbose and ugly. It is intended as a *semantic* design, conveying the intent of the queryant, ontop of which we can overaly easier query languages like SQL, PromQL (incubating in the PromQL plugin), possibly Flux and others. It does not support branches or loops at this time so it is not a Turing complete DSL but should support the vast majority of operations required for time series analysis.

These documents will include query examples in JSON as the most common use case will be querying an OpenTSDB instance via the HTTP interface. YAML may also be used over HTTP. For those importing the OpenTSDB JAR files, a ``SemanticQuery.newBuilder()`` method can be called to start constructing a query. We'll have documentation on making calls from Java later on.

Overview
--------

The top level query has the following fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "start", "String or Integer", "Required", "The start time for the query in relative or absolute timestamps. This field must have a value and if ``end`` is not set, data from this time until the current time on the TSD server will be fetched. See", "null", "1h-ago"
   "end", "String or Integer", "Optional", "The end time of the query in relative or absolute timestamps. If not set, the current time on the TSD server will be used. See.", "null", "5m-ago"
   "executionGraph", "Array", "Required", "An array of one or more query node definitions to determine what data is fetched and how it is transformed.", "null", "See below"
   "filters", "Array", "Optional", "An optional array of named data filters that can be used by ``TimeSeriesDataSource`` query nodes for filtering.", "null", "See ___."
   "serdesConfigs", "Array", "Optional", "An optional array of serialization configurations to control what data is serialized in the response.", "null", "See----"
   "logLevel", "String", "Optional", "A string that determines how much data is returned in the ``log`` field of the query response. This can be a one of the following literal values in order from the most detailed information to least information: ``TRACE``, ``DEBUG``, ``INFO``, ``WARN``, ``ERROR``. Note that ``DEBUG`` and ``TRACE`` can affect query performance as more measurements are captured and more log lines will be serialized. See ____", "ERROR", "INFO"
   "cacheMode", "String", "Optional", "An optional caching mode when a query cache node is available. TODO", "null", "NORMAL"
   
At a minimum, every query must have a start time and an execution graph with a ``TimeSeriesDataSource `` query node. For example:

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
    }]
  }

This query would fetch all of the data for the metric `sys.if.in` from 1 hour in the past to the current wall-clock time and serialize each time series individually. (If there are many hosts emitting this metric, you could see a *lot* of data.)

Note the ``executionGraph`` field. This is the most important part of the query.

Execution Graph
---------------

A query execution graph consists of one or more "Query Node" entries that define a data source or transformation on data flowing through network of query nodes. Execution graphs are directed acyclic graphs or `DAG <https://en.wikipedia.org/wiki/Directed_acyclic_graph>`_ in computer science terms. Each node has an ``id`` field and links are created by adding an ``id`` to the ``sources`` list of another node.

.. WARNING::

    Graphs cannot create a circular link, meaming a node cannot have itself as a soure or have the `id` of a node downstream of it as a source. E.g. if we have three nodes: ``m1, ds, gb`` and a link like ``gb <- ds <- m1``, we cannot have ``gb`` be a source of ``ds``.
    
An example execution graph with node configuration fields omitted:

.. code-block:: javascript

 {
  "start": "1h-ago",
  "executionGraph": [{
      "id": "m1",
      "type": "TimeSeriesDataSource"
      }
    },
    {
      "id": "ds1",
      "sources": ["m1"]
    },
    {
      "id": "gb1",
      "sources": ["ds1"]
    },
    {
      "id": "m2",
      "type": "TimeSeriesDataSource"
      }
    },
    {
      "id": "ds2",
      "sources": ["m2"]
    },
    {
      "id": "gb2",
      "sources": ["ds2"]
    },
    {
      "id": "expression",
      "sources": ["gb1", "gb2"]
    }]
  }

In this graph we have two metrics, ``m1`` and ``m2`` that are data sources. Each metric has a downsample node, ``ds1`` that has as a source ``m1``, and ``ds2`` that has ``m2`` as a source. Each downsample feeds into a group by node, ``gb1`` and ``gb2`` respectively. Finally, the two group by nodes feed into a single expression node where we may perform some operation like ``gb1 / gb2``. 

.. NOTE::
    
    There are currently some bugs around feeding multiple sources through the same nodes. E.g. you could have ``m1,m2 -> ds -> gb -> expression`` to save two node definitions. We'll fix it eventually but for now, if you run into problems with queries timing out, try splitting out the nodes so they have independent execution paths.
    
Some important notes:

* At least one data source must be present or the TSD will respond with an exception.
* Note that in the query definition, nodes can appear in any order. They will be sorted by the TSD during query planning. 
* Nodes without sources will simply be ignored.
* If a cycle (a circular link in the graph) is detected, the query will fail with an error.
* Parallel graphs are allowed and terminal leaf nodes will be serialized in the output.

Common Query Node Fields
^^^^^^^^^^^^^^^^^^^^^^^^

All query nodes have three fields defined below. Documentation for each node will ommit these fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25

   "id", "String", "Required", "A unique ID for the graph, i.e. no other node in the graph array can have the same ID. This can either be a descriptive name for the node such as ``downsample_metric1`` wherein the ``type`` field is the ID or name of a query node in the Registry, or it can be the ID of a node in the Registry and the ``type`` field can be missing.", "null", "m1"
   "type", "String", "Optional\*", "The ID or name of a query node in the Registry. \*If there is only one node in the list of the given type and the ``id`` is the name in the Registry, this field may be omitted. Otherwise the type must be specified.", "null", "timeseriesdatasource"
   "sources", "List", "Optional", "A list of ``id`` s that should pass data into this node. This is how the graph is formed. *Note* that data source nodes cannot have sources.", "null", "[""m1"", ""m2""]"

Built-in Query Nodes
^^^^^^^^^^^^^^^^^^^^

.. toctree::
   :maxdepth: 1
   
   bucketquantiles
   downsample
   expression
   filters
   groupby
   interpolator
   join
   movingaverage
   rate
   ratio
   slidingwindow
   summarizer
   timedifference
   timeseriesdatasource
   topn

Plugin Query Nodes
^^^^^^^^^^^^^^^^^^

TODO - Link to docs about plugins with query ndoes.


Filters
-------

Data filters can be defined in a time series data source query node but if you have multiple sources that share the same filter, it's cleaner and simpler to define the filter once and refer to it from each node. Imagine computing the percent of time a Linux CPU is busy on hosts for a role in a data center. This requires loading 8 different CPU metrics. Instead of defining the filter 8 times, define a named filter at the top level of the query and refer to the ID of the filter in each node. 

For example:

.. code-block:: javascript

    "filters": [{
        "id": "f1",
        "filter": {
				"type": "Chain",
				"op": "AND",
				"filters": [{
					"type": "TagValueLiteralOr",
					"filter": "phx",
					"tagKey": "dc"
				}, {
					"type": "TagValueLiteralOr",
					"filter": "web_server",
					"tagKey": "role"
				}, {
					"type": "TagValueLiteralOr",
					"filter": "prod",
					"tagKey": "environment"
				}]
			}
		}]

The ``filters`` field is an array of one or more named filter objects. Each named filter consists of:

* **id** - A unique alpha-numeric ID for the filter.
* **filter** - The filter definition. Same as a regular data source filter.

To use a top-level, named filter, reference the ``id`` in a data source query node definition, e.g. if we use the example above with an ``id`` of ``f1``:

.. code-block:: javascript

    {
      "id": "m1",
      "type": "TimeSeriesDataSource",
      "metric": {
        "type": "MetricLiteral",
        "metric": "sys.if.in"
      },
      "filterId": "f1"
    }

Serializer Configs
------------------

The ``serdesConfigs`` field is an optional array of configuration options that determine what data is emitted in the final, serialized results. 

By default, the terminal leaves of a graph are serialized (i.e. the query nodes that do not feed into another node.) Using the example execution graph above, only time series from the ``expression`` graph would be serialized. However, a common use case might be graphing the results of the group by nodes as well as the expression. Instead of defining another pair of parallel query graphs that would reprocess the data (or firing a separate query), you can tell the TDS to be more efficient by asking to serialize both the expression and the group by nodes. An example serialization config would look like this:

.. code-block:: javascript

    "serdesConfigs": [{
		"id": "JsonV3QuerySerdes",
		"filter": ["gb1", "gb2", "expression"]
	}]

Fields:

* **id** - The ID of the serialization plugin or formatter to use. **NOTE** We only have one type available at this time, the ``JsonV3QuerySerdes`` that emitts JSON.
* **filter** - An array of ``id``s from query nodes. The order does not matter.

If no ``serdesConfigs`` are defined in the query, defaults are used.