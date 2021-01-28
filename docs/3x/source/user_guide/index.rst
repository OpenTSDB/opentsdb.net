Users Guide
===========

These pages serve as a guide for using OpenTSDB, i.e. querying and writing data. More to come.

Querying Data
-------------

TSDB V3 provides backwards compatibility with the V2 HTTP query APIs via query parameters or JSON payloads. It also introduces new querying means including a pedantic semantic query via JSON and plugins for other languages such as PromQL. 

.. toctree::
   :maxdepth: 1
   
   semanticquery/index
   ../api_http/query/index
   ../api_http/query/exp

Anomaly Detection
^^^^^^^^^^^^^^^^^

V3 also supports time series forecasting/predictions with optional anomaly detection. Optional plugins are provided to use different models or algorithms for computing the forecasts.

.. toctree::
   :maxdepth: 1
   
   anomaly

Writing Data
------------

V3 also supports previous write protocols over HTTP.

.. WARNING::
  
  The write path hasn't been tested a great deal yet and some features are missing. TODOs include:
  
  * Telnet writes
  * Rollup writes via HTTP
  * Validation of the data and proper UTs