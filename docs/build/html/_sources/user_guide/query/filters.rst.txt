Query Filters
=============
.. index:: Filters
A critical function of any database system is to enable fetching subsets of the full data set using some form of filtering. OpenTSDB has provided filtering since version 1.x with expanded capabilities starting with 2.2 and beyond. Filters currently operate on tag values at this time. That means that any metrics and tag keys must be specified exactly as they appear in the database when fetching data.

**Example Data**

As each filter is explained below, the following data set is used. It consists of a single metric with multiple time series defined on various tags. Only one data point is given at *T1* as an example.

.. csv-table::
   :header: "TS#", "Metric", "Tags", "Value @ T1"
   :widths: 10, 20, 50, 20
   
   "1", "sys.cpu.system", "dc=dal host=web01", "3"
   "2", "sys.cpu.system", "dc=dal host=web02", "2"
   "3", "sys.cpu.system", "dc=dal host=web03", "10"
   "4", "sys.cpu.system", "host=web01", "1"
   "5", "sys.cpu.system", "host=web01 owner=jdoe", "4"
   "6", "sys.cpu.system", "dc=lax host=web01", "8"
   "7", "sys.cpu.system", "dc=lax host=web02", "4"

Grouping
--------
.. index:: Grouping
.. index:: Group By
Grouping, also referred to as *group-by*, is the process of combining multiple time series into one using the required aggregation function and filters. By default, OpenTSDB groups everything by metric so that if the query returned 10 time series with an aggregator of ``sum``, all 10 series would be added together over time to arrive at one value. See :doc:`aggregators` for details on how time series are merged.

To avoid grouping and fetch each underlying time series without any aggregation, use the ``none`` aggregator included in version 2.2. Alternatively, you can disable grouping on a per-filter bases with OpenTSDB 2.2 and later. See API documentation on how to do so.

OpenTSDB 1.x - 2.1
------------------

In the original OpenTSDB release and up to 2.1, only two types of filters were available and they were implicitly configured for grouping. The two operators allowed were:

* **\*** - The asterisk (or *wildcard*) will return a separate result for each unique tag value detected. E.g. if the tag key ``host`` was paired with ``web01`` and ``web02`` then there would be two groups emitted, one on ``web01`` and one on ``web02``.
* **|** - The pipe (or *literal_or*) will return a separate result *only* for the exact tag values specified. I.e. it will match only time series with the given tag value and group on each of those matches.

Multiple filters can be provided per query and the results are always *ANDed* together. These filters are still available for use in 2.x and later.

Examples
^^^^^^^^

The following examples use the v1 HTTP URI syntax wherein the ``m`` parameter consists of the aggregator, a colon, then the metric and tag filters in brackets separated by equal signs.

**Example 1:** 
``http://host:4242/q?start=1h-ago&m=sum:sys.cpu.system{host=web01}``

.. csv-table::
   :header: "Time Series Included", "Tags", "Aggregated Tags", "Value @ T1"
   :widths: 40, 25, 25, 10
   
   "1, 4, 5, 6", "host=web01", "", "16"
   
In this case the aggregated tags set will be empty as time series 4 and 5 have tags that are not in common with the entire set.

**Example 2:**
``http://host:4242/q?start=1h-ago&m=sum:sys.cpu.system{host=web01,dc=dal}``

.. csv-table::
   :header: "Time Series Included", "Tags", "Aggregated Tags", "Value @ T1"
   :widths: 40, 25, 25, 10
   
   "1", "host=web01,dc=dal", "", "3"

**Example 3:**
``http://host:4242/q?start=1h-ago&m=sum:sys.cpu.system{host=*,dc=dal}``

.. csv-table::
   :header: "Time Series Included", "Tags", "Aggregated Tags", "Value @ T1"
   :widths: 40, 25, 25, 10
   
   "1", "host=web01,dc=dal", "", "3"
   "2", "host=web02,dc=dal", "", "2"
   "3", "host=web03,dc=dal", "", "10"

This time we provided the ``*`` for the host and an explicit match for ``dc``. This will group on the ``host`` tag key and return a time series per unique host tag value, in this case 3 series.

