/api/stats/region_clients
=========================
.. index:: HTTP /api/stats/region_clients
Returns information about the various HBase region server clients in AsyncHBase. This helps to identify issues with a particular region server. (v2.2)

Verbs
-----

* GET

Requests
--------

No parameters available.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/stats/region_clients
   
Response
--------
   
The response is an array of objects. Fields in the response include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20
  
  "pendingBreached", "Integer", "The total number of times writes to a new region client were discarded because it's pending RPC buffer was full. This should almost always be zero and a positive value indicates the TSD took a long time to connect to a region server.", "0"
  "writesBlocked", "Integer", "How many RPCs (batched or individual) in total were blocked due to the connection's send buffer being full. A positive value indicates a slow HBase server or poor network performance.", "0"
  "inflightBreached", "Integer", "The total number of times RPCs were blocked due to too many outstanding RPCs waiting for a response from HBase. A positive value indicates the region server is slow or network performance is poor.", "0"
  "dead", "Boolean", "Whether or not the region client is marked as dead due to a connection close event (such as region server going down)", "false"
  "rpcsInFlight", "Integer", "The current number of RPCs sent to HBase and awaiting a response.", "10"
  "rpcsSent", "Integer", "The total number of RPCs sent to HBase.", "424242"
  "rpcResponsesUnknown", "Integer", "The total number of responses received from HBase for which we couldn't find an RPC. This may indicate packet corruption or an incompatible HBase version.", "0"
  "pendingBatchedRPCs", "Integer", "The number of RPCs queued in the batched RPC awaiting the next flush or the batch limit.", "0"
  "endpoint", "String", "The IP and port of the region server in the format '/<ip>:<port>'", "/127.0.0.1:35008"
  "rpcResponsesTimedout", "Integer", "The total number of responses from HBase for RPCs that have previously timedout. This means HBase may be catching up and responding to stale RPCs.", "0"
  "rpcid", "Integer", "The ID of the last RPC sent to HBase. This may be a negative number", "42"
  "rpcsTimedout", "Integer", "The total number of RPCs that have timed out. This may indicate a slow region server, poor network performance or GC issues with the TSD.", "0"
  "pendingRPCs", "Integer", "The number of RPCs queued and waiting for the connection handshake with the region server to complete", "0"

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  [
      {
          "pendingBreached": 0,
          "writesBlocked": 0,
          "inflightBreached": 0,
          "dead": false,
          "rpcsInFlight": 0,
          "rpcsSent": 35704,
          "rpcResponsesUnknown": 0,
          "pendingBatchedRPCs": 452,
          "endpoint": "/127.0.0.1:35008",
          "rpcResponsesTimedout": 0,
          "rpcid": 35703,
          "rpcsTimedout": 0,
          "pendingRPCs": 0
      }
  ]
