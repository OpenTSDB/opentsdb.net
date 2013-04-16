/api/uid/uidmeta
================

This endpoint enables editing or deleting UID meta data information, that is meta data associated with *metrics*, *tag names* and *tag values*. Some fields are set by the TSD but others can be set by the user. When using the ``POST`` method, only the fields supplied with the request will be stored. Existing fields that are not included will be left alone. Using the ``PUT`` method will overwrite all user mutable fields with given values or defaults if a given field is not provided.

Please note that deleting a meta data entry will not delete the UID assignment nor will it delete any data points or associated timeseries information. Deletion only removes the specified meta data object.

Verbs
-----

* GET - Query string only
* POST - Updates only the fields provided
* PUT - Overwrites all user configurable meta data fields
* DELETE - Deletes the UID meta data

Requests
--------

Fields that can be supplied with a request include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "uid", "String", "Required", "A hexadecimal representation of the UID", "", "uid", "RO", "00002A"
   "type", "String", "Required", "The type of UID, must be ``metric``, ``tagk`` or ``tagv``", "", "type", "RO", "metric"
   "description", "String", "Optional", "A brief description of what the UID represents", "", "description", "RW", "System processor time"
   "displayName", "String", "Optional", "A short name that can be displayed in GUIs instead of the default name", "", "display_name", "RW", "System CPU Time"
   "notes", "String", "Optional", "Detailed notes about what the UID represents", "", "notes", "RW", "Details"
   "custom", "Map", "Optional", "A key/value map to store custom fields and values", "null", "", "RW", "*See Below*"

.. NOTE:: Custom fields cannot be passed via query string. You must use the ``POST`` or ``PUT`` verbs.

.. WARNING:: If your request uses ``PUT``, any fields that you do not supply with the request will be overwritten with their default values. For example, the ``description`` field will be set to an emtpy string and the ``custom`` field will be reset to ``null``.

Example GET Request
^^^^^^^^^^^^^^^^^^^

::
  
  http://localhost:4242/api/uid/uidmeta?uid=00002A&type=metric

Example POST or PUT Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Query String:*
::

  http://localhost:4242/api/uid/uidmeta?uid=00002A&type=metric&method=post&display_name=System%20CPU%20Time

*JSON Content:*

.. code-block :: javascript 

  {
      "uid":"00002A",
      "type":"metric",
      "displayName":"System CPU Time",
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

  http://localhost:4242/api/uid/uidmeta?uid=00002A&type=metric&method=delete

*JSON Content:*

.. code-block :: javascript 

  {
      "uid":"00002A",
      "type":"metric"
  }

Response
--------
   
A successful response to a ``GET``, ``POST`` or ``PUT`` request will return the full UID meta data object with any given changes. Successful ``DELETE`` calls will return with a ``204`` status code and no body content. When modifying data, if no changes were present, i.e. the call did not provide any data to store, the resposne will be a ``304`` without any body content. If the requested UID did not exist in the system, a ``404`` will be returned with an error message. If invalid data was supplied an error will be returned.

All **Request** fields will be present in the response in addition to a couple of others:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "name", "String", "The name of the UID as given when the data point was stored or the UID assigned", "sys.cpu.0"
   "created", "Integer", "A Unix epoch timestamp in seconds when the UID was first created. If the meta data was not stored when the UID was assigned, this value may be 0.", "1350425579"

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "uid": "00002A",
      "type": "TAGV",
      "name": "web01.mysite.com",
      "description": "Website hosting server",
      "notes": "This server needs a new boot disk",
      "created": 1350425579,
      "custom": {
          "owner": "Jane Doe",
          "department": "Operations",
          "assetTag": "12345"
      },
      "displayName": "Webserver 01"
  }
