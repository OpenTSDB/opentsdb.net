Plugins
=======
.. index:: Plugins
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

The HTTP API provides a plugin interface for serializing and deserializing data in formats other than the default JSON formats. These plugins do not require a plugin name or enable flag in the configuration file. Instead simply drop the plugin in the plugin directory and it will be loaded when the TSD is launched. More than one serializer plugin can be loaded on startup. Serializer plugins may require configuration properties, so check the documentation before using them.

Plugins
-------

No implementations, aside from the default, at this time.

Authentication
^^^^^^^^^^^

Authentication plugins allow OpenTSDB to authenticate a request prior to handling it. This plugin is inserted into the Netty pipeline and will remove itself for that connection once the authentication has been completed.

.. NOTE::
   Added in 2.4.0

Plugins
-------

* `Basic Authentication <https://github.com/inst-tech/opentsdb-plugins/blob/master/src/main/java/io/tsdb/opentsdb/authentication/SimpleAuthenticationPlugin.java>`_ - An example which checks a provided username and password against a list of accepted users. Not for production use, does not persist or store users, and really isn't all that secure. This plugin is intended to show the basics of implementing an authentication plugin and for testing the plugin interface.


Startup and Service Discovery
^^^^^^^^^^^

OpenTSDB is sometimes used within environments where additional initialization or registration is desired beyond what OpenTSDB typically can do out of the box. Startup plugins can be enabled which will be called when OpenTSDB is initializing, when it is ready to serve traffic, and when it is being shutdown. The ``tsd.startup.plugin`` property can be used to specify the plugin class and ``tsd.startup.enable`` will instruct OpenTSDB to attempt to load the startup plugin.

.. NOTE::
   Added in 2.3.0

Plugins
-------

* `Identity Plugin <https://github.com/inst-tech/opentsdb-discoveryplugins/blob/master/src/main/java/io/tsdb/opentsdb/discoveryplugins/IdentityPlugin.java>`_ - An example plugin which does nothing but can be used as a starting point for future Startup Plugins and can be used to test the registration mechanism.

* `Apache Curator <https://github.com/inst-tech/opentsdb-discoveryplugins/blob/master/src/main/java/io/tsdb/opentsdb/discoveryplugins/CuratorPlugin.java>`_ - A beta plugin which can be used to register OpenTSDB in Zookeeper using Apache Curator's Service Discovery mechanism

Search
^^^^^^

OpenTSDB can emit meta data and annotations to a search engine for complex querying. A single search plugin can be enabled for a TSD to push data or execute queries. The ``tsd.search.plugin`` property lets you select a search plugin and ``tsd.search.enable`` will start sending data and queries. Search plugins will be loaded by TSDs and select command line tools such as the UID Manager tool.

Plugins
-------

* `Elastic Search <https://github.com/manolama/opentsdb-elasticsearch>`_ - A beta plugin that connects to an Elastic Search cluster

Real Time Publishing
^^^^^^^^^^^^^^^^^^^^

Every data point received by a TSD can be sent to another destination for real time processing. One plugin for this type may be enabled at a time. The ``tsd.rtpublisher.plugin`` property lets you select a plugin and ``tsd.rtpublisher.enable`` will start sending data.

Plugins
-------

* `RabbitMQ <https://github.com/manolama/opentsdb-rtpub-rabbitmq>`_ - A proof-of-concept plugin to publish to a RabbitMQ cluster by metric name
* `Skyline <https://github.com/gutefrage/OpenTsdbSkylinePublisher>`_ - A proof-of-concept plugin to publish to an  Etsy Skyline processor

RPC
^^^

Natively, OpenTSDB supports ingesting data points via Telnet or HTTP. The RPC plugin interface allows users to implement and choose alternative protocols such as Protobufs, Thrift, Memcache or any other means of storing information. More than one plugin can be loaded at a time via the ``tsd.rpc.plugins`` or `tsd.http.rpc.plugins`` configuration property. Simply list the class name of any RPC plugins you wish to load, separated by a comma if you have more than one. RPC plugins are only initialized when running a TSD.

Plugins
-------

No implementations at this time.

Storage Exception Handler
^^^^^^^^^^^^^^^^^^^^^^^^^

If a write to the underlying storage layer fails for any reason, an exception is raised. When this happens, if a a storage exception handler plugin is enabled, the data points that couldn't be written can be retried at a later date by spooling to disk or passing to a messaging system. (v2.2)

Plugins
-------

No implementations at this time.

HTTP RPC Plugin
^^^^^^^^^^^^^^^

This is an interface used to implement additional HTTP API endpoints for OpenTSDB. (v2.2)

Plugins
-------

No implementations at this time.

Histogram Plugins
^^^^^^^^^^^^^^^^^

These are implementations of histograms, digests or sketches for storing multiple measurements in one interval then extracting data such as quantiles in an accurate manner.

Plugins
-------

* `Yahoo Data Sketches <https://github.com/OpenTSDB/opentsdb-datasketches>`_ - A set of algorithms for collecting various metrics, merging the results from distributed sources, and computing useful metrics from the results. This implementation uses the quantiles sketch for encoding and storing fixed error rated latency measurements.
