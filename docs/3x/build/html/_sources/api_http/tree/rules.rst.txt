/api/tree/rules
===============
.. index:: HTTP /api/tree/rules
The rules endpoint is used for bulk merging, replacing or deleting the entire ruleset of a tree. Instead of calling the ``tree/rule`` endpoint multiple times for a single rule, you can supply a list of rules that will be merged into, or replace, the current rule set. Note that the ``GET`` verb is not supported for this endpoint. To fetch the ruleset, load the tree via the ``/tree`` endpoint. Also, all data must be provided in request content, query strings are not supported.
   
Verbs
-----

* POST - Merge rule sets
* PUT - Replace the entire rule set
* DELETE - Delete a rule

Requests
--------

A request to store data must be an array of objects in the content of the request. The same fields as required for the :doc:`rule` endpoint are supported.
   
Response
--------

A successful response to a ``POST`` or ``PUT`` request will return a ``204`` response code without body content. Successful ``DELETE`` calls will return with a ``204`` status code and no body content. If a tree does not have any rules, the ``DELETE`` request will still return a ``204``. When modifying data, if no changes were present, i.e. the call did not provide any data to store, the response will be a ``304`` without any body content. If the requested tree did not exist in the system, a ``404`` will be returned with an error message. If invalid data was supplied a ``400`` error will be returned.


POST/PUT
--------

Issuing a ``POST`` will merge the given rule set with any that already exist. This means that if a rule already exists for one of the given rules, only the fields given will be modified in the existing rule. Using the ``PUT`` method will replace *all* of the rules for the given tree with the new set. Any existing rules for the tree will be deleted before the new rules are stored.

.. NOTE:: All of the rules in the request array must belong to the same ``treeId`` or a ``400`` exception will be returned. Likewise, all of the rules will pass validation and must include the ``level`` and ``order`` fields.

Example POST Request
^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript
  
  http://localhost:4242/api/tree/rule?treeId=1&level=0&order=0&type=METRIC&separator=.&method_override=post


Example Content Request
^^^^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript

  [
      {
          "treeId": 1,
          "level": 0,
          "order": 0,
          "type": "METRIC",
          "description": "Metric split rule",
          "split": "\\."
      },
      {
          "treeId": 1,
          "level": 0,
          "order": 1,
          "type": "tagk",
          "field": "fqdn",
          "description": "Hostname for the device"
      },
      {
          "treeId": 1,
          "level": 1,
          "order": 0,
          "type": "tagk",
          "field": "department"
          "description": "Department that owns the device"
      }
  ]

DELETE
------

Using the ``DELETE`` method will remove all rules from a tree. A successful deletion will respond with a ``204`` status code and no content body. If the tree did not exist, a ``404`` error will be returned.

.. WARNING:: This method cannot be undone.

Example DELETE Request
^^^^^^^^^^^^^^^^^^^^^^
::

  http://localhost:4242/api/tree/rules?treeId=1&method_override=delete
