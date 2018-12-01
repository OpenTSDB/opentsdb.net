HTTP API
========

These are some notes on adding to the HTTP API.

Reserved Query String Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following is a list of query string parameters that are used by OpenTSDB across the entire API. Don't try to overload their use please:

.. csv-table::
   :header: "Parameter", "Description"
   :widths: 20, 80
   
   "serializer", "The name of a serializer to use for parsing input or formatting return data"
   "method", "Allows for overriding the HTTP verb when necessary"
   
   