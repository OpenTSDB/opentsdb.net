Expression
==========
.. index:: expression
Computes an arbitrary expression on time series fed to the node. It supports arithmentic, relational and logical operations. 

.. Note:: When combining arithmetic and relational/logical ops, we currently treat values > 0 as true and <= 0 as false. At some point we need to make it configurable.

Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "expression", "String", "Required", "The expression string to compute.", "null", "m2 / (m1 + m2)"
   "as", "String", "Required", "A name to substitute for the metric name for time series emitted from this node. Tags are preserved.", "null", "Percent"
   "joinConfig", "Object", "Required", "The join config to use when combining series.", "null", "See :doc:`join`"
   "interpolatorConfig", "List", "Required *for now*", "A list of interpolator configs for the downsampler to deal with empty buckets.", "null", "See :doc:`interpolator`"
   "infectiousNan", "boolean", "Optional", "Whether or not NaNs from the source data should infect each timestamp when aggregating values. E.g. if one value out of 20 are ``NaN`` for a timestamp and this is true, the timestamp will return a ``NaN``. If all values for the timestamp are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"
   
Notes:

* Variable names in expression must match either a ``TimeSeriesDataSource`` node ID name or the exact metric of the data source. Other nodes can funnel a data source into an expression, just make sure the ID is of the original source node.
* Literals can be used in expressions including ``true``, ``false`` integers and floating point values.

Operators
---------

Currently supported operators include:

* **+** - Addition
* **-** - Subtraction
* **\*** - Multiplication
* **/** - Division
* **%** - Modulo
* **>, <, ==, !=, <=, >=** - Conditionals
* **AND, OR, NOT** - Relationals

We'll have ternary support shortly.

Examples:

.. code-block:: javascript
  
  {
  "id": "m0",
  "type": "expression",
  "expression": "m01 * 1024",
  "join": {
    "type": "Join",
    "joinType": "NATURAL"
  },
  "interpolatorConfigs": [{
    "dataType": "numeric",
    "fillPolicy": "NAN",
    "realFillPolicy": "NONE"
  }],
  "sources": ["m01"]
  }