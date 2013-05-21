/api/annotation
===============

This endpoint provides a means of adding, editing or deleting annotations stored in the OpenTSDB backend. Annotations are very basic objects used to record a note of an arbitrary event at some point, optionally associated with a timeseries. Annotations are not meant to be used as a tracking or event based system, rather they are useful for providing links to such systems by displaying a notice on graphs or via API query calls.

When creating, modifying or deleting annotations, all changes will be propagated to the search plugin if configured.

Verbs
-----

* GET - Retrieve a single annotation
* POST - Create or modify an annotation
* PUT - Create or replace an annotation
* DELETE - Delete an annotation

Requests
--------

All annotations are identified by the ``startTime`` field and optionally the ``tsuid`` field. Each note can be global, meaning it is associated with all timeseries, or it can be local, meaning it's associated with a specific tsuid. If the tsuid is not supplied or has an empty value, the annotation is considered to be a global note.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "startTime", "Integer", "Required", "A Unix epoch timestamp, in seconds, marking the time when the annotation event should be recorded", "", "start_time", "RW", "1369141261"
   "endTime", "Integer", "Optional", "An optional end time for the event if it has completed or been resolved", "0", "end_time", "RW", "1369141262"
   "tsuid", "String", "Optional", "A TSUID if the annotation is associated with a timeseries. This may be null or empty if the note was for a global event", "", "tsuid", "RW", "000001000001000001"
   "description", "String", "A brief description of the event. As this may appear on GnuPlot graphs, the description should be very short, ideally less than 25 characters.", "", "description", "RW", "Network Outage"
   "notes", "String", "Optional", "Detailed notes about the event", "", "notes", "RW", "Switch #5 died and was replaced"
   "custom", "Map", "Optional", "A key/value map to store custom fields and values", "null", "", "RW", "*See Below*"

.. NOTE:: Custom fields cannot be passed via query string. You must use the ``POST`` or ``PUT`` verbs.

.. WARNING:: If your request uses ``PUT``, any fields that you do not supply with the request will be overwritten with their default values. For example, the ``description`` field will be set to an emtpy string and the ``custom`` field will be reset to ``null``.

Example GET Request
^^^^^^^^^^^^^^^
::
  
  http://localhost:4242/api/annotation?start_time=1369141261&tsuid=000001000001000001

Example POST Request
^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
    "startTime":"1369141261",
    "tsuid":"000001000001000001",
    "description": "Testing Annotations",
    "notes": "These would be details about the event, the description is just a summary",
    "custom": {
        "owner": "jdoe",
        "dept": "ops"
    }
  }
   
Response
--------
   
A successful response to a ``GET``, ``POST`` or ``PUT`` request will return the full rule object with optional requested changes. Successful ``DELETE`` calls will return with a ``204`` status code and no body content. When modifying data, if no changes were present, i.e. the call did not provide any data to store, the resposne will be a ``304`` without any body content. If the requested tree or rule did not exist in the system, a ``404`` will be returned with an error message. If invalid data was supplied a ``400`` error will be returned.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

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
  }
