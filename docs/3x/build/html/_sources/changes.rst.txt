Changes in 3.0
==============
.. index:: News
OpenTSDB 3.0 is mostly a re-write of the original code with a focus on making it a time series data routing and analysis engine. The new framework goals include:

* Support for multiple types of data sources such as HBase, Bigtable, cloud providers and the latest time series DBs.
* Pluggable everything with support for custom data types, functions, etc.
* Streaming support for large queries that won't fit in memory.
* Flexible querying by providing an executable graph of operations.
* Support for multiple query languages such as OpenTSDB, PromQL, SQL, etc.
* Provide backwards compatibility with previous versions to easy migration.

New Features
------------

Noteable new features that have been implemented so far include:

* A new configuration system that supports properties, JSON or YAML (and eventually remote sources) that allows for configuration via:
  * Environment variables
  * Java system properties
  * Command line arguments
  * Java properties, YAML or JSON encoded files
* A new low-level DSL for querying that allows for flexible ordering of operations (e.g. group by then downsample or downsample then group by) and merging data from multiple sources.
* HA query support, querying two or more sources that should have the same data. E.g. when running HBase and dual-writing to two different clusters, we can query the two clusters and merge the results so that one can be in maintenance mode.
* Faster queries from HBase by re-writing the query pipeline.
* New aggregation functions and more advanced expressions.

Whats Missing
-------------

Stuff we have to get to include:

* The old Telnet style API, at least we'll maintain the write method though we may drop the other commands.
* A GUI. Right nowe we only have the HTTP API.
* OS packages.
* Histograms and annotations.