**Example 4:**
``http://host:4242/q?start=1h-ago&m=sum:sys.cpu.system{dc=dal|lax}``

.. csv-table::
   :header: "Time Series Included", "Tags", "Aggregated Tags", "Value @ T1"
   :widths: 40, 25, 25, 10
   
   "1, 2, 3", "dc=dal", "host", "15"
   "6, 7", "dc=lax", "host", "12"

Here the ``|`` operator is used to match only the values for the ``dc`` tag key that are provided in the query. Therefore the TSD will group together any time series with those values. The ``host`` tag is moved to the *Aggregated Tags* list as every time series in the set has a ``host`` tag and there are multiple values for the tag key.

.. WARNING:: Because these filters are limited, if users write time series like **#1**, **#4** and **#5**, unexpected results can be returned as a result of aggregating time series that may have one common tag but varying additional tags. This problem is somewhat addressed with 2.3 and **Explicit Tags**.

OpenTSDB 2.2
------------

In OpenTSDB 2.2 a more flexible filter framework was added that allows for disabling grouping as well as additional filter types such as regular expressions and wild cards. The filter framework is plugable to allow for tying into external systems such as asset management or provisioning systems.

Multiple filters on the same tag key are allowed and when processed, they are *ANDed* together e.g. if we have two filters ``host=literal_or(web01)`` and ``host=literal_or(web02)`` the query will always return empty. If two or more filters are included for the same tag key and one has group by enabled but another does not, then group by will effectively be true for all filters on that tag key.

.. WARNING:: Some type of filters may cause queries to execute slower than others, particularly the ``regexp``, ``wildcard`` and case-insensitive filters. Before fetching data from storage, the filters are processed to create a database filter based on UIDs so using the case sensitive ``literal_or`` filter is always faster than ``regexp`` because we can resolve the strings to UIDs and send those to the storage system for filtering. Instead if you ask for regex or wildcards with pre, post or infix filtering the TSD must retrieve all of the rows from storage with the tag key UID, then for each unique row, resolve the UIDs back to strings and then run the filter over the results. Also, filter sets with a large list of literals will be processed post storage to avoid creating a massive filter for the backing store to process. This limit defaults to ``4096`` and can be configured via the ``tsd.query.filter.expansion_limit`` parameter.

Explicit Tags
-------------
.. index:: Explicit Tags
As of 2.3 and later, if you know all of the tag keys for a given metric query latency can be improved greatly by using the ``explicitTags`` feature. This flag has two benefits:

#. For metrics that have a high cardinality, the backend can switch to a more efficient query to fetch a smaller subset of data from storage. (Particularly in 2.4)
#. For metrics with varying tags, this can be used to avoid aggregating time series that should not be included in the final result.

Explicit tags will craft an underlying storage query that fetches only those rows with the given tag keys. That can allow the database to skip over irrelevant rows and answer in less time.

Examples
^^^^^^^^

The following examples use the v2 HTTP URI syntax wherein the ``m`` parameter consists of the aggregator, a colon, the ``explicit_tags`` URI flag, then the metric and tag filters in brackets separated by equal signs.

**Example 1:** 
``http://host:4242/q?start=1h-ago&m=sum:explicit_tags:sys.cpu.system{host=web01}``

.. csv-table::
   :header: "Time Series Included", "Tags", "Aggregated Tags", "Value @ T1"
   :widths: 40, 25, 25, 10
   
   "4", "host=web01", "", "1"

This solves the issue of inconsistent tag keys, allowing us to pick out only time series *#4*.

**Example 2:** 
``http://host:4242/q?start=1h-ago&m=sum:explicit_tags:sys.cpu.system{host=*}{dc=*}``

.. csv-table::
   :header: "Time Series Included", "Tags", "Aggregated Tags", "Value @ T1"
   :widths: 40, 25, 25, 10
   
   "1, 6", "host=web01", "dc", "11"
   "2, 7", "host=web02", "dc", "6"
   "3", "host=web03,dc=dal", "", "10"

This query uses the v2 URI syntax to avoid grouping on the ``dc`` tag key by putting it in a second set of curly braces. This allows us to filter out only the time series that have both a ``host`` and ``dc`` tag key while grouping only on the ``host`` value. It skips time series *#4* and *#5*.

