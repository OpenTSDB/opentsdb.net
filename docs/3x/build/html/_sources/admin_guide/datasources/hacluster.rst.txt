HA Cluster
==========
.. index:: hacluster

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