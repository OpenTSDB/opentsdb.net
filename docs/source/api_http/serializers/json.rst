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