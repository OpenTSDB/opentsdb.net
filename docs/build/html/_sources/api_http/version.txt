/api/version
============
.. index:: HTTP /api/version
This endpoint returns information about the running version of OpenTSDB.

Verbs
-----

* GET
* POST

Requests
--------

This endpoint does not require any parameters via query string or body.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  http://localhost:4242/api/version
   
Response
--------
   
The response is a hash map of version properties and values.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "timestamp": "1362712695",
      "host": "localhost",
      "repo": "/opt/opentsdb/build",
      "full_revision": "11c5eefd79f0c800b703ebd29c10e7f924c01572",
      "short_revision": "11c5eef",
      "user": "localuser",
      "repo_status": "MODIFIED",
      "version": "2.0.0"
  }
