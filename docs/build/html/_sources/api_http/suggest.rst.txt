/api/suggest
============
.. index:: HTTP /api/suggest
This endpoint provides a means of implementing an "auto-complete" call that can be accessed repeatedly as a user types a request in a GUI. It does not offer full text searching or wildcards, rather it simply matches the entire string passed in the query on the first characters of the stored data. For example, passing a query of ``type=metrics&q=sys`` will return the top 25 metrics in the system that start with ``sys``. Matching is case sensitive, so ``sys`` will not match ``System.CPU``. Results are sorted alphabetically.

Verbs
-----

* GET
* POST

Requests
--------

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "type", "String", "Required", "The type of data to auto complete on. Must be one of the following: **metrics**, **tagk** or **tagv**", "", "type", "", "metrics"
   "q", "String", "Optional", "A string to match on for the given type", "", "q", "", "web"
   "max", "Integer", "Optional", "The maximum number of suggested results to return. Must be greater than 0", "25", "max", "", "10"

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/suggest?type=metrics&q=sys&max=10

**JSON Content**

.. code-block :: javascript 

  {
    "type":"metrics",
    "q":"sys",
    "max":10
  }
   
Response
--------
   
The response is an array of strings of the given type that match the query. If nothing was found to match the query, an empty array will be returned.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  [
    "sys.cpu.0.nice",
    "sys.cpu.0.system",
    "sys.cpu.0.user",
    "sys.cpu.1.nice",
    "sys.cpu.1.system",
    "sys.cpu.1.user"
  ]
