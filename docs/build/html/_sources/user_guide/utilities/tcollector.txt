TCollector
==========

`tcollector <https://github.com/OpenTSDB/tcollector/>`_ is a client-side
process that gathers data from local collectors and pushes the data to
OpenTSDB. You run it on all your hosts, and it does the work of sending each
host's data to the TSD.

OpenTSDB is designed to make it easy to collect and write data to it.
It has a simple protocol, simple enough for even a shell script to start
sending data. However, to do so reliably and consistently is a bit harder.
What do you do when your TSD server is down? How do you make sure your
collectors stay running?  This is where tcollector comes in.

Tcollector does several things for you:

* Runs all of your data collectors and gathers their data
* Does all of the connection management work of sending data to the TSD
* You don't have to embed all of this code in every collector you write
* Does de-duplication of repeated values
* Handles all of the wire protocol work for you, as well as future enhancements

Deduplication
^^^^^^^^^^^^^

Typically you want to gather data about everything in your system.
This generates a lot of datapoints, the majority of which don't
change very often over time (if ever).  However, you want fine-grained
resolution when they do change.  Tcollector remembers the last value
and timestamp that was sent for all of the time series for all of
the collectors it manages.  If the value doesn't change between sample
intervals, it suppresses sending that datapoint.  Once the value does change
(or 10 minutes have passed), it sends the last suppressed value and timestamp,
plus the current value and timestamp.  In this way all of your graphs and
such are correct.  Deduplication typically reduces the number of datapoints
TSD needs to collect by a large fraction.  This reduces network load and
storage in the backend.  A future OpenTSDB release however will improve on
the storage format by using RLE (among other things), making it essentially
free to store repeated values.

Collecting lots of metrics with tcollector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Collectors in tcollector can be written in any language.  They just need to
be executable and output the data to stdout.  Tcollector will handle the rest.
The collectors are placed in the ``collectors`` directory.  Tcollector
iterates over every directory named with a number in that directory and runs all
the collectors in each directory.  If you name the directory ``60``,
then tcollector will try to run every collector in that directory every 60
seconds. The shortest supported interval is 15 seconds, you should use a
long-running collector in the 0 folder for intervals shorter than 15 seconds.
TCollector will sleep for 15 seconds after each time it runs the collectors
so intervals of 15 seconds are the only actually supported intervals. For example,
this would allow you to run a collector every 15, 30, 45, 60, 75, or 90 seconds,
but not 80 or 55 seconds. Use the directory ``0`` for any collectors that are long-lived
and run continuously. Tcollector will read their output and respawn them if they
die. Generally you want to write long-lived collectors since that has less
overhead. OpenTSDB is designed to have lots of datapoints for each metric (for
most metrics we send datapoints every 15 seconds).

If there any non-numeric named directories in the ``collectors``
directory, then they are ignored.  We've included a ``lib`` and
``etc`` directory for library and config data used by all collectors.

Installation of tcollector
^^^^^^^^^^^^^^^^^^^^^^^^^^

You need to clone tcollector from GitHub: ::

  git clone git://github.com/OpenTSDB/tcollector.git

and edit 'tcollector/startstop' script to set following variable:
``TSD_HOST=dns.name.of.tsd``


To avoid having to run ``mkmetric`` for every metric that
tcollector tracks you can to start TSD with the ``--auto-metric``
flag.  This is useful to get started quickly, but it's not recommended to
keep this flag in the long term, to avoid accidental metric creation.

Collectors bundled with ``tcollector``
======================================

The following are the collectors we've included as part of the base package,
together with all of the metric names they report on and what they mean. If you
have any others you'd like to contribute, we'd love to hear about them so we can
reference them or include them with your permission in a future release.

General collectors
^^^^^^^^^^^^^^^^^^

``0/dfstat.py``
---------------
These stats are similar to ones provided by ``/usr/bin/df`` util.

* ``df.bytes.total`` 
    total size of data
