/api/search
==========
.. index:: HTTP /api/search
This endpoint provides a basic means of searching OpenTSDB meta data. Lookups can be performed against the ``tsdb-meta`` table when enabled. Optionally, a search plugin can be installed to send and retreive information from an external search indexing service such as Elastic Search. It is up to each search plugin to implement various parts of this endpoint and return data in a consistent format. The type of object searched and returned depends on the endpoint chosen. 

.. NOTE:: If the plugin is not configured or enabled, endpoints other than ``/api/search/lookup`` will return an exception.

Search API Endpoints
--------------------

* :doc:`lookup`
* /api/search/tsmeta - :ref:`tsmeta_endpoint`
* /api/search/tsmeta_summary - :ref:`tsmeta_summary_endpoint`
* /api/search/tsuids - :ref:`tsuids_endpoint`
* /api/search/uidmeta - :ref:`uidmeta_endpoint`
* /api/search/annotation - :ref:`annotation_endpoint`

Verbs
-----

* GET
* POST

Requests
--------

Parameters used by the search endpoint include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15

   "query", "String", "Optional", "The string based query to pass to the search engine. This will be parsed by the engine or plugin to perform the actual search. Allowable values depends on the plugin. Ignored for lookups.", "", "query", "", "name:sys.cpu.\*"
   "limit", "Integer", "Optional", "Limits the number of results returned per query so as not to override the TSD or search engine. Allowable values depends on the plugin. Ignored for lookups.", "25", "limit", "", "100"
   "startIndex", "Integer", "Optional", "Used in combination with the ``limit`` value to page through results. Allowable values depends on the plugin. Ignored for lookups.", "0", "start_index", "", "42"
   "metric", "String", "Optional", "The name of a metric or a wildcard for lookup queries", "\*", "metric", "", "tsd.hbase.rpcs"
   "tags", "Array", "Optional", "One or more key/value objects with tag names and/or tag values for lookup queries. See :doc:`lookup`", "", "tags", "", "See :doc:`lookup`"

Example Request
^^^^^^^^^^^^^^^

Query String:
::
  
  http://localhost:4242/api/search/tsmeta?query=name:*&limit=3&start_index=0

POST:

.. code-block :: javascript 

  {
      "query": "name:*",
      "limit": 4,
      "startIndex": 5
  }

Response
--------
   
Depending on the endpoint called, the output will change slightly. However common fields include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20
  
  "type", "String", "The type of query submitted, i.e. the endpoint called. Will be one of the endpoints listed above.", "TSMETA"
  "query", "String", "The query string submitted. May be altered by the plugin", "name:sys.cpu.\*"
  "limit", "Integer", "The maximum number of items returned in the result set. Note that the actual number returned may be less than the limit.", "25"
  "startIndex", "Integer", "The starting index for the current result set as provided in the query", "0"
  "metric", "String", "The metric used for the lookup", "*"
  "tags", "Array", "The list of tag pairs used for lookup queries. May be an empty list.", "[ ]"
  "time", "Integer", "The amount of time it took, in milliseconds, to complete the query", "120"
  "totalResults", "Integer", "The total number of results matched by the query", "1024"
  "results", "Array", "The result set. The format depends on the endpoint requested.", "*See Below*"
  
This endpoint will almost always return a ``200`` with content body. If the query doesn't match any results, the ``results`` field will be an empty array and ``totalResults`` will be 0. If an error occurs, such as the plugin being disabled or not configured, an exception will be returned.

.. _tsmeta_endpoint:

TSMETA Response
---------------

The TSMeta endpoint returns a list of matching TSMeta objects.

