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
   "as", "String", "Optional", "A name to substitute for the metric name for time series emitted from this node. If the ``as`` config is missing, the expression ID is substituted as the metric name. Tags are preserved.", "null", "Percent"
   "joinConfig", "Object", "Required", "The join config to use when combining series.", "null", "See the Join section below."
   "interpolatorConfig", "List", "Required *for now*", "A list of interpolator configs for the downsampler to deal with empty buckets.", "null", "See :doc:`interpolator`"
   "infectiousNan", "boolean", "Optional", "Whether or not NaNs from the source data should infect each timestamp when aggregating values. E.g. if one value out of 20 are ``NaN`` for a timestamp and this is true, the timestamp will return a ``NaN``. If all values for the timestamp are ``NaN`` then the result will be ``NaN`` regardless.", "false", "true"
   
Variable Names
--------------

Variable names in expressions can be one of two values:

* A ``TimeSeriesDataSource`` node ID such as ``m1`` if the node had that ID. This is also the data source ID.
* The full metric name such as ``sys.cpu.busy``.

Literals
--------

Literals may also be used such as:

* Integers
* Double precision floating point values
* ``true`` or ``false``

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
* **? :** - Ternary/Conditional Expression

Substitution
^^^^^^^^^^^^

When a value is missing at a given timestamp for either side of an expression and the interpolator does not return a literal value, a value may be subsituted based on the operator in order to provide a useful result.

* For addition and subtraction, missing values are treated as zero.
* For all other operations, missing values are treated as infectious NaNs.

Ternary or Conditional Expressions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A ternary expression is a simple if/else statement that evaluates a condition and returns one value if the result is true and a different value if the result is false. V3 supports single level ternary expressions at this time (nesting to come in the future).

The condition of a ternary can be one of:

* A relational condition such as ``m1 > 1 AND m2 > 1 ? 1 : 0``
* A logical condition such as ``m1 > 1 ? 1 : 0``
* A single metric such as ``m1 ? m1 : NaN`` in which case the value of the condition metric is treated as boolean according to the rules at the top of this document.

Note that ``NaN`` can be used as a literal in a ternary operand but not in the condition (yet).

Joining Time Series
-------------------

Because multiple time series are received in an expression node from multiple sources, the time series must be grouped so that time series from source A match up with those from source B based on the tag values. Additionally, when two time series are matched, the data points at each timestamp must be aligned as well.

.. NOTE::

    We highly recommend that you apply a downsampling operator to all data sources before linking them into an expression node so that the values align cleanly and interpolation is skipped.

If we take the example query below, we'll see time series like the following:

.. csv-table::
   :header: "Number", "Source", "Metric", "Tags"
   :widths: 15, 15, 30, 40

   "TS1", "m1", "sys.if.in", "host=web01, dc=PHX"
   "TS2", "m1", "sys.if.in", "host=web02, dc=PHX"
   "TS3", "m1", "sys.if.in", "host=web01, dc=DEN"
   "TS4", "m2", "sys.if.out", "host=web01, dc=PHX"
   "TS5", "m2", "sys.if.out", "host=web02, dc=PHX"
   "TS6", "m2", "sys.if.out", "host=web01, dc=DEN"

We have 6 total time series with 3 from each time series data source.

Similar to a relational database, there are a number of join types that you can choose from. The most common join is the ``NATURAL_OUTER`` join that will attempt a one-to-one match using all of the tags in a time series and for those that do not align it will use substitution rules to handle the missing series. Using a ``NATURAL_OUTER`` join (or even an ``INNER`` join) we would match ``TS1 <=> TS3``, ``TS2 <=> TS4`` and ``TS3 <=> TS5``. The result of the expression would have 3 time series:

.. csv-table::
   :header: "Number", "Metric", "Tags"
   :widths: 15, 35, 50

   "TS7", "if.in.pct_of_total", "host=web01, dc=PHX"
   "TS8", "if.in.pct_of_total", "host=web02, dc=PHX"
   "TS9", "if.in.pct_of_total", "host=web01, dc=DEN"

As another example, lets assume that we are using the ``INNER`` join and ``TS2`` and ``TS6`` are both missing values for our query time range. In this case our output would only have 1 time series, that of ``TS7`` in the table above because an inner join requires that both time series on either side of an expression be present in order for it to be evaluated.

When processing multi-variate expressions, the expression is broken into a tree of binary expressions. If a pair of time series at one level of the tree fails to satisfy join requirements, the rest of the tree is not evaluated.

For simple expressions where a single variable is combined with a literal value, join configurations are essentially ignored.

For more details on join configs see :doc:`join`.

Joining On Time
^^^^^^^^^^^^^^^

Once two time series are joined on time, we must then proceede to compute the expression for each data point in each series. Expressions will follow the same logic as downsamplers and group by nodes in that when particular values are missing at a timestamp, an interpolated value is used.

Example Query
-------------

.. code-block:: javascript

    {
    	"start": "1h-ago",
    	"executionGraph": [{
    			"id": "m1",
    			"type": "TimeSeriesDataSource",
    			"metric": {
    				"type": "MetricLiteral",
    				"metric": "sys.if.in"
    			}
    		},
    		{
    			"id": "ds1",
    			"type": "downsample",
    			"aggregator": "sum",
    			"interval": "1m",
    			"runAll": false,
    			"fill": true,
    			"interpolatorConfigs": [{
    				"dataType": "numeric",
    				"fillPolicy": "NAN",
    				"realFillPolicy": "NONE"
    			}],
    			"sources": ["m1"]
    		},
    		{
    			"id": "m2",
    			"type": "TimeSeriesDataSource",
    			"metric": {
    				"type": "MetricLiteral",
    				"metric": "sys.if.out"
    			}
    		},
    		{
    			"id": "ds2",
    			"type": "downsample",
    			"aggregator": "sum",
    			"interval": "1m",
    			"runAll": false,
    			"fill": true,
    			"interpolatorConfigs": [{
    				"dataType": "numeric",
    				"fillPolicy": "NAN",
    				"realFillPolicy": "NONE"
    			}],
    			"sources": ["m2"]
    		}, {
    			"id": "e1",
    			"as": "if.in.pct_of_total",
    			"type": "expression",
    			"expression": "(m1 / (m1 + m2)) * 100",
    			"join": {
    				"type": "Join",
    				"joinType": "NATURAL_OUTER"
    			},
    			"interpolatorConfigs": [{
    				"dataType": "numeric",
    				"fillPolicy": "NAN",
    				"realFillPolicy": "NONE"
    			}],
    			"sources": ["ds1", "ds2"]
    		}
    	]
    }
  