* ``df.bytes.used`` 
    bytes used
* ``df.bytes.free`` 
    bytes free
* ``df.inodes.total`` 
    total number of inodes
* ``df.inodes.used`` 
    number of inodes used
* ``df.inodes.free`` 
    number of inodes free

These metrics include time series tagged with each mount point and the
filesystem's fstype. This collector filters out any cgroup, debugfs, devtmpfs,
rpc_pipefs, rootfs filesystems, as well as any any mountpoints mounted under
``/dev/``, ``/sys/``, ``/proc/``, and ``/lib/``.

With these tags you can select to graph just a specific filesystem, or all
filesystems with a particular fstype (e.g. ext3).

``0/ifstat.py``
---------------

These stats are from ``/proc/net/dev``.

* ``proc.net.bytes`` 
    (rate) Bytes in/out
* ``proc.net.packets`` 
    (rate) Packets in/out
* ``proc.net.errs`` 
    (rate) Packet errors in/out
* ``proc.net.dropped`` 
    (rate) Dropped packets in/out

These are interface counters, tagged with the interface, ``iface=``, and
``direction=`` in or out. Only ``ethN`` interfaces are tracked. We
intentionally exclude ``bondN`` interfaces, because bonded interfaces
still keep counters on their child ``ethN`` interfaces and we don't want
to double-count a box's network traffic if you don't select on ``iface=``.

``0/iostat.py``
---------------
Data is from ``/proc/diskstats``.

* ``iostat.disk.*`` 
    per-disk stats
* ``iostat.part.*`` 
    per-partition stats (see note below on different metrics, depending 
    on if you have a 2.6 kernel before 2.6.25 or after.)

See `iostats.txt <http://www.kernel.org/doc/Documentation/iostats.txt>`_

``/proc/diskstats`` has 11 stats for a given physical device.
These are all rate counters, except ``ios_in_progress``. ::

  .read_requests       Number of reads completed
  .read_merged         Number of reads merged
  .read_sectors        Number of sectors read
  .msec_read           Time in msec spent reading
  .write_requests      Number of writes completed
  .write_merged        Number of writes merged
  .write_sectors       Number of sectors written
  .msec_write          Time in msec spent writing
  .ios_in_progress     Number of I/O operations in progress
  .msec_total          Time in msec doing I/O
  .msec_weighted_total Weighted time doing I/O (multiplied by ios_in_progress)


in 2.6.25 and later, by-partition stats are reported the same as disks.

.. NOTE:: in 2.6 before 2.6.25, partitions have only 4 stats per partition
::

  .read_issued
  .read_sectors
  .write_issued
  .write_sectors

For partitions, these ``*_issued`` are counters collected before requests are
merged, so aren't the same as ``*_requests`` (which is post-merge, which
more closely represents represents the actual number of disk transactions).

Given that diskstats provides both per-disk and per-partition data, for
TSDB purposes we put them under different metrics (versus the same
metric and different tags).  Otherwise, if you look at a given metric, the data
for a given box will be double-counted, since a given operation will increment
both the disk series and the partition series.  To fix this, we output by-disk
data to ``iostat.disk.*`` and by-partition data to ``iostat.part.*``.

``0/netstat.py``
----------------

Socket allocation and network statistics.

Metrics from ``/proc/net/sockstat``.

* ``net.sockstat.num_sockets``
    Number of sockets allocated (only TCP)
* ``net.sockstat.num_timewait``
    Number of TCP sockets currently in ``TIME_WAIT`` state
* ``net.sockstat.sockets_inuse``
    Number of sockets in use (TCP/UDP/raw)
* ``net.sockstat.num_orphans``
    Number of orphan TCP sockets (not attached to any file descriptor)
* ``net.sockstat.memory``
    Memory allocated for this socket type (in bytes)
* ``net.sockstat.ipfragqueues``
    Number of IP flows for which there are currently fragments queued for
    reassembly

