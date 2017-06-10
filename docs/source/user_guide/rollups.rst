Rollup And Pre-Aggregates
=========================

While TSDB is designed to store original, full resolution data as long as there is space, queries for wide time ranges or over many tag combinations can be quite painful. Such queries can take a long time to complete or, in the worst case, kill TSDs with out-of-memory exceptions. As of OpenTSDB 2.4, a set of new APIs allow for storing and querying lower resolution data to answer such queries much quicker. This page will give you an overview of what rollups and pre-aggregates are, how they work in TSDB and how best to use them. Look in the API's section for specific implementation details.

.. NOTE::
  
  OpenTSDB does not itself calculate and store rollup or pre-aggregated data. There are multiple ways to compute the results but they all have benefits and drawbacks depending on the scale and accuracy requirements. See the :ref:`generating` section discussing how to create this data.

Example Data
^^^^^^^^^^^^

To help describe the lower resolution data, lets look at some full resolution (also known as *raw* data) example data. The first table defines the time series with a short-cut identifier.

.. csv-table::
  :header: "Series ID", "Metric", "Tag 1", "Tag 2", "Tag 3"
  :widths: 10, 30, 20, 20, 20
  
  "ts1", "system.if.bytes.out", "host=web01", "colo=lga", "interface=eth0"
  "ts2", "system.if.bytes.out", "host=web02", "colo=lga", "interface=eth0"
  "ts3", "system.if.bytes.out", "host=web03", "colo=sjc", "interface=eth0"
  "ts4", "system.if.bytes.out", "host=web04", "colo=sjc", "interface=eth0"

Notice that they all have the same ``metric`` and ``interface`` tag, but different ``host`` and ``colo`` tags.

Next for some data written at 15 minute intervals:

.. csv-table::
  :header: "Series ID", "12:00", "12:15", "12:30", "12:45", "13:00", "13:15", "13:30", "13:45"
  :widths: 20, 10, 10, 10, 10, 10, 10, 10, 10
  
  "ts1", "1", "4", "-3", "8", "2", "-4", "5", "2"
  "ts2", "7", "2", "8", "-9", "4", "", "1", "1"
  "ts3", "9", "3", "-2", "-1", "6", "3", "8", "2"
  "ts4", "", "2", "5", "2", "8", "5", "-4", "7"

Notice that some data points are missing. With those data sets, lets look at rollups first.

Rollups
^^^^^^^
.. index:: Rollups
A "rollup" is defined, in OpenTSDB, as a **single** time series aggregated over time. It may also be called a "time-based aggregation". Rollups help to solve the problem of looking at wide time spans. For example, if you write a data point every 60 seconds and query for one year of data, a time series would return more than 525k individual data points. Graphing that many points could be pretty messy. Instead you may want to look at lower resolution data, say 1 hour data where you only have around 8k values to plot. Then you can identify anomalies and drill down for finer resolution data.

If you have already used OpenTSDB to query data, you are likely familiar with **downsamplers** that aggregate each time series into a smaller, or lower resolution, value. A rollup is essentially the result of a downsampler stored in the system and called up at will. Each rollup (or downsampler) requires two pieces of information:

* **Interval** - How much time is "rolled" up into the new value. For example, ``1h`` for one hour of data or ``1d`` for a day of data.
* **Aggregation Function** - What arithmetic was performed on the underlying values to arrive at the new value. E.g. ``sum`` to add all of the values or ``max`` to store the largest.

.. WARNING::
  When storing rollups, it's best to avoid functions such as **average**, **median** or **deviation**. When performing further downsampling or grouping aggregations, such values become meaningless. Instead it's much better to always store the **sum** and **count** from which, at least, the **average** can be computed at query time. For more information, see the section below.

The timestamp of a rolled-up data point should snap to the top of the rollup interval. E.g. if the rollup interval is ``1h`` then it contains 1 hour of data and should snap to the top of the hour. (As all timestamps are written in Unix Epoch format, defined as the UTC timezone, this would be the start of an hour UTC time).

Rollup Example
--------------

Given the series above, lets store the ``sum`` and ``count`` with an interval of ``1h``. 

.. csv-table::
  :header: "Series ID", "12:00", "13:00"
  :widths: 50, 25, 25
  
  "ts1 SUM", "10", "5"
  "ts1 COUNT", "4", "4"
  "ts2 SUM", "8", "6"
  "ts2 COUNT", "4", "3"
  "ts3 SUM", "9", "19"
  "ts3 COUNT", "4", "4"
  "ts4 SUM", "9", "16"
  "ts4 COUNT", "3", "4"

