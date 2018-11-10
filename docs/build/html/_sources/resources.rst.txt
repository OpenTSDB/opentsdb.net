Additional Resources
====================
.. index:: Resources
These are just some of the awesome front-ends, utilities, libraries and resources created by the OpenTSDB community. Please let us know if you have a project you'd like to see listed and if you don't see something you need, search for it on Github (new projects are popping up all the time) or your favorite search engine.

Monitoring
^^^^^^^^^^
* `Bosun <https://bosun.org/>`_ - A monitoring and alerting system built on OpenTSDB from the folks at `Stack Exchange <http://stackexchange.com/>`_. 

Docker Images
^^^^^^^^^^^^^
* `petergrace/opentsdb-docker <https://registry.hub.docker.com/u/petergrace/opentsdb-docker/>`_ - A prebuilt Docker image with HBase and OpenTSDB already configured and ready to run!  If you have Docker installed, execute ``docker run -d -p 4242:4242 petergrace/opentsdb-docker`` to create an opentsdb instance running on port 4242.
* `opower/opentsdb <https://registry.hub.docker.com/u/opower/opentsdb/>`_ - A Docker image containing OpenTSDB, HBase, and tcollector. Comes in both 2.0.1 and 2.1 versions (latest defaults to 2.1). Execute ``docker run -d -p 4242:4242 opower/opentsdb`` to create an OpenTSDB instance running on port 4242.

Front Ends
^^^^^^^^^^

* `Status Wolf <https://github.com/box/StatusWolf>`_ - A PHP and MySQL based dashboard for creating and storing dynamic custom graphs with OpenTSDB data including anonmaly detection.
* `Metrilyx <https://github.com/Ticketmaster/metrilyx-2.0>`_ - A Python and Django based dashboard system with dynamic graphs from Ticketmaster.
* `Opentsdb-Dashboard <https://github.com/clover/opentsdb-dashboard>`_ - An HBase based dashboard system for OpenTSDB 1.x from Clover.
* `TSDash <https://github.com/facebook/tsdash>`_ - A Java based UI and dashboard from Facebook.
* `OpenTSDB Dashboard <https://github.com/turn/opentsdb-dashboard>`_ - A JQuery based dashboard from Turn.
* `Grafana <http://grafana.org>`_ - A dashboard and graph editor with OpenTSDB support.
* `Graphite OpenTSDB Finder <https://github.com/mikebryant/graphite-opentsdb-finder>`_ - A Graphite plugin to load TSDB data.

Utilities
^^^^^^^^^

* `opentsdbjsonproxy <https://github.com/noca/opentsdbjsonproxy>`_ - An HTTP proxy to convert 1.x ASCII output from the ``/q`` endpoint to JSON for use with High Charts or other libraries.
* `Collectd-opentsdb <https://github.com/auxesis/collectd-opentsdb>`_ - A Collectd plugin to emmit stats to a TSD.
* `Collectd-opentsdb Java <https://github.com/dotcloud/collectd-opentsdb>`_ - A Collectd plugin to that uses the OpenTSDB Java API to push data to a TSD.
* `TSD_proxy` <https://github.com/aravind/tsd_proxy>`_ - A buffering write proxy for OpenTSDB and alternate DBs.
* `Vacuumetrix <https://github.com/99designs/vacuumetrix>`_ - Utility to pull data from various cloud services or APIs and store the results in backends such as Graphite, Ganglia and OpenTSDB.
* `JuJu Deployment Charm <https://github.com/charms/opentsdb>`_ - Utility to compile OpenTSDB from GIT and deploy on a cluster.
* `Statsd Publisher <https://github.com/danslimmon/statsd-opentsdb-backend>`_ - A statsd backend to publish data to a TSD.
* `OpenTSDB Proxy <https://github.com/nimbusproject/opentsdbproxy>`_ - A Django based proxy with authentication and SSL support to run in front of the TSDs.
* `Puppet Module <https://github.com/mburger/puppet-opentsdb>`_ - A puppet deployment module.
* `Flume Module <https://github.com/yandex/opentsdb-flume>`_ - Write data from Flume to a TSD.
* `Chef Cookbook <https://github.com/looztra/opentsdb-cookbook>`_ - Deploy from source via Chef.
* * `OpenTSDB Cookbook <https://github.com/acaiafa/opentsdb-cookbook>`_ - A Chef cookbook for CentOS or Ubuntu.
* `Coda Hale Metrics Reporter <https://github.com/sps/metrics-opentsdb>`_ - Writes data to OpenTSDB from the Java Metrics library.
* `Alternative Coda Hale Metrics Reporter <https://github.com/stuart-warren/metrics-opentsdb>`_ - Writes data to OpenTSDB from the Java Metrics library.
* `opentsdb-snmp <https://github.com/frogmaster/opentsdb-snmp>`_ - Fetches data from SNMP enabled devices and writes to OpenTSDB.
* `proxTSDB <https://github.com/worldline/proxyTSDB>`_ - A metric data gateway capable of buffering data to RAM or disk if the TSD is down.
* `OpenTSDB Pig UDFs <https://github.com/santosh-d3vpl3x/opentsdb-udfs>`_ - Integrate OpenTSDB with Apache Pig for large data set processing.

