Metadata
========

The primary purpose of OpenTSDB is to store timeseries data points and allow for various operations on that data. However it helps to know what kind of data is stored and provide some context when working with the information. OpenTSDB's metadata is data about the data points. Much of it is user configurable to provide tie-ins with external tools such as search engines or issue tracking systems. This chapter describes various metadata available and what it's used for.

UIDMeta
^^^^^^^

Every data point stored in OpenTSDB has at least three UIDs associated with it. There will always be a ``metric`` and one or more tag pairs consisting of a ``tagk`` or tag name, and a ``tagv`` or tag value. When a new name for orne of these UIDs comes into the system, a Unique ID is assigned so that there is always a UID name and numeric identifier pair. 

Each UID may also have a metadata entry recorded in the ``tsdb-uid`` table. Data available for each UID includes immutable fields such as the ``uid``, ``type``, ``name`` and ``created`` timestamp that reflects the time when the UID was first assigned. Additionaly some fields may be edited such as the ``description``, ``notes``, ``displayName`` and a set of ``custom`` key/value pairs to record extra information. For details on the fields, see the :doc:`../api_http/uid/uidmeta` endpoint.

Whenever a new UIDMeta object is created or modified, it will be pushed to the Search plugin if a plugin has been configured and loaded. For information about UID values, see :doc:`uids`.

TSMeta
^^^^^^

Each timeseries in OpenTSDB is uniquely identified by the combination of it's metric UID and tag name/value UIDs, creating a TSUID as per :doc:`uids`. When a new timeseries is received, a TSMeta object can be recorded in the ``tsdb-uid`` table in a row identified by the TSUID. The meta object includes some immutable fields such as the ``tsuid``, ``metric``, ``tags``, ``lastReceived`` and ``created`` timestamp that reflects the time when the TSMeta was first received. Additionally some fields can be edited such as a ``description``, ``notes`` and others. See :doc:`../api_http/uid/tsmeta` for details.

Enabling Metadata
^^^^^^^^^^^^^^^^^

If you want to use metadata in your OpenTSDB setup, you must explicitly enable real-time metadata tracking and/or use the CLI tools. There are multiple options for meta data generation due to impacts on performance, so before you enable any of these settings, please test the impact on your TSDs before enabling the settings in production. 

Three options are available, starting with the least impact to the most.

* ``tsd.core.meta.enable_tsuid_incrementing`` - When this setting is enabled, every data point written will increment a counter in the ``tsdb-meta`` table corresponding to the time series the data point belongs to. Future query optimization will make heavy use of this feature so we highly recommend that you enable it for all of your TSDs where data is inbound. 
* ``tsd.core.meta.enable_realtime_uid`` - When enabled, any time a new metric, tag name or tag value is assigned a UID, a UIDMeta object is generated and optionally sent to the configured search plugin. Generally this incurs a small performance impact so we recommend enabling this setting as well.
* ``tsd.core.meta.enable_realtime_ts`` - When enabled, any time a new time series arrives, a TSMeta object will be created and optionally sent to a configured search plugin. This option will also enabled the ``tsd.core.meta.enable_tsuid_incrementing`` setting even if it's explicitly set to ``false`` in the config. If you often push new time series to your TSDs, this option may incur a fair amount of overhead and require some garbage collection tuning. If you do not often push new time series, you should be able to enable this setting without a problem, but watch the memory usage of your TSDs.

For situations where a TSD crashes before metadata can be written to storage or if you do not enable real-time tracking, you can periodically use the ``uid`` CLI tool and the ``metasync`` sub command to generate missing UIDMeta and TSMeta objects. See :doc:`cli/uid` for information.

Annotations
^^^^^^^^^^^

Another form of metadata is the *annotation*. Annotations are simple objects associated with a timestamp and, optionally, a timeseries. Annotations are meant to be a very basic means of recording an event. They are not intended as an event management or issue tracking system. Rather they can be used to link a timeseries to such an external system.

Every annotation is associated with a start timestamp. This determines where the note is stored in the backend and may be the start of an event with a beggining and end, or just used to record a note at a specific point in time. Optionally an end timestamp can be set if the note represents a time span, such as an issue that was resolved some time after the start.

Additionally, an annotation is defined by a TSUID. If the TSUID field is set to a valid TSUID, the annotation will be stored, and associated, along with the data points for the timeseries defined by the ID. This means that when creating a query for data points, any annotations stored within the requested timespan will be retrieved and optionally returned to the user. These annotations are considered "local".

If the TSUID is empty, the annotation is considered a "global" notation, something associated with all timeseries in the system. When querying, the user can specify that global annotations be fetched for the timespan of the query. These notes will then be returned along with "local" annotations.

Annotations should have a very brief *description*, limited to 25 characters or so since the note may appear on a graph. If the requested timespan has many annotations, the graph can become clogged with notes. User interfaces can then let the user select an annotation to retrieve greater detail. This detail may include lengthy "notes" and/or a custom map of key/value pairs.

Users can add, edit and delete annotations via the Http API at :doc:`../api_http/annotation`.

An example GnuPlot graph with annotation markers appears below. Notice how only the ``description`` field appears in a box with a blue line recording the ``start_time``. Only the ``start_time`` appears on the graph.

.. image:: ../images/annotation_ex.png