Plugins
=======
.. index:: HTTP /api/registry/plugins
These are the plugins loaded in the TSD grouped by the fully qualified plugin interface name. Each implementation will then have an object with details on the implementation.

Verbs
-----

* GET

Requests
--------

An optional filter will return only plugins matching a regular expression. (For now it only matches on the interface name.)

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "filter", "String", "Optional", "A regular expression that will match on the interface name.", "", "filter", "", "?filter=aggregators"

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/registry/plugins
   
Response
--------
   
The response is an object containing objects keyed on their fully qualified class interface name. Each nested object is keyed on the lower case instance ID that can be used in configurations or queries to reference the particular plugin. Each plugin then has the following fields:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20
  
  "id", "String", "The configured ID of the instance.", "Median"
  "type", "String", "The short name of the type of plugin implemented. Often the same as the ID for default instances.", "Median"
  "version", "String", "The plugin version.", "3.0.0"
  "info", "String", "Details about the plugin (TODO)", ""
  "class", "String", "The fully qualified class name of the implementation.", "net.opentsdb.data.types.numeric.aggregators.MedianFactory"

Example Response
^^^^^^^^^^^^^^^^

.. code-block :: javascript 

  {
	"net.opentsdb.data.types.numeric.aggregators.NumericArrayAggregatorFactory": {
		"average": {
			"id": "Avg",
			"type": "Avg",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArrayAverageFactory"
		},
		"avg": {
			"id": "Avg",
			"type": "Avg",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArrayAverageFactory"
		},
		"min": {
			"id": "Min",
			"type": "Min",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArrayMinFactory"
		},
		"max": {
			"id": "Max",
			"type": "Max",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArrayMaxFactory"
		},
		"zimsum": {
			"id": "Sum",
			"type": "Sum",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArraySumFactory"
		},
		"mimmax": {
			"id": "Max",
			"type": "Max",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArrayMaxFactory"
		},
		"mimmin": {
			"id": "Min",
			"type": "Min",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArrayMinFactory"
		},
		"sum": {
			"id": "Sum",
			"type": "Sum",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.data.types.numeric.aggregators.ArraySumFactory"
		}
	},
	"net.opentsdb.storage.DatumIdValidator": {
		"Default": {
			"id": "DefaultDatumIdValidator",
			"type": "DefaultDatumIdValidator",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.storage.DefaultDatumIdValidator"
		},
		"defaultdatumidvalidator": {
			"id": "DefaultDatumIdValidator",
			"type": "DefaultDatumIdValidator",
			"version": "3.0.0",
			"info": "",
			"class": "net.opentsdb.storage.DefaultDatumIdValidator"
		}
	}
  }