Notice that all timestamps align to the top of the hour regardless of when the first data point in the interval "bucket" appears. Also notice that if a data point is not present for an interval, the count is lower.

In general, you should aim to compute and store the ``MAX``, ``MIN``, ``SUM`` and ``COUNT`` for each time series when storing rollups.

Averaging Rollup Example
------------------------

When rollups are enabled and you request a downsampler with the ``avg`` function from OpenTSDB, the TSD will scan storage for ``SUM`` and ``COUNT`` values. Then while iterating over the data it will accurately compute the average. 

The timestamps for count and sum values must match. However, if the expected count value for a sum is missing, the sum will be kicked out of the results. Take the following example set from above where we're now missing a count data point in ``ts2``.

.. csv-table::
  :header: "Series ID", "12:00", "13:00"
  :widths: 50, 25, 25
  
  "ts1 SUM", "10", "5"
  "ts1 COUNT", "4", "4"
  "ts2 SUM", "8", "6"
  "ts2 COUNT", "4", ""
  
The resulting ``avg`` for a ``2h`` downsampling query would look like this:

.. csv-table::
  :header: "Series ID", "12:00"
  :widths: 50, 25
  
  "ts1 AVG", "1.875"
  "ts2 AVG", "2"

Pre-Aggregates
^^^^^^^^^^^^^^
.. index:: Pre-Aggregates
While rollups help with wide time span queries, you can still run into query performance issues with small ranges if the metric has high cardinality (i.e. the unique number of time series for the given metric). In the example above, we have 4 web servers. But lets say that we have 10,000 servers. Fetching the sum or average of interface traffic may be fairly slow. If users are often fetching the group by (or some think of it as the spatial aggregate) of large sets like this then it makes sense to store the aggregate and query that instead, fetching *much* less data.

Unlike rollups, pre-aggregates require only one extra piece of information:

* **Aggregation Function** - What arithmetic was performed on the underlying values to arrive at the new value. E.g. ``sum`` to add all of the time series or ``max`` to store the largest.

In OpenTSDB, pre-aggregates are differentiated from other time series with a special tag. The default tag key is ``_aggregate`` (configurable via ``tsd.rollups.agg_tag_key``). The **aggregation function** used to generate the data is then stored in the tag value in upper-case. Lets look at an example:

Pre-Aggregate Example
---------------------

Given the example set at the top, we may want to look at the total interface traffic by colo (data center). In that case, we can aggregate by ``SUM`` and ``COUNT`` similarly to the rollups. The result would be four **new** time series with meta data like:

.. csv-table::
  :header: "Series ID", "Metric", "Tag 1", "Tag 2"
  :widths: 10, 30, 30, 30
  
  "ts1'", "system.if.bytes.out", "colo=lga", "_aggregate=SUM"
  "ts2'", "system.if.bytes.out", "colo=lga", "_aggregate=COUNT"
  "ts3'", "system.if.bytes.out", "colo=sjc", "_aggregate=SUM"
  "ts4'", "system.if.bytes.out", "colo=sjc", "_aggregate=SUM"

Notice that these time series have dropped the tags for ``host`` and ``interface``. That's because, during aggregation, multiple, different values of the ``host`` and ``interface`` have been wrapped up into this new series so it no longer makes sense to have them as tags. Also note that we injected the new ``_aggregate`` tag in the stored data. Queries can now access this data by specifying an ``_aggregate`` value.

.. NOTE::
  With rollups enabled, if you plan to use pre-aggregates, you may want to help differentiate raw data from pre-aggregates by having TSDB automatically inject ``_aggregate=RAW``. Just configure the ``tsd.rollups.tag_raw`` setting to true.

Now for the resulting data:

.. csv-table::
  :header: "Series ID", "12:00", "12:15", "12:30", "12:45", "13:00", "13:15", "13:30", "13:45"
  :widths: 20, 10, 10, 10, 10, 10, 10, 10, 10
  
  "ts1'", "8", "6", "5", "-1", "6", "-4", "6", "3"
  "ts2'", "2", "2", "2", "2", "2", "1", "2", "2"
  "ts3'", "9", "5", "3", "1", "14", "8", "4", "9"
  "ts4'", "1", "2", "2", "2", "2", "2", "2", "2"

Since we're performing a group by aggregation (grouping by ``colo``) we have a value for each timestamp from the original data set. We are *not* downsampling or performing a rollup in this situation.

