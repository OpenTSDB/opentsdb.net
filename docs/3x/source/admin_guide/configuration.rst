TSDB Configuration
==================
.. index:: Configuration
As of 3.0 OpenTSDB has a much more flexible configuration system with features like:

* Dynamic updates of configuration parameters to avoid JVM restarts (depends on the specific config)
* Secure key/value support like AWS Secrets
* Combining multiple configuration sources
* Configs via HTTP to for containerized deployments
* YAML or JSON support for objec configurations
* Plugins

Overview
--------

OpenTSDB is now configured via one or more sources that are flattened into a single application wide configuration consisting of keys and values. Multiple sources can be provided with the same keys but different values and later values will override the earlier values. As an example, a common config may be available over HTTP with many settings but a local config may override some of those settings for a specific environment.

Available built-in providers include:

* **Environment** - Environment variables can be set with keys and values, useful in a containerized environment.
* **System Properties** - JVM properties can be parsed such as those given over the command line in the `-Dmy.key=my.value` format.
* **Command Line** - Traditional command line arguments like `--my.key=my.value`
* **YAML/JSON File** - Either a local file or available over HTTP(S). Suffixes supported include `.yaml, .yml, .json, .jsn`.
* **Java Properties File** - Either a local file or available over HTTP(S). Suffixes supported include `.conf, .config, .txt, .properties`.
* **Secrets Support** - A plugin to load encrypted values from a secure location like Amazon's AWS Secrets, a local key vault or other secure locations. Useful for credential storage.

The `config.providers` key is used to set the providers and order that they're loaded in. Providers are separated by commas and the last configuration in the list is loaded first, with earlier configs over-ridding the later configs (**NOTE:** If this is a pain we can reverse it before release, let us know what ya'll think). And example config may look like this:

`--config.providers=secrets://net.opentsdb.configuration.providers.AWSSecretsProvider:AWS,https://tsdbconfig.mysite.com/stage/elasticsearch.yaml,https://tsdbconfig.mysite.com/stage/tsdr.yaml,https://tsdbconfig.mysite.com/stage/hbase.yaml,https://tsdbconfig.mysite.com/stage/common.yaml`

With secrets, files and remote files, the configuration format uses protocols like `https://`, `file://` or `secrets://`. These protocols determine which plugin or built-in module parses the config. For remote and files, the suffix will also determine the parser. 

Because multiple configurations are flattened into a single structure, key values in earlier providers will be overwritten by those in later providers. For example, lets assume the following providers config: `--config.providers=https://tsdbconfig.mysite.com/stage/tsdr.yaml,https://tsdbconfig.mysite.com/stage/common.yaml`.

Lets say `https://tsdbconfig.mysite.com/stage/common.yaml` contains:

.. code-block:: yaml
    
    tsd.stats.environment: development
  
and `https://tsdbconfig.mysite.com/stage/tsdr.yaml` defines

.. code-block:: yaml

    tsd.stats.environment: stage

since we're in stage. The final value read by TSDB for `tsd.stats.environment` will be `stage`.

Default Providers
^^^^^^^^^^^^^^^^^

The default provider set is `PropertiesFile,Environment,SystemProperties,CommandLine,RuntimeOverride` where the properties file will automatically search for Java property formatted files in the following locations:

* /etc/opentsdb.conf
* /etc/opentsdb/opentsdb.conf
* /opt/opentsdb/opentsdb.conf

This is useful when migrating from an OpenTSDB 2.0 config file.

Plugin Location
^^^^^^^^^^^^^^^

When secrets need to be loaded (and particularly when they need to be used during bootstraping) a path to a plugin directory can be provided via the `config.plugin.path` key. For example `--config.plugin.path=/usr/share/opentsdb/plugins` can be given on the command line.

Bootstrapping
^^^^^^^^^^^^^

On TSD startup, the configuration class will look for `config.providers` and `config.plugin.path` in the following locations and take the first value found:

* Environment variable
* System properties
* Command line

Reloading
^^^^^^^^^

All file based or remote configurations will be reloaded, by default, every 5 minutes. To change the interval, set `config.reload.interval` to an integer in seconds. This feature allows for common tunnable parameters to be changed during runtime without having to restart the TSD. 

Plugin and Module Configuration
-------------------------------

OpenTSDB is a flexible time series solution wherein a JVM can be configured as a query router or a data store. Therefore the most important configuration is the module config or `tsd.plugin.config`.

Many modules or plugins are loaded automatically, e.g. aggregators, query nodes like the downsampler or group by. But some modules, like data sources or authentication methods, must be configured by the administrator or they won't load. There are four sections to the `tsd.plugin.config`:

* **configs** - This is a list of one or more plugin configuration definitions that will be loaded in the order they are defined. See the configs section below for details.
* **pluginLocations** - An optional list of directories in which to search for plugins (compiled as `.jar` files).
* **continueOnError** - Whether or not to allow the TSD to startup when an error is encountered trying to load a plugin.
* **loadDefaultInstances** - Whether or not to load default module instances.

configs
^^^^^^^

Each module config entry is a map of keys and values with the following keys available:

.. csv-table::foo
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