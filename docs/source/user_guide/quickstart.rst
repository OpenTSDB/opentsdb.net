Quick Start
===========
.. index:: Quick Start
Once you have a TSD up and running (after following the :doc:`../installation` guide) you can follow the steps below to get some data into OpenTSDB. After you have some data stored, pull up the GUI and try generating some graphs.

Create Your First Metrics
^^^^^^^^^^^^^^^^^^^^^^^^^

Metrics need to be registered before you can start storing data points for them. This helps to avoid ingesting unwanted data and catch typos. You can enable auto-metric creation via configuration. To register one or more metrics, call the ``mkmetric`` CLI::

  ./tsdb mkmetric mysql.bytes_received mysql.bytes_sent

This will create 2 metrics: ``mysql.bytes_received`` and ``mysql.bytes_sent``

New tags, on the other hand, are automatically registered whenever they're used for the first time. Right now OpenTSDB only allows you to have up to 2^24 = 16,777,216 different metrics, 16,777,216 different tag names and 16,777,216 different tag values. This is because each one of those is assigned a UID on 3 bytes. Metric names, tag names and tag values have their own UID spaces, which is why you can have 16,777,216 of each kind. The size of each space is configurable but there is no knob that exposes this configuration parameter right now. So bear in mind that using user ID or event ID as a tag value will not work right now if you have a large site.

Start Collecting Data
^^^^^^^^^^^^^^^^^^^^^

So now that we have our 2 metrics, we can start sending data to the TSD. Let's write a little shell script to collect some data off of MySQL and send it to the TSD::

  cat >mysql-collector.sh <<\EOF
  #!/bin/bash
  set -e
  while true; do
    mysql -u USER -pPASS --batch -N --execute "SHOW STATUS LIKE 'bytes%'" \
    | awk -F"\t" -v now=`date +%s` -v host=`hostname` \
      '{ print "put mysql." tolower($1) " " now " " $2 " host=" host }'
    sleep 15
  done | nc -w 30 host.name.of.tsd PORT
  EOF
  chmod +x mysql-collector.sh
  nohup ./mysql-collector.sh &

Every 15 seconds, the script will collect 2 data points from MySQL and send them to the TSD. You can use a smaller sleep interval for greater granularity.

What does the script do? If you're not a big fan of shell and awk scripting, it may not be obvious how this works. But it's simple. The ``set -e`` command simply instructs bash to exit with an error if any of the commands fail. This simplifies error handling. The script then enters an infinite loop. In this loop, we query MySQL to retrieve 2 of its status variables::

  $ mysql -u USER -pPASS --execute "SHOW STATUS LIKE 'bytes%'"
  +----------------+-------+
  | Variable_name  | Value |
  +----------------+-------+
  | Bytes_received | 133   |
  | Bytes_sent     | 190   |
  +----------------+-------+

The ``--batch -N`` flags ask the mysql command to remove the human friendly fluff so we don't have to filter it out ourselves. Then the output is piped to awk, which is told to split fields on tabs ``-F"\t"`` because with the ``--batch`` flag that's what mysql will use. We also create a couple of variables, one named ``now` and initialize it to the current timestamp, the other named ``host` and set to the hostname of the local machine. Then, for every line, we print put ``mysql.``, followed by the lower-case form of the first word, then by a space, then by the current timestamp, then by the second word (the value), another space, and finally ``host=`` and the current hostname. Rinse and repeat every 15 seconds. The ``-w 30`` parameter given to ``nc`` simply sets a timeout on the connection to the TSD.
Bear in mind, this is just an example, in practice you can use tcollector's MySQL collector.

If you don't have a MySQL server to monitor, you can try this instead to collect basic load metrics from your Linux servers::

  cat >loadavg-collector.sh <<\EOF
  #!/bin/bash
  set -e
  while true; do
    awk -v now=`date +%s` -v host=`hostname` \
    '{ print "put proc.loadavg.1m " now " " $1 " host=" host;
      print "put proc.loadavg.5m " now " " $2 " host=" host }' /proc/loadavg
    sleep 15
  done | nc -w 30 host.name.of.tsd PORT
  EOF
  chmod +x loadavg-collector.sh
  nohup ./loadavg-collector.sh &

