/api/uid/assign
===============

This endpoint enables assigning UIDs to new metrics, tag names and tag values. Multiple types and names can be provided in a single call and the API will process each name individually, reporting which names were assigned UIDs successfully, along with the UID assigned, and which failed due to invalid characters or had already been assigned. Assignment can be performed via query string or content data.

Verbs
-----

* GET
* POST

Requests
--------

Each request must have one or more of the following fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "metric", "String", "Optional", "A list of metric names for assignment", "", "metric", "RW", "sys.cpu.0"
   "tagk", "String", "Optional", "A list of tag names for assignment", "", "tagk", "RW", "host"
   "tagv", "String", "Optional", "A list of tag values for assignment", "", "tagv", "RW", "web01"

When making a query string request, multiple names for a given type can be supplied in a comma separated fashion. E.g. ``metric=sys.cpu.0,sys.cpu.1,sys.cpu.2,sys.cpu.3``. Naming conventions apply: see _______.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/uid/assign?metric=sys.cpu.0,sys.cpu.1&tagk=host&tagv=web01,web02,web03

**JSON Content**

.. code-block :: javascript 

  {
      "metric": [
          "sys.cpu.0",
          "sys.cpu.1",
          "illegal!character"
      ],
      "tagk": [
          "host"
      ],
      "tagv": [
          "web01",
          "web02",
          "web03"
      ]
  }
   
Response
--------
   
The response will contain a map of successful assignments along with the hex encoded UID value. If one or more values were not assigned, a separate map will contain a list of the values and the reason why they were not assigned. Maps with the type name and ``<type>_errors`` will be generated only if one or more values for that type were provided.

When all values are assigned, the endpoint returns a 200 status code but if any value failed assignment, it will return a 400. 

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "metric": {},
      "metric_errors": {
          "sys.cpu.0": "Name already exists with UID: 000042",
          "sys.cpu.1": "Name already exists with UID: 000043",
          "illegal!character": "Invalid metric (illegal!character): illegal character: !",
      },
      "tagv": {},
      "tagk_errors": {
          "host": "Name already exists with UID: 0007E5"
      },
      "tagk": {
          "web01": "000012",
          "web02": "000013",
          "web03": "000014"
      }
  }
