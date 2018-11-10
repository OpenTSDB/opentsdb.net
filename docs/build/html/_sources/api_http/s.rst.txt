/s
==
.. index:: HTTP /s
This endpoint was introduced in 1.0 as a means of accessing static files on the local system. ``/s`` will be maintained in the future and will not be deprecated. The static root is definied in the config file as ``tsd.http.staticroot`` or CLI via ``--staticroot``.

By default, static files will be returned with a header telling clients to cache them for 1 year. Any file that contains ``nocache`` in the name (e.g. ``queryui.nocache.js``, the idiom used by GWT) will not include the cache header.

.. NOTE:: The TSD will attempt to return the correct **Content-Type** header for the requested file. However the TSD code doesn't support very many formats at this time, just HTML, JSON, Javascript and PNG. Let us know what formats you need or issue a pull request with your patches.

.. WARNING:: The code for this endpoint is very simple and does not include any security. Thus you should make sure that permissions on your static root directory are secure so that users can't write malicious files and serve them out of OpenTSDB. Users shouldn't be able to write files via OpenTSDB, but take precautions just to be safe.

Verbs
-----

All verbs are supported and simply ignored

Requests
--------

Query string and content body requests are ignored. Rather the requested file is a component of the path, e.g. ``/s/index.html`` will return the contents of the ``index.html`` file. 

Example Request
---------------

**Query String**
::
  http://localhost:4242/s/queryui.nocache.js

Response
--------
   
The response will be the contents of the requested file with appropriate HTTP headers configured.