/api/uid/tsmeta
===============

This endpoint enables editing or deleting timeseries meta data information, that is meta data associated with a specific timeseries associated with a *metric* and one or more *tag name/value* pairs. Some fields are set by the TSD but others can be set by the user. When using the ``POST`` method, only the fields supplied with the request will be stored. Existing fields that are not included will be left alone. Using the ``PUT`` method will overwrite all user mutable fields with given values or defaults if a given field is not provided.

Please note that deleting a meta data entry will not delete the data points stored for the timeseries. Neither will it remove the UID assignments or associated UID meta objects. 

Verbs
-----

* GET - Query string only
* POST - Updates only the fields provided
* PUT - Overwrites all user configurable meta data fields
* DELETE - Deletes the TS meta data

Requests
--------

Fields that can be supplied with a request include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "tsuid", "String", "Required", "A hexadecimal representation of the timeseries UID", "", "tsuid", "RO", "00002A000001000001"
   "description", "String", "Optional", "A brief description of what the UID represents", "", "description", "RW", "System processor time"
   "displayName", "String", "Optional", "A short name that can be displayed in GUIs instead of the default name", "", "display_name", "RW", "System CPU Time"
   "notes", "String", "Optional", "Detailed notes about what the UID represents", "", "notes", "RW", "Details"
   "custom", "Map", "Optional", "A key/value map to store custom fields and values", "null", "", "RW", "*See Below*"
   "units", "String", "Optional", "Units reflective of the data stored in the timeseries, may be used in GUIs or calculations", "", "units", "RW", "Mbps"
   "dataType", "String", "Optional", "The kind of data stored in the timeseries such as ``counter``, ``gauge``, ``absolute``, etc. These may be defined later but they should be similar to Data Source Types in an `RRD <http://oss.oetiker.ch/rrdtool>`_", "", "data_type", "RW", "counter"
   "retention", "Integer", "Optional", "The number of days of data points to retain for the given timeseries. **Not Implemented**. When set to 0, the default, data is retained indefinitely.", "0", "retention", "RW", "365"
   "max", "Float", "Optional", "An optional maximum value for this timeseries that may be used in calculations such as percent of maximum. If the default of ``NaN`` is present, the value is ignored.", "NaN", "max", "RW", "1024"
   "min", "Float", "Optional", "An optional minimum value for this timeseries that may be used in calculations such as percent of minimum. If the default of ``NaN`` is present, the value is ignored.", "NaN", "min", "RW", "0"

.. NOTE:: Custom fields cannot be passed via query string. You must use the ``POST`` or ``PUT`` verbs.

.. WARNING:: If your request uses ``PUT``, any fields that you do not supply with the request will be overwritten with their default values. For example, the ``description`` field will be set to an emtpy string and the ``custom`` field will be reset to ``null``.

Example GET Request
^^^^^^^^^^^^^^^^^^^

::
  
  http://localhost:4242/api/uid/tsmeta?tsuid=00002A000001000001

Example POST or PUT Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Query String:*
::

  http://localhost:4242/api/uid/tsmeta?tsuid=00002A000001000001&method=post&display_name=System%20CPU%20Time

*JSON Content:*

.. code-block :: javascript 

  {
      "tsuid":"00002A000001000001",
      "displayName":"System CPU Time for Webserver 01",
      "custom": {
          "owner": "Jane Doe",
          "department": "Operations",
          "assetTag": "12345"
      }
  }

Example DELETE Request
^^^^^^^^^^^^^^^^^^^^^^

*Query String:*
::

  http://localhost:4242/api/uid/tsmeta?tsuid=00002A000001000001&method=delete

*JSON Content:*

.. code-block :: javascript 

  {
      "tsuid":"00002A000001000001"
  }

Response
--------
   
A successful response to a ``GET``, ``POST`` or ``PUT`` request will return the full TS meta data object with any given changes. Successful ``DELETE`` calls will return with a ``204`` status code and no body content. When modifying data, if no changes were present, i.e. the call did not provide any data to store, the resposne will be a ``304`` without any body content. If the requested UID did not exist in the system, a ``404`` will be returned with an error message. If invalid data was supplied an error will be returned.

All **Request** fields will be present in the response in addition to others:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "metric", "UIDMeta", "A UID meta data object representing information about the UID", "*See Below*"
   "tags", "Array of UIDMeta", "A list of tag name / tag value UID meta data objects associated with the timeseries. The ``tagk`` UID will be first followed by it's corresponding ``tagv`` object.", "*See Below*"
   "created", "Integer", "A Unix epoch timestamp, in seconds, when the timeseries was first recorded in the system. Note that if the TSD was upgraded or meta data recently enabled, this value may not be accurate. Run the ______ utility to synchronize meta data.", "1350425579"
   "lastReceived", "Integer", "A Unix epoch timestamp, in seconds, when a data point was last recieved. This is only updated on TSDs where meta data is enabled and it is not updated for every data point so there may be some lag.", "1350425579"

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "tsuid": "00002A000001000001",
      "metric": {
          "uid": "00002A",
          "type": "METRIC",
          "name": "sys.cpu.0",
          "description": "System CPU Time",
          "notes": "",
          "created": 1350425579,
          "custom": null,
          "displayName": ""
      },
      "tags": [
          {
              "uid": "000001",
              "type": "TAGK",
              "name": "host",
              "description": "Server Hostname",
              "notes": "",
              "created": 1350425579,
              "custom": null,
              "displayName": "Hostname"
          },
          {
              "uid": "000001",
              "type": "TAGV",
              "name": "web01.mysite.com",
              "description": "Website hosting server",
              "notes": "",
              "created": 1350425579,
              "custom": null,
              "displayName": "Web Server 01"
          }
      ],
      "description": "Measures CPU activity",
      "notes": "",
      "created": 1350425579,
      "units": "",
      "retention": 0,
      "max": "NaN",
      "min": "NaN",
      "custom": {
          "owner": "Jane Doe",
          "department": "Operations",
          "assetTag": "12345"
      },
      "displayName": "",
      "dataType": "absolute",
      "lastReceived": 1350425590
  }