Metrics from ``/proc/net/netstat`` (``netstat -s`` command).

* ``net.stat.tcp.abort``
    Number of connections that the kernel had to abort.
    <code>type=memory</code> is especially bad, the kernel had to drop a
    connection due to having too many orphaned sockets. Other types are normal
    (e.g. timeout)
* ``net.stat.tcp.abort.failed``
    Number of times the kernel failed to abort a connection because it didn't
    even have enough memory to reset it (bad)
* ``net.stat.tcp.congestion.recovery``
    Number of times the kernel detected spurious retransmits and was able to
    recover part or all of the CWND
* ``net.stat.tcp.delayedack``
    Number of delayed ACKs sent of different types.
* ``net.stat.tcp.failed_accept``
    Number of times a connection had to be dropped after the 3WHS.
    ``reason=full_acceptq`` indicates that the application isn't
    accepting connections fast enough.  You should see SYN cookies too
* ``net.stat.tcp.invalid_sack``
    Number of invalid SACKs we saw of diff types.
    (requires Linux v2.6.24-rc1 or newer)
* ``net.stat.tcp.memory.pressure``
    Number of times a socket entered the "memory pressure" mode (not great).
* ``net.stat.tcp.memory.prune``
    Number of times a socket had to discard received data due to low memory
    conditions (bad)
* ``net.stat.tcp.packetloss.recovery``
    Number of times we recovered from packet loss by type of recovery (e.g.
    fast retransmit vs SACK)
* ``net.stat.tcp.receive.queue.full``
    Number of times a received packet had to be dropped because the socket's
    receive queue was full. (requires Linux v2.6.34-rc2 or newer)
* ``net.stat.tcp.reording``
    Number of times we detected re-ordering and how
* ``net.stat.tcp.syncookies``
    SYN cookies (both sent &amp; received)


``0/nfsstat.py``
----------------
These stats are from ``/proc/net/rpc/nfs``.


* ``nfs.client.rpc.stats`` 
    RPC stats counter

It tagged with the type (<code>type=</code>) of operation. There are 3
operations: ``authrefrsh`` - number of times the authentication information
refreshed, ``calls`` - number of calls conducted, and ``retrans`` - number
of retransmissions

* ``nfs.client.rpc`` 
    RPC calls counter

It tagged with the version (``version=``) of NFS server that conducted
the operation, and name of operation (``op=``)

Description of operations can be found at appropriate RFC:
NFS ver. 3 `RFC1813 <http://tools.ietf.org/html/rfc1813>`_,
NFS ver. 4 `RFC3530 <http://tools.ietf.org/html/rfc3530>`_,
NFS ver. 4.1 `RFC5661 <http://tools.ietf.org/html/rfc5661>`_.

``0/procnettcp.py``
-------------------

These stats are all from ``/proc/net/tcp{,6}``. (Note if IPv6 is enabled,
some IPv4 connections seem to get put into ``/proc/net/tcp6``). Collector
sleeps 60 seconds in between intervals. Due in part to a kernel performance
issue in older kernels and in part due to systems with many TCP connections,
this collector can take sometimes 5 minutes or more to run one interval, so
the frequency of datapoints can be highly variable depending on the
system.

* ``proc.net.tcp`` 
    Number of TCP connections

For each run of the collector, we classify each connection and generate
subtotals. TSD will automatically total these up when displaying the graph,
but you can drill down for each possible total or a particular one.  Each
connection is broken down with a tag for ``user=username`` (with a fixed list
of users we care about or put under "other" if not in the list). It is also
broken down into state with ``state=``, (established, time_wait, etc). It is
also broken down into services with <code>service=</code> (http, mysql,
memcache, etc) Note that once a connection is closed, Linux seems to forget
who opened/handled the connection. For connections in time_wait, for example,
they will always show user=root. This collector does generate a large amount
of datapoints, as the number of points is (S*(U+1)*V), where S=number of TCP
states, U=Number of users you track, and V=number of services (collections of
ports). The deduper does dedup this down very well, as only 3 of the 10 TCP
states are generally ever seen. On a typical server this can dedup down to
under 10 values per interval.

