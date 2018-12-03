Shared
======
.. index:: HTTP /api/registry/shared
This page shows a list of shared objects loaded in the registry for use by various plugins.

Verbs
-----

* GET

Requests
--------

No parameters are available.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/registry/shared
   
Response
--------
   
For now the response is just the name of the object and the fully qualified class name.

Example Response
^^^^^^^^^^^^^^^^

.. code-block :: javascript 

  {
	"default_uidstore": "class net.opentsdb.storage.Tsdb1xUniqueIdStore"
  }