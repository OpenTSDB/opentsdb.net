Troubleshooting
===============
.. index:: Troubleshooting
This page lists common issues encountered by users of OpenTSDB along with various troubleshooting steps. If you run into an issue, please check the `OpenTSDB Google Group <https://groups.google.com/forum/#!forum/opentsdb>`_ or the `Github Issues <https://github.com/OpenTSDB/opentsdb/issues>`_. If you can't find an answer, please include your operating system, TSD version and HBase version in your question.

OpenTSDB compactions trigger large .tmp files and region server crashes in HBase
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This can be caused if you use millisecond timestamps and write thousands of data points for a single metric in a single hour. In this case, the column qualifier and row key can grow larger than the configured ``hfile.index.block.max.size``. In this situation we recommend that you disable TSD compaction code. In the future we will support appends which will allow for compacted columns with small qualifiers.

TSDs are slow to respond after region splits or over long run times
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

During region splits or region migrations, OpenTSDB's AsyncHBase client will buffer RPCs in memory and attempt to flush them once the regions are back online. Each region has a 10,000 RPC buffer by default and if many regions are down then the RPCs can eventually fill up the TSD heap and cause long garbage collection pauses. If this happens, you can either increase your heap to accommodate more region splits or decrease the NSRE queue size by modifying the ``hbase.nsre.high_watermark`` config parameter in AsyncHBase 1.7 and OpenTSDB 2.2.

TSDs are stuck in GC or crashing due to Out of Memory Exceptions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are a number of potential causes for this problem including:

* Multiple NSREs from HBase - See the section above about TSDs being slow to respond.
* Too many writes - If the rate of writes to TSD is high, queues can build up in AsyncHBase (see above) or in the compaction queue. If this is the case, check HBase performance and try disabling compactions.
* Large queries - A very large query with many time series or for a long range can cause the TSD to OOM. Try reducing query size or break large queries up into smaller chunks.
