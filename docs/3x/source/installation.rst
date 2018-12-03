Installation
============
.. index:: Installation
OpenTSDB, so far, must be compiled from source. You can use the compiled libs directly or build a Docker image. The source is at `https://github.com/OpenTSDB/opentsdb/tree/3.0 <https://github.com/OpenTSDB/opentsdb/tree/3.0>`_, just make sure to checkout the 3.0 branch.

Runtime Requirements
^^^^^^^^^^^^^^^^^^^^
.. index:: Requirements
To actually run OpenTSDB, you'll need to meet the following:

* A Linux system (or Windows with manual building)
* Java Runtime Environment 1.8 or later
* HBase 0.92 or later

Installation
^^^^^^^^^^^^

3.0 has a built-in super simple and inefficient in-memory data store that you can read and write from. If the ``MockBase`` plugin is loaded, you can query some data as soon as you start the process and write using the ``/api/put`` HTTP API.

If you have data in HBase (TODO, Bigtable support is kinda working but it's slow right now) then you can query it without problem. If you want to test with HBase, follow the 2.x documentation to install HBase and configure the tables.

Compile
^^^^^^^

From the root directory, run ``mvn package`` and look in the ``distribution/target/`` directory. There will be a tarball you can move around and uncompress, e.g. to some place like ``/opt/opentsdb/`` or ``/usr/share/opentsdb``. That directory will contain sub directories including `bin` where the exec script is located, ``conf`` where configurations lie and `lib` where the JARs are located. To start a TSD, run ``bin/tsdb tsd --config.providers=file://conf/opentsdb_dev.yaml`` to run the in-memory store or ``bin/tsdb tsd --config.providers=file://conf/opentsdb.yaml`` to run it with HBase (and make sure to modify the config for your HBase settings).

Docker
^^^^^^

To build the Docker image, from the root directory run ``mvn package -Pdocker`` and it should build and install an image in your local docker repo (assuming Docker is installed). NOTE: We could use some help on properly building docker and getting instructions together on how to upload the image somewhere).

To start the docker image, run ``docker run --name opentsdb -d -p 4242:4242 opentsdb``. 