``0/procstats.py``
------------------

Miscellaneous stats from ``/proc``.


* ``proc.stat.cpu`` 
    (rate) CPU counters (jiffies), tagged by cpu type 
    (type=user, nice, system, idle, iowait, irq, softirq, etc). As a rate
    they should aggregate up to approximately 100*numcpu per host. Best
    viewed as type=* or maybe type={user|nice|system|iowait|irq}
* ``proc.stat.intr`` 
    (rate) Number of interrupts
* ``proc.stat.ctxt`` 
    (rate) Number of context switches

See http://www.linuxhowtos.org/System/procstat.htm

* ``proc.vmstat.*`` 
    A subset of VM Stats from ``/proc/vmstat`` (mix of rate  and non-rate).
    See http://www.linuxinsight.com/proc_vmstat.html .
* ``proc.meminfo.*`` 
    Memory usage stats from ``/proc/meminfo``. See the 
    `Linux kernel documentation <http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/filesystems/proc.txt;hb=HEAD>`_
* ``proc.loadavg.*`` 
    1min, 5min, 15min, runnable, total_threads metrics from ``/proc/loadavg``
* ``proc.uptime.total`` 
    (rate) Seconds since boot
* ``proc.uptime.now`` 
    (rate) Seconds since boot that the system has been idle
* ``proc.kernel.entropy_avail`` 
    Amount of entropy (in bits) available in the  input pool 
    (the one that's cryptographically strong and backing ``/dev/random`` 
    among other things). Watch this value on your frontend servers that do 
    SSL unwrapping, if it gets too low, your SSL performance will suffer
* ``sys.numa.zoneallocs`` 
    Number of pages allocated from the preferred node 
    (``type=hit``) or not (``type=miss``)
* ``sys.numa.foreign_allocs`` 
    Number of pages this node allocated because the preferred node didn't 
    have a free page to accommodate the request
* ``sys.numa.allocation`` 
    Number of pages allocated locally (``type=local``) or remotely 
    (``type=remote``) for processes executing on this node
* ``sys.numa.interleave`` 
    Number of pages allocated successfully by the interleave strategy

``0/smart-stats.py``
--------------------

Stats from SMART disks.

* ``smart.raw_read_error_rate`` 
    Data related to the rate of hardware read  errors that occurred when 
    reading data from a disk surface. The raw value has different structure 
    for different vendors and is often not meaningful as a decimal number.
    (vendor specific)
* ``smart.throughput_performance`` 
    Overall throughput performance of a hard disk drive
* ``smart.spin_up_time`` 
    Average time of spindle spin up (from zero RPM to fully operational 
    [millisecs])
* ``smart.start_stop_count`` 
    A tally of spindle start/stop cycles
* ``smart.reallocated_sector_ct`` 
    Count of reallocated sectors
* ``smart.seek_error_rate`` 
    Rate of seek errors of the magnetic heads. (vendor specific)
* ``smart.seek_time_performance`` 
    Average performance of seek operations of the magnetic heads
* ``smart.power_on_hours`` 
    Count of hours in power-on state, shows total count of hours 
    (or minutes, or seconds) in power-on state. (vendor specific)
* ``smart.spin_retry_count`` 
    Count of retry of spin start attempts  
* ``smart.recalibration_retries`` 
    The count that recalibration was requested (under the condition 
    that the first attempt was unsuccessful) 
* ``smart.power_cycle_count`` 
    The count of full hard disk power on/off cycles
* ``smart.soft_read_error_rate`` 
    Uncorrected read errors reported to the operating system
* ``smart.program_fail_count_chip`` 
    Total number of Flash program operation failures since the drive was 
    deployed