This will store a reading of the 1-minute and 5-minute load average of your server in OpenTSDB by sending simple "telnet-style commands" to the TSD::

  put proc.loadavg.1m 1288946927 0.36 host=foo
  put proc.loadavg.5m 1288946927 0.62 host=foo
  put proc.loadavg.1m 1288946942 0.43 host=foo
  put proc.loadavg.5m 1288946942 0.62 host=foo

Batch Imports
^^^^^^^^^^^^^
.. index:: Batch Importing
Let's imagine that you have a cron job that crunches gigabytes of application logs every day or every hour to extract profiling data. For instance, you could be logging the time taken to process a request and your cron job would compute an average for every 30 second window. Maybe you're particularly interested in 2 types of requests handled by your application, so you'll compute separate averages for those requests, and an another average for every other request type. So your cron job may produce an output file that looks like this::

  1288900000 42 foo
  1288900000 51 bar
  1288900000 69 other
  1288900030 40 foo
  1288900030 59 bar
  1288900030 80 other

The first column is a timestamp, the second is the average latency for that 30 second window, and the third is the type of request we're talking about. If you run your cron job on a day worth of logs, you'll end up with 8640 such lines. In order to import those into OpenTSDB, you need to adjust your cron job slightly to produce its output in the following format::

  myservice.latency.avg 1288900000 42 reqtype=foo
  myservice.latency.avg 1288900000 51 reqtype=bar
  myservice.latency.avg 1288900000 69 reqtype=other
  myservice.latency.avg 1288900030 40 reqtype=foo
  myservice.latency.avg 1288900030 59 reqtype=bar
  myservice.latency.avg 1288900030 80 reqtype=other

Notice we're simply associating each data point with the name of a metric (myservice.latency.avg) and naming the tag that represents the request type. If each server has its own logs and you process them separately, you may want to add another tag to each line like the ``host=foo`` tag we saw in the previous section. This way you'll be able to plot the latency of each server individually, in addition to your average latency across the board and/or per request type.
In order to import a data file in the format above (metric timestamp value tags) simply run the following command::

  ./tsdb import your-file

If your data file is large, consider gzip'ing it first. This can be as simple as piping the output of your cron job to ``gzip -9 >output.gz`` instead of writing directly to a file. The import command is able to read gzip'ed files and it greatly helps performance for large batch imports.

Self Monitoring
^^^^^^^^^^^^^^^
.. index:: Monitoring TSDs
Each TSD exports some stats about itself through the simple stats command. You can collect those stats and feed them back to the TSD every few seconds. First, create the necessary metrics::

  echo stats | nc -w 1 localhost 4242 \
  | awk '{ print $1 }' | sort -u \
  | xargs ./tsdb mkmetric

This requests the stats from the TSD (assuming it's running on the local host and listening to port 4242), extract the names of the metrics from the stats and assigns them UIDs.
Then you can use this simple script to collect stats and store them in OpenTSDB::

  #!/bin/bash
  INTERVAL=15
  while :; do
    echo stats || exit
    sleep $INTERVAL
  done | nc -w 30 localhost $1 \
      | sed 's/^/put /' \
      | nc -w 30 localhost $1

This way you will collect and store stats from the TSD every 15 seconds.

Create a Graph
^^^^^^^^^^^^^^

Once you've written some data using any of the methods above, you can now try to create a graph using that data. Pull up the GUI in your favorite browser. If you're running your TSD on the localhost, simply visit `http://127.0.0.1:4242 <http://127.0.0.1:4242>`_.

First, pick one of the metrics and put that in the ``Metric`` box. For example, ``proc.loadavg.1m``. As you type, you should see auto-complete lines pop up and you can click on any of them.

Then click the ``From`` box at the top and a date-picker pop-up should appear. Select any time from yesterday and click on another box. At this point you should see "Loading graph.." very briefly followed by the actual graph. If the graph is empty, it may not have found the most recent data points so click the ``(now)`` link and the page should refresh.

This initial graph will aggregate all of the time series for the metric you selected. Try limiting your query to a specific host by adding ``host`` as a value in the left-hand box next to the ``Tags`` label (if it isn't already there) and add the specific host name (e.g. ``foo``) in the right-hand box. After clicking in another box you should see the graph re-draw with different information.
