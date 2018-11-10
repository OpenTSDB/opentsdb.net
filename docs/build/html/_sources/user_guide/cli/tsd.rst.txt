tsd
===
.. index:: CLI TSD
The TSD command launches the OpenTSDB daemon in the foreground so that it can accept connections over TCP and HTTP. If successful, you should see a number of messages then:

::

  2014-02-26 18:33:02,472 INFO  [main] TSDMain: Ready to serve on 0.0.0.0:4242
  
The daemon will continue to run until killed via a Telnet or HTTP command is sent to tell it to stop. If an error occurred, such as failure to connect to Zookeeper or the inability to bind to the proper interface and port, an error will be logged and the daemon will exit.

Note that the daemon does not fork and run in the background. 