HBase Quick Start
=================

3.x is backwards compatible with 1.x and 2.x data stored in HBase. (Note we're still working on supporting annotations and histograms but numerical data is queryable without issue).

Access to HBase is through the `opentsdb-asynchbase` module and must be loaded as a plugin with the `net.opentsdb.storage.Tsdb1xHBaseFactory` class. A built-in 1x schema plugin must also be configured and told to read from HBase. (It can also read from Bigtable). An example plugin config looks like this:

.. code-block:: yaml

  tsd.plugin.config:
    configs:
      - plugin: net.opentsdb.storage.Tsdb1xHBaseFactory
        isDefault: true
        type: net.opentsdb.storage.schemas.tsdb1x.Tsdb1xDataStoreFactory

      - plugin: net.opentsdb.storage.schemas.tsdb1x.SchemaFactory
        isDefault: true
        type: net.opentsdb.data.TimeSeriesDataSourceFactory
  
    pluginLocations:
    continueOnError: true
    loadDefaultInstances: true

Next you need to point to the proper Zoo Keeper and parent znode path:

.. code-block:: yaml

  tsd.storage.zookeeper.quorum: 127.0.0.1:2181
  tsd.storage.zookeeper.znode.parent: /hbase


Then make sure to set the tables your data will be written to (or has been written to):

.. code-block:: yaml

  tsd.storage.data_table: tsdb
  tsd.storage.uid_table: tsdb-uid
  
If you have an existing HBase instance with OpenTSDB data and have modified the default UID widths, make sure to change them:

.. code-block: yaml

  tsd.storage.uid.width.metric: 3
  tsd.storage.uid.width.tagk: 3
  tsd.storage.uid.width.tagv: 3

A complete config file example that ships with the Docker container can be found at `https://github.com/OpenTSDB/opentsdb/blob/3.0/distribution/src/resources/docker/opentsdb.yaml <https://github.com/OpenTSDB/opentsdb/blob/3.0/distribution/src/resources/docker/opentsdb.yaml>`_.