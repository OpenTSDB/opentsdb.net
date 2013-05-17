CLI Tools
=========

OpenTSDB consists of a single JAR file that uses a shell script to determine what actiosn the user wants to take. While the most common action is to start the TSD with the ''tsd' command so that it can run all the time and process RPCs, other commands are available to work with OpenTSDB data. These commands include:

.. toctree::
   :maxdepth: 2
   
   uid
   mkmetric
   import
   query
   fsck
   scan
   tsd
   
Accessing a CLI tool is performed from the location of the ''tsdb'' file, built after compiling OpenTSDB. By default the tsdb file will be located in the ''build'' directory so you may access it via ''./build/tsdb''. Provide the name of the CLI utility as in ''./build/tsdb tsd''.
   
Common Parameters
^^^^^^^^^^^^^^^^^

All command line utilities share some common command line parameters:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 10, 10, 50, 10, 20
   
   "--config", "String", "The full or relative path to an OpenTSDB :doc:`configuration` file. If this parameter is not provided, the command will attempt to load the default config file.", "See :doc:`configuration`", "--config=/usr/local/tempconfig.conf"
   "--table", "String", "Name of the HBase table where datapoints are stored", "tsdb", "--table=prod-tsdb"
   "--uidtable", "String", "Name of the HBase table where UID information is stored", "tsdb-uid", "--uidtable=prod-tsdb-uid"
   "--zkbasedir", "String", "Path under which is the znode for the -ROOT- region", "/hbase", "--zkbasedir=/prod/hbase"
   "--zkquorum", "String", "Specification of the ZooKeeper quorum to use, i.e. a list of servers and/or ports in the ZooKeeper cluster", "localhost", "--zkquorum=zkhost1,zkhost2,zkhost3"
   
Site-specific Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The common parameters above are required by all the CLI commands. It can be tedious to manually type them over and over again. You can instead store typically used values in a file ''./tsdb.local''. This file is expected to be a shell script and will be sourced by ''./tsdb'' if it exists. 

*Setting default values for common parameters*

If, for example, your ZooKeeper quorum is behind the DNS name "zookeeper.example.com" (a name with 5 A records), instead of always passing ''--zkquorum=zookeeper.example.com'' to the CLI tool each time you use it, you can create ''./tsdb.local'' with the following contents: 

.. code-block :: bash

  #!/bin/bash
  MY_ARGS='--zkquorum=zookeeper'
  set x $MY_ARGS "$@"
  shift
  
*Overriding the timezone of the TSD*

Servers are frequently using UTC as their timezone. By default, the TSD renders graphs using the local timezone of the server. You can override this to have graphs in your local time by specifying a timezone in ''./tsdb.local''. For example, if you're in California, this will force the TSD to use your timezone:

.. code-block :: bash

  echo export TZ=PST8PDT >>tsdb.local

On most Linux and BSD systems, you can look under ''/usr/share/zoneinfo'' for names of timezones supported on your system. 

*Changing JVM parameters*

You might want to adjust JVM parameters, for instance to turn on GC activity logging or to set the size of various memory regions. In order to do so, simply set the variable JVMARGS in ''./tsdb.local''.

Here is an example that is recommended for production use: 

.. code-block :: bash

  GCARGS="-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps\ 
   -XX:+PrintTenuringDistribution -Xloggc:/tmp/tsd-gc-`date +%s`.log" 
  if test -t 0; then # if stdin is a tty, don't turn on GC logging. 
    GCARGS= 
  fi 
  # The Sun JDK caches all name resolution results forever, which is stupid. 
  # This forces you to restart your application if any of the backends change 
  # IP. Instead tell it to cache names for only 10 minutes at most. 
  FIX_DNS='-Dsun.net.inetaddr.ttl=600' 
  JVMARGS="$JVMARGS $GCARGS $FIX_DNS"