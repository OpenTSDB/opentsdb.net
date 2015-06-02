What's New
==========

OpenTSDB has a thriving community who contributed and requested a number of new features. 

2.2
---

Currently in the "next" branch on Github.

* Appends - Support writing all data points for an hour in a single column. This saves the need for TSD compactions and reduces network traffic at query time.
* Salting - Enables greater distribution of writes for high cardinality metrics as well as asynchronous scanning for improved query speed. (Non backwards compatible)
* Random Metric UIDs - Enables better distribution of writes when creating new metrics
* Storage Exception Plugins - Enables various handling of data points when HBase is unavailable
* Secure AsyncHBase - Access HBase clusters requiring Kerberos or simple authentication along with optional encryption.
* Fill Policy - Enable emitting NaNs or Nulls via the JSON query endpoint when data points are "missing"
* Count and Percentiles - New aggregator functions

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
* Rate Counter Calculations - Handle roll-over and anomaly suppression
* Additional Statistics - Including the number of UIDs assigned and available

Thank you to everyone who has contributed to |version|. Help us out by sharing your ideas and code at `GitHub <https://github.com/OpenTSDB>`_
