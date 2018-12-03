/api/tree/test
==============
.. index:: HTTP /api/tree/test
For debugging a rule set, the test endpoint can be used to run a TSMeta object through a tree's rules and determine where in the heirarchy the leaf would appear. Or find out why a timeseries failed to match on a rule set or collided with an existing timeseries. The only method supported is ``GET`` and no changes will be made to the actual tree in storage when using this endpoint.

The ``messages`` field of the response contains information about what occurred during processing. If the TSUID did not exist or an error occurred, the reason will be found in this field. During processing, each rule that the TSMeta is processed through will generate a message. If a rule matched on the TSMeta successfully or failed, the reason will be recorded.
   
Verbs
-----

* GET

Requests
--------

The following fields are required for this endpoint.

.. csv-table::
  :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
  :widths: 10, 5, 5, 45, 10, 5, 5, 15

  "treeId", "Integer", "Required", "The ID of the tree to pass the TSMeta objects through", "", "treeid", "", "1"
  "tsuids", "String", "Required", "A list of one or more TSUIDs to fetch TSMeta for. If requesting testing of more than one TSUID, they should be separted by a comma.", "", "tsuids", "", "000001000001000001,00000200000200002" 
   
Response
--------

A successful response will return a list of JSON objects with a number of items including the TSMeta object, messages about the processing steps taken and a resulting branch. There will be one object for each TSUID requested with the TSUID as the object name. If the requested tree did not exist in the system, a ``404`` will be returned with an error message. If invalid data was supplied a ``400`` error will be returned.

Fields found in the response include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20

  "messages", "Array of Strings", "A list of messages for each level and rule of the rule set", "*See Below*"
  "meta", "Object", "The TSMeta object loaded from storage", "*See Below*"
  "branch", "Object", "The full tree if successfully parsed", "*See Below*"

Example Request
^^^^^^^^^^^^^^^
..
  
  http://localhost:4242/api/tree/test?treeId=1&tsuids=000001000001000001000002000002


Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "000001000001000001000002000002": {
          "messages": [
              "Processing rule: [1:0:0:TAGK]",
              "Matched tagk [host] for rule: [1:0:0:TAGK]",
              "Processing rule: [1:1:0:METRIC]",
              "Depth [3] Adding leaf [name: sys.cpu.0 tsuid: 000001000001000001000002000002] to parent branch [Name: [web-01.lga.mysite.com]]"
          ],
          "meta": {
              "tsuid": "000001000001000001000002000002",
              "metric": {
                  "uid": "000001",
                  "type": "METRIC",
                  "name": "sys.cpu.0",
                  "description": "",
                  "notes": "",
                  "created": 1368979404,
                  "custom": null,
                  "displayName": ""
              },
              "tags": [
                  {
                      "uid": "000001",
                      "type": "TAGK",
                      "name": "host",
                      "description": "",
                      "notes": "",
                      "created": 1368979404,
                      "custom": null,
                      "displayName": ""
                  },
                  {
                      "uid": "000001",
                      "type": "TAGV",
                      "name": "web-01.lga.mysite.com",
                      "description": "",
                      "notes": "",
                      "created": 1368979404,
                      "custom": null,
                      "displayName": ""
                  },
                  {
                      "uid": "000002",
                      "type": "TAGK",
                      "name": "type",
                      "description": "",
                      "notes": "",
                      "created": 1368979404,
                      "custom": null,
                      "displayName": ""
                  },
                  {
                      "uid": "000002",
                      "type": "TAGV",
                      "name": "user",
                      "description": "",
                      "notes": "",
                      "created": 1368979404,
                      "custom": null,
                      "displayName": ""
                  }
              ],
              "description": "",
              "notes": "",
              "created": 0,
              "units": "",
              "retention": 0,
              "max": "NaN",
              "min": "NaN",
              "displayName": "",
              "lastReceived": 0,
              "totalDatapoints": 0,
              "dataType": ""
          },
          "branch": {
              "leaves": null,
              "branches": [
                  {
                      "leaves": [
                          {
                              "metric": "",
                              "tags": null,
                              "tsuid": "000001000001000001000002000002",
                              "displayName": "sys.cpu.0"
                          }
                      ],
                      "branches": null,
                      "path": {
                          "0": "ROOT",
                          "1": "web-01.lga.mysite.com"
                      },
                      "treeId": 1,
                      "displayName": "web-01.lga.mysite.com",
                      "branchId": "0001247F7202",
                      "numLeaves": 1,
                      "numBranches": 0,
                      "depth": 1
                  }
              ],
              "path": {
                  "0": "ROOT"
              },
              "treeId": 1,
              "displayName": "ROOT",
              "branchId": "0001",
              "numLeaves": 0,
              "numBranches": 1,
              "depth": 0
          }
      }
  }
  
Example Error Response
^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "000001000001000001000002000003": {
          "branch": null,
          "messages": [
              "Unable to locate TSUID meta data"
          ],
          "meta": null
      }
  }