.. WARNING::
  As with rollups, when writing pre-aggregates, it's best to avoid functions such as **average**, **median** or **deviation**. Just store **sum** and **count**

Rolled-up Pre-Aggregates
^^^^^^^^^^^^^^^^^^^^^^^^

While pre-aggregates certainly help with high-cardinality metrics, users may still want to ask for wide time spans but run into slow queries. Thankfully you can roll up a pre-aggregate in the same way as raw data. Just generate the pre-aggregate, then roll it up using the information above.

.. _generating:

Generating Rollups and Pre-Aggregates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Currently the TSDs do not generate the rollup or pre-aggregated data for you. The primary reason for this is that OpenTSDB is meant to handle huge amounts of time series data so individual TSDs are focused on getting their data into storage as quickly as possible. 

Problems
--------

Because of the (essentially) stateless nature of the TSDs, they likely won't have the full set of data available to perform pre-aggregates. E.g., our sample ``ts1`` data may be written to ``TSD_A`` while ``ts2`` is written to ``TSD_B``. Neither can perform a proper group-by without reading the data out of storage. We also don't know at what time we should perform the pre-aggregation. We could wait for 1 minute and pre-aggregate the data but miss anything that came in after that minute. Or we could wait an hour and queries over the pre-aggregates won't have data for the last hour. And what happens if data comes in much later?

Additionally for rollups, depending on how users write data to TSDs, for ``ts1``, we may receive the ``12:15`` data point on ``TSD_A`` but the ``12:30`` value arrives on ``TSD_B`` so neither has the data required for the full hour. Time windowing constraints also apply to rollups.

Solutions
---------

Using rollups and pre-aggregates require some analysis and a choice between various trade-offs. Since some OpenTSDB users already have means in place for calculating this kind of data, we simply provide the API to store and query. However here are some tips on how to compute these on your own.

**Batch Processing**

One method that is commonly used by other time series databases is to read the data out of the database after some delay, calculate the pre-aggs and rollups, then write them. This is the easiest way of solving the problem and works well at small scales. However there are still a number of issues:

* As data grows, queries for generating the rollups grow as well to the point where the query load impacts write and user query performance. OpenTSDB runs into this same problem when data compactions are enabled under HBase.
* Also as data grows, more data means the batch processing time takes longer and must be sharded across multiple workers which can be a pain to coordinate and troubleshoot.
* Late or historical data may not be rolled up unless some means of tracking is in place to trigger a new batch on old data.

Some methods of improving batch processing include:

* Reading from replicated systems, e.g. if you setup HBase replication, you could have users query the master system and aggregations read from the replicated store.
* Read from alternate stores. One example is to mirror all data to another store such as HDFS and run batch jobs against that data.

**Queueing on TSDs**

Another option that some databases use is to queue all of the data in memory in the process and write the results after a configured time window has passed. But because TSDs are stateless and generally users put a load balancer in front of their TSDs, a single TSD may not get the full picture of the rollup or pre-agg to be calculated (as we mentioned above). For this method to work, upstream collectors would have to route all of the data required for a calculation to a specific TSD. It's not a difficult task but the problems faced include:

