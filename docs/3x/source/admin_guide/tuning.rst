Tuning
======
.. index:: Tuning

As with any database there are many tuning parameters for OpenTSDB that can be used to improve write and read performance. Some of these options are specific to certain backends, others are global.

TSDB Memory
-----------

As with any server process, tuning the TSD's memory footprint is important for a successful install. There are a number of caches in OpenTSDB that can be tuned.

UID Caches
^^^^^^^^^^

OpenTSDB saves space in storage by converting strings to binary UIDs. However for writing and querying, these UIDs have to be cached to improve performance (otherwise every operation would amplify queries against storage). In early versions of OpenTSDB, the cache would maintain an unbounded map of strings to UIDs and UIDs to strings regardless of modes of operation. In 2.4 you can choose how much data to cache and optionally use an LRU. The pertinent settings include:

* 'tsd.uid.use_mode=true' - When this is set to true, the `tsd.mode` value is examined to determine if either or both of the forward (string to UID) and reverse (UID to string) maps are populated. When empty or set to `rw`, both maps are populated. When set to `ro`, only the reverse map is populated (as query results need caching). When in `w` or write-only mode, only the forward map is populated as metrics need to find their UIDs when writing.
* `tsd.uid.lru.enable=true` - Switch to the LRU version of the cache that will expire entries that haven't been read in a while.
* `tsd.uid.lru.id.size=<integer>` - For TSDs focused on reads, set this size larger than `tsd.uid.lru.name.size`.
* `tsd.uid.lru.name.size=<integer>` - For TSDs focused on writes, set this size larger than the `tsd.uid.lru.id.size`.

HBase Storage
-------------

These are parameters to look at for using OpenTSDB with Apache HBase.

.. _date_tierd_compaction:

Date Tierd Compaction
^^^^^^^^^^^^^^^^^^^^^

HBase is an LSM store meaning data is written to blocks in memory, then flushed in blocks to disk, then periodically those blocks on disk are merged into fewer blocks to reduce file count and redundancies. The process of reading and merging blocks from disk can consume a fair amount of CPU and memory so if a system is heavily loaded with time series write traffic, background compactions can begin to impact write performance. HBase offers various compaction strategies including Date Tiered Compaction that looks at the the edit timestamps of columns to figure out if stale file that haven't been modified should be ignored and arranges data so that time ranged queries are much more efficient.

OpenTSDB can leverage this compaction strategy (as of 2.4) to improve HBase performance, particularly for queries. To setup Date Tiered Compaction in HBase, see `HBase Book <http://hbase.apache.org/book.html#ops.date.tiered>`_. Parameters that must be set in the OpenTSDB config include:

* `tsd.storage.use_otsdb_timestamp=true` - By default the edit timestamps of every data point is `now`. This changes the timestamp to be that of the actual data point. Note that rollups do not use this strategy yet.
* `tsd.storage.get_date_tiered_compaction_start=<Unix Epoch MS timestamp>` - A timestamp in milliseconds when the date tiered compactor was enabled on a table. If you are creating a brand new table for OpenTSDB you can leave this at the default of `0`.

HBase Read/Write Queues
^^^^^^^^^^^^^^^^^^^^^^^

HBase has the ability to split the queues that handle RPCs for writes (mutations) and reads. This is a huge help for OpenTSDB as massive queries will avoid impacting writes and vice-versa. See the `HBase Book <http://hbase.apache.org/book.html#_tuning_code_callqueue_code_options>`_ for various configuration options. Note that different HBase versions have different names for these properties. 

Possible starting values are 50% or 60%. E.g. `hbase.ipc.server.callqueue.read.share=0.60` or `hbase.ipc.server.callqueue.read.ratio=0.60` depending on HBase version.

Also, tuning the call queue size and threads is important. With a large queue, the region server can possibly OOM (if there are a large number of writes backing up) and RPCs will be more likely to time out on the client side if they sit in the queue too long. The queue size is a factor of the number of handlers. Reducing the call queue size also helps to cause clients to throttle, particularly the AsyncHBase client. For HBase 1.3 a good setting may be `hbase.ipc.server.max.callqueue.length=100` and `hbase.ipc.server.read.threadpool.size=2`. If you need to increase the threads, reduce the queue length as well.

HBase Cache
^^^^^^^^^^^

Tuning the HBase cache is also important for queries as you want to avoid reading data off disk as much as possible (particularly if that disk is S3). Try using the offheap cache via `hbase.bucketcache.combinedcache.enabled=true` and `hbase.bucketcache.ioengine=offheap`. Give the offheap cache a good amount of RAM, e.g. `hbase.bucketcache.size=4000` for 4GB of RAM. Since the most recent data is usually queried when reading time series, it's a good idea to populate the block cache on writes and use most of that space for the latest data. Try the following settings:

:: 

  hbase.rs.cacheblocksonwrite=true
  hbase.rs.evictblocksonclose=false
  hfile.block.bloom.cacheonwrite=true
  hfile.block.index.cacheonwrite=true
  hbase.block.data.cachecompressed=true
  hbase.bucketcache.blockcache.single.percentage=.99
  hbase.bucketcache.blockcache.multi.percentage=0
  hbase.bucketcache.blockcache.memory.percentage=.01
  hfile.block.cache.size=.054 #ignored but needs a value.

This will allocate the majority of the black cache for writes and cache it in memory.

For the on-heap cache, you can try an allocation of:
::

  hbase.lru.blockcache.single.percentage=.50
  hbase.lru.blockcache.multi.percentage=.49
  hbase.lru.blockcache.memory.percentage=.01

HBase Compaction
^^^^^^^^^^^^^^^^

Compaction is the process of merging multiple stores on disk for a region into fewer files to reduce space and query times. You can tune the number of threads and thresholds for compaction to avoid using too many resources when the focus should be on writes.
::
  
  hbase.hstore.compaction.ratio=1.2
  hbase.regionserver.thread.compaction.large=2
  hbase.regionserver.thread.compaction.small=6
  hbase.regionserver.thread.compaction.throttle=524288000

HBase Regions
^^^^^^^^^^^^^

For OpenTSDB we've observed that 10G regions are a good size for a large cluster `hbase.hregion.max.filesize=10737418240`.

HBase Memstore
^^^^^^^^^^^^^^

Try flushing the mem store to disk (and cache) more often, particularly for heavy write loads. We've seen good behavior with 16MBs `hbase.hregion.memstore.flush.size=16777216`. Also try reducing the memstore size limit via `hbase.regionserver.global.memstore.lowerLimit=.20` and `hbase.regionserver.global.memstore.upperLimit=.30`.


