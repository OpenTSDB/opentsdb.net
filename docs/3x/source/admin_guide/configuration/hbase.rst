HBase Configuration
===================
.. index:: hbaseconfiguration

HBase configurations for the ``net.opentsdb.storage.Tsdb1xHBaseFactory`` have the prefix ``tsd.storage.`` to be somewhat compatible with previous TSD configs. For plugins with an ID, the ID follows the prefix and comes before the suffix. E.g. if our plugin had an ID of ``DEN`` then the ZK quorum would be ``tsd.storage.DEN.zookeeper.quorum: zk1:281``. Configurations in the table do **not** have the prefixes, so make sure you use ``tsd.storage.`` before any config name.

The most important settings are:
* ``zookeeper.quorum`` - The set of Zookeeper hosts configured for HBase.
* ``zookeeper.znode.parent`` - The zookeeper node where the HBase configuration lives.
* ``data_table`` - The name of the TSDB data table.
* ``tsdb-uid`` - The name of the TSDB UID table where meta data will be stored.

.. NOTE::

  Additional settings can be configured from `http://opentsdb.net/docs/build/html/user_guide/configuration.html <http://opentsdb.net/docs/build/html/user_guide/configuration.html>`_. Simply place them in the same YAML configuration as the rest of the HBase settings and anything prefixed with ``hbase`` will be passed to the AsyncHBase client configuration.

Configurations
^^^^^^^^^^^^^^

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "zookeeper.quorum", "String", "Required", "A comma-separated list of ZooKeeper hosts to connect to, with or without port specifiers.", "localhost:2181", "192.168.1.1:2181"
   "zookeeper.znode.parent", "String", "Required", "Path under which the znode for the ``-ROOT-`` region is located.", "/hbase", "/hbase"
   "data_table", "String", "Optional", "Name of the HBase table where data points are stored.", "tsdb", "namespace:tsdb"
   "uid_table", "String", "Optional", "Name of the HBase table where meta data are stored.", "tsdb-uid", "namespace:tsdb-uid"
   "salt.buckets", "Integer", "Optional", "The number of salt buckets used to distribute load across regions. **WARNING** Changing this value after writing data may cause TSUID based queries to fail.", "0", "20"
   "salt.width", "Integer", "Optional", "The width, in bytes, of the salt prefix used to indicate which bucket a time series belongs in. A value of 0 means salting is disabled. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "0", "1"
   "uid.width.metric", "Integer", "Optional", "The width, in bytes, of metric UIDs. Maximum value is 7. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "3", "4"
   "uid.width.tagk", "Integer", "Optional", "The width, in bytes, of tag key UIDs. Maximum value is 7. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "3", "4"
   "uid.width.tagv", "Integer", "Optional", "The width, in bytes, of tag value UIDs. Maximum value is 7. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "3", "4"
   "uid.cache.type.metric", "String", "Optional", "Type of cache used for metric UIDs.", "", "LRUUniqueId"
   "uid.cache.type.tagk", "String", "Optional", "Type of cache used for metric UIDs.", "", "LRUUniqueId"
   "rollups.enable", "Boolean", "Optional", "Whether or not rollups are enabled for reading and/or writing. Note that ``rollups.config`` must also be supplied.", "false", "true"
   "rollups.config", "Object", "Optional", "A rollup config. See :doc:`rollup`", "", ":doc:`rollup`"
