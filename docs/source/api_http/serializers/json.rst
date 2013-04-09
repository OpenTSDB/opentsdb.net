JSON Serializer
===============

The default OpenTSDB serializer parses and returns JSON formatted data.

Serializer Name
---------------

``json``

Serializer Options
------------------

The following options are supported via query string:

.. csv-table::
   :header: "Parameter", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 55, 10, 15
   
   "jsonp", "String", "Optional", "Wraps the response in a JavaScript function name passed to the parameter.", "``empty``", "jsonp=callback"
   
JSONP
-----

The JSON formatter can wrap responses in a JavaScript function using the ``jsonp`` query string parameter. Supply the name of the function you wish to use and the result will be wrapped.

Example Request
^^^^^^^^^^^^^^^
::

  http://localhost:4242/api/version?jsonp=callback

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  callback({
      "timestamp": "1362712695",
      "host": "DF81QBM1",
      "repo": "/c/temp/a/opentsdb/build",
      "full_revision": "11c5eefd79f0c800b703ebd29c10e7f924c01572",
      "short_revision": "11c5eef",
      "user": "df81qbm1_/clarsen",
      "repo_status": "MODIFIED",
      "version": "2.0.0"
  })
  
api/put
-------

Each data point for the JSON serializer requires the following fields:

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
  
