/api/query
==========

Probably the most useful endpoint in the API, ``/api/query`` enables extracting data from the storage system in various formats determined by the serializer selected. Queries can be submitted via the 1.0 query string format or body content.

Verbs
-----

* GET
* POST

Requests
--------

For query string requests, please see `/q <http://opentsdb.net/http-api.html#/q>`_ until we get some other docs written.

Example Query String Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  http://localhost:4242/api/query?start=1h-ago&m=sum:rate:proc.stat.cpu{host=foo,type=idle}

Example Content Request
^^^^^^^^^^^^^^^^^^^^^^^

Please see the serializer documentation for request information.

:doc:`serializers/index`
   
Response
--------
   
The output generated for a query depends heavily on the chosen serializer: 

:doc:`serializers/index`

Unless there was an error with the query, you will generally receive a ``200`` status with content. However if your query couldn't find any data, it will return an empty result set. In the case of the JSON serializer, the result will be an empty array:

.. code-block :: javascript  

  []

