Alerting with Nagios
====================

OpenTSDB is great, but it's not (yet) a full monitoring platform. Now that you have a bunch of metrics in OpenTSDB, you want to start sending alerts when thresholds are getting too high. It's easy!

In the ``tools`` directory is a Python script ``check_tsd``. This script queries OpenTSDB and returns Nagios compatible output that gives you OK/WARNING/CRITICAL state.

Parameters
^^^^^^^^^^

::

  Options:
    -h, --help            show this help message and exit
    -H HOST, --host=HOST  Hostname to use to connect to the TSD.
    -p PORT, --port=PORT  Port to connect to the TSD instance on.
    -m METRIC, --metric=METRIC
                          Metric to query.
    -t TAG, --tag=TAG     Tags to filter the metric on.
    -d SECONDS, --duration=SECONDS
                          How far back to look for data. Default 600s.
    -D METHOD, --downsample=METHOD
                          Downsample function, e.g. one of avg, min, sum, max ... etc
    -W SECONDS, --downsample-window=SECONDS
                          Window size over which to downsample.
    -a METHOD, --aggregator=METHOD
                          Aggregation method: avg, min, sum (default), max .. etc
    -x METHOD, --method=METHOD
                          Comparison method: gt, ge, lt, le, eq, ne.
    -r, --rate            Use rate value as comparison operand.
    -w THRESHOLD, --warning=THRESHOLD
                          Threshold for warning.  Uses the comparison method.
    -c THRESHOLD, --critical=THRESHOLD
                          Threshold for critical.  Uses the comparison method.
    -v, --verbose         Be more verbose.
    -T SECONDS, --timeout=SECONDS
                          How long to wait for the response from TSD.
    -E, --no-result-ok    Return OK when TSD query returns no result.
    -I SECONDS, --ignore-recent=SECONDS
                          Ignore data points that are that are that recent.
    -P PERCENT, --percent-over=PERCENT
                          Only alarm if PERCENT of the data points violate the
                          threshold.
    -N UTC, --now=UTC     Set unix timestamp for "now", for testing
    -S, --ssl             Make queries to OpenTSDB via SSL (https)

For a complete list of downsample & aggregation modes, see http://opentsdb.net/docs/build/html/user_guide/query/aggregators.html#available-aggregators


Nagios Setup
^^^^^^^^^^^^

Drop the script into your Nagios path and set up a command like this::

  define command{
          command_name check_tsd
          command_line $USER1$/check_tsd -H $HOSTADDRESS$ $ARG1$
  }
  
Then define a host in nagios for your TSD server(s). You can give it a check_command that is guaranteed to always return something if the backend is healthy.
::

  define host{
          host_name               tsd
          address                 tsd
          check_command           check_tsd!-d 60 -m rate:tsd.rpc.received -t type=put -x lt -c 1
          [...]
  }
  
Then define some service checks for the things you want to monitor.
::

  define service{
          host_name                       tsd
          service_description             Apache too many internal errors
          check_command                   check_tsd!-d 300 -m rate:apache.stats.hits -t status=500 -w 1 -c 2
          [...]
  }

Testing
^^^^^^^

If you have want to test your parameters against some specific point in time, you can use the ``--now <UTC>`` parameter to specify an explicit unix timestamp
which is used as the current timestamp instead of the actual current time.
If set, the script will fetch data starting at ``UTC - duration``, ending at ``UTC``.

To see the values retreived, and potentially ignored (due to duration), use the ``--verbose`` option.