* ``smart.erase_fail_count_chip`` 
    "Pre-Fail" Attribute
* ``smart.wear_leveling_count`` 
    The maximum number of erase operations performed on a single flash memory block
* ``smart.used_rsvd_blk_cnt_chip`` 
    The number of a chip’s used reserved blocks
* ``smart.used_rsvd_blk_cnt_tot`` 
    "Pre-Fail" Attribute (at least HP devices)
* ``smart.unused_rsvd_blk_cnt_tot`` 
    "Pre-Fail" Attribute (at least Samsung devices)
* ``smart.program_fail_cnt_total`` 
    Total number of Flash program operation failures since the drive was deployed
* ``smart.erase_fail_count_total`` 
    "Pre-Fail" Attribute
* ``smart.runtime_bad_block`` 
    The total count of all read/program/erase failures
* ``smart.end_to_end_error`` 
    The count of parity errors which occur in the data path to the media via 
    the drive's cache RAM (at least Hewlett-Packard)
* ``smart.reported_uncorrect`` 
    The count of errors that could not be recovered using hardware ECC
* ``smart.command_timeout`` 
    The count of aborted operations due to HDD timeout
* ``smart.high_fly_writes`` 
    HDD producers implement a Fly Height Monitor that attempts to provide 
    additional protections for write operations by detecting when a recording 
    head is flying outside its normal operating range. If an unsafe fly height 
    condition is encountered, the write process is stopped, and the information 
    is rewritten or reallocated to a safe region of the hard drive. This 
    attribute indicates the count of these errors detected over the lifetime 
    of the drive
* ``smart.airflow_temperature_celsius`` 
    Airflow temperature
* ``smart.g_sense_error_rate`` 
    The count of errors resulting from externally induced shock & vibration
* ``smart.power-off_retract_count`` 
    The count of times the heads are loaded off the media
* ``smart.load_cycle_count`` 
    Count of load/unload cycles into head landing zone position
* ``smart.temperature_celsius`` 
    Current internal temperature
* ``smart.hardware_ecc_recovered`` 
    The count of errors that were recovered using hardware ECC
* ``smart.reallocated_event_count`` 
    Count of remap operations. The raw value of this attribute shows the total 
    count of attempts to transfer data from reallocated sectors to a spare area
* ``smart.current_pending_sector`` 
    Count of "unstable" sectors (waiting to be remapped, because of 
    unrecoverable read errors)
* ``smart.offline_uncorrectable`` 
    The total count of uncorrectable errors when reading/writing a sector
* ``smart.udma_crc_error_count`` 
    The count of errors in data transfer via the interface cable as determined 
    by ICRC (Interface Cyclic Redundancy Check)
* ``smart.write_error_rate`` 
    The total count of errors when writing a sector 
* ``smart.media_wearout_indicator`` 
    The normalized value of 100 (when the SSD is new) and declines to a minimum 
    value of 1
* ``smart.transfer_error_rate`` 
    Count of times the link is reset during a data transfer
* ``smart.total_lba_writes`` 
    Total count of LBAs written
* ``smart.total_lba_read`` 
    Total count of LBAs read

Description of metrics can be found at:
`S.M.A.R.T. article on wikipedia <https://en.wikipedia.org/wiki/S.M.A.R.T.#Known_ATA_S.M.A.R.T._attributes>`_.
The best way to understand/find metric is to look at producer's specification.


Other collectors
^^^^^^^^^^^^^^^^

``0/couchbase.py``
------------------

Stats from couchbase (document-oriented NoSQL database).

All metrics are tagged with name of related bucket(``bucket=``). A bucket is
a logical grouping of physical resources within a cluster of Couchbase
Servers. They can be used by multiple client applications across a cluster.
Buckets provide a secure mechanism for organizing, managing, and analyzing
data storage resources.

Refer to the following documentation for metrics description:
`Cbstats documentation <http://docs.couchbase.com/couchbase-manual-2.1/#cbstats-tool>`_.


