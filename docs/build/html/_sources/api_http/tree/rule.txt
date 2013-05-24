/api/tree/rule
==============

Each rule in a tree is an individual object in storage, thus the ``/api/tree/rule`` endpoint allows for easy modification of a single rule in the set. Rules are addressed by their ``tree`` ID, ``level`` and ``order`` and all requests require these three parameters.

.. NOTE:: If a manual tree synchronization is running somewhere or there is a large number of TSMeta objects being created or edited, the tree rule may be cached and modifications to a tree's rule set may take some time to propagate. If you make any modifications to the rule set, other than to meta information such as the ``description`` and ``notes``, you may want to flush the tree data and perform a manual synchronization so that branches and leaves reflect the new rules.
   
Verbs
-----

* GET - Retrieve one or more rules
* POST - Create or modify a rule
* PUT - Create or replace a rule
* DELETE - Delete a rule

Requests
--------

The following fields can be used for all rule endpoint requests:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "QS", "RW", "Example"
   :widths: 10, 5, 5, 45, 10, 5, 5, 15
   
   "treeId", "Integer", "Required", "The tree the requested rule belongs to", "", "treeid", "RO", "1"
   "level", "Integer", "Required", "The level in the rule heirarchy where the rule resides. Must be 0 or greater.", "0", "level", "RW", "2"
   "order", "Integer", "Required", "The order within a level where the rule resides. Must be 0 or greater.", "0", "order", "RW", "1"
   "description", "String", "Optional", "A brief description of the rule's purpose", "", "description", "RW", "Split the metric by dot"
   "notes", "String", "Optional", "Detailed notes about the rule", "", "notes", "RW", ""
   "type", "String", "Required*", "The type of rule represented. See :doc:`../../user_guide/trees`. *Required when creating a new rule.", "", "type", "RW", "METRIC"
   "field", "String", "Optional", "The name of a field for the rule to operate on", "", "field", "RW", "host"
   "customField", "String", "Optional", "The name of a ``TSMeta`` custom field for the rule to operate on. Note that the ``field`` value must also be configured or an exception will be raised.", "", "custom_field", "RW", "owner"
   "regex", "String", "Optional", "A regular expression pattern to process the associated field or custom field value through.", "", "regex", "RW", "^.*\\.([a-zA-Z]{3,4})[0-9]{0,1}\\..*\\..*$"
   "separator", "String", "Optional", "If the field value should be split into multiple branches, provide the separation character.", "", "separator", "RW", "\\."
   "regexGroupIdx", "Integer", "Optional", "A group index for extracting a portion of a pattern from the given regular expression pattern. Must be 0 or greater.", "0", "regex_group_idx", "RW", "1"
   "displayFormat", "String", "Optional", "A display format string to alter the ``display_name`` value of the resulting branch or leaf. See :doc:`../../user_guide/trees`", "", "display_format", "RW", "Port: {ovalue}"
   
.. NOTE:: When supplying a ``separator`` or a ``regex`` value, you must supply a valid regular expression. For separators, the most common use is to split dotted metrics into branches. E.g. you may want "sys.cpu.0.user" to be split into "sys", "cpu", "0" and "user" branches. You cannot supply just a "." for the separator value as that will not match properly. Instead, escape the period via "\.". Note that if you are supplying JSON via a POST request, you must escape the backslash as well and supply "\\.". GET request responses will escape all backslashes.

Response
--------

A successful response to a ``GET``, ``POST`` or ``PUT`` request will return the full rule object with optional requested changes. Successful ``DELETE`` calls will return with a ``204`` status code and no body content. When modifying data, if no changes were present, i.e. the call did not provide any data to store, the resposne will be a ``304`` without any body content. If the requested tree or rule did not exist in the system, a ``404`` will be returned with an error message. If invalid data was supplied a ``400`` error will be returned.

GET
---

A ``GET`` request requires a specific tree ID, rule level and order. Otherwise a ``400`` will be returned. To fetch all of the rules for a tree, use the ``/api/tree`` endpoint with a ``treeId' value.

Example GET Query
^^^^^^^^^^^^^^^^^
::

  http://localhost:4242/api/tree/rule?treeId=1&level=0&order=0
  
Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "type": "METRIC",
      "field": "",
      "regex": "",
      "separator": "\\.",
      "description": "Split the metric on periods",
      "notes": "",
      "level": 1,
      "order": 0,
      "treeId": 1,
      "customField": "",
      "regexGroupIdx": 0,
      "displayFormat": ""
  }

POST/PUT
--------

Using the ``POST`` or ``PUT`` methods, you can create a new rule or edit an existing rule. New rules require a ``type`` value. Existing trees require a valid ``treeId`` ID and any fields that require modification. A successful request will return the modified rule object. Note that if a rule exists at the given level and order, any changes will be merged with or overwrite the existing rule.

Example Query String Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::
  
  http://localhost:4242/api/tree/rule?treeId=1&level=0&order=0&type=METRIC&separator=.&method=post


Example Content Request
^^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "type": "METRIC",
      "separator": "\\.",
      "description": "Split the metric on periods",
      "level": 1,
      "order": 0,
      "treeId": 1
  }

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "type": "METRIC",
      "field": "",
      "regex": "",
      "separator": "\\.",
      "description": "Split the metric on periods",
      "notes": "",
      "level": 1,
      "order": 0,
      "treeId": 1,
      "customField": "",
      "regexGroupIdx": 0,
      "displayFormat": ""
  }

DELETE
------

Using the ``DELETE`` method will remove a rule from a tree. A successful deletion will respond with a ``204`` status code and no content body. If the rule did not exist, a ``404`` error will be returned.

.. WARNING:: This method cannot be undone.

Example DELETE Request
^^^^^^^^^^^^^^^^^^^^^^
::

  http://localhost:4242/api/tree/rule?treeId=1&level=0&order=0&method=delete
