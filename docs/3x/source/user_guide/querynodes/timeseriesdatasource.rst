TimeSeriesDataSource
====================
.. index:: timeseriesdatasource
Arguably the most important node in OpenTSDB, this type of node will retreive data and pass it through the execution graph.

There can be many types of time series data sources in the system including caching sources that will pull from a cache before trying to query a data store, routing sources to pick from various data stores and direct storage sources.

Fields common for all ata sources include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "metric", "Object", "Required", "A metric filter object (see below) that determines which metric(s) to fetch.", "null", "See :doc:`filters`"
   "fetchLast", "Boolean", "Optional", "Whether or not to just fetch the last possible value for the metric(s) if the underlying store supports such an operation.", "false", "true"
   "filter", "Object", "Optional", "A filter object to narrow down the choice of data.", "null", "See :doc:`filters`"
   "filterId", "String", "Optional", "An ID of a named filter in the containing query. If this field is not null and not empty then it would override the ``filter`` field.", "null", "f1"
   "sourceId", "String", "Optional", "The ID of a data source loaded in the Registry. If null, then the default data source is used.", "null", "AWS"
   "types", "List", "Optional", "A list of data types to filter out the response from the source. E.g. if the query only wants annotations it could specify that type here. By default all types are returned.", "null", "[""Annotations""]"

HACluster
^^^^^^^^^

This is a source that takes one or more downstream sources, sends the same query to each, then merge the results before sending them upstream. Use it when you write the same data to multiple clusters for high availability.

TODO - talk about the config.

Fields that can be set at query time include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25

   "dataSources", "List", "Optional", "A means of overriding the configured data sources by, for example, selecting a subset of sources or different sources entirely.", "null", "[""s1"", ""s2""]"
   "dataSourceConfigs", "List", "Optional", "An optional list of complete data source config nodes to execute downstream. This allows for custom configurations per source, e.g. maybe disable caching on one.", "null", "TODO"
   "mergeAggregator", "String", "Optional", "An optional override of the configured aggregator", "null", "max"
   "primaryTimeout", "String", "Optional", "An optional override of the configured primary timeout (i.e. how long to wait for the primary source when a secondary source has responded). In the TSDB duration format.", "null", "10s"
   "secondaryTimeout", "String", "Optional", "An optional override of the configured secondary timeout (i.e. how long to wait for at least one secondary source when the primary source has responded). In the TSDB duration format.", "null", "5s"