``0/elasticsearch.py``
----------------------

Stats from Elastic Search (search and analytics engine).

Refer to the following documentation for metrics description:
`ElasticSearch cluster APIs <http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster.html>`_.


``0/hadoop_datanode_jmx.py``
----------------------------

Stats from Hadoop (framework for the distributed processing), DataNode stats.

Following metrics are disabled at the collector by default: revision,
hdfsUser, hdfsDate, hdfsUrl, date, hdfsRevision, user, hdfsVersion, url,
version, NamenodeAddress, Version, RpcPort, HttpPort, CurrentThreadCpuTime,
CurrentThreadUserTime, StorageInfo, VolumeInfo.

Refer to the following documentation for metrics description:
`HBase metrics <http://hbase.apache.org/book.html#hbase_metrics>`_.


``0/haproxy.py``
-----------------

Stats from Haproxy (TCP/HTTP load balancer).

* ``haproxy.current_sessions`` 
    Current number of sessions
* ``haproxy.session_rate`` 
    Number of new sessions per second

All metrics are tagged with server (``server=``) and cluster (``cluster=``).

Refer to the following documentation for metrics description:
`Haproxy configuration <http://haproxy.1wt.eu/download/1.4/doc/configuration.txt>`_
# section 9.2.Unix Socket commands


``0/hbase_regionserver_jmx.py``
--------------------------------

Stats from Hadoop (framework for the distributed processing), RegionServer
stats.

Following metrics are disabled at the collector by default: revision, hdfsUser,
hdfsDate, hdfsUrl, date, hdfsRevision, user, hdfsVersion, url, version,
Version, RpcPort, HttpPort,HeapMemoryUsage, NonHeapMemoryUsage.

Refer to the following documentation for metrics description:
`HBase metrics <http://hbase.apache.org/book.html#hbase_metrics>`_.


``0/mongo.py``
--------------

Stats from Mongo (document NoSQL database).

Refer to the following documentation for metrics description:
`Mongo DB server-status <http://docs.mongodb.org/manual/reference/server-status/>`_.


``0/mysql.py``
--------------

Stats from MySQL (relational database).

Refer to the following documentation for metrics description:
InnoDB `Innodb monitors <http://dev.mysql.com/doc/refman/5.0/en/innodb-monitors.html>`_,
Global `Show status <http://dev.mysql.com/doc/refman/5.0/en/show-status.html>`_,
Engine `Show engine <http://dev.mysql.com/doc/refman/5.1/en/show-engine.html>`_,
Slave `Show slave status <http://dev.mysql.com/doc/refman/5.0/en/show-slave-status.html>`_,
Process list `Show process list <a href="http://dev.mysql.com/doc/refman/5.0/en/show-processlist.html">`_.


``0/postgresql.py``
-------------------

Stats from PostgreSQL (relational database).

Refer to the following documentation for metrics description:
`PostgreSQL monitoring stats <http://www.postgresql.org/docs/9.2/static/monitoring-stats.html>`_.


``0/redis-stats.py``
--------------------

Stats from Redis (key-value store).

Refer to the following documentation for metrics description:
`Redis info comands <http://redis.io/commands/INFO>`_.


``0/riak.py``
-------------

Stats from Riak (document NoSQL database).

Refer to the following documentation for metrics description:
`Riak statistics <http://docs.basho.com/riak/latest/ops/running/stats-and-monitoring/#Statistics-from-Riak>`_.


``0/varnishstat.py``
--------------------

Stats from Varnish (HTTP accelerator).

By default all metrics collected, it can be changed by editing "vstats" array
of the collector.

Refer to the following documentation for metrics description: run
"varnishstat -l" to have lists the available metrics.


``0/zookeeper.py``
------------------

Stats from Zookeeper (centralized service for distributed synchronization).

Refer to the following documentation for metrics description:
`Zookeeper admin commands <http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html#sc_zkCommands>`_.

