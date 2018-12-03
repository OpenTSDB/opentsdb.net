/api/histogram
==============
.. index:: HTTP /api/histogram

**Available with OpenTSDB 2.4**

This endpoint allows for storing histogram data in OpenTSDB over HTTP as an alternative to the Telnet interface. Histogram write requests can only be performed via content associated with the POST method. Queries over histogram data are performed via the query endpoints.

To save on bandwidth, the put API allows clients to store multiple data points in a single request. The data points do not have to be related in any way. Each data point is processed individually and an error with one piece of data will not affect the storing of good data. This means if your request has 100 data points and 1 of them has an error, 99 data points will still be written and one will be rejected. See the Response section below for details on determining what data point was not stored.

.. NOTE:: If the content you provide with the request cannot be parsed, such JSON content missing a quotation mark or curly brace, then all of the datapoints will be discarded. The API will return an error with details about what went wrong.

While the API does support multiple data points per request, the API will not return until every one has been processed. That means metric and tag names/values must be verified, the value parsed and the data queued for storage. If your put request has a large number of data points, it may take a long time for the API to respond, particularly if OpenTSDB has to assign UIDs to tag names or values. Therefore it is a good idea to limit the maximum number of data points per request; 50 per request is a good starting point.

Another recommendation is to enable keep-alives on your HTTP client so that you can re-use your connection to the server every time you put data.

.. NOTE:: When using HTTP for puts, you may need to enable support for chunks if your HTTP client automatically breaks large requests into smaller packets. For example, CURL will break up messages larger than 2 or 3 data points and by default, OpenTSDB disables chunk support. Enable it by setting ``tsd.http.request.enable_chunked`` to true in the config file.

.. NOTE:: If the ``tsd.mode`` is set to ``ro``, the ``/api/histogram`` endpoint will be unavailable and all calls will return a 404 error.

.. WARNING:: Histograms as implemented in 2.4 do not support derivative computations at query time (e.g. rates). When writing histograms, they should come from each source at regular intervals and must reflect *only the measurements for that particular interval*. E.g. If the source wants to report latency histograms every 5 minutes, then the source should create a new histogram object every 5 minutes, populate it with measurements, write it to TSDB and create a new, empty histogram for the next 5 minute interval. 

Verbs
-----

* POST

Requests
--------

Some query string parameters can be supplied that alter the response to a put request:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "summary", "Present", "Optional", "Whether or not to return summary information", "false", "summary", "", "/api/put?summary"
   "details", "Present", "Optional", "Whether or not to return detailed information", "false", "details", "", "/api/put?details"
   "sync", "Boolean", "Optional", "Whether or not to wait for the data to be flushed to storage before returning the results.", "false", "sync", "", "/api/put?sync"
   "sync_timeout", "Integer", "Optional", "A timeout, in milliseconds, to wait for the data to be flushed to storage before returning with an error. When a timeout occurs, using the ``details`` flag will tell how many data points failed and how many succeeded. ``sync`` must also be given for this to take effect. A value of 0 means the write will not timeout.", "0", "sync_timeout", "", "/api/histogram/?sync&sync_timeout=60000"

If both ``detailed`` and ``summary`` are present in a query string, the API will respond with ``detailed`` information.

The fields and examples below refer to the default JSON serializer.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "metric", "String", "Required", "The name of the metric you are storing", "", "", "W", "sys.cpu.nice"
   "timestamp", "Integer", "Required", "A Unix epoch style timestamp in seconds or milliseconds. The timestamp must not contain non-numeric characters.", "", "", "W", "1365465600"
   "id", "Integer", "Optional", "When writing histograms or sketches other than the default simple bucketed histogram, this value must be set to the ID of the proper histogram codec as defined in the ``tsd.core.histograms.config`` configuration setting. The value must be between 0 and 255. When given, the ``value`` must be set.", "", "", "w", "1"
   "value", "String", "Optional", "The base 64 encoded binary data of the histogram or sketch to be stored. **Note** The ID must also be given when writing binary data in order to match the proper codec.", "", "", "W", "AgMIGo="
   "buckets", "Map", "Optional", "A map of bucket lower and upper bounds (separated by commas) as keys with integer counter bucket values. Details are below.", "", "", "W", "{""0,1.75"":12,""1.75,3.5"":16}"
   "underflow", "Integer", "Optional", "The count of measurements lower than the lowest bucket lower bound. Default is zero.", "", "", "W", "0"
   "overflow", "Integer", "Optional", "The count of measurements higher than the highest bucket upper bound. Default is zero.", "", "", "W", "0"
   "tags", "Map", "Required", "A map of tag name/tag value pairs. At least one pair must be supplied.", "", "", "W", "{""host"":""web01""}"

.. NOTE:: Either the ``id`` and ``value`` fields must be set *or* the ``buckets`` must have values. If both ``value`` and ``buckets`` are set then ``value`` takes precedence and the buckets are ignored.

**Buckets**

The comma separated bucket lower bound (left of the comma) and upper bound (right of the comma). The upper and lower bounds of consecutive buckets must overlap. I.e. we may have two buckets ``0,1.75=12`` and ``1.75,3.5=16``.", "0,1.75=12". The simple histogram is also limited to a maximum of ``100`` buckets. Buckets may appear in any order.

Example Single Data Point Write
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can supply a single data point in a request:

.. code-block :: javascript

  {
      "metric": "sys.cpu.nice",
      "timestamp": 1356998400,
      "overflow": 1,
      "underflow": 0,
      "buckets": {
          "0,1.75": 12,
          "1.75,3.5": 16
      },
      "tags": {
          "host": "web01",
          "dc": "lga"
      }
  }
  
Example Multiple Data Point Write
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Multiple data points must be encased in an array:

.. code-block :: javascript

  [{
      "metric": "sys.cpu.nice",
      "timestamp": 1346846400,
      "value": "AgMIGoAAAAADAAAAAAAAAAAAAAAAAPA/AAAAAABARUAAAAAAAADwPwAAAAAAADhAAAAAAABARUA=",
      "tags": {
          "host": "web01",
          "dc": "lga"
      },
      "id": 1
  }, {
      "metric": "sys.cpu.nice",
      "timestamp": 1346846460,
      "value": "AgMIGoAAAAADAAAAAAAAAAAAAAAAAChAMzMzMzNTVkAAAAAAAAAoQAAAAAAAAC5AMzMzMzNTVkA=",
      "tags": {
          "host": "web01",
          "dc": "lga"
      },
      "id": 1
  }, {
      "metric": "sys.cpu.nice",
      "timestamp": 1346846520,
      "value": "AgMIGoAAAAADAAAAAAAAAOxRuB6F6xtAAAAAAACAQEDsUbgehesbQGZmZmZmZjZAAAAAAACAQEA=",
      "tags": {
          "host": "web01",
          "dc": "lga"
      },
      "id": 1
  }]

Response
--------
   
By default, the histogram endpoint will respond with a ``204`` HTTP status code and no content if all data points were stored successfully. If one or more data points had an error, the API will return a ``400`` with an error message in the content.

For debugging purposes, you can ask for the response to include a summary of how many data points were stored successfully and failed, or get details about what data points could not be stored and why so that you can fix your client code. Also, errors with a data point will be logged in the TSD's log file so you can look there for issues.

Fields present in ``summary`` or ``detailed`` responses include:

.. csv-table::
   :header: "Name", "Data Type", "Description"
   :widths: 10, 10, 80
   
   "success", "Integer", "The number of data points that were queued successfully for storage"
   "failed", "Integer", "The number of data points that could not be queued for storage"
   "errors", "Array", "A list of data points that failed be queued and why. Present in the ``details`` response only."

Example Response with Summary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "failed": 1,
      "success": 0
  }

Example Response With Details
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "errors": [{
          "datapoint": {
              "metric": "sys.cpu.nice",
              "timestamp": 1346846460,
              "value": "AgMIGoAAAAADAAAAAAAAAAAAAAAAAChAMzMzMzNTVkAAAAAAAAAoQAAAAAAAAC5AMzMzMzNTVkA=",
              "tags": {
                  "host": "web01",
                  "dc": "lga"
              },
              "id": 1
          },
          "error": "Unable to find histogram codec for id: 1"
      }],
      "failed": 1,
      "success": 0
  }
