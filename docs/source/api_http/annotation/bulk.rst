/api/annotation/bulk
====================

*NOTE: (Version 2.1)*
The bulk endpoint enables adding or updating multiple annotations in a single call. Annotations must be sent over PUT or POST as content data. Query string requests are not supported. Each annotation is processed individually and synchronized with the backend. If one of the annotations has an error, such as a missing field, an exception will be returned and some of the annotations may not be written to storage. In such an event, the errant annotation should be fixed and all annotations sent again.

Verbs
-----

* POST - Create or modify an annotation
* PUT - Create or replace an annotation

Requests
--------

Fields for annotations are documented at :doc:`index`

.. WARNING:: If your request uses ``PUT``, any fields that you do not supply with the request will be overwritten with their default values. For example, the ``description`` field will be set to an emtpy string and the ``custom`` field will be reset to ``null``.

Example POST Request
^^^^^^^^^^^^^^^^^^^^
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
   
Response
--------
   
A successful response to a ``POST`` or ``PUT`` request will return the list of annotations after synchronization (i.e. if issuing a ``POST`` call, existing objects will be merged with the new objects). If invalid data was supplied a ``400`` error will be returned along with the specific annotation that caused the error in the ``details`` field of the error object.

Example Response
^^^^^^^^^^^^^^^^
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
