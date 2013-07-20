Configuration
-------------

OpenTSDB can be configured via a file on the local system, via command line arguments or a combination or both. 

Configuration File
^^^^^^^^^^^^^^^^^^

The configuration file conforms to the Java properties specification. Configuration names are lower-case, dotted strings without spaces. Each name is followed by an equals sign, then the value for the property. All OpenTSDB properties start with "tsd." Comments or inactive configuration lines are blocked by a hash symbol "#". For example::

  # List of Zookeeper hosts that manage the HBase cluster
  tsd.storage.hbase.zk_quorum - 192.168.1.100
  
will configure the TSD to connect to "192.168.1.100" for HBase storage access.

When combining configuration files and command line arguments, the order of processing is as follows:

#. Default values are loaded
#. Configuration file values are loaded, overriding default values
#. Command line parameters are loaded, overriding config file and default values 

File Locations
^^^^^^^^^^^^^^

You can use the ``--config`` command line argument to specify the full path to a configuration file. Otherwise if not specified, OpenTSDB and some of the commandline tools will attempt to search for a valid configuration file in the following locations:

* ./opentsdb.conf
* /etc/opentsdb.conf
* /etc/opentsdb/opentsdb.conf
* /opt/opentsdb/opentsdb.conf

In the event that a valid configuration file cannot be found and the required properties are not set, the TSD will not start. Please see the properties table below for a list of required configuration settings.

Properties
^^^^^^^^^^

The following is a table of configuration options for all tools. When applicable, the corresponding command line override is provided. Please note that individual command line tools may have their own values so see their documentation for details.

.. csv-table::
   :header: "Property", "Type", "Required", "Description", "Default", "CLI"
   :widths: 20, 5, 5, 55, 5, 10

   "tsd.core.auto_create_metrics", "Boolean", "Optional", "Whether or not new, incoming metrics will automatically create a new UID. When false, a metric that doesn't match an existing UID will be rejected and will not be written to storage. Tag names and tag values are always created automatically.", "False", "--auto-metric"
   "tsd.core.meta.enable_tracking", "Boolean", "Optional", "Whether or not to enable real-time metadata tracking/creation. See :doc:`../user_guide/metadata`", "False", ""
   "tsd.core.plugin_path", "String", "Optional", "A path to search for plugins when the TSD starts. If the path is invalid, the TSD will fail to start. Plugins can still be enabled if they are in the class path.", "", ""
   "tsd.core.timezone", "String", "Optional", "A localized timezone identification string used to override the local system timezone used when converting absolute times to UTC when executing a query. This does not affect incoming data timestamps.
   E.g. America/Los_Angeles", "System Configured", ""
   "tsd.core.tree.enable_processing", "Boolean", "Optional", "Whether or not to enable processing new/edited TSMeta through tree rule sets", "false", ""
   "tsd.http.cachedir", "String", "Required", "The full path to a location where temporary files can be written.
   E.g. /tmp/opentsdb", "", "--cachedir"
   "tsd.http.request.cors_domains", "String", "Optional", "A comma separated list of domain names to allow access to OpenTSDB when the ``Origin`` header is specified by the client. If empty, CORS requests are passed through without validation. The list may not contain the public wildcard ``*`` and specific domains at the same time.", "", ""
   "tsd.http.request.enable_chunked", "Boolean", "Optional", "Whether or not to enable incoming chunk support for the HTTP RPC", "false", ""
   "tsd.http.request.max_chunk", "Integer", "Optional", "The maximum chunk size to support for incoming HTTP requests.", "4096", ""
   "tsd.http.show_stack_trace", "Boolean", "Optional", "Whether or not to return the stack trace with an API query response when an exception occurs.", "false", ""
   "tsd.http.staticroot", "String", "Required", "Location of a directory where static files, such as javascript files for the web interface, are located.
   E.g. /opt/opentsdb/staticroot", "", "--staticroot"
   "tsd.network.async_io", "Boolean", "Optional", "Whether or not to use NIO or tradditional blocking IO", "True", "--async-io"
   "tsd.network.backlog", "Integer", "Optional", "The connection queue depth for completed or incomplete connection requests depending on OS. The default may be limited by  the 'somaxconn' kernel setting or set by Netty to 3072.", "See Description", "--backlog"
   "tsd.network.bind", "String", "Optional", "An IPv4 address to bind to for incoming requests. The default is to listen on all interfaces.
   E.g. 127.0.0.1", "0.0.0.0", "--bind"
   "tsd.network.keep_alive", "Boolean", "Optional", "Whether or not to allow keep-alive connections", "True", ""
   "tsd.network.port", "Integer", "Required", "The TCP port to use for accepting connections", "", "--port"
   "tsd.network.reuse_address", "Boolean", "Optional", "Whether or not to allow reuse of the bound port within Netty", "True", ""
   "tsd.network.tcp_no_delay", "Boolean", "Optional", "Whether or not to disable TCP buffering before sending data", "True", ""
   "tsd.network.worker_threads", "Integer", "Optional", "The number fo asynchronous IO worker threads for Netty", "*#CPU cores \* 2*", "--worker-threads"
   "tsd.rpc.plugins", "String", "Optional", "A comma delimited list of RPC plugins to load when starting a TSD. Must contain the entire class name.", "", ""
   "tsd.rtpublisher.enable", "Boolean", "Optional", "Whether or not to enable a real time publishing plugin. If true, you must supply a valid ``tsd.rtpublisher.plugin`` class name", "False", ""
   "tsd.rtpublisher.plugin", "String", "Optional", "The class name of a real time publishing plugin to instantiate. If ``tsd.rtpublisher.enable`` is set to false, this value is ignored.
   E.g. net.opentsdb.tsd.RabbitMQPublisher", "", ""
   "tsd.search.enable", "Boolean", "Optional", "Whether or not to enable search functionality. If true, you must supply a valid ``tsd.search.plugin`` class name", "False", ""
   "tsd.search.plugin", "String", "Optional", "The class name of a search plugin to instantiate. If ``tsd.search.enable`` is set to false, this value is ignored.
   E.g. net.opentsdb.search.ElasticSearch", "", ""
   "tsd.stats.canonical", "Boolean", "Optional", "Whether or not the FQDN should be returned with statistics requests. The default stats are returned with ""host=<hostname>"" which is not gauranteed to perform a lookup and return the FQDN. Setting this to true will perform a name lookup and return the fqdn if found, otherwise it may return the IP. The stats output should be ""fqdn=<hostname""", "false", ""
   "tsd.storage.enable_compaction", "Boolean", "Optional", "Whether or not to enable compactions", "True", ""
   "tsd.storage.flush_interval", "Integer", "Optional", "How often, in milliseconds, to flush the data point storage write buffer", "1000", "--flush-interval"
   "tsd.storage.hbase.data_table", "String", "Optional", "Name of the HBase table where data points are stored", "tsdb", "--table"
   "tsd.storage.hbase.uid_table", "String", "Optional", "Name of the HBase table where UID information is stored", "tsdb-uid", "--uidtable"
   "tsd.storage.hbase.zk_basedir", "String", "Optional", "Path under which the znode for the -ROOT- region is located", "/hbase", "--zkbasedir"
   "tsd.storage.hbase.zk_quorum", "String", "Optional", "A space separated list of Zookeeper hosts to connect to, with or without port specifiers.
   E.g. 192.168.1.1:2181 192.168.1.2:2181", "localhost", "--zkquorum"
   
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