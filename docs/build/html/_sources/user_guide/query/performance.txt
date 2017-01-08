Query Performance
=================
.. index:: Query Performance
Query performance is critical for any database system. This page lists some common OpenTSDB issues and steps to improve performance.

Caching
^^^^^^^
.. index:: Caching
At this time OpenTSDB doesn't have a built-in cache (aside from the built-in GUI that will cache PNG image files for 60 seconds). Therefore we rely on the underlying database's cache. In HBase (the most common OpenTSDB backend) there is the concept of a Block cache that will store blocks of rows and columns in memory on write and/or read. A good primer is `Nick Dimiduck's Block Cache 101 <http://www.n10k.com/blog/blockcache-101/>`_. One good way to setup the cache is to use the ``BucketCache`` and size the L1 cache fairly large so that it acts as a write cache and keeps most of your recent data in memory. Then the L2 cache can keep frequently queried data in memory as users run their queries.

Carefully watch your region servers for GC pauses. Users typically run the bucket cache in off-heap mode but there is still a penalty to pay in serializing between Java and JNI for off-heap cache hits and writes.

Also, make sure that compression is enabled on your HBase tables. Blocks are stored in memory using the compression algorithm specified on the table, thus you can fit more compressed blocks in cache than uncompressed.

One Out of Many Queries
^^^^^^^^^^^^^^^^^^^^^^^

If you commonly have queries where you're looking for one or two time series amongst a metric with vary high cardinality (i.e. many tag values) then make sure you are using version 2.3 or later with ``explicitTags`` enabled in your query. The query must list all of the tag keys associated with the data you are looking for but it will enable a special filter on HBase that will help to reduce the number of rows scanned. See :doc:`filters` for details.

Alternatively, if you place a high-cardinality tag in the metric name, this will greatly reduce the amount of data scanned at query time and improve performance. See :doc:`../writing/index` for more information.

High Cardinality Query
^^^^^^^^^^^^^^^^^^^^^^

For queries that are aggregating many time series together, the best way to improve performance is to run OpenTSDB 2.2 or later with salting enabled and run multiple region servers in an HBase cluster. This will execute queries in parallel, fetching subsets of data from each region server and merging the results. For example, with a single region server, a query may take 10 seconds to complete. When writing the same data to 5 region servers with salting, the same query should take about 2 seconds, the time it takes for the slowest region server to respond. Merging the sets is generally insignificant time wise.

Wide Time Span Queries
^^^^^^^^^^^^^^^^^^^^^^

Queries that are looking at wide timespans (such as months or years) can benefit from dowmsampling if the bottleneck is observed between the TSD and consuming application (such as a UI or API client). Using a downsampler will reduce the amount of data serialized by the TSD and sent to the user.

However if the bottleneck is between storage (HBase) and the TSD then the best solution is to start writing rolled-up data using OpenTSDB 2.4 or later. This requires an external system to compute time-based rollups and write them to storage. Alternatively a UI or API client can execute multiple queries against multiple TSDs for smaller time spans and merge the results together. In the future we plan on adding such capabilities to TSDs directly.

General Improvements
^^^^^^^^^^^^^^^^^^^^

Additional items to consider:

Multiple Read TSDs
------------------

Run multiple TSDs dedicated to reading data and place a load balancer in front of them. This is the most common setup observed when running OpenTSDB and allows for rotating upgrades of TSDs without taking down the entire system.

Tune Storage
------------

HBase has many, many parameters that can be tuned and in general, most of OpenTSDB's bottlenecks arise from HBase. Make sure to monitor the servers, particularly queues, cache, response times, CPU and GCs.

Educate Users
-------------

No database system is immune to long-running or resource hogging queries. Ask users to start with smaller time ranges, such as 1 hour, and gradually increase their time-ranges. Also help users understand cardinality and how asking for ``high_cardinality_tag_key=*`` may be a bad idea.