/api/tree/collisions
====================

When processing a TSMeta, if the resulting leaf would overwrite an existing leaf with a different TSUID, a collision will be recorded. This endpoint allows retreiving a list of the TSUIDs that were not included in a tree due to collisions. It is useful for debugging in that if you find a TSUID in this list, you can pass it through the ``/tree/test`` endpoint to get details on why the collision occurred.

.. NOTE:: Calling this endpoint without a list of one or more TSUIDs will return all collisions in the tree. If you have a large number of timeseries in your system, the response can potentially be very large. Thus it is best to use this endpoint with specific TSUIDs.
   
Verbs
-----

* GET

Requests
--------

The following fields are used for this endpoint

.. csv-table::
  :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
  :widths: 10, 5, 5, 45, 10, 5, 5, 15

  "treeId", "Integer", "Required", "The ID of the tree to pass the TSMeta objects through", "", "treeid", "", "1"
  "tsuids", "String", "Required", "A list of one or more TSUIDs to search for collision entries. If requesting testing of more than one TSUID, they should be separted by a comma.", "", "tsuids", "", "000001000001000001,00000200000200002" 
   
Response
--------

A successful response will return a map of key/value pairs where the unrecorded TSUID as the key and the existing leave's TSUID as the value. The response will only return collisions that were found. If one or more of the TSUIDs requested did not result in a collision, it will not be returned with the result. This may mean that the TSMeta has not been processed yet. Note that if no collisions have occurred or the tree hasn't processed any data yet, the result set will be empty. If the requested tree did not exist in the system, a ``404`` will be returned with an error message. If invalid data was supplied a ``400`` error will be returned.

Example Request
^^^^^^^^^^^^^^^
..
  
  http://localhost:4242/api/tree/collisions?treeId=1&tsuids=010101,020202


Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "010101": "AAAAAA",
      "020202": "BBBBBB"
  }