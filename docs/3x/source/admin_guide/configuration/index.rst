TSDB Configuration
==================
.. index:: Configuration
As of 3.0 OpenTSDB has a much more flexible configuration system with features like:

* Dynamic updates of configuration parameters to avoid JVM restarts (depends on the specific config)
* Secure key/value support like AWS Secrets
* Combining multiple configuration sources
* Configs via HTTP to for containerized deployments
* YAML or JSON support for object configurations
* Plugins

Because there are so many new configs we've broken them up into sections below. For details on how the config system works, jump to the overview. Start with the :doc:plugin documentation as all TSDs require this section to be present.

Index
-----
.. toctree::
   :maxdepth: 1
   
   plugin
   query
   httpserver
   hbase
   rollup
   2xto3x
   

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
