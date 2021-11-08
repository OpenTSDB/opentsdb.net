2.x to 3.x Configuration Mapping
================================

HBase
^^^^^

.. csv-table::
   :header: "2.x", "3.x", "Description"
   :widths: 20, 20, 60
   
   "tsd.storage.hbase.zk_quorum", "tsd.storage.zk_quorum", "Drop ``hbase.``"
   "tsd.storage.hbase.znode.parent", "tsd.storage.znode.parent", "Drop ``hbase.``"
   "tsd.storage.hbase.data_table", "tsd.storage.data_table", "Drop ``hbase.``"
   "tsd.storage.hbase.uid_table", "tsd.storage.uid_table", "Drop ``hbase.``"
   "tsd.storage.hbase.meta_table", "", "TODO."
   "tsd.storage.hbase.tree_table", "", "Not supported"
   "tsd.storage.salt.buckets", "tsd.storage.salt.buckets", "Same"
   "tsd.storage.salt.width", "tsd.storage.salt.width", "Same"
   "tsd.storage.uid.width.metric", "tsd.storage.uid.width.metric", "Same"
   "tsd.storage.uid.width.tagk", "tsd.storage.uid.width.tagk", "Same"
   "tsd.storage.uid.width.tagv", "tsd.storage.uid.width.tagv", "Same"
   "tsd.uid.lru.enable", "", "See the ``uid.cache.type`` configurations in :doc:`hbase`"
   "tsd.storage.hbase.prefetch_meta", "", ""
   "tsd.storage.hbase.scanner.maxNumRows", "", ""
   
   
   