Clients
^^^^^^^

* `R Client <https://github.com/holstius/opentsdbr>`_ - A client to pull data from OpenTSDB into R.
* `Erlang Client <https://github.com/bradfordw/gen_opentsdb>`_ - A simple client to publish data to a TSD from Erlang.
* `time-series <https://github.com/opower/time-series>`_ - A Ruby client that supports both reading and writing to OpenTSDB 2.x - contains support for synthetic time series calculations.
* `Ruby <https://github.com/j05h/continuum>`_ - A read-only client for querying data from the 1.x API.
* `Ruby <https://github.com/johnewart/ruby-opentsdb>`_ A write-only client for pushing data to a TSD.
* `Go <https://github.com/bzub/go-opentsdb>`_ - Work with OpenTSDB data in Go.
* `Potsdb <https://pypi.python.org/pypi/potsdb>`_ - A Python client for writing data.
* `vert.x OpenTsDb <https://github.com/cyngn/vertx-opentsdb>`_ - A library to write data to OpenTSDB from Vert.x.

References to OpenTSDB
^^^^^^^^^^^^^^^^^^^^^^

* `HBase in Action <http://www.manning.com/dimidukkhurana/>`_ (Manning Publications) - Chapter 7: HBase by Example: OpenTSDB
* `Professional NoSQL <http://www.wrox.com/WileyCDA/WroxTitle/Professional-NoSQL.productCd-047094224X.html>`_ (Wrox Publishing) - Mentioned in Chapter 17: Tools and Utilities
* `OSCon Data 2011 <http://www.youtube.com/watch?v=WlsyqhrhRZA>`_ - Presentation from Benoit Sigoure
* `Percona Live 2013 <http://www.slideshare.net/geoffanderson/monitoring-mysql-with-opentsdb-19982758>`_ Presentation from Geoffrey Anderson
* `HBaseCon 2013 <http://www.hbasecon.com/sessions/opentsdb-at-scale/>`_ - Presentation from Jonathan Creasy and Geoffrey Anderson
* `Strata 2011 <http://strataconf.com/strata2011/public/schedule/detail/16996>`_ - Presentation by Benoit Sigoure

Statistical Analysis Tools
^^^^^^^^^^^^^^^^^^^^^^^^^^

* `GnuPlot <http://www.gnuplot.info/>`_ - Graphing library used by OpenTSDB
* `R <http://www.r-project.org/>`_ - Statistical computing framework
* `SciPy <http://www.scipy.org/>`_ - Python libraries for dealing with numbers (Pandas library has time series support)
