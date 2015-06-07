Filters
=======

In OpenTSDB 2.2 tag key and value filters were introduced. This makes it easier to extract only the data that you want from storage. The filter framework is plugable to allow for tying into external systems such as asset management or provisioning systems.

Multiple filters on the same tag key are allowed and when processed, they are *ANDed* together e.g. if we have two filters ``host=literal_or(web01)`` and ``host=literal_or(web02)`` the query will always return empty. If two or more filters are included for the same tag key and one has group by enabled but another does not, then group by will effectively be true for all filters on that tag key.

Note that some type of filters may cause queries to execute slower than others, e.g. the regex and wildcard filters. Before fetching data from storage, the filters are processed to create a database filter based on UIDs so using the case sensitive "literal or" filter is always faster than regex because we can resolve the strings to UIDs and send those to the storage system for filtering. Instead if you ask for regex or wildcards with pre, post or infix filtering the TSD must retrieve all of the rows from storage with the tag key UID, then for each unique row, resolve the UIDs back to strings and then run the filter over the results. Also, filter sets with a large list of literals will be processed post storage to avoid creating a massive filter for the backing store to process. This limit defaults to ``4096`` and can be configured via the ``tsd.query.filter.expansion_limit`` parameter.

Built-in Filters
^^^^^^^^^^^^^^^^

literal_or
----------

Takes a single literal value or a pipe delimited list of values and returns any time series matching the results on a case sensitive bases. This is a very efficient filter as it can resolve the strings to UIDs and send that to the storage layer for pre-filtering.

*Examples*

``literal_or(web01|web02|web03)``
``literal_or(web01)``

ilteral_or
----------

The same as a ``literal_or`` but is case insensitive. Note that this is not efficient like the literal or as it must post-process all rows from storage.

not_literal_or
--------------

Case sensitive ``literal_or`` that will return series that do **NOT** match the given list of values. Efficient as it can be pre-processed by storage.

not_iliteral_or
---------------

Case insensitive ``not_literal_or``.

wildcard
--------

Provides case sensitive postfix, prefix, infix and multi-infix filtering. The wildcard character is an asterisk (star) ``*``. Multiple wildcards can be used. If only the asterisk is given, the filter effectively returns any time series that include the tag key (and is an efficient filter that can be pre-processed). 

*Examples*
``wildcard(*mysite.com)``
``wildcard(web*)``
``wildcard(web*mysite.com)``
``wildcard(web*mysite*)``
``wildcard(*)``

iwildcard
---------

The same as ``wildcard`` but case insensitive.

regexp
------

Filters using POSIX compliant regular expressions post fetching from storage. The filter uses Java's built-in regular expression operation. Be careful to escape special characters depending on the query method used.

*Examples*
``regexp(web.*)``
``regexp(web[0-9].mysite.com)``

Plugins
^^^^^^^

As developers add plugins we will list them here.

To develop a plugin, simply extend the ``net.opentsdb.query.filter.TagVFilter`` class, create JAR per the :doc:`../../development/plugins` documentation and drop it in your plugins directory. On start, the TSD will search for the plugin and load it. If there was an error with the implementation the TSD will not start up and will log the exception.