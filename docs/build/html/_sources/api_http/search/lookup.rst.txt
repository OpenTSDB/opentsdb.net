/api/search/lookup
==================
.. index:: HTTP /api/lookup
.. NOTE::

  Available in 2.1

Lookup queries use either the meta data table or the main data table to determine what time series are associated with a given metric, tag name, tag value, tag pair or combination thereof. For example, if you want to know what metrics are available for a tag pair ``host=web01`` you can execute a lookup to find out. Lookups do not require a search plugin to be installed.

.. NOTE:: 

  Lookups are performed against the ``tsdb-meta`` table. You must enable real-time meta data creation or perform a ``metasync`` using the ``uid`` command in order to retreive data from a lookup. Lookups can be executed against the raw data table using the CLI command only: :doc:`../../user_guide/cli/search`

Verbs
-----

* GET
* POST

Requests
--------

Parameters used by the lookup endpoint include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15

   "query", "String", "Required", "A lookup query as defined below.", "", "m", "", "tsd.hbase.rpcs{type=*}"
   "useMeta", "Boolean", "Optional", "Whether or not to use the meta data table or the raw data table. The raw table will be much slower.", "False", "use_meta", "", "True"
   "limit", "Integer", "Optional", "The maximum number of items returned in the result set.", "25", "", "", "100"
   "startIndex", "Integer", "Optional", "Ignored for lookup queries, always the default.", "0", "", "", "10"

Lookup Queries
^^^^^^^^^^^^^^

A lookup query consists of at least one metric, tag name (tagk) or tag value (tagv). Each value must be a literal name in the UID table. If a given name cannot be resolved to a UID, an exception will be returned. Only one metric can be supplied per query but multiple tagk, tagv or tag pairs may be provided.

Normally, tags a provided in the format ``<tagk>=<tagv>`` and a value is required on either side of the equals sign. However for lookups, one value may an asterisk ``*``, i.e. ``<tagk>=*`` or ``*=<tagv>``. In these cases, the asterisk acts as a wildcard meaning any time series with the given tagk or tagv will be returned. For example, if we issue a query for ``host=*`` then we will get all of the time series with a ``host`` tagk such as ``host=web01`` and ``host=web02``. 

For complex queries with multiple values, each type is ``AND``'d with the other types and ``OR``'d with it's own type. 

::

  <metric> AND (<tagk1>=[<tagv1>] OR <tagk1>=[<tagv2>]) AND ([<tagk2>]=<tagv3> OR [<tagk2>]=<tagv4>)

For example, the query ``tsd.hbase.rpcs{type=*,host=tsd1,host=tsd2,host=tsd3}`` would return only the time series with the metric ``tsd.hbase.rpcs`` and the ``type`` tagk with any value and a ``host`` tag with either ``tsd1`` or ``tsd2`` or ``tsd3``. Unlike a data query, you may supply multiple tagks with the same name as seen in the example above. Wildcards always take priority so if your query looked like ``tsd.hbase.rpcs{type=*,host=tsd1,host=tsd2,host=*}``, then the query would effectively be treated as ``tsd.hbase.rpcs{type=*,host=*}``.

To retreive a list of all time series with a specific tag value, e.g. a particular host, you could issue a query like ``{*=web01}`` that will return all time series with a tag value of ``web01``. This can be useful in debugging tag name issues such as some series having ``host=web01`` or ``server=web01``. 

Example Request
^^^^^^^^^^^^^^^

Query String:
::
  
  http://localhost:4242/api/search/lookup?m=tsd.hbase.rpcs{type=*}

POST:

JSON requests follow the search query format on the :doc:`index` page. Limits and startNote that tags are supplied as a list of objects. The value for the ``key`` should be a ``tagk`` and the value for ``value`` should be a ``tagv`` or wildcard.

.. code-block :: javascript 

  {
      "metric": "tsd.hbase.rpcs",
      "tags":[
          {
              "key": "type",
              "value": "*"
          }
      ]
  }

Response
--------
   
Depending on the endpoint called, the output will change slightly. However common fields include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20
  
  "type", "String", "The type of query submitted, i.e. the endpoint called.", "LOOKUP"
  "query", "String", "Ignored for lookup queries.", ""
  "limit", "Integer", "The maximum number of items returned in the result set.", "25"
  "startIndex", "Integer", "Ignored for lookup queries, always the default.", "0"
  "metric", "String", "The metric used for the lookup", "\*"
  "tags", "Array", "The list of tag pairs used for the lookup. May be an empty list.", "[ ]"
  "time", "Integer", "The amount of time it took, in milliseconds, to complete the query", "120"
  "totalResults", "Integer", "The total number of results matched by the query", "1024"
  "results", "Array", "The result set with the TSUID, metric and tags for each series.", "*See Below*"
  
This endpoint will almost always return a ``200`` with content body. If the query doesn't match any results, the ``results`` field will be an empty array and ``totalResults`` will be 0. If an error occurs, such as a failure to resolve a metric or tag name to a UID, an exception will be returned.

Example Response
----------------

.. code-block :: javascript 

  {
      "type": "LOOKUP",
      "metric": "tsd.hbase.rpcs",
      "tags":[
          {
              "key": "type",
              "value": "*"
          }
      ]
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
