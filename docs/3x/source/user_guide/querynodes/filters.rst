Filters
=======
.. index:: filters
Filters allow for fetching a select set of time series with a common metric. 3.x filters are much more capable than 2.x filters with the ability to search across multiple fields and combine them for boolean queries.

A filter is a single object and in places where filters are used, only the one object is allowed. However multiple filters can be combined in various ways via the ``chain`` filter. Chains allow for ``AND`` ing operations or ``OR`` ing filtering as well as nested chains for complex filtering. Additional modifying filters are available such as the ``Not`` filter that negates nested filters.

**Note** that we're still working out some bugs with the filters, particularly with legacy data sources so file any that you see.

**TYPE**

All filter definitions require the ``type`` field that is the name of the filter from these documents. The type must be loaded in the registry as the ID of the plugin.

Filters currently built-in to OpenTSDB include:

Chain
-----
Combines one or more filters with a logical ``AND`` (the default) or a logical ``OR``. Fields include:

* **op** - Either the literal ``AND`` (default) or ``OR``.
* **filters** - A list of one or more filter objects. These can be any type of filter.

MetricLiteral
-------------
Matches a single metric in the data store.

* **metric** - The literal, case-sensitive name of the metric.

MetricRegex
-----------
Executes the regular expression against metrics to fetch all metrics that match.

* **metric** - The valid regular expression to use.

TagKeyLiteralOr
---------------
Matches one or more literal tag keys. Multiple values are separated by a pipe.

* **filter** - A pipe separated list of case-sensitive tag keys.

TagKeyLiteralRegex
------------------
Matches the regular expression against tag keys.

* ** filter** - The valid regular expression to use.

TagValueLiteralOr
-----------------
Matches one or more literal tag values. Multiple values are separated by a pipe.

* **tagKey** - The literal case-sensitive name of a tag key.
* **filter** - A pipe separated list of case-sensitive tag values.

TagValueWildcard
----------------
Matches on the globs of a case-sensitive tag value using the literal ``*`` as the wildcard place-holder.

* **tagKey** - The literal case-sensitive name of a tag key.
* **filter** - A case-sensitive tag value with asterisks for the wildcard. Must include at least one asterisk. If the value is just ``*`` then it will match all series with the given ``tagKey``.

TagValueRange
-------------
Expands a syntax into multiple literal values. E.g. ``web{01-05}.{dc1|dc2}`` would generate 10 values such as ``web01.dc1` through ``web05.dc2``.
TODO - docs

* **tagKey** - The literal case-sensitive name of a tag key.
* **filter** - The range expression.

TagValueRegex
-------------
Matches a regular expression on the tag value.

* **tagKey** - The literal case-sensitive name of a tag key.
* **filter** - A properly formed regular expression.

ExplicitTags
------------
Must be used as the top-level filter if applicable and means that a time series must have all of the tag keys specified in the nested filter set and no other tags.

* **filter** - A required nested filter.

Not
---
Negates the nested filter.

* **filter** - A required nested filter.

AnyFieldRegex
-------------
Matches on any field including the metric, tag keys and tag values.

* **filter** - A properly formed regular expression.

