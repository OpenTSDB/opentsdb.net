Metadata
========

The primary purpose of OpenTSDB is to store timeseries data points and allow for various operations on that data. However it helps ot know what kind of data is stored and provide some context when working with the information. OpenTSDB's metadata is data about the data points. Much of it is user configurable to provide tie-ins with external tools such as search engines or issue tracking systems. This chapter describes various metadata available and what it's used for.

UIDMeta
=======

Every data point stored in OpenTSDB has at least three UIDs associated with it. There will always be a ``metric`` and one or more tag pairs consisting of a ``tagk`` or tag name, and a ``tagv`` or tag value. When a new name for orne of these UIDs comes into the system, a Unique ID is assigned so that there is always a UID name and numeric identifier pair. 

Each UID may also have a metadata entry recorded in the ``tsdb-uid`` table. Data available for each UID includes immutable fields such as the ``uid``, ``type``, ``name`` and ``created`` timestamp that reflects the time when the UID was first assigned. Additionaly some fields may be edited such as the ``description``, ``notes``, ``displayName`` and a set of ``custom`` key/value pairs to record extra information. For details on the fields, see the :doc:`../api_http/uid/uidmeta` endpoint.

Whenever a new UIDMeta object is created or modified, it will be pushed to the Search plugin if a plugin has been configured and loaded. For information about UID values, see :doc:`uids`.

TSMeta
======

Each timeseries in OpenTSDB is uniquely identified by the combination of it's metric UID and tag name/value UIDs, creating a TSUID as per :doc:`uids`. When a new timeseries is received, a TSMeta object can be recorded in the ``tsdb-uid`` table in a row identified by the TSUID. The meta object includes some immutable fields such as the ``tsuid``, ``metric``, ``tags``, ``lastReceived`` and ``created`` timestamp that reflects the time when the TSMeta was first received. Additionally some fields can be edited such as a ``description``, ``notes`` and others. See :doc:`../api_http/uid/tsmeta` for details.

Tracking
========

If you want to use metadata in your OpenTSDB setup, you must explicitly enable real-time metadata tracking and/or use the CLI tools. In the configuration file, you can set ``tsd.core.meta.enable_tracking`` to ``true`` for a TSD and each time a new UID is assigned a UIDMeta object will be recorded. Every data point will also increment a counter in the ``tsdb-uid`` table that indicates a data point was received. The first time this counter is created, a new TSMeta object will be recorded.

.. NOTE:: For extremely busy TSDs that are receiving many data points per second, you may want to leave meta tracking disabled to increase throughput. For most TSDs you shouldn't have a problem enabling this setting.

For situations where a TSD crashes or if you do not enable real-time tracking, you can periodically use the ``uid`` CLI tool and the ``metasync`` sub command to generate missing UIDMeta and TSMeta objects. See :doc:`cli/uid` for information.