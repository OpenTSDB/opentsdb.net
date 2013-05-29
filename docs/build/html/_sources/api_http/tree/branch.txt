/api/tree/branch
================

A branch represents a level in the tree heirarchy and contains information about child branches and/or leaves. Branches are immutable from an API perspective and can only be created or modified by processing a TSMeta through tree rules via a CLI command or when a new timeseries is encountered or a TSMeta object modified. Therefore the ``branch`` endpoint only supports the ``GET`` verb.

A branch is identified by a ``branchId``, a hexadecimal encoded string that represents the ID of the tree it belongs to as well as the IDs of each parent the branch stems from. All branches stem from the **ROOT** branch of a tree and this is usually the starting place when browsing. To fetch the **ROOT** just call this endpoingt with a valid ``treeId``. The root branch ID is also a 4 character encoding of the tree ID.

Verbs
-----

* GET

Requests
--------

The following fields can be used to request a branch. Only one or the other may be used.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "treeId", "Integer", "Optional", "Used to fetch the root branch of the tree. If used in combination with a branchId, the tree ID will be ignored.", "", "treeid", "RO", "1"
   "branch", "String", "Required", "A hexadecimal representation of the branch ID, required for all but the root branch request", "", "branch", "RO", "000183A21C8F"
   
Response
--------

A successful response to a request will return the branch object using the requested serializer. If the requested tree or branch did not exist in the system, a ``404`` will be returned with an error message.

Fields returned with the response include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20

  "treeId", "Integer", "The ID of the tree the branch belongs to", "1"
  "displayName", "String", "Name of the branch as determined by the rule set", "sys"
  "branchId", "String", "Hexadecimal encoded ID of the branch", "00010001BECD"
  "depth", "Integer", "Depth of the branch within the tree, starting at *0* for the root branch", "1"
  "path", "Map", "List of parent branch names and their depth.", "*See Below*"
  "branches", "Array", "An array of child branch objects. May be ``null``.", "*See Below*"
  "leaves", "Array", "An array of child leaf objects. May be ``null``.", "*See Leaves Below*"

**Leaves**

If a branch contains child leaves, i.e. timeseries stored in OpenTSDB, their metric, tags, TSUID and display name will be contained in the results. Leaf fields are as follows:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20

  "metric", "String", "The name of the metric for the timeseries", "sys.cpu.0"
  "tags", "Map", "A list of tag names and values representing the timeseries", "*See Below*"
  "tsuid", "String", "Hexadecimal encoded timeseries ID", "000001000001000001"
  "displayName", "String", "A name as parsed by the rule set", "user"
GET
---

Example Root GET Query
^^^^^^^^^^^^^^^^^^^^^^
::

  http://localhost:4242/api/tree/branch?treeid=1
  
Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "leaves": null,
      "branches": [
          {
              "leaves": null,
              "branches": null,
              "path": {
                  "0": "ROOT",
                  "1": "sys"
              },
              "treeId": 1,
              "displayName": "sys",
              "branchId": "00010001BECD",
              "depth": 1
          }
      ],
      "path": {
          "0": "ROOT"
      },
      "treeId": 1,
      "displayName": "ROOT",
      "branchId": "0001",
      "depth": 0
  }

Example Branch GET Query
^^^^^^^^^^^^^^^^^^^^^^^^
::

  http://localhost:4242/api/tree/branch?branchid=00010001BECD000181A8
  
Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "leaves": [
          {
              "metric": "sys.cpu.0.user",
              "tags": {
                  "host": "web01"
              },
              "tsuid": "000001000001000001",
              "displayName": "user"
          }
      ],
      "branches": [
          {
              "leaves": null,
              "branches": null,
              "path": {
                  "0": "ROOT",
                  "1": "sys",
                  "2": "cpu",
                  "3": "mboard"
              },
              "treeId": 1,
              "displayName": "mboard",
              "branchId": "00010001BECD000181A8BF992A99",
              "depth": 3
          }
      ],
      "path": {
          "0": "ROOT",
          "1": "sys",
          "2": "cpu"
      },
      "treeId": 1,
      "displayName": "cpu",
      "branchId": "00010001BECD000181A8",
      "depth": 2
  }
