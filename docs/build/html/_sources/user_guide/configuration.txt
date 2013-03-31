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
   :header: "Property", "Type", "Required", "Description", "Default", "CLI", "Example"
   :widths: 20, 5, 5, 40, 5, 10, 15

   "tsd.core.auto_create_metrics", "Boolean", "Optional", "Whether or not new, incoming metrics will automatically create a new UID. When false, a metric that doesn't match an existing UID will be rejected and will not be written to storage. Tag names and tag values are always created automatically.", "False", "--auto-metric", "True"
   "tsd.core.enable_milliseconds", "Boolean", "Optional", "Whether or not to enable millisecond timestamp support.", "False", "", "True"
   "tsd.core.timezone", "String", "Optional", "A localized timezone identification string used to override the local system timezone used when converting absolute times to UTC when executing a query. This does not affect incoming data timestamps.", "System Configured", "", "America/Los_Angeles"
   "tsd.http.cachedir", "String", "Required", "The full path to a location where temporary files can be written", "", "--cachedir", "/tmp/opentsdb"
   "tsd.http.staticroot", "String", "Required", "Location of a directory where static files, such as javascript files for the web interface, are located", "", "--staticroot", "/opt/opentsdb/staticroot"
   "tsd.network.async_io", "Boolean", "Optional", Whether or not to use NIO or tradditional blocking IO", "True", "--async-io", "False"
   "tsd.network.bind", "String", "Optional", "An IPv4 address to bind to for incoming requests. The default is to listen on all interfaces.", "0.0.0.0", "--bind", "127.0.0.1"
   "tsd.network.keep_alive", "Boolean", "Optional", "Whether or not to allow keep-alive connections", "True", "", "False"
   "tsd.network.port", "Integer", "Required", "The TCP port to use for accepting connections", "", "--port", "4242"
   "tsd.network.reuse_address", "Boolean", "Optional", "Wether or not to allow reuse of the bound port within Netty", "True", "", "False"
   "tsd.network.tcp_no_delay", "Boolean", "Optional", "Whether or not to disable TCP buffering before sending data", "True", "", "False"
   "tsd.network.worker_threads", "Integer", "Optional", "The number fo asynchronous IO worker threads for Netty", "#CPU cores \* 2", "--worker-threads", "15"
   "tsd.storage.enable_compaction", "Boolean", "Optional", "Whether or not to enable compactions", "True", "", "False"
   "tsd.storage.flush_interval", "Integer", "Optional", "How often, in milliseconds, to flush the data point storage write buffer", "1000", "--flush-interval", "500"
   "tsd.storage.hbase.data_table", "String", "Optional", "Name of the HBase table where data points are stored", "tsdb", "--table", "tsdb"
   "tsd.storage.hbase.uid_table", "String", "Optional", "Name of the HBase table where UID information is stored", "tsdb-uid", "--uidtable", "tsdb-uid"
   "tsd.storage.hbase.zk_basedir", "String", "Optional", "Path under which the znode for the -ROOT- region is located", "/hbase", "--zkbasedir", "/hbase"
   "tsd.storage.hbase.zk_quorum", "String", "Optional", "A space separated list of Zookeeper hosts to connect to, with or without port specifiers", "localhost", "--zkquorum", "192.168.1.1:2181 192.168.1.2:2181"
   
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