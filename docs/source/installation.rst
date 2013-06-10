Installation
============

OpenTSDB is currently only available via GIT but you can compile and generate packages for distribution throughout your environment.

Compiling
^^^^^^^^^

TODO

Debian Package
^^^^^^^^^^^^^^

You can generate a Debian package by calling ``sh build.sh debian``. The package will be located at ``./build/opentsdb-2.x.x/opentsdb-2.x.x_all.deb``. Then simply distribute the package and install it as you regularly would. For example ``dpkg -i opentsdb-2.0.0_all.deb``.

The Debian package will create the following directories:

* /etc/opentsdb - Configuration files
* /tmp/opentsdb - Temporary cache files
* /usr/share/opentsdb - Application files
* /usr/share/opentsdb/bin - The "tsdb" startup script that launches a TSD or commandline tools
* /usr/share/opentsdb/lib - Java JAR library files
* /usr/share/opentsdb/plugins - Location for plugin files and dependencies
* /usr/share/opentsdb/static - Static files for the GUI
* /usr/share/opentsdb/tools - Scripts and other tools
* /var/log/opentsdb - Logs

.. NOTE: After installing the package you should edit ``/etc/opentsdb/opentsdb.conf`` with the proper Zookeeper quorum servers. The default is localhost.

Installation includes an init script at ``/etc/init.d/opentsdb`` that can start, stop and restart OpenTSDB. Simply call ``service opentsdb start`` to start the tsd and ``service opentsdb stop`` to gracefully shutdown. Note after install, the tsd will not be running so that you can edit the configuration file. Edit the config file, then start the TSD.

The Debian package also creates an ``opentsdb`` user and group for the TSD to run under for increased security. TSD only requires write permission to the temporary and logging directories. If you can't use the default locations, plesae change them in ``/etc/opentsdb/opentsdb.conf`` and ``/etc/opentsdb/logback.xml`` respectively and apply the proper permissions for the ``opentsdb`` user.

.. NOTE: The default temporary directory ``/tmp/opentsdb`` may fill up quickly if you use the TSD for graphing lots of queries. Consider adding ``/usr/share/opentsdb/tools/clean_cache.sh`` as a cron job to clean out old files, or move the temporary directory to a location with greater capacity.
