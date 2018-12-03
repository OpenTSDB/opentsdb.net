/api/annotation/bulk
====================
.. index:: HTTP /api/annotation/bulk
*NOTE: (Version 2.1)*
The bulk endpoint enables adding, updating or deleting multiple annotations in a single call. Annotation updates must be sent over PUT or POST as content data. Query string requests are not supported for ``POST`` or ``GET``. Each annotation is processed individually and synchronized with the backend. If one of the annotations has an error, such as a missing field, an exception will be returned and some of the annotations may not be written to storage. In such an event, the errant annotation should be fixed and all annotations sent again.

Annotations may also be deleted in bulk for a specified time span. If you supply a list of of one or more TSUIDs, annotations with a ``start time`` that falls within the specified timespan and belong to those TSUIDs will be removed. Alternatively the ``global`` flag can be set and any global annotations (those not associated with a time series) will be deleted within the range.

Verbs
-----

* POST - Create or modify annotations
* PUT - Create or replace annotations
* DELETE - Delete annotations within a time range


Requests
--------

Fields for posting or updating annotations are documented at :doc:`index`

Fields for a bulk delete request are defined below:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "startTime", "Integer", "Required", "A timestamp for the start of the request. The timestamp may be relative or absolute as per :doc:`../../user_guide/query/dates`.", "", "start_time", "RO", "1369141261"
   "endTime", "Integer", "Optional", "An optional end time for the event if it has completed or been resolved. The timestamp may be relative or absolute as per :doc:`../../user_guide/query/dates`.", "", "end_time", "RO", "1369141262"
   "tsuids", "Array", "Optional", "A list of TSUIDs with annotations that should be deleted. This may be empty or null (for JSON) in which case the ``global`` flag should be set. When using the query string, separate TSUIDs with commas.", "", "tsuids", "RO", "000001000001000001, 000001000001000002"
   "global", "Boolean", "Optional", "Whether or not global annotations should be deleted for the range", "false", "global", "RO", "true"

.. WARNING:: If your request uses ``PUT``, any fields that you do not supply with the request will be overwritten with their default values. For example, the ``description`` field will be set to an empty string and the ``custom`` field will be reset to ``null``.

Example POST/PUT Request
^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  [
    {
      "startTime":"1369141261",
      "tsuid":"000001000001000001",
      "description": "Testing Annotations",
      "notes": "These would be details about the event, the description is just a summary",
      "custom": {
          "owner": "jdoe",
          "dept": "ops"
      }
    },
    {
      "startTime":"1369141261",
      "tsuid":"000001000001000002",
      "description": "Second annotation on different TSUID",
      "notes": "Additional details"
    }
  ]

Example DELETE QS Request
^^^^^^^^^^^^^^^^^^^^^^^^^
::

  /api/annotation/bulk?start_time=1d-ago&end_time=1h-ago&method_override=delete&tsuids=000001000001000001,000001000001000002
  
Example DELETE Request
^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "tsuids": [
          "000001000001000001",
          "000001000001000002"
      ],
      "global": false,
      "startTime": 1389740544690,
      "endTime": 1389823344698,
      "totalDeleted": 0
  }

Response
--------
   
A successful response to a ``POST`` or ``PUT`` request will return the list of annotations after synchronization (i.e. if issuing a ``POST`` call, existing objects will be merged with the new objects). Delete requests will return an object with the delete query and a ``totalDeleted`` field with an integer number reflecting the total number of annotations deleted. If invalid data was supplied a ``400`` error will be returned along with the specific annotation that caused the error in the ``details`` field of the error object.

Example POST/PUT Response
^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  [
    {
        "tsuid": "000001000001000001",
        "description": "Testing Annotations",
        "notes": "These would be details about the event, the description is just a summary",
        "custom": {
            "owner": "jdoe",
            "dept": "ops"
        },
        "endTime": 0,
        "startTime": 1369141261
    },
    {
        "tsuid": "000001000001000002",
        "description": "Second annotation on different TSUID",
        "notes": "Additional details",
        "custom": null,
        "endTime": 0,
        "startTime": 1369141261
    }
  ]

Example DELETE Response
^^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript 
  
  {
      "tsuids": [
          "000001000001000001",
          "000001000001000002"
      ],
      "global": false,
      "startTime": 1389740544690,
      "endTime": 1389823344698,
      "totalDeleted": 42
  }