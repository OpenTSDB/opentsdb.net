Data Types
==========
.. index:: HTTP /api/registry/datatypes
This is a list of data type supported by the TSD including the concrete type names and mappings.

Verbs
-----

* GET

Requests
--------

No request parameters are available.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/registry/datatypes
   
Response
--------
   
The response object has two fields, the ``defaultTypeNames`` that map the fully qualified class name of the type to the short name of the type and ``namesToTypes`` that map the lower cased short names to fully qualified class names. The short names can be used in configurations.

Example Response
^^^^^^^^^^^^^^^^

.. code-block :: javascript 

  {
	"defaultTypeNames": {
		"net.opentsdb.data.types.numeric.NumericSummaryType": "NumericSummary",
		"net.opentsdb.data.types.numeric.NumericType": "Numeric"
	},
	"namesToTypes": {
		"numericsummary": "net.opentsdb.data.types.numeric.NumericSummaryType",
		"numericsummarytype": "net.opentsdb.data.types.numeric.NumericSummaryType",
		"net.opentsdb.data.types.numeric.numerictype": "net.opentsdb.data.types.numeric.NumericType",
		"net.opentsdb.data.types.numeric.numericsummarytype": "net.opentsdb.data.types.numeric.NumericSummaryType",
		"numeric": "net.opentsdb.data.types.numeric.NumericType",
		"numerictype": "net.opentsdb.data.types.numeric.NumericType"
	}
  }