Filters
=======
.. index:: filters
Filters allow for fetching a select set of time series with a common metric. 3.x filters are much more capable than 2.x filters with the ability to search across multiple fields and combine them for boolean queries.

A filter is a single object and in places where filters are used, only the one object is allowed. However multiple filters can be combined in various ways via the ``chain`` filter. Chains allow for ``AND`` ing operations or ``OR`` ing filtering as well as nested chains for complex filtering. Additional modifying filters are available such as the ``Not`` filter that negates nested filters.

Thefield required for *all* filters is:

* **TYPE** - All filter definitions require the ``type`` field that is the name of the filter from these documents. The type must be loaded in the registry as the ID of the plugin.

Note that not all filters are supported by all endpoints or nodes. For example, at this time, time series data sources only support the tag value filters (and wrappers around them like chains, nots, etc) while event, meta or status sources may support all of them.

Filters currently built-in to OpenTSDB include:

AnyFieldRegex
-------------
Matches on any field including the metric, tag keys and tag values or properties in an event or status. Not supported for time series data sources yet.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "filter", "Filter", "Required", "A properly formed PCRE regular expression.", ""

.. code-block:: javascript

  {
	 "type": "AnyFieldRegex",
 	 "filter": "web0[123]"
  }

Chain
-----
Combines one or more filters with a logical ``AND`` (the default) or a logical ``OR``. We generally recommend using a chain filter as the top level filter if you're building a query by hand as it makes adding tag values easy. Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10

   "op", "String", "Optional", "Either the literal ``AND`` (default) or ``OR``", "OR"
   "filters", "Array", "Required", "A list of one or more filter objects. These can be any type of filter and you can nest chain filters.", ""

Example:

.. code-block:: javascript

    {
    	"type": "chain",
    	"filters": [{
    			"type": "TagValueLiteralOr",
    			"filter": "PHX",
    			"tagKey": "dc"
    		},
    		{
    			"type": "TagValueRegex",
    			"filter": "web.*den.*",
    			"tagKey": "host"
    		}
    	]
    }

ExplicitTags
------------
Must be used as the top-level filter if applicable and means that a time series must have all of the tag keys specified in the nested filter set and no other tags.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "filter", "Filter", "Required", "A nested filter definition.", ""

.. code-block:: javascript

  {
	 "type": "ExplicitTags",
 	 "filter": {
    	"type": "chain",
    	"filters": [{
    			"type": "TagValueLiteralOr",
    			"filter": "PHX",
    			"tagKey": "dc"
    		},
    		{
    			"type": "TagValueRegex",
    			"filter": "web.*den.*",
    			"tagKey": "host"
    		}
    	]
    }
  }

FieldLiteralOr
--------------

Matches a non-tag field key and one or more values separated by a pipe character, similar to the ``TagValueLiteralOr``.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "key", "String", "Required", "A field name for the type of data being fetched.", ""
   "filter", "String", "Required", "A case sensitive literal value with multiple values delimited by a ``|``.", ""

.. code-block:: javascript

  {
	 "type": "FieldLiteralOr",
	 "key": "status",
 	 "filter": "0|1"
  }

FieldRegex
----------

Matches a non-tag field key and the value based on a given regular expression, similar to the ``TagValueRegex``.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "key", "String", "Required", "A field name for the type of data being fetched.", ""
   "filter", "String", "Required", "A PCRE compatible regular expression.", ""

.. code-block:: javascript

  {
	 "type": "FieldRegex",
	 "key": "status",
 	 "filter": "[01]"
  }
  
MetricLiteral
-------------
Matches a single metric in the data store. This is only applicable for meta queries and in the metric filter of a time series data source.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "metric", "String", "Required", "The literal, case-sensitive name of the metric.", ""

Example:

.. code-block:: javascript

  {
	 "type": "MetricLiteral",
 	 "metric": "sys.if.in"
  }

MetricRegex
-----------
Executes the regular expression against metrics to fetch all metrics that match. **NOTE** Currently only supported by meta queries, not time series data sources.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "metric", "String", "Required", "The valid PCRE compatible regular expression to use.", ""

.. code-block:: javascript

  {
	 "type": "MetricRegex",
 	 "metric": "sys.if.*"
  }

Not
---

Negates the nested filter. If a chain is nested, the ``not`` filter negates the entire chain.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "filter", "Filter", "Required", "A nested filter definition.", ""

.. code-block:: javascript

  {
	 "type": "not",
 	 "filter": {
    		"type": "TagValueLiteralOr",
    		"filter": "PHX",
    		"tagKey": "dc"
    	}
  }

TagKeyLiteralOr
---------------
Matches one or more literal tag keys. Multiple values are separated by a pipe.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "filter", "String", "Required", "A pipe separated list of case-sensitive tag keys.", ""

.. code-block:: javascript

  {
	 "type": "TagKeyLiteralOr",
 	 "filter": "host|Host"
  }

TagKeyLiteralRegex
------------------
Matches the regular expression against tag keys.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "filter", "String", "Required", "The PRCE compatible regular expression to use.", ""

.. code-block:: javascript

  {
	 "type": "TagKeyLiteralRegex",
 	 "filter": "[Hh]ost"
  }

TagValueLiteralOr
-----------------
Matches one or more literal tag values. Multiple values are separated by a pipe.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "key", "String", "Required", "The literal case-sensitive name of a tag key.", ""
   "filter", "String", "Required", "A pipe separated list of case-sensitive tag values.", ""

.. code-block:: javascript

  {
	 "type": "TagValueLiteralOr",
	 "key": "host",
 	 "filter": "web01|web02|web03"
  }

TagValueWildcard
----------------
Matches on the globs of a case-sensitive tag value using the literal ``*`` as the wildcard place-holder.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "key", "String", "Required", "The literal case-sensitive name of a tag key.", ""
   "filter", "String", "Required", "A case-sensitive tag value with asterisks for the wildcard. Must include at least one asterisk. If the value is just ``*`` then it will match all series with the given ``key``.", ""

.. code-block:: javascript

  {
	 "type": "TagValueLiteralOr",
	 "key": "host",
 	 "filter": "web01|web02|web03"
  }

TagValueRange
-------------
Expands a syntax into multiple literal values. E.g. ``web{01-05}.{dc1|dc2}`` would generate 10 values such as ``web01.dc1` through ``web05.dc2``.
TODO - docs

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "key", "String", "Required", "The literal case-sensitive name of a tag key.", ""
   "filter", "String", "Required", "The range expression.", ""

.. code-block:: javascript

  {
	 "type": "TagValueRange",
	 "key": "host",
 	 "filter": "web{01-03}"
  }

TagValueRegex
-------------
Matches a regular expression on the tag value.

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default"
   :widths: 10, 10, 10, 55, 10
  
   "key", "String", "Required", "The literal case-sensitive name of a tag key.", ""
   "filter", "String", "Required", "A properly formed CPRE compatible regular expression", ""

.. code-block:: javascript

  {
	 "type": "TagValueRegex",
	 "key": "host",
 	 "filter": "web0[123]"
  }

