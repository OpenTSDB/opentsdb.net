Plugins
=======

OpenTSDB implements a very simple plugin model to extend the application. Plugins use the *service* and *service provider* facilities built into Java 1.6 that allows for dynamically loading JAR files and instantiating plugin implementations after OpenTSDB has been started. While not as flexible as many framework implementations, all we need to do is load a plugin on startup, initialize the implementation, and start passing data to or through it. 

To create a plugin, all you have to do is extend one of the *abstract* plugin classes, write a service description/manifest, compile, drop your JAR (along with any dependencies needed) into the OpenTSDB plugin folder, edit the TSD config and restart. That's all there is to it. No fancy frameworks, no worrying about loading and unloading at strange times, etc.


Manifest
--------

A plugin JAR requires a manifest with a special *services* folder and file to enable the `ServiceLoader <http://docs.oracle.com/javase/6/docs/api/java/util/ServiceLoader.html>`_ to load it properly. Here are the steps for creating the proper files:

  * Create a ``META-INF`` directory under your ``src`` directory. Some IDEs can automatically generate this
  * Within the ``META-INF`` directory, create a file named ``MANIFEST.MF``. Again some IDEs can generate this automatically.
  * Edit the ``MANIFEST.MF`` file and add::
  
      Manifest-Version: 1.0
      
    making sure to end with a blank line. You can add more manifest information if you like. This is the bare minimum to satisfy plugin requirements.
  * Create a ``services`` directory under ``META-INF``
  * Within ``services`` create a file with the canonical class name of the abstract plugin class you are implementing. E.g. if you implement ``net.opentsdb.search.SearchPlugin``, use that for the name of the file.
  * Edit the new file and put the canonical name of each class that implements the abstract interface on a new line of the file. E.g. if your implementation is called ``net.opentsdb.search.ElasticSearch``, put that on a line. Some quick notes about this file:
  
    * You can put comments in the service implementation file. The comment character is the ``#``, just like a Java properties file. E.g.::
    
        # ElasticSearch plugin written by John Doe
        # that sends data over HTTP to a number of ElasticSearch servers
        net.opentsdb.search.ElasticSearch
        
    * You can have more than one implementation of the same abstract class in one JAR and in this file.
      NOTE: If you have widely different implementations, start a different project and JAR. E.g. if you implement a search plugin for ElasticSearch and another for Solr, put Solr in a different project. However if you have two implementations that are very similar but slightly different, you can create one project. For example you could write an ElasticSearch plugin that uses HTTP for a protocol and another that uses Thrift. In that case, you could have a file like::
      
         # ElasticSearch HTTP
         net.opentsdb.search.ElasticSearchHTTP
         # ElasticSearch Thrift
         net.opentsdb.search.ElasticSearchThrift
         
  * Now compile your JAR and make sure to include the manifest file. Each IDE handles this differently. If you're going command line, try this::
  
      jar cvmf <path to MANIFEST.MF> <plugin jar name> <list of class files>
      
    Where the ``<list of class files>`` includes the services file that you created above. E.g.::
    
      jar cvmf META-INF/MANIFEST.MF searchplugin.jar ../bin/net/opentsdb/search/myplugin.class META-INF/services/net.opentsdb.search.SearchPlugin
      
Startup Plugins
---------------

Startup Plugins can be used to perform additional initialization steps during the OpenTSDB startup process.

There are four hooks available, and they are called in this order:
    * Constructor
    * Initialize
    * Ready
    * Shutdown

Constructor
```````````

In the constructor for your plugin, you should initialize your plugin and make any external connections required here. For example, to connect to a service discovery tool such as Etcd or Curator.

Initialize
``````````
The Initialize hook is called once OpenTSDB has fully read the configuration options, both from the file, and the command line. This is called prior to creating the TSDB object so you can modify the configuration at this time.

This hook could be used to register OpenTSDB with a service discovery mechanism or look up the location of an HBase cluster dynamically and populate the connfiguration. You could potentially create HBase tables if they do not exist at this time.

.. note:: You will want to make sure you set the status to PENDING or some other non-ready state in your service discovery system when this is called. TSDB has not been initialized yet at this point.

Ready
`````

This hook is called once OpenTSDB has been fully initialized and is ready to serve traffic. This hook could be used to set the status to READY in a service discovery system, change the state of in a load balancer or perform other tasks which require a fully functioning OpenTSDB instance.

Shutdown
````````

This hook is called when OpenTSDB is performing shutdown tasks. No work should be done here which requires a functioning and connected OpenTSDB instance. You could use this to update the status of this node within your service discovery mechanism.