* Having enough RAM or disk space to spool the data locally on for each TSD.
* If a TSD process dies, you'll either loose the data for the aggregation or it must be bootstrapped from storage.
* Whenever the aggregation calculations are taking place, overall write throughput of the raw data can be affected.
* You still have the late/historical data issue.
* Since TSDB is JVM based, keeping all of that data in RAM and then running GC will hurt. A lot. (spooling to disk is better, but then you'll hit IO issues)

In general, queueing on a writer is a bad idea. Avoid the pain.

**Stream Processing**

A better way of dealing with rollups and pre-aggregates is to route the data into a stream processing system where it can be processed in near-real-time and written to the TSDs. It's similar to the *Queuing on TSDs* option but using one of the myriad stream processing frameworks (Storm, Flink, Spark, etc.) to handle message routing and in-memory storage. Then you simply write some code to compute the aggregates and spit the data out after a window has passed.

This is the solution used by many next-generation monitoring solutions such as that at Yahoo!. Yahoo is working to open source their stream processing system for others who need monitoring at massive scales and it plugs neatly into TSDB.

While stream processing is better you still have problems to deal with such as:

* Enough resources for the stream workers to do their job.
* A dead stream worker requires bootstrapping from storage.
* Late/historical data must be handled.

**Share**

If you have working code for calculating aggregations, please share with the OpenTSDB group. If your solution is open-source we may be able to incorporate it in the OpenTSDB ecosystem.

Configuration
^^^^^^^^^^^^^

.. _rollup_configuration:

For Opentsdb 2.4, the rollup configuration is referenced by the opentsdb.conf key ``tsd.rollups.config``. The value of this key must either but a quote-escaped JSON string without newlines or, preferably, the path to a JSON file containing the configuration. The file name must end with ``.json`` as in ``rollup_config.json``. 

The JSON configuration should look something like this:

.. code-block :: javascript
  
  {
  	"aggregationIds": {
  		"sum": 0,
  		"count": 1,
  		"min": 2,
  		"max": 3
  	},
  	"intervals": [{
  		"table": "tsdb",
  		"preAggregationTable": "tsdb-preagg",
  		"interval": "1m",
  		"rowSpan": "1h",
  		"defaultInterval": true
  	}, {
  		"table": "tsdb-rollup-1h",
  		"preAggregationTable": "tsdb-rollup-preagg-1h",
  		"interval": "1h",
  		"rowSpan": "1d"
  	}]
  }

The two top level fields include:

* **aggregationIds** - A map of OpenTSDB aggregation function names to numeric identifiers used for compressed storage.
* **intervals** - A list of one or more interval definitions containing table names and interval definitions.

aggregationIds
--------------

The aggregation ids map is used for reducing storage by prepending each type of rolled up data with the numeric ID instead of spelling out the full aggregation function. E.g. if we prefixed every column with ``COUNT:`` that's 6 bytes for every value (or compacted column) that we can save using an ID.

IDs must be integers from 0 to 127. This means we can store up to 128 different rollups per interval. Only one ID of each numeric value may be provided in the map and only one aggregation function of each type can be given. If a function name does not map to an aggregation function supported by OpenTSDB, an exception will be thrown on start up. Likewise, at least one aggregation must be given for a TSD to start.

.. WARNING:: The aggregation IDs cannot be changed once you start writing data. If you change mappings, the incorrect data may be returned or queries and writes may fail. You can always add functions in the future but never, ever change the mappings.

intervals
---------

Each interval object defines table routing for where rollup and pre-aggregate data should be written to and queried from. There are two types of intervals:

* **Default** - This is the default, *raw* data OpenTSDB table defined by ``"defaultInterval":true``. For existing installations, this would be the ``tsdb`` table or whatever is defined in ``tsd.storage.hbase.data_table``. Intervals and spans are ignored, defaulting to the OpenTSDB 1 hour row width and storing data with the resolution and timestamp given. Each TSD and configuration can have *only one* default configured at a time.
* **Rollup Interval** - Any interval with ``"defaultInterval":false`` or the default interval not set. These are rollup tables where values are snapped to interval boundaries.

The following fields should be defined:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Example"
   :widths: 15, 10, 5, 55, 15
   
   "table", "String", "Required", "The base or rollup table for non-pre-aggregated data. For the default table, this should be ``tsdb`` or the table existing raw data is written to. For rolled up data, it must be a different table than the raw data.", "tsdb-rollup-1h"
   "preAggregationTable", "String", "Required", "The table where pre-aggregated and (optionally) rolled up data should be written to. This may be the same table as the ``table`` value.", "tsdb-rollup-preagg-1h"
   "interval", "String", "Required", "The expected interval between data points in the format ``<interval><units>``. E.g. if rollups are computed every hour, the interval should be ``1h``. If they are computed every 10 minutes, set it to ``10m``. For the default table, this value is ignored.", "1h"
   "rowSpan", "String", "Required", "The width of each row in storage. This value must be greater than the ``interval`` and defines the number of ``interval``s that will fit in each row. E.g. if the interval is ``1h`` and ``rowSpan`` is ``1d`` then we would have 24 values per row.", "1d"
   "defaultInterval", "Boolean", "Optional", "Whether or not the configured interval is the default for raw, non-rolled up data.", "true"

In storage, rollups are written similar to the raw data in that each row has a base timestamp and each data point is an offset from that base time. Each offset is an increment off of the base time, not an actual offset. For example, if a row stores 1 day of 1 hour data, there would be up to 24 offsets. Offset ``0`` would map to midnight for the row and offset 5 would map to 6 AM. Because rollup offsets are encoded on 14 bits, if too many intervals would be stored in a row to fit within 14 bits, an error will be thrown when the TSD is started. 

.. WARNING:: After writing data to a TSD, do **NOT** change the interval widths or row spans for rollup intervals. This will result in garbage data and possibly failed queries.