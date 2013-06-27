Logging
=======

OpenTSDB uses the `SLF4J <http://www.slf4j.org/>`_ abstraction layer along with `Logback <http://logback.qos.ch/>`_ for logging flexibility. Configuration is performed via an XML file and there are many different formatting, level and destination options.

Levels
^^^^^^

Every log message is accompanied by a descriptive severity level. Levels employed by OpenTSDB include:

* **ERROR** - Something failed, be it invalid data, a failed connection or a bug in the code. You should pay attention to these and figure out what caused the error. Check with the user group for assistance.
* **WARN** - These are often caused by bad user data or something else that was wrong but not a critical error. Look for warnings if you are not receiving the results you expect when using OpenTSDB.
* **INFO** - Informational messages are notifications of expected or normal behavior. They can be useful during troubleshooting. Most logging appenders should be set to ``INFO``.
* **DEBUG** - If you require further troubleshooting you can enable ``DEBUG`` logging that will give much greater detail about what OpenTSDB is doing under the hood. Be careful enabling this level as it can return a vast amount of data. 

Configuration
^^^^^^^^^^^^^

A file called ``logback.xml`` is included in the ``/src`` directory and copied for distributions. On startup, OpenTSDB will search the class path for this file and if found, load the configuration. The default config from GIT will log INFO level events to console and store the 1,024 latest messages in a round-robin buffer to be accessed from the GUI. Packages built from GIT also include rotating file logs. 

The default config for OpenTSDB is:

.. code-block :: xml 

  <?xml version="1.0" encoding="UTF-8"?>
  <configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
      <encoder>
        <pattern>
          %d{ISO8601} %-5level [%thread] %logger{0}: %msg%n
        </pattern>
      </encoder>
    </appender>
    
    <appender name="CYCLIC" class="ch.qos.logback.core.read.CyclicBufferAppender">
      <MaxSize>1024</MaxSize>
    </appender>

    <logger name="org.apache.zookeeper" level="INFO"/>
    <logger name="org.hbase.async" level="INFO"/>
    <logger name="com.stumbleupon.async" level="INFO"/>
    <root level="INFO">
      <appender-ref ref="STDOUT"/>
      <appender-ref ref="CYCLIC"/>
    </root>
  </configuration>

The config is broken up into the following sections:

Appenders
---------

Appenders are destinations where logging information is sent. Typically logging configs send results to the console and a file. Optionally you can send logs to Syslog, email, sockets, databases and more. Each appender section defines a destination, a format and an optional trigger. Read about appenders in the `Logback Manual <http://logback.qos.ch/manual/appenders.html>`_.

Loggers
-------

Loggers determine what data and what level of data is routed to the appenders. Loggers can match a particular Java class namespace and affect all messages emitted from that space. The default OpenTSDB config explicitly lists some loggers for Zookeeper, Asyncbase and the Async libraries to set their levels to ``INFO`` so as to avoid chatty outputs that are not relevant most of the time. If you enable a plugin and start seeing a lot of messages that you don't care about, add a logger entry to suppress the messages.

Root
----

The root section is the catch-all logger that determines that default logging level for all messages that don't match an explicit logger. It also handles routing to the different appenders.

Examples
^^^^^^^^

If you aren't installing from a package, you may want to try adding some of the following appenders to your file.

Log to Rotating File
--------------------

.. code-block :: xml 

  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>/var/log/opentsdb/opentsdb.log</file>
    <append>true</append>
    
    <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
      <fileNamePattern>/var/log/opentsdb/opentsdb.log.%i</fileNamePattern>
      <minIndex>1</minIndex>
      <maxIndex>3</maxIndex>
    </rollingPolicy>

    <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
      <maxFileSize>128MB</maxFileSize>
    </triggeringPolicy>

    <!-- encoders are assigned the type
         ch.qos.logback.classic.encoder.PatternLayoutEncoder by default -->
    <encoder>
      <pattern>%d{HH:mm:ss.SSS} %-5level [%logger{0}.%M] - %msg%n</pattern>
    </encoder>
  </appender>
  
This appender will write to a log file called ``/var/log/opentsdb/opentsdb.log``. When the file reaches 128MB in size, it will rotate the log to ``opentsdb.log.1`` and start a new ``opentsdb.log`` file. Once the new log fills up, it bumps ``.1`` to ``.2``, ``.log`` to ``.1`` and creates a new one. It repeats this until there are four log files in total. The next time the log fills up, the last log is deleted. This way you are gauranteed to only use up to 512MB of disk space. Many other appenders are available so see what fits your needs the best.