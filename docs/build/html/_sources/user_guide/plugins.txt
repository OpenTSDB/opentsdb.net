Plugins
=======

OpenTSDB 2.0 introduced a plugin framework, allowing varous contributors to quickly and easily customize their TSDs. This document gives you an overview of the plugin system and will link to some available implementations.

General
^^^^^^^

Plugins are loaded at run time by a TSD or command line utility. Once the program or daemon is running, plugin configurations cannot be changed. You must restart the program for changes to take effect.

Plugins are JAR files that must be downloaded to a directory accessible by OpenTSDB. Once a directory is created, it must be specified in the ``opentsdb.conf`` config file via the ``tsd.core.plugin_path`` property. If the plugin has dependency JARs that were not compiled into the plugin and are not located in the standard class path, they must be copied to this plugin directory as well.

Once the JARs are in place, they must be selected in the configuration file for the type of plugin specified. Usually this will be the fully qualified Java class name such as "net.opentsdb.search.ElasticSearch". Each plugin should have an "enabled" property as well that must be set to ``true`` for the plugin to be loaded. Plugins may also have configuration settings that must be added to the ``opentsdb.conf`` file before they can operate properly. See your plugin's documentation. See :doc:`configuration` for details.

When starting a TSD or CLI tool, a number of errors may prevent a successful launch due to plugin issues. If something happens you should see an exception in the logs related to a plugin. Some things to troubleshoot include:

* Make sure the ``tsd.core.plugin_path`` is configured
* Check that the path is readable for the user OpenTSDB is running under, i.e. check permissions
* Check for typos in the config file. Case matters for plugin names.
* The plugin may not have access to the dependencies it needs. If it has dependencies that are not included with OpenTSDB or packaged into it's own JAR you need to drop the dependencies in the plugin path.
* The plugin may be missing configuration settings required for it to be initialized. Read the docs and see if anything is missing.

.. NOTE:: You should always test a new plugin in a development or QA environment before enabling them in production. Plugins may adversely affect write or read performance so be sure to do some load testing to avoid taking down your TSDs and losing data.

Logging
-------

Plugins and their dependencies can be pretty chatty so you may want to tweak your Logback settings to reduce the number of messages.

Serializers
^^^^^^^^^^^

The HTTP API provides a plugin interface for serializing and deserializing data in formats other than the default JSON formats. These plugins do not require a plugin name or enable flag in the configuraiton file. Instead simply drop the plugin in the plugin directory and it will be loaded when the TSD is launched. More than one serializer plugin can be loaded on startup. Serializer plugins may require configuration properties, so check the documentation before using them.

Plugins
-------

No implementations, aside from the default, at this time.

Search
^^^^^^

OpenTSDB can emit meta data and annotations to a search engine for complex querying. A single search plugin can be enabled for a TSD to push data or execute queries. The ``tsd.search.plugin`` property lets you select a search plugin and ``tsd.search.enable`` will start sending data and queries.

Plugins
-------

* `Elastic Search <https://github.com/manolama/opentsdb-elasticsearch>`_ - A beta plugin that connects to an Elastic Search cluster

Real Time Publishing
^^^^^^^^^^^^^^^^^^^^

Every data point received by a TSD can be sent to another destination for real time processing. One plugin for this type may be enabled at a time. The ``tsd.rtpublisher.plugin`` proeprty lets you select a plugin and ``tsd.rtpublisher.enable`` will start sending data.

Plugins
-------

* `RabbitMQ <https://github.com/manolama/opentsdb-rtpub-rabbitmq>`_ - A proof-of-concept plugin to publish to a RabbitMQ cluster by metric name
* `Skyline <https://github.com/gutefrage/OpenTsdbSkylinePublisher>`_ - A proof-of-concept plugin to publish to an  Etsy Skyline processor