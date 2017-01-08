/api/stats/jvm
==============
.. index:: HTTP /api/stats/jvm
The threads endpoint is used for debugging the TSD's JVM process and includes stats about the garbage collector, system load and memory usage. (v2.2)

.. NOTE ::

  The information printed will change depending on the JVM you are running the TSD under. In particular, the pools and GC sections will differ quite a bit.

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
  
  http://localhost:4242/api/stats/jvm
   
Response
--------
   
The response is an object with multiple sub objects. Top level objects include

.. csv-table::
  :header: "Name", "Data Type", "Description"
  :widths: 10, 10, 80
  
  "os", "Object", "Information about the system"
  "gc", "Object", "Information about the various garbage collectors such as how many times GC occurred and how long the process spent collecting."
  "runtime", "Object", "Details about the JVM including version and vendor, start timestamp (in millieconds) and the uptime."
  "pools", "Object", "Details about each of the memory pools, particularly when used with a generational collector."
  "memory", "Object", "Information about the JVM's memory usage."

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "os": {
          "systemLoadAverage": 4.85
      },
      "gc": {
          "parNew": {
              "collectionTime": 26027510,
              "collectionCount": 361039
          },
          "concurrentMarkSweep": {
              "collectionTime": 333710,
              "collectionCount": 396
          }
      },
      "runtime": {
          "startTime": 1441069233346,
          "vmVersion": "24.60-b09",
          "uptime": 1033439220,
          "vmVendor": "Oracle Corporation",
          "vmName": "Java HotSpot(TM) 64-Bit Server VM"
      },
      "pools": {
          "cMSPermGen": {
              "collectionUsage": {
                  "init": 21757952,
                  "used": 30044544,
                  "committed": 50077696,
                  "max": 85983232
              },
              "usage": {
                  "init": 21757952,
                  "used": 30045408,
                  "committed": 50077696,
                  "max": 85983232
              },
              "type": "NON_HEAP",
              "peakUsage": {
                  "init": 21757952,
                  "used": 30045408,
                  "committed": 50077696,
                  "max": 85983232
              }
          },
          "parSurvivorSpace": {
              "collectionUsage": {
                  "init": 157024256,
                  "used": 32838400,
                  "committed": 157024256,
                  "max": 157024256
              },
              "usage": {
                  "init": 157024256,
                  "used": 32838400,
                  "committed": 157024256,
                  "max": 157024256
              },
              "type": "HEAP",
              "peakUsage": {
                  "init": 157024256,
                  "used": 157024256,
                  "committed": 157024256,
                  "max": 157024256
              }
          },
          "codeCache": {
              "collectionUsage": null,
              "usage": {
                  "init": 2555904,
                  "used": 8754368,
                  "committed": 8978432,
                  "max": 50331648
              },
              "type": "NON_HEAP",
              "peakUsage": {
                  "init": 2555904,
                  "used": 8767040,
                  "committed": 8978432,
                  "max": 50331648
              }
          },
          "cMSOldGen": {
              "collectionUsage": {
                  "init": 15609561088,
                  "used": 1886862056,
                  "committed": 15609561088,
                  "max": 15609561088
              },
              "usage": {
                  "init": 15609561088,
                  "used": 5504187904,
                  "committed": 15609561088,
                  "max": 15609561088
              },
              "type": "HEAP",
              "peakUsage": {
                  "init": 15609561088,
                  "used": 11849865176,
                  "committed": 15609561088,
                  "max": 15609561088
              }
          },
          "parEdenSpace": {
              "collectionUsage": {
                  "init": 1256259584,
                  "used": 0,
                  "committed": 1256259584,
                  "max": 1256259584
              },
              "usage": {
                  "init": 1256259584,
                  "used": 825272064,
                  "committed": 1256259584,
                  "max": 1256259584
              },
              "type": "HEAP",
              "peakUsage": {
                  "init": 1256259584,
                  "used": 1256259584,
                  "committed": 1256259584,
                  "max": 1256259584
              }
          }
      },
      "memory": {
          "objectsPendingFinalization": 0,
          "nonHeapMemoryUsage": {
              "init": 24313856,
              "used": 38798912,
              "committed": 59056128,
              "max": 136314880
          },
          "heapMemoryUsage": {
              "init": 17179869184,
              "used": 6351794296,
              "committed": 17022844928,
              "max": 17022844928
          }
      }
  }
