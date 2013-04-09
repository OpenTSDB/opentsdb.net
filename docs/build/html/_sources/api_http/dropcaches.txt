/api/dropcaches
===============

This endpoint purges the in-memory data cached in OpenTSDB. This includes all UID to name and name to UID maps for metrics, tag names and tag values. 

.. NOTE:: This endpoint does not purge the on-disk temporary cache where graphs and other files are stored.

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
  http://localhost:4242/api/dropcaches
   
Response
--------
   
The response is a hash map of information. Unless something goes wrong, this should always result in a ``status`` of ``200`` and a message of ``Caches dropped``.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "message": "Caches dropped",
      "status": "200"
  }
