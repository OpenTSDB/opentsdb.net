What's New
==========
.. index:: News
OpenTSDB has a thriving community who contributed and requested a number of new features. 

3.X (Planned)
-------------
While 3.0 is still a ways off, we'll be pushing some of the new features into a new branch of the repo. Some are in progress and other features are planned. If you have any features that you want to see, let us know.

* Distributed Queries - Based on the great work of Turn on `Splicer <https://github.com/turn/splicer>`_ we have a distributed query layer to split queries amongst multiple TSDs for greater throughput.
* Query Caching - Improve queries with time-sharded caching of results.
* Improved Expressions - Perform group by, downsampling and arithmetic modifications in any order. Potentially support UDFs as well.
* Anomaly Processing/Forecasting - Integrate with modeling libraries (such as `EGADs <https://github.com/yahoo/egads>`_) for deeper time series analysis. 

2.4 (Planned)
-------------

* Rollup/Pre-Aggregates - Support for storing and querying time-based rolled up data and/or pre-aggregated values.
* Distributed Percentile - Store histograms (or sketches) for calculating proper percentiles over multiple sources.

2.3
---

* Expressions - Query time computations using time series data. For example, dividing one metric by another.
* Graphite Style Functions - Additional filtering and mutation of data at query time using Graphite style functions.
* Calendar Based Downsampling - The ability to align downsampled data on Gregorian calendar boundaries.
* Bigtable Support - Run TSDB in the cloud using Google's hosted Bigtable service.
* Cassandra Support - Support for running OpenTSDB on legacy Cassandra clusters.
* Write Filters - Block or allow time series or UID assignments based on plugins or whitelists.
* New Aggregators - None for returning raw data. First and Last to return the first or last data points during downsampling.
* Meta Data Cache Plugin - A new API for caching meta data to improve query performance.
* Startup Plugins - APIs to help with service discovery on TSD startup.
* Example Java API usage classes.

2.2
---

* Appends - Support writing all data points for an hour in a single column. This saves the need for TSD compactions and reduces network traffic at query time.
* Salting - Enables greater distribution of writes for high cardinality metrics as well as asynchronous scanning for improved query speed. (Non backwards compatible)
* Random Metric UIDs - Enables better distribution of writes when creating new metrics
* Storage Exception Plugin - Enables various handling of data points when HBase is unavailable
* Secure AsyncHBase - Access HBase clusters requiring Kerberos or simple authentication along with optional encryption.
* Fill Policy - Enable emitting NaNs or Nulls via the JSON query endpoint when data points are "missing"
* Count and Percentiles - New aggregator functions
* More Stats - Gives greater insight into query performance via the query stats endpoint and new stats for threads, region clients and the JVM
* Annotations - Scan for multiple annotations only via the /api/annotations endpoint
* Query Filters - New filters for flexibility including case (in)sensitive literals, wildcards and regular expressions.
* Override Tag Widths - You can now override tag widths in the config instead of having to recompile the code.
* Compaction Tuning - New parameters allow for tuning the TSD compaction process.
* Delete Data And UIDs - Allow for deleting data at query time as well as removing UIDs from the system.
* Synchronous Writing - The HTTP Put API now supports synchronous writing to make sure data is flushed to HBase.
* Query Stats - Query details are now logged that include timing statistics. A new endpoint also shows running and completed queries.

2.1
---

* Downsampling - Timestamps are now aligned on modulus boundaries, reducing the need to interpolation across series.
* Last Data Point API - Query for the last data point for specific time series within a certain time window
* Duplicates - Handle duplicate data points at query time or during FSCK
* FSCK - An updated FSCK utility that iterates over the main data table, finding and fixing errors
* Read/Write Modes - Block assigning UIDs on individual TSDs for backup clusters
* UID Cache - Preload portions of the UID table on startup to improve writes

2.0
---

* Lock-less UID Assignment - Drastically improves write speed when storing new metrics, tag names, or values
* Restful API - Provides access to all of OpenTSDB's features as well as offering new options, defaulting to JSON
* Cross Origin Resource Sharing - For the API so you can make AJAX calls easily
* Store Data Via HTTP - Write data points over HTTP as an alternative to Telnet
* Configuration File - A key/value file shared by the TSD and command line tools
* Pluggable Serializers - Enable different inputs and outputs for the API
* Annotations - Record meta data about specific time series or data points
* Meta Data - Record meta data for each time series, metrics, tag names, or values
* Trees - Flatten metric and tag combinations into a single name for navigation or usage with different tools
* Search Plugins - Send meta data to search engines to delve into your data and figure out what's in your database
* Real-Time Publishing Plugin - Send data to external systems as they arrive to your TSD
* Ingest Plugins - Accept data points in different formats
* Millisecond Resolution - Optionally store data with millisecond precision
* Variable Length Encoding - Use less storage space for smaller integer values
* Non-Interpolating Aggregation Functions - For situations where you require raw data
* Rate Counter Calculations - Handle roll-over and anomaly supression
* Additional Statistics - Including the number of UIDs assigned and available

Thank you to everyone who has contributed to |version|. Help us out by sharing your ideas and code at `GitHub <https://github.com/OpenTSDB>`_
