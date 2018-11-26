Configuration
-------------
.. index:: Configuration
OpenTSDB can be configured via a file on the local system, via command line
arguments or a combination or both.

Configuration File
^^^^^^^^^^^^^^^^^^
.. index:: Config File
The configuration file conforms to the Java properties specification.
Configuration names are lower-case, dotted strings without spaces. Each name
is followed by an equals sign, then the value for the property. All OpenTSDB
properties start with ``tsd.`` Comments or inactive configuration lines are
blocked by a hash symbol ``#``. For example::

  # List of Zookeeper hosts that manage the HBase cluster
  tsd.storage.hbase.zk_quorum = 192.168.1.100
  
will configure the TSD to connect to Zookeeper on ``192.168.1.100``.

When combining configuration files and command line arguments, the order of
processing is as follows:

#. Default values are loaded
#. Configuration file values are loaded, overriding default values
#. Command line parameters are loaded, overriding config file and default values 

File Locations
^^^^^^^^^^^^^^
.. index:: Config Locations
You can use the ``--config`` command line argument to specify the full path to
a configuration file. Otherwise if not specified, OpenTSDB and some of the
command-line tools will attempt to search for a valid configuration file in
the following locations:

* ./opentsdb.conf
* /etc/opentsdb.conf
* /etc/opentsdb/opentsdb.conf
* /opt/opentsdb/opentsdb.conf

In the event that a valid configuration file cannot be found and the required
properties are not set, the TSD will not start. Please see the properties
table below for a list of required configuration settings.

Properties
^^^^^^^^^^

The following is a table of configuration options for all tools. When
applicable, the corresponding command line override is provided. Please note
that individual command line tools may have their own values so see their
documentation for details.

.. NOTE::

  For additional parameters used for tuning the AsyncHBase client, see `AsyncHBase Configuration <http://opentsdb.github.io/asynchbase/docs/build/html/configuration.html>`_

