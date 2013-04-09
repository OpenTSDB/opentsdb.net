/api/aggregators
================

This endpoint simply lists the names of implemented aggregation functions used in timeseries queries.

Verbs
-----

* GET
* POST

Requests
--------

This endpoint does not require any parameters via query string or body.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  http://localhost:4242/api/aggregators
   
Response
--------
   
The response is an array of strings that are the names of aggregation functions that can be used in a timeseries query.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  [
      "min",
      "sum",
      "max",
      "avg",
      "dev"
  ]
