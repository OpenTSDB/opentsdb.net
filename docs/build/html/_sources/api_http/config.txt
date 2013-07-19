/api/config
===========

This endpoint returns information about the running configuration of the TSD. It is read only and cannot be used to set configuration options.

Verbs
-----

* GET
* POST

Requests
--------

This endpoint does not require any parameters via query string or body.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  http://localhost:4242/api/config
   
Response
--------
   
The response is a hash map of configuration properties and values.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
      "tsd.search.elasticsearch.tsmeta_type": "tsmetadata",
      "tsd.storage.flush_interval": "1000",
      "tsd.network.tcp_no_delay": "true",
      "tsd.search.tree.indexer.enable": "true",
      "tsd.http.staticroot": "/usr/local/opentsdb/staticroot/",
      "tsd.network.bind": "0.0.0.0",
      "tsd.network.worker_threads": "",
      "tsd.storage.hbase.zk_quorum": "localhost",
      "tsd.network.port": "4242",
      "tsd.rpcplugin.DummyRPCPlugin.port": "42",
      "tsd.search.elasticsearch.hosts": "localhost",
      "tsd.network.async_io": "true",
      "tsd.rtpublisher.plugin": "net.opentsdb.tsd.RabbitMQPublisher",
      "tsd.search.enableindexer": "false",
      "tsd.rtpublisher.rabbitmq.user": "guest",
      "tsd.search.enable": "false",
      "tsd.search.plugin": "net.opentsdb.search.ElasticSearch",
      "tsd.rtpublisher.rabbitmq.hosts": "localhost",
      "tsd.core.tree.enable_processing": "false",
      "tsd.stats.canonical": "true",
      "tsd.http.cachedir": "/tmp/opentsdb/",
      "tsd.http.request.max_chunk": "16384",
      "tsd.http.show_stack_trace": "true",
      "tsd.core.auto_create_metrics": "true",
      "tsd.storage.enable_compaction": "true",
      "tsd.rtpublisher.rabbitmq.pass": "guest",
      "tsd.core.meta.enable_tracking": "true",
      "tsd.mq.enable": "true",
      "tsd.rtpublisher.rabbitmq.vhost": "/",
      "tsd.storage.hbase.data_table": "tsdb",
      "tsd.storage.hbase.uid_table": "tsdb-uid",
      "tsd.http.request.enable_chunked": "true",
      "tsd.core.plugin_path": "/usr/local/opentsdb/plugins",
      "tsd.storage.hbase.zk_basedir": "/hbase",
      "tsd.rtpublisher.enable": "false",
      "tsd.rpcplugin.DummyRPCPlugin.hosts": "localhost",
      "tsd.storage.hbase.tree_table": "tsdb-tree",
      "tsd.network.keep_alive": "true",
      "tsd.network.reuse_address": "true",
      "tsd.rpc.plugins": "net.opentsdb.tsd.DummyRpcPlugin"
  }