.. csv-table::
   :header: "Property", "Type", "Required", "Description", "Default", "CLI"
   :widths: 20, 5, 5, 55, 5, 10

   "tsd.core.auto_create_metrics", "Boolean", "Optional", "Whether or not a data point with a new metric will assign a UID to the metric. When false, a data point with a metric that is not in the database will be rejected and an exception will be thrown.", "False", "--auto-metric"
   "tsd.core.auto_create_tagks *(2.1)*", "Boolean", "Optional", "Whether or not a data point with a new tag name will assign a UID to the tagk. When false, a data point with a tag name that is not in the database will be rejected and an exception will be thrown.", "True", ""
   "tsd.core.auto_create_tagvs *(2.1)*", "Boolean", "Optional", "Whether or not a data point with a new tag value will assign a UID to the tagv. When false, a data point with a tag value that is not in the database will be rejected and an exception will be thrown.", "True", ""
   "tsd.core.connections.limit *(2.3)*", "Integer", "Optional", "Sets the maximum number of connections a TSD will handle, additional connections are immediately closed.", "0", ""
   "tsd.core.enable_api *(2.3)*", "Boolean", "Optional", "Whether or not to allow the 2.x HTTP API to function. When disabled, calls to endpoints such as ``/api/query`` or ``/api/suggest`` will return a 404.", "True", "--disable-api"
   "tsd.core.enable_ui *(2.3)*", "Boolean", "Optional", "Whether or not to allow the built-in GUI and legacy HTTP API to function. When disabled, calls to the root endpoint or other such as ``/logs`` or ``/suggest`` will return a 404.", "True", "--disable-ui"
   "tsd.core.histograms.config *(2.4)*", "JSON/File Path", "Optional", "A mapping of histogram codec class names to numeric identifications for storing multi-measurement data. For simple configurations, the value may be a quote-escaped JSON map, e.g. ``{\""net.opentsdb.core.SimpleHistogramDecoder\"": 0,\""net.opentsdb.core.CompactQuantilesSketchCodec\"":1}``. If the value ends with ``.json`` then it will be treated as a file path and the given file will be opened and parsed. Numeric IDs must be between 0 and 255.", "", ""
   "tsd.core.meta.cache.enable *(2.3)*", "Boolean", "Optional", "Whether or not the meta data caching plugin is enabled.", "False", "True"
   "tsd.core.meta.cache.plugin *(2.3)*", "String", "Optional", "The class name of a plugin implementing the meta cache interface.", "", ""
   "tsd.core.meta.enable_realtime_ts", "Boolean", "Optional", "Whether or not to enable real-time TSMeta object creation. See :doc:`../user_guide/metadata`", "False", ""
   "tsd.core.meta.enable_realtime_uid", "Boolean", "Optional", "Whether or not to enable real-time UIDMeta object creation. See :doc:`../user_guide/metadata`", "False", ""
   "tsd.core.meta.enable_tsuid_incrementing", "Boolean", "Optional", "Whether or not to enable tracking of TSUIDs by incrementing a counter every time a data point is recorded. See :doc:`../user_guide/metadata` (Overrides ""tsd.core.meta.enable_tsuid_tracking"")", "False", ""
   "tsd.core.meta.enable_tsuid_tracking", "Boolean", "Optional", "Whether or not to enable tracking of TSUIDs by storing a ``1`` with the current timestamp every time a data point is recorded. See :doc:`../user_guide/metadata`", "False", ""
   "tsd.core.plugin_path", "String", "Optional", "A path to search for plugins when the TSD starts. If the path is invalid, the TSD will fail to start. Plugins can still be enabled if they are in the class path.", "", ""
   "tsd.core.preload_uid_cache *(2.1)*", "Boolean", "Optional", "Enables pre-population of the UID caches when starting a TSD.", "False", ""
   "tsd.core.preload_uid_cache.max_entries *(2.1)*", "Integer", "Optional", "The number of rows to scan for UID pre-loading.", "300,000", ""
   "tsd.core.stats_with_port *(2.3)*", "Boolean", "Optional", "Whether or not to export the listening network port of the TSD as a tag with stats when calling one of the stats endpoints.", "False", "True"
   "tsd.core.storage_exception_handler.enable *(2.2)*", "Boolean", "Optional", "Whether or not to enable the configured storage exception handler plugin.", "False", ""
   "tsd.core.storage_exception_handler.plugin *(2.2)*", "String", "Optional", "The full class name of the storage exception handler plugin you wish to use.", "", ""
   "tsd.core.tag.allow_specialchars *(2.3)*", "String", "Optional", "An optional list of ASCII characters allowed in metric names, tag names and tag keys above those already allowed by TSDB. Spaces are allowed.", "", "! ~/\"
   "tsd.core.timezone", "String", "Optional", "A localized timezone identification string used to override the local system timezone used when converting absolute times to UTC when executing a query. This does not affect incoming data timestamps.
   E.g. America/Los_Angeles", "System Configured", ""
   "tsd.core.tree.enable_processing", "Boolean", "Optional", "Whether or not to enable processing new/edited TSMeta through tree rule sets", "false", ""
   "tsd.core.uid.random_metrics *(2.2)*", "Boolean", "Optional", "Whether or not to randomly assign UIDs to new metrics as they are created", "false", ""
   "tsd.core.bulk.allow_out_of_order_timestamps *(2.3)", "Boolean", "Optional", "Whether or not to allow out-of-order values when bulk importing data from a text file.", "false", ""
   "tsd.core.authentication.enable *(2.4)", "Boolean", "Optional", "Whether or not to enable the specified Authentication plugin", "false", ""
   "tsd.core.authentication.plugin *(2.4)", "String", "Optional", "The class name of an authentication plugin to instantiate. If ``tsd.core.authentication.enable`` is set to false, this value is ignored.", "", ""
   "tsd.http.cachedir", "String", "Required", "The full path to a location where temporary files can be written.
   E.g. /tmp/opentsdb", "", "--cachedir"
   "tsd.http.query.allow_delete", "Boolean", "Optional", "Whether or not to allow deleting data points from storage during query time.", "False", ""
   "tsd.query.enable_fuzzy_filter", "Boolean", "Optional", "Whether or not to enable the FuzzyRowFilter for HBase when making queries using the ``explicitTags`` flag.", "True", ""
   "tsd.http.header_tag *(2.4)*", "String", "Optional", "An optional HTTP header that, when passed to the HTTP /api/put API, will be extracted and added to the tags of the values posted with the content. Must match an HTTP header exactly.", "", "X-CustomTag"
   "tsd.http.request.cors_domains", "String", "Optional", "A comma separated list of domain names to allow access to OpenTSDB when the ``Origin`` header is specified by the client. If empty, CORS requests are passed through without validation. The list may not contain the public wildcard ``*`` and specific domains at the same time.", "", ""
   "tsd.http.request.cors_headers *(2.1)*", "String", "Optional", "A comma separated list of headers sent to clients when executing a CORs request. The literal value of this option will be passed to clients.", "Authorization, Content-Type, Accept, Origin, User-Agent, DNT, Cache-Control, X-Mx-ReqToken, Keep-Alive, X-Requested-With, If-Modified-Since", ""
   "tsd.http.request.enable_chunked", "Boolean", "Optional", "Whether or not to enable incoming chunk support for the HTTP RPC", "false", ""
   "tsd.http.request.max_chunk", "Integer", "Optional", "The maximum request body size to support for incoming HTTP requests when chunking is enabled.", "4096", ""
   "tsd.http.rpc.plugins *(2.2)*", "String", "Optional", "A comma delimited list of RPC plugins to load when starting a TSD. Must contain the entire class name.", "", ""
   "tsd.http.show_stack_trace", "Boolean", "Optional", "Whether or not to return the stack trace with an API query response when an exception occurs.", "false", ""
   "tsd.http.staticroot", "String", "Required", "Location of a directory where static files, such as JavaScript files for the web interface, are located.
   E.g. /opt/opentsdb/staticroot", "", "--staticroot"
   "tsd.mode *(2.1)*", "String", "Optional", "Whether or not the TSD will allow writing data points. Must be either ``rw`` to allow writing data or ``ro`` to block data point writes. Note that meta data such as UIDs can still be written/modified.", "rw", ""
   "tsd.network.async_io", "Boolean", "Optional", "Whether or not to use NIO or traditional blocking IO", "True", "--async-io"
   "tsd.network.backlog", "Integer", "Optional", "The connection queue depth for completed or incomplete connection requests depending on OS. The default may be limited by  the 'somaxconn' kernel setting or set by Netty to 3072.", "See Description", "--backlog"
   "tsd.network.bind", "String", "Optional", "An IPv4 address to bind to for incoming requests. The default is to listen on all interfaces.
   E.g. 127.0.0.1", "0.0.0.0", "--bind"
   "tsd.network.keep_alive", "Boolean", "Optional", "Whether or not to allow keep-alive connections", "True", ""
   "tsd.network.port", "Integer", "Required", "The TCP port to use for accepting connections", "", "--port"
   "tsd.network.reuse_address", "Boolean", "Optional", "Whether or not to allow reuse of the bound port within Netty", "True", ""
   "tsd.network.tcp_no_delay", "Boolean", "Optional", "Whether or not to disable TCP buffering before sending data", "True", ""
   "tsd.network.worker_threads", "Integer", "Optional", "The number of asynchronous IO worker threads for Netty", "*#CPU cores \* 2*", "--worker-threads"
   "tsd.no_diediedie *(2.1)*", "Boolean", "Optional", "Enable or disable the ``diediedie`` HTML and ASCII commands to shutdown a TSD.", "False", ""
   "tsd.query.allow_simultaneous_duplicates *(2.2)*", "Boolean", "Optional", "Whether or not to allow simultaneous duplicate queries from the same host. If disabled, a second query that comes in matching one already running will receive an exception.", "False", ""
   "tsd.query.filter.expansion_limit *(2.2)*", "Integer", "Optional", "The maximum number of tag values to include in the regular expression sent to storage during scanning for data. A larger value means more computation on the HBase region servers.", "4096", ""
   "tsd.query.limits.bytes.allow_override, *(2.4)*", "Boolean", "Optional", "Whether or not the query byte limiter can be overiden on a per-query basis.", "False", "True"
   "tsd.query.limits.bytes.default *(2.4)*", "Integer", "Optional", "A limit on the number of bytes fetched from storage. When this limit is hit, the query will return with an exception. A value of `0` disables the limitter.", "0", "268435456" 
   "tsd.query.limits.data_points.allow_override *(2.4)*", "Boolean", "Optional", "Whether or not the query data point limiter can be overiden on a per-query basis.", "False", "True"
   "tsd.query.limits.data_points.default *(2.4)*", "Integer", "Optional", "A limit on the number of data points fetched from storage. When this limit is hit, the query will return with an exception. A value of `0` disables the limiter.", "0", "1000000"
   "tsd.query.limits.overrides.interval *(2.4)*", "Integer", "Optional", "How often, in milliseconds, to reload the byte and data point query limiter plugin configuration.", "60000", ""
   "tsd.query.limits.overrides.config *(2.4)*", "JSON/File Path", "Optional", "The path or full config of a query limit configuration with options to match on metric names.", "", ""
   "tsd.query.multi_get.enable *(2.4)*", "Boolean", "Optional", "Whether or not multi-get queries are enabled in conjunction with the search plugin.", "False", "True"
   "tsd.query.multi_get.batch_size *(2.4)*", "Integer", "Optional", "The number of `get` requests sent to storage in a single request.", "1024", ""
   "tsd.query.multi_get.concurrent *(2.4)*", "Integer", "Optional", "The number of simultaneous batches outstanding at any given time for multi-get queries.", "20", ""
   "tsd.query.multi_get.get_all_salts *(2.4)*", "Boolean", "Optional", "Whether or not a get request is fired for every bucket of salt or if the proper bucket is calculated. Used when salting configurations have changed.", "False", "True"
   "tsd.query.skip_unresolved_tagvs *(2.2)*", "Boolean", "Optional", "Whether or not to continue querying when the query includes a tag value that hasn't been assigned a UID yet and may not exist.", "False", ""
   "tsd.query.timeout *(2.2)*", "Integer", "Optional", "How long, in milliseconds, before canceling a running query. A value of 0 means queries will not timeout.", "0", ""
   "tsd.rollups.config *(2.4)*", "String", "Optional", "The path to a configuration file detailing available rollup tables and aggregations. Must set ``tsd.rollups.enable`` to ``true`` for this option to be parsed. See :doc:`rollups`", "", "rollup_config.json"
   "tsd.rollups.enable *(2.4)*", "Boolean", "Optional", "Whether or not to enable rollup and pre-aggregation storage and writing.", "false", ""
   "tsd.rollups.tag_raw *(2.4)*", "Boolean", "Optional", "Whether or not to tag non-rolled-up and non-pre-aggregated values with the tag key configured in ``tsd.rollups.agg_tag_key`` and value configured in ``tsd.rollups.raw_agg_tag_value``", "false", ""
   "tsd.rollups.agg_tag_key *(2.4)*", "String", "Optional", "A special key to tag pre-aggregated data with when writing to storage", "_aggregate", ""
   "tsd.rollups.raw_agg_tag_value *(2.4)*", "String", "Optional", "A special tag value to non-rolled-up and non-pre-aggregated data with when writing to storage. ``tsd.rollups.tag_raw`` must be set to true.", "RAW", ""
   "tsd.rollups.block_derived *(2.4)*", "Boolean", "Optional", "Whether or not to block storing derived aggregations such as ``AVG`` and ``DEV``.", "true", ""
   "tsd.rpc.plugins", "String", "Optional", "A comma delimited list of RPC plugins to load when starting a TSD. Must contain the entire class name.", "", ""
   "tsd.rpc.telnet.return_errors *(2.4)*", "Boolean", "Optional", "Whether or not to return errors to the Telnet style socket when writing data via ``put`` or ``rollup``", "true", ""
   "tsd.rtpublisher.enable", "Boolean", "Optional", "Whether or not to enable a real time publishing plugin. If true, you must supply a valid ``tsd.rtpublisher.plugin`` class name", "False", ""
   "tsd.rtpublisher.plugin", "String", "Optional", "The class name of a real time publishing plugin to instantiate. If ``tsd.rtpublisher.enable`` is set to false, this value is ignored.
   E.g. net.opentsdb.tsd.RabbitMQPublisher", "", ""
   "tsd.search.enable", "Boolean", "Optional", "Whether or not to enable search functionality. If true, you must supply a valid ``tsd.search.plugin`` class name", "False", ""
   "tsd.search.plugin", "String", "Optional", "The class name of a search plugin to instantiate. If ``tsd.search.enable`` is set to false, this value is ignored.
   E.g. net.opentsdb.search.ElasticSearch", "", ""
   "tsd.stats.canonical", "Boolean", "Optional", "Whether or not the FQDN should be returned with statistics requests. The default stats are returned with ``host=<hostname>`` which is not guaranteed to perform a lookup and return the FQDN. Setting this to true will perform a name lookup and return the FQDN if found, otherwise it may return the IP. The stats output should be ``fqdn=<hostname>``", "false", ""
   "tsd.startup.enable *(2.3)*", "Boolean", "Optional", "Whether or not a startu plugin should be loaded before the TSD.", "False", "True"
   "tsd.startup.plugin *(2.3)*", "String", "Optional", "The name of a plugin implementing the `StartupPlugin` interface.", "", ""
   "tsd.storage.compaction.flush_interval *(2.2)*", "Integer", "Optional", "How long, in seconds, to wait in between compaction queue flush calls", "10", ""
   "tsd.storage.compaction.flush_speed *(2.2)*", "Integer", "Optional", "A multiplier used to determine how quickly to attempt flushing the compaction queue. E.g. a value of 2 means it will try to flush the entire queue within 30 minutes. A value of 1 would take an hour.", "2", ""
   "tsd.storage.compaction.max_concurrent_flushes *(2.2)*", "Integer", "Optional", "The maximum number of compaction calls inflight to HBase at any given time", "10000", ""
   "tsd.storage.compaction.min_flush_threshold *(2.2)*", "Integer", "Optional", "Size of the compaction queue that must be exceeded before flushing is triggered", "100", "" 
   "tsd.storage.enable_appends *(2.2)*", "Boolean", "Optional", "Whether or not to append data to columns when writing data points instead of creating new columns for each value. Avoids the need for compactions after each hour but can use more resources on HBase.", "False", ""
   "tsd.storage.enable_compaction", "Boolean", "Optional", "Whether or not to enable compactions", "True", ""
   "tsd.storage.fix_duplicates *(2.1)*", "Boolean", "Optional", "Whether or not to accept the last written value when parsing data points with duplicate timestamps. When enabled in conjunction with compactions, a compacted column will be written with the latest data points.", "False", ""
   "tsd.storage.flush_interval", "Integer", "Optional", "How often, in milliseconds, to flush the data point storage write buffer", "1000", "--flush-interval"
   "tsd.storage.get_date_tiered_compaction_start", "Integer", "Optional", "A Unix Epoch timestamp in milliseconds when date tierd compactions were enabled on the HBase table. This is useful for existing OpenTSDB installations moving to DTC. Queries starting before this time period will not set time boundaries on queries. See :ref:`date_tierd_compaction`.", "0", "1514764800000"
   "tsd.storage.hbase.data_table", "String", "Optional", "Name of the HBase table where data points are stored", "tsdb", "--table"
   "tsd.storage.hbase.meta_table", "String", "Optional", "Name of the HBase table where meta data are stored", "tsdb-meta", ""
   "tsd.storage.hbase.prefetch_meta *(2.2)*", "Boolean", "Optional", "Whether or not to prefetch the regions for the TSDB tables before starting the network interface. This can improve performance.", "False", ""
   "tsd.storage.hbase.scanner.maxNumRows *(2.3)*", "Integer", "Optional", "The maximum number of rows to fetch from HBase per call to the scanner's `nextRows()` method.", "128", "4096"
   "tsd.storage.hbase.tree_table", "String", "Optional", "Name of the HBase table where tree data are stored", "tsdb-tree", ""
   "tsd.storage.hbase.uid_table", "String", "Optional", "Name of the HBase table where UID information is stored", "tsdb-uid", "--uidtable"
   "tsd.storage.hbase.zk_basedir", "String", "Optional", "Path under which the znode for the -ROOT- region is located", "/hbase", "--zkbasedir"
   "tsd.storage.hbase.zk_quorum", "String", "Optional", "A comma-separated list of ZooKeeper hosts to connect to, with or without port specifiers. E.g. ``192.168.1.1:2181,192.168.1.2:2181``", "localhost", "--zkquorum"
   "tsd.storage.repair_appends *(2.2)*", "Boolean", "Optional", "Whether or not to re-write appended data point columns at query time when the columns contain duplicate or out of order data.", "False", ""
   "tsd.storage.max_tags *(2.2)*", "Integer", "Optional", "The maximum number of tags allowed per data point.  **NOTE** Please be aware of the performance tradeoffs of overusing tags :doc:`writing`", "8", ""
   "tsd.storage.salt.buckets *(2.2)*", "Integer", "Optional", "The number of salt buckets used to distribute load across regions. **NOTE** Changing this value after writing data may cause TSUID based queries to fail.", "20", ""
   "tsd.storage.salt.width *(2.2)*", "Integer", "Optional", "The width, in bytes, of the salt prefix used to indicate which bucket a time series belongs in. A value of 0 means salting is disabled. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "0", ""
   "tsd.timeseriesfilter.enable *(2.3)*", "Boolean", "Optional", "Whether or not the data writing filter plugins are enabled.", "False", "True"
   "tsd.timeseriesfilter.plugin *(2.3)*", "String", "Optional", "The class path to a plugin that implements the `WriteableDataPointFilterPlugin` interface for filtering time series on writes.", "", ""
   "tsd.storage.uid.width.metric *(2.2)*", "Integer", "Optional", "The width, in bytes, of metric UIDs. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "3", ""
   "tsd.storage.uid.width.tagk *(2.2)*", "Integer", "Optional", "The width, in bytes, of tag name UIDs. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "3", ""
   "tsd.storage.uid.width.tagv *(2.2)*", "Integer", "Optional", "The width, in bytes, of tag value UIDs. **WARNING** Do not change after writing data to HBase or you will corrupt your tables and not be able to query any more.", "3", ""
	"tsd.storage.use_max_value *(2.4)*", "Boolean", "Optional", "Whether or not to choose the larger numeric value during TSDB compaction when duplicates are found and `tsd.storage.use_otsdb_timestamp` has been set to `true`.", "True", "False"
   "tsd.storage.use_otsdb_timestamp *(2.4)*", "Boolean", "Optional", "Uses the data point's timestamp for the edits in storage instead of the default `now`. See :ref:`date_tierd_compaction`.", "False", "True"
   "tsd.uidfilter.enable *(2.3)*", "Boolean", "Optional", "Whether or not the UID assignment plugin filter is enabled.", "False", "True"
   "tsd.uidfilter.plugin *(2.3)*", "String", "Optional", "A plugin implementing the `UniqueIdFilterPlugin` interface.", "", ""
   "tsd.uid.lru.enable *(2.4)*", "Boolean", "Optional", "Changes the UID caches from unbounded maps to LRU caches.", "False", "True"
   "tsd.uid.lru.id.size *(2.4)*", "Integer", "Optional", "The total number of entries in the reverse UID to string map. Multiply this by 3 to get the total number of entries available, one per UID type (metric, tag key, tag value).", "5000000", "1000000"
   "tsd.uid.lru.name.size *(2.4)*", "Integer", "Optional", "The total number of entries in the forward string to UID map. Multiply this by 3 to get the total number of entries available, one per UID type (metric, tag key, tag value).", "5000000", "1000000"
   "tsd.uid.use_mode *(2.4)*", "Boolean", "Optional", "Determines if the name and/or ID caches should be populated based on the `tsd.mode` setting. ", "False", "True"
   
Data Types
^^^^^^^^^^

Some configuration values require special consideration:

* Booleans - The following literals will parse to ``True``:

  * ``1``
  * ``true``
  * ``yes``
  
  Any other values will result in a ``False``. Parsing is case insensitive
  
* Strings - Strings, even those with spaces, do not require quotation marks, but some considerations apply:

  * Special characters must be escaped with a backslash include: ``#``, ``!``, ``=``, and ``:``
    E.g.::
    
      my.property = Hello World\!
      
  * Unicode characters must be escaped with their hexadecimal representation, e.g.::
  
      my.property = \u0009
