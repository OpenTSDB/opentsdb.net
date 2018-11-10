JSON Serializer
===============
.. index:: HTTP JSON Serializer
The default OpenTSDB serializer parses and returns JSON formatted data. Below you'll find details about the serializer and request parameters that affect only the the JSON serializer. If the serializer has extra parameters for a specific endpoint, they'll be listed below.

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

api/query
---------

The JSON serializer allows some query string parameters that modify the output but have no effect on the data retrieved.

.. csv-table::
  :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
  :widths: 10, 10, 5, 50, 10, 15
  
  "arrays", "Boolean", "Optional", "Returns the data points formatted as an array of arrays instead of a map of key/value pairs. Each array consists of the timestamp followed by the value.", "false", "arrays=true"