.. code-block :: javascript 

  {
      "type": "TSMETA",
      "query": "name:*",
      "metric": "*",
      "tags": [],
      "limit": 2,
      "time": 675,
      "results": [
          {
              "tsuid": "0000150000070010D0",
              "metric": {
                  "uid": "000015",
                  "type": "METRIC",
                  "name": "app.apache.connections",
                  "description": "",
                  "notes": "",
                  "created": 1362655264,
                  "custom": null,
                  "displayName": ""
              },
              "tags": [
                  {
                      "uid": "000007",
                      "type": "TAGK",
                      "name": "fqdn",
                      "description": "",
                      "notes": "",
                      "created": 1362655264,
                      "custom": null,
                      "displayName": ""
                  },
                  {
                      "uid": "0010D0",
                      "type": "TAGV",
                      "name": "web01.mysite.com",
                      "description": "",
                      "notes": "",
                      "created": 1362720007,
                      "custom": null,
                      "displayName": ""
                  }
              ],
              "description": "",
              "notes": "",
              "created": 1362740528,
              "units": "",
              "retention": 0,
              "max": 0,
              "min": 0,
              "displayName": "",
              "dataType": "",
              "lastReceived": 0,
              "totalDatapoints": 0
          },
          {
              "tsuid": "0000150000070010D5",
              "metric": {
                  "uid": "000015",
                  "type": "METRIC",
                  "name": "app.apache.connections",
                  "description": "",
                  "notes": "",
                  "created": 1362655264,
                  "custom": null,
                  "displayName": ""
              },
              "tags": [
                  {
                      "uid": "000007",
                      "type": "TAGK",
                      "name": "fqdn",
                      "description": "",
                      "notes": "",
                      "created": 1362655264,
                      "custom": null,
                      "displayName": ""
                  },
                  {
                      "uid": "0010D5",
                      "type": "TAGV",
                      "name": "web02.mysite.com",
                      "description": "",
                      "notes": "",
                      "created": 1362720007,
                      "custom": null,
                      "displayName": ""
                  }
              ],
              "description": "",
              "notes": "",
              "created": 1362882263,
              "units": "",
              "retention": 0,
              "max": 0,
              "min": 0,
              "displayName": "",
              "dataType": "",
              "lastReceived": 0,
              "totalDatapoints": 0
          }
      ],
      "startIndex": 0,
      "totalResults": 9688066
  }

.. _tsmeta_summary_endpoint:

TSMETA_SUMMARY Response
-----------------------

The TSMeta Summary endpoint returns just the basic information associated with a timeseries including the TSUID, the metric name and tags. The search is run against the same index as the TSMeta query but returns a subset of the data.

.. code-block :: javascript 

  {
      "type": "TSMETA_SUMMARY",
      "query": "name:*",
      "metric": "*",
      "tags": [],
      "limit": 3,
      "time": 565,
      "results": [
          {
              "tags": {
                  "fqdn": "web01.mysite.com"
              },
              "metric": "app.apache.connections",
              "tsuid": "0000150000070010D0"
          },
          {
              "tags": {
                  "fqdn": "web02.mysite.com"
              },
              "metric": "app.apache.connections",
              "tsuid": "0000150000070010D5"
          },
          {
              "tags": {
                  "fqdn": "web03.mysite.com"
              },
              "metric": "app.apache.connections",
              "tsuid": "0000150000070010D6"
          }
      ],
      "startIndex": 0,
      "totalResults": 9688066
  }

.. _tsuids_endpoint:

TSUIDS Response
---------------

The TSUIDs endpoint returns a list of TSUIDS that match the query. The search is run against the same index as the TSMeta query but returns a subset of the data.

.. code-block :: javascript 

  {
      "type": "TSUIDS",
      "query": "name:*",
      "metric": "*",
      "tags": [],
      "limit": 3,
      "time": 517,
      "results": [
          "0000150000070010D0",
          "0000150000070010D5",
          "0000150000070010D6"
      ],
      "startIndex": 0,
      "totalResults": 9688066
  }

.. _uidmeta_endpoint:

UIDMETA Response
----------------

The UIDMeta endpoint returns a list of UIDMeta objects that match the query.

.. code-block :: javascript 

  {
      "type": "UIDMETA",
      "query": "name:*",
      "metric": "*",
      "tags": [],
      "limit": 3,
      "time": 517,
      "results": [
          {
              "uid": "000007",
              "type": "TAGK",
              "name": "fqdn",
              "description": "",
              "notes": "",
              "created": 1362655264,
              "custom": null,
              "displayName": ""
          },
          {
              "uid": "0010D0",
              "type": "TAGV",
              "name": "web01.mysite.com",
              "description": "",
              "notes": "",
              "created": 1362720007,
              "custom": null,
              "displayName": ""
          },
          {
              "uid": "0010D5",
              "type": "TAGV",
              "name": "web02.mysite.com",
              "description": "",
              "notes": "",
              "created": 1362720007,
              "custom": null,
              "displayName": ""
          }
      ],
      "startIndex": 0,
      "totalResults": 9688066
  }

.. _annotation_endpoint:

Annotation Response
-------------------

The Annotation endpoint returns a list of Annotation objects that match the query.

.. code-block :: javascript 

  {
      "type": "ANNOTATION",
      "query": "description:*",
      "metric": "*",
      "tags": [],
      "limit": 25,
      "time": 80,
      "results": [
          {
              "tsuid": "000001000001000001",
              "description": "Testing Annotations",
              "notes": "These would be details about the event, the description is just a summary",
              "custom": {
                  "owner": "jdoe",
                  "dept": "ops"
              },
              "endTime": 0,
              "startTime": 1369141261
          }
      ],
      "startIndex": 0,
      "totalResults": 1
  }
