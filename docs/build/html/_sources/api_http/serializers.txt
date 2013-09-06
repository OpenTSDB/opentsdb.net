/api/serializers
================

This endpoint lists the serializer plugins loaded by the running TSD. Information given includes the name, implemented methods, content types and methods. 

Verbs
-----

* GET
* POST

Requests
--------

No parameters are available, this is a read-only endpoint that simply returns system data.

Response
--------

The response is an array of serializer objects. Each object has the following fields:

.. csv-table::
   :header: "Field Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "serializer", "String", "The name of the serializer, suitable for use in the query string ``serializer=<serializer_name>`` parameter", "xml"
   "formatters", "Array<String>", "An array of methods or endpoints that the serializer implements to convert response data. These usually map to an endpoint such as ``/api/suggest`` mapping to ``Suggest``. If the serializer does not implement a certain method, the default formatter will respond. Each name also ends with the API version supported, e.g. ``V1`` will support version 1 API calls.", """Error"",""Suggest"""
   "parsers", "Array<String>", "An array of methods or endpoints that the serializer implements to parse user input in the HTTP request body. These usually map to an endpoint such as ``/api/suggest`` will map to ``Suggest``. If a serializer does not implement a parser, the default serializer will be used. Each name also ends with the API version supported, e.g. ``V1`` will support version 1 API calls.", """Suggest"",""Put"""
   
This endpoint should always return data with the JSON serializer as the default. If you think the TSD should have other formatters listed, check the plugin documentation to make sure you have the proper plugin and it's located in the right directory.

Example Response
----------------
.. code-block :: javascript 

  [
      {
          "formatters": [
              "SuggestV1",
              "SerializersV1",
              "ErrorV1",
              "ErrorV1",
              "NotFoundV1"
          ],
          "serializer": "json",
          "parsers": [
              "SuggestV1"
          ],
          "class": "net.opentsdb.tsd.HttpJsonSerializer",
          "response_content_type": "application/json; charset=UTF-8",
          "request_content_type": "application/json"
      }
  ]
