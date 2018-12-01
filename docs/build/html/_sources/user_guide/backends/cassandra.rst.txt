Cassandra
=========
.. index:: Cassandra
Cassandra is an eventually consistent key value store similar to HBase and Google`s Bigtable. It implements a distributed hash map with column families originally it supported a Thrift based API very close to HBase`s. Lately Cassandra has moved towards a SQL like query language with much more flexibility around data types, joints and filters. Thankfully the Thrift interface is still there so it`s easy to convert the OpenTSDB HBase schema and calls to Cassandra at a low level through the AsyncHBase ``HBaseClient`` API. `AsyncCassandra <https://github.com/OpenTSDB/asynccassandra>`_ is a shim between OpenTSDB and Cassandra for trying out TSDB with an alternate backend.

.. WARN:: The shim is in alpha shape. Please help us improve it by forking the repo and issuing pull requests.

.. WARN:: Cassandra is **eventually consistent** as opposed to HBase`s **atomically consistent**. Because OpenTSDB`s schema makes use of UIDs to reduce storage space, we need a way to generate those UIDs atomically. Since Cassandra doesn`t offer atomic updates we **fudge** it a bit by writing **lock** columns to Cassandra to avoid UID collisions between TSDs. Therefore please be aware that assigning UIDs may be slower or error prone until we can improve the client.

Setup
^^^^^

1. Setup a Cassandra cluster using the ``ByteOrderedPartitioner``. This is critical as we require the row keys to be sorted. Because this setting affects the entire node, you may need to setup a cluster dedicated to OpenTSDB.
2. Create the proper keyspsaces and column families by using the `cassandra-cli` script:

::
  
  create keyspace tsdb;
  use tsdb;
  create column family t with comparator = BytesType;
  
  create keyspace tsdbuid;
  use tsdbuid;
  create column family id with comparator = BytesType;
  create column family name with comparator = BytesType;


3. Build TSDB by executing `sh build-cassandra.sh` (or if you prefer Maven, `sh build-cassandra.sh pom.xml`)
4. Modify your `opentsdb.conf` file with the `asynccassandra.seeds` parameter, e.g. `asynccassandra.seeds=127.0.0.1:9160`.
5. In the config file, set `tsd.storage.hbase.uid_table=tsdbuid`
6. Run the tsd via `build/tsdb tsd --config=<path>/opentsdb.conf`

If you intend to use meta data or tree features, repeat the keyspace creation with the proper table name.

Configuration
^^^^^^^^^^^^^

The following is a table with required and optional parameters to run OpenTSDB with Cassandra. These are in addition to the standard TSD configuration parameters from :doc:`../configuration`

.. csv-table::
   :header: "Property", "Type", "Required", "Description", "Default"
   :widths: 20, 5, 5, 60, 10

   "asynccassandra.seeds", "String", "Required", "The list of nodes in your Cassandra cluster. These can be formatted `<hostname>:<port>`", ""
   "asynccassandra.port", "Integer", "Optional", "An optional port to use for all nodes if not configured in the seeds setting.", "9160"
