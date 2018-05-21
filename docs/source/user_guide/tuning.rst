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

