What's New
==========

OpenTSDB has a thriving community who contributed and requested a number of new features. 2.0 has the following new features:

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
