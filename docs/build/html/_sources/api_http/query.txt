/api/query
==========

Probably the most useful endpoint in the API, ``/api/query`` enables extracting data from the storage system in various formats determined by the serializer selected. Queries can be submitted via the 1.0 query string format or body content.

Verbs
-----

* GET
* POST

Requests
--------

For query string requests, please see `/q <http://opentsdb.net/http-api.html#/q>`_ until we get some other docs written.

Common parameters include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "start", "String, Integer", "Required", "The start time for the query. This can be a relative or absolute timestamp. See :doc:`../user_guide/query/index` for details.", "", "start", "", "1h-ago"
   "end", "String, Integer", "Optional", "An end time for the query. If not supplied, the TSD will assume the local system time on the server. This may be a relative or absolute timestamp. See :doc:`../user_guide/query/index` for details.", "*current time*", "end", "", "1s-ago"
   "noAnnotations", "Boolean", "Optional", "Whether or not to return annotations with a query. The default is to return annotations for the requested timespan but this flag can disable the return. This affects both local and global notes and overrides ``globalAnnotations``", "true", "no_annotations", "", "false"
   "globalAnnotations", "Boolean", "Optional", "Whether or not the query should retrieve global annotations for the requested timespan", "false", "global_annotations", "", "true"

Example Query String Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  http://localhost:4242/api/query?start=1h-ago&m=sum:rate:proc.stat.cpu{host=foo,type=idle}

Example Content Request
^^^^^^^^^^^^^^^^^^^^^^^

Please see the serializer documentation for request information.

:doc:`serializers/index`
   
Response
--------
   
The output generated for a query depends heavily on the chosen serializer :doc:`serializers/index`. A request may result in multiple sets of data returned, particularly if the request included multiple queries or grouping was requested. Some common fields included with each data set in the response will be:

.. csv-table::
  :header: "Name", "Description"
  :widths: 20, 80
  
  "metric", "Name of the metric retreived"
  "tags", "A list of tags only returned when the results are for a single timeseries. If results are aggregated, this value may be null or an empty map"
  "aggregatedTags", "If more than one timeseries were included in the result set, i.e. they were aggregated, this will display a list of tag names that were found in common across all time series."
  "dps", "Retrieved data points after being processed by the aggregators. Each data point consists of a timestamp and a value, the format determined by the serializer."
  "annotations", "If the query retrieved annotations for timeseries over the requested timespan, they will be returned in this group. Annotations for every timeseries will be merged into one set and sorted by ``start_time``. Aggregator functions do not affect annotations, all annotations will be returned for the span."
  "globalAnnotations", "If requested by the user, the query will scan for global annotations during the timespan and the results returned in this group"

Unless there was an error with the query, you will generally receive a ``200`` status with content. However if your query couldn't find any data, it will return an empty result set. In the case of the JSON serializer, the result will be an empty array:

.. code-block :: javascript  

  []