.. NOTE:: When using HBase (0.98 and later) or Bigtable, make sure ``tsd.query.enable_fuzzy_filter`` is enabled in the config (enabled by default). A special filter is given to the backend that enables skipping ahead to rows that we need for the query instead of iterating over every row key and comparing a regular expression.

.. NOTE:: With 2.4, TSDB will issue multiple ``get`` requests against the backend instead of using a scanner. This can reduce query time by multiple factors, particularly with high-cardinality time series. However the filters must consist of only `literal_or``'s.

Built-in 2.x Filters
--------------------

The following list are built-in filters included with OpenTSDB. Additional filters can be loaded as plugins. Each heading is the ``type`` of filter to use in a URI or JSON query. When writing a URI query, the filter is used by placing the filter name after the tag key's equals sign and placing the filter value in parentheses. E.g. ``{host=regexp(web[0-9]+.lax.mysite.com)}``. For JSON queries simply use the filter name as the ``type`` parameter and the filter value as the ``filter`` parameter, e.g.

::

  {
    "type": "regexp",
    "filter": "web[0-9]+.lax.mysite.com",
    "tagk": "host",
    "groupBy": false
  }

The examples below use the URI syntax.

literal_or
^^^^^^^^^^
.. index:: literal_or
Takes a single literal value or a ``|`` pipe delimited list of values and returns any time series matching the results on a case sensitive bases. This is a very efficient filter as it can resolve the strings to UIDs and send that to the storage layer for pre-filtering. In SQL this is similar to the ``IN`` or ``=`` predicates.

*Examples*

* ``host=literal_or(web01|web02|web03)``  In SQL: ``WHERE host IN ('web01', 'web02', 'web03')``
* ``host=literal_or(web01)``  In SQL: ``WHERE host = 'web01'``

ilteral_or
^^^^^^^^^^
.. index:: iliteral_or
The same as a ``literal_or`` but is case insensitive. Note that this is not efficient like the literal or as it must post-process all rows from storage.

not_literal_or
^^^^^^^^^^^^^^
.. index:: not_literal_or
Case sensitive ``literal_or`` that will return series that do **NOT** match the given list of values. Efficient as it can be pre-processed by storage.

not_iliteral_or
^^^^^^^^^^^^^^^
.. index:: not_iliteral_or
Case insensitive ``not_literal_or``.

wildcard
^^^^^^^^
.. index:: wildcard
Provides case sensitive postfix, prefix, infix and multi-infix filtering. The wildcard character is an asterisk (star) ``*``. Multiple wildcards can be used. If only the asterisk is given, the filter effectively returns any time series that include the tag key (and is an efficient filter that can be pre-processed). In SQL land, this is similar to ``LIKE`` predicate with a bit more flexibility.

*Examples*

* ``host=wildcard(*mysite.com)`` In SQL: ``WHERE host='%mysite.com'``
* ``host=wildcard(web*)``
* ``host=wildcard(web*mysite.com)``
* ``host=wildcard(web*mysite*)``
* ``host=wildcard(*)`` This is equivalent to the v1 basic group by operator and is efficient.

iwildcard
^^^^^^^^^
.. index:: iwildcard
The same as ``wildcard`` but case insensitive.

regexp
^^^^^^
.. index:: regexp
Filters using POSIX compliant regular expressions post fetching from storage. The filter uses Java's built-in regular expression operation. Be careful to escape special characters depending on the query method used.

*Examples*

* ``regexp(web.*)`` In SQL: ``WHERE host REGEXP 'web.*'``
* ``regexp(web[0-9].mysite.com)``

Loaded Filters
--------------

To show the loaded filters in OpenTSDB 2.2 and later, call the HTTP ``/api/config/filters`` endpoint. This will list loaded plugins along with a description and example usage.

Plugins
-------

As developers add plugins we will list them here.

To develop a plugin, simply extend the ``net.opentsdb.query.filter.TagVFilter`` class, create JAR per the :doc:`../../development/plugins` documentation and drop it in your plugins directory. On start, the TSD will search for the plugin and load it. If there was an error with the implementation the TSD will not start up and will log the exception.