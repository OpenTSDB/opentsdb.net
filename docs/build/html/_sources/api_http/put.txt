/api/put
========

This endpoint allows for storing data in OpenTSDB over HTTP as an alternative to the Telnet interface. Put requests can only be performed via content associated with the POST method. The format of the content is dependent on the serializer selected. However there are some common parameters and responses as documented below.

To save on bandwidth, the put API allows clients to store multiple data points in a single request. The data points do not have to be related in any way. Each data point is processed individually and an error with one piece of data will not affect the storing of good data. This means if your request has 100 data points and 1 of them has an error, 99 data points will still be written and one will be rejected. See the Response section below for details on determining what data point was not stored.

.. NOTE:: If the content you provide with the request cannot be parsed, such JSON content missing a quotation mark or curly brace, then all of the datapoints will be discarded. The API will return an error with details about what went wrong.

While the API does support multiple data points per request, the API will not return until every one has been processed. That means metric and tag names/values must be verified, the value parsed and the data queued for storage. If your put request has a large number of data points, it may take a long time for the API to respond, particularly if OpenTSDB has to assign UIDs to tag names or values. Therefore it is a good idea to limit the maximum number of data points per request; 50 per request is a good starting point.

Another recommendation is to enable keep-alives on your HTTP client so that you can re-use your connection to the server every time you put data.

.. NOTE:: When using HTTP for puts, you may need to enable support for chunks if your HTTP client automatically breaks large requests into smaller packets. For example, CURL will break up messages larger than 2 or 3 data points and by default, OpenTSDB disables chunk support. Enable it by setting ``tsd.http.request.enable_chunked`` to true in the config file.

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

If both ``detailed`` and ``summary`` are present in a query string, the API will respond with ``detailed`` information.

The fields and examples below refer to the default JSON serializer.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "metric", "String", "Required", "The name of the metric you are storing", "", "", "W", "sys.cpu.nice"
   "timestamp", "Integer", "Required", "A Unix epoch style timestamp in seconds or milliseconds. The timestamp must not contain non-numeric characters.", "", "", "W", "1365465600"
   "value", "Integer, Float, String", "Required", "The value to record for this data point. It may be quoted or not quoted and must conform to the OpenTSDB value rules: :doc:`../../user_guide/writing`", "", "", "W", "42.5"
   "tags", "Map", "Required", "A map of tag name/tag value pairs. At least one pair must be supplied.", "", "", "W", "{""host"":""web01""}"
   
Example Single Data Point Put
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can supply a single data point in a request:

.. code-block :: javascript

  {
      "metric": "sys.cpu.nice",
      "timestamp": 1346846400,
      "value": 18,
      "tags": {
         "host": "web01",
         "dc": "lga"
      }
  }
  
Example Multiple Data Point Put
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Multiple data points must be encased in an array:

.. code-block :: javascript

  [
      {
          "metric": "sys.cpu.nice",
          "timestamp": 1346846400,
          "value": 18,
          "tags": {
             "host": "web01",
             "dc": "lga"
          }
      },
      {
          "metric": "sys.cpu.nice",
          "timestamp": 1346846400,
          "value": 9,
          "tags": {
             "host": "web02",
             "dc": "lga"
          }
      }
  ]

Response
--------
   
By default, the put endpoint will respond with a ``204`` HTTP status code and no content if all data points were stored successfully. If one or more datapoints had an error, the API will return a ``400`` with an error message in the content.

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
      "errors": [
          {
              "datapoint": {
                  "metric": "sys.cpu.nice",
                  "timestamp": 1365465600,
                  "value": "NaN",
                  "tags": {
                      "host": "web01"
                  }
              },
              "error": "Unable to parse value to a number"
          }
      ],
      "failed": 1,
      "success": 0
  }
