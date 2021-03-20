Plugin Loading Configuration
============================


OpenTSDB is a flexible time series solution wherein a JVM can be configured as a query router or a data store. Therefore the most important configuration is the module config or `tsd.plugin.config`.

Many modules or plugins are loaded automatically, e.g. aggregators, query nodes like the downsampler or group by. But some modules, like data sources or authentication methods, must be configured by the administrator or they won't load. There are four sections to the `tsd.plugin.config`:

* **configs** - This is a list of one or more plugin configuration definitions that will be loaded in the order they are defined. See the configs section below for details.
* **pluginLocations** - An optional list of directories in which to search for plugins (compiled as `.jar` files).
* **continueOnError** - Whether or not to allow the TSD to startup when an error is encountered trying to load a plugin.
* **loadDefaultInstances** - Whether or not to load default module instances.

Configurations
^^^^^^^^^^^^^^

Each module config entry is a map of keys and values with the following keys available:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "plugin", "String", "Required", "The fully qualified class name of the plugin or module.", "", "net.opentsdb.query.execution.HttpQueryV3Factory"
   "type", "String", "Required", "The fully qualified class name of the type (interface) of plugin or module to be loaded.", "", "net.opentsdb.data.TimeSeriesDataSourceFactory"
   "id", "String", "Optional", "A unique ID, amongst all modules, for the instance of the plugin or module to be instantiated. Must contain only alpha-numeric characters. Only one module can be instantiated with any given ID.", "", "PHXDataCenter"
   "isDefault", "Boolean", "Optional", "Whether or not this instance should be the default instance of it's type. Only one default plugin for each `type` can be instantiated.", "false", "true"

.. Note::

  Each config must include either a non-empty `id` or `isDefault` must be set to true. 

Each module or plugin may have various configurations that are required for it to load properly. These configs can appear in any config source and in any order. The configuration is loaded and flattened prior to module initialization.

If a module has a dependency on another module, make sure the required module is listed *before* the dependent module in the configuration list.

Example
^^^^^^^

In this example we will define two HTTP query factories that communicate with TSDs in two different data centers with unique IDs. We will also declare an HA cluster factory that will route queries to both data centers and merge the responses. This will be the default time series data source.

.. code-block:: yaml

  tsd.plugin.config:
    configs:
      - plugin: net.opentsdb.query.execution.HttpQueryV3Factory
        id: DEN
        type: net.opentsdb.data.TimeSeriesDataSourceFactory

      - plugin: net.opentsdb.query.execution.HttpQueryV3Factory
        id: LON
        type: net.opentsdb.data.TimeSeriesDataSourceFactory
  
      - plugin: net.opentsdb.query.hacluster.HAClusterFactory
        isDefault: true
        type: net.opentsdb.data.TimeSeriesDataSourceFactory
  
    pluginLocations:
    continueOnError: true
    loadDefaultInstances: true
  
  # ------- HA --------
  tsd.query.hacluster.sources: DEN,LON
