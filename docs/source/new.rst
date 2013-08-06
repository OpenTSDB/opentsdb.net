What's New
==========

OpenTSDB has a thriving community who contributed and requested a number of new features. 2.0 has the following new features:

* Lock-less UID Assignment - Drastically improves write speed when storing new metrics, tag names ore values.
* Restful API - Provides access to all of OpenTSDB's features as well as offering new options, defaulting to JSON
* Cross Origin Resource Sharing - For the API so you can make AJAX calls easily
* Store Data Via HTTP - Write data points over HTTP as an alternative to Telnet
* Configuration File - A key/value file shared by the TSD and command line tools
* Plugable Serializers - Enable different input and outputs for the API
* Annotations - Record meta data about specific time series or data points
* Meta Data - Record meta data for each time series or metrics, tag names and values
* Trees - Flatten metric and tag combinations into single names for navigation or use with other tools
* Search Plugins - Send meta data to search engines to delve into your data and figure out what's in your database
* Real-Time Publishing Plugin - Send data to external systems as they arrive your TSD
* Ingest Plugins - Accept data points in different formats
* Millisecond Resolution - Optionally store data with millisecond precision
* Variable Length Encoding - Use less space in storage for smaller integer values
* Non-Interpolating Aggregation Functions - For situations where you require raw data
* Rate Counter Calculations - To handle roll-over and anamoly supression
* Additional Statistics - Including the number of UIDs assigned and available

More features are on the way. Help us out by sharing your ideas.