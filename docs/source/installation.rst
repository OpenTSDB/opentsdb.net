Installation
============

OpenTSDB is currently only available via GIT but you can compile and generate packages for distribution throughout your environment.

Upgrading
^^^^^^^^^

OpenTSDB 2.0 is fully backwards compatible with 1.x data. We've taken great pains to make sure you can download 2.0, compile, stop your old TSD and start the new one. You don't *have* to change a thing. Your existing tools will read and write to the TSD without a problem. 

While you can start a 2.0 TSD with the same command line options as a 1.0 TSD, we highly recommend that you create a configuration file based on the config included at ``./src/opentsdb.conf``. Or if you install from a package, you'll want to edit the included default config. The config file includes many more options than are accesible via command line and the file is shared with CLI tools. See :doc:`user_guide/configuration` for details.

You do not have to upgrade all of your TSDs to 2.0 at the same time. Some users upgrade their read-only TSDs first to gain access to the full HTTP API and test the new features. Later on you can upgrade the write-only TSDs at leisure. You can also perform a rolling upgrade without issues. Simply stop traffic to one TSD, upgrade it, restore traffic, and continue on until you have upgraded all of your TSDs. 

If you do perform a rolling upgrade where you have multiple TSDs, heed the following warning:

.. WARNING:: Do not write **Annotations** or **Data point with Millisecond Timestamps** while you run a mixture of 1.x and 2.x. Because these data are stored in the same rows as regular data points, they can affect compactions and queries. 

Before upgrading to 2.x, you may want to upgrade all of your TSDs to OpenTSDB 1.2. This release is fully forwards compatible in that it will ignore annotations and millisecond timestamps and operate as expected. With 1.2 running, if you accidentally record an annotation or millisecond data point, your 1.2 TSDs will operate normally.

Downgrading
^^^^^^^^^^^

Because we've worked hard to maintain backwards compatability, you can turn off a 2.x TSD and restart your old 1.x TSD. The only exceptions are if you have written annotations or milliseconds as you saw in the warning above. In these cases you must downgrade to 1.2 or later.

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
