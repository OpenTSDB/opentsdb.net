/api/stats
==========

This endpoint provides a list of statistics for the running TSD. These statistics are automatically recorded by a running TSD every 5 minutes but may be accessed via this endpoint. All statistics are read only.

Verbs
-----

* GET
* POST

Requests
--------

No parameters available.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/stats
   
Response
--------
   
The response is an array of objects. Fields in the response include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20
  
  "metric", "String", "Name of the metric the statistic is recording", "tsd.connectionmgr.connections"
  "timestamp", "Integer", "Unix epoch timestamp, in seconds, when the statistic was collected and displayed", "1369350222"
  "value", "Integer", "The numeric value for the statistic", "42"
  "tags", "Map", "A list of key/value tag name/tag value pairs", "*See Below*"

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  [
    {
        "metric": "tsd.connectionmgr.connections",
        "timestamp": 1369350222,
        "value": "1",
        "tags": {
            "host": "wtdb-1-4"
        }
    },
    {
        "metric": "tsd.connectionmgr.exceptions",
        "timestamp": 1369350222,
        "value": "0",
        "tags": {
            "host": "wtdb-1-4"
        }
    },
    {
        "metric": "tsd.rpc.received",
        "timestamp": 1369350222,
        "value": "0",
        "tags": {
            "host": "wtdb-1-4",
            "type": "telnet"
        }
    }
  ]
