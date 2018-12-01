fsck
====
.. index:: CLI FSCK
Similar to a file system check, the fsck command will scan and, optionally, attempt to repair problems with data points in OpenTSDB's data table. The fsck command only operates on the ``tsdb`` storage table, scanning the entire data table or any rows of data that match on a given query. Fsck can be used to repair errors and also reclaim space by compacting rows that were not compacted by a TSD and variable-length encoding data points from previous versions of OpenTSDB.

By default, running fsck will only report errors found by the query. No changes are made to the underlying data unless you supply the ``--fix`` or ``--fix-all`` flags. Generally you should run an fsck without a fix flag first and verify issues found in the log file. If you're confident in the repairs, add a fix flag. Not all errors can be repaired automatically.

.. WARNING:: Running fsck with ``--fix`` or ``--fix-all`` may delete data points, columns or entire rows and deleted data is unrecoverable unless you restore from a backup. (or perform some HBase trickery to restore the data before a major compaction)

.. NOTE:: This page documents the OpenTSDB 2.1 fsck utility. For previous versions, only the ``--fix`` flag is available and only data within a query may be fsckd.

Parameters
^^^^^^^^^^

.. code-block :: bash

  fsck [flags] [START-DATE [END-DATE] query [queries...]] 

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 15, 5, 40, 5, 35
   
   "--fix", "Flag", "Optional flag that will attempt to repair errors. By itself, fix will only repair sign extension bugs, 8 byte floats with 4 byte qualifiers and VLE stand-alone data points. Use in conjunction with other flags to repair more issues.", "Not set", "--fix"
   "--fix-all", "Flag", "Sets all repair flags to attempt to fix all issues at once. **Use with caution**", "Not set", "--fix"
   "--compact", "Flag", "Compacts non-compacted rows during a repair.", "Not Set", "--compact"
   "--delete-bad-compacts", "Flag", "Removes columns that appear to be compacted but failed parsing. If a column parses properly but the final byte of the value is not set to a 0 or a 1, the column will be left alone.", "Not Set", "--delete-bad-compacts"
   "--delete-bad-rows", "Flag", "Removes any row that doesn't match the OpenTSDB row key format of a metric UID followed by a timestamp and tag UIDs.", "Not Set", "--delete-bad-rows"
   "--delete-bad-values", "Flag", "Removes any stand-alone data points that could not be repaired or did not conform to the OpenTSDB specification.", "Not Set", "--delete-bad-values"
   "--delete-orphans", "Flag", "Removes rows where one or more UIDs could not be resolved to a name.", "Not Set", "--delete-orphans"
   "--delete-unknown_columns", "Flag", "Removes any column that does not appear to be a compacted column, a stand-alone data point or a known or future OpenTSDB object.", "Not Set", "--delete-unknown-columns"
   "--resolve-duplicates", "Flag", "Enables duplicate data point resolution by deleting all but the latest or oldest data point. Also see ``--last-write-wins``.", "Not Set", "--resolve-duplicates"
   "--last-write-wins", "Flag", "When set, deletes all but the most recently written data point when resolving duplicates. If the config value ``tsd.storage.fix_duplicates`` is set to true, then the latest data point will be kept regardless of this value.", "Not Set", "--last-write-wins"
   "--full-scan", "Flag", "Scans the entire data table. **Note:** This can take a very long time to complete.", "Not Set", "--full-scan"
   "--threads", "Integer", "The number of threads to use when performing a full scan. The default is twice the number of CPU cores.", "2 x CPU Cores", "--threads=16"
   "START-DATE", "String or Integer", "Starting time for the query. This may be an absolute or relative time. See :doc:`../query/dates` for details", "", "1h-ago"
   "END-DATE", "String or Integer", "Optional end time for the query. If not provided, the current time is used. This may be an absolute or relative time. See :doc:`../query/dates` for details", "Current timestamp", "2014/01/01-00:00:00"
   "query", "String", "One or more command line queries", "", "sum tsd.hbase.rpcs type=put"
   
Examples
^^^^^^^^

**Query**

.. code-block :: bash

  fsck --fix 1h-ago now sum tsd.hbase.rpcs type=put sum tsd.hbase.rpcs type=scan

**Full Table**

.. code-block :: bash

  fsck --full-scan --threads=8 --fix --resolve-duplicates --compact

Full Table Vs Queries
^^^^^^^^^^^^^^^^^^^^^

Using the ``--full-scan`` flag, the entire OpenTSDB ``tsdb`` data table will be scanned. By default the utility will launch ``2 x CPU core`` threads for optimal performance. Data is stored with the metric UID as the start of each row key so the utility will determine the maximum metric UID and split up the main data table equally among threads. If your data is distributed among metrics fairly evenly, then each thread should complete in roughly the same amount of time. However some metrics usually have more data or time series than others so these threads may be running much longer than others. Future updates to OpenTSDB will be able to divy up the workload in a more efficient manner.

Alternatively you can spcify a CLI query to fsck over a smaller timespan and look at a specific metric or time series. These queries will almost always complete much faster than a full scan and will uncover similar issues. However orphaned metrics will not found as the query will only operate on known time series. Orphans where tag names or values have been deleted will still be found.

Regardless of the method used, fsck only looks at the most recent column value in HBase. If the table is configured to store multiple versions, older versions of a column are ignored.

Results
^^^^^^^

The results will be logged with settings in the ``logback.xml`` file. For long fscks, it's recommended to run in the background and configure LogBack to have plenty of space for writing data. On completion, statistics about the run will be printed. An example looks like:

::

  2014-07-07 13:09:15,610 INFO  [main] Fsck: Starting full table scan
  2014-07-07 13:09:15,619 INFO  [main] Fsck: Max metric ID is [0]
  2014-07-07 13:09:15,619 INFO  [main] Fsck: Spooling up [1] worker threads
  2014-07-07 13:09:16,358 INFO  [main] Fsck: Thread [0] Finished
  2014-07-07 13:09:16,358 INFO  [main] Fsck: Key Values Processed: 301
  2014-07-07 13:09:16,358 INFO  [main] Fsck: Rows Processed: 1
  2014-07-07 13:09:16,359 INFO  [main] Fsck: Valid Datapoints: 300
  2014-07-07 13:09:16,359 INFO  [main] Fsck: Annotations: 1
  2014-07-07 13:09:16,359 INFO  [main] Fsck: Invalid Row Keys Found: 0
  2014-07-07 13:09:16,360 INFO  [main] Fsck: Invalid Rows Deleted: 0
  2014-07-07 13:09:16,360 INFO  [main] Fsck: Duplicate Datapoints: 0
  2014-07-07 13:09:16,360 INFO  [main] Fsck: Duplicate Datapoints Resolved: 0
  2014-07-07 13:09:16,361 INFO  [main] Fsck: Orphaned UID Rows: 0
  2014-07-07 13:09:16,361 INFO  [main] Fsck: Orphaned UID Rows Deleted: 0
  2014-07-07 13:09:16,361 INFO  [main] Fsck: Possible Future Objects: 0
  2014-07-07 13:09:16,362 INFO  [main] Fsck: Unknown Objects: 0
  2014-07-07 13:09:16,362 INFO  [main] Fsck: Unknown Objects Deleted: 0
  2014-07-07 13:09:16,362 INFO  [main] Fsck: Unparseable Datapoint Values: 0
  2014-07-07 13:09:16,362 INFO  [main] Fsck: Unparseable Datapoint Values Deleted: 0
  2014-07-07 13:09:16,363 INFO  [main] Fsck: Improperly Encoded Floating Point Values: 0
  2014-07-07 13:09:16,363 INFO  [main] Fsck: Improperly Encoded Floating Point Values Fixed: 0
  2014-07-07 13:09:16,363 INFO  [main] Fsck: Unparseable Compacted Columns: 0
  2014-07-07 13:09:16,364 INFO  [main] Fsck: Unparseable Compacted Columns Deleted: 0
  2014-07-07 13:09:16,364 INFO  [main] Fsck: Datapoints Qualified for VLE : 0
  2014-07-07 13:09:16,364 INFO  [main] Fsck: Datapoints Compressed with VLE: 0
  2014-07-07 13:09:16,365 INFO  [main] Fsck: Bytes Saved with VLE: 0
  2014-07-07 13:09:16,365 INFO  [main] Fsck: Total Errors: 0
  2014-07-07 13:09:16,366 INFO  [main] Fsck: Total Correctable Errors: 0
  2014-07-07 13:09:16,366 INFO  [main] Fsck: Total Errors Fixed: 0
  2014-07-07 13:09:16,366 INFO  [main] Fsck: Completed fsck in [1] seconds

For the most part, these statistics should be self-explanatory. ``Key Values Processed`` indicates the number of individual columns in HBase. ``VLE`` referse to ``variable length encoding``. 

During a run, progress will be reported every 5 seconds so that you know the utility is still working. You should see lines similar to the following:

::

  10:14:00.518 INFO  [Fsck.run] - Processed 47689680000 rows, 449891670779 valid datapoints
  10:14:01.518 INFO  [Fsck.run] - Processed 47689730000 rows, 449892264237 valid datapoints
  10:14:02.519 INFO  [Fsck.run] - Processed 47689780000 rows, 449892880333 valid datapoints

Any time an error is found (and possibly fixed), the log will be updated immediately. Errors will usually include the column where the error was found in the output. Byte arrays are represented in either Java style signed bytes, e.g. ``[0, 1, -42]`` or hex encoded strings, e.g. ``00000000000000040000000000000005``. Short-hand references include (k) for the row key, (q) for the qualifier and (v) for the value. 

Types of Errors and Fixes
^^^^^^^^^^^^^^^^^^^^^^^^^
The following is a list of errors and/or fixes that can be found or performed with fsck.

Bad Row Keys
------------

If a row key is found that doesn't conform to the OpenTSDB data table specification ``<metric_UID><base_timestamp><tagk1_UID><tagv1_UID>[...<tagkn_UID><tagvn_UID>]``, the entire row is considered invalid.

.. code-block :: bash

  2014-07-07 15:03:46,483 ERROR [Fsck #0] Fsck: Invalid row key.
	Key: 000001
	
*Fix:*

If ``--delete-bad-rows`` is set, then the entire row will be removed from HBase.

Orphaned Rows
-------------

If a row key is parsed as a proper OpenTSDB row, then the UIDs for the time series ID (TSUID) of the row are resolved to their names. If any of the UIDs does not match a name in the ``tsdb-uid`` table, then the row is considered an orphan. This can happen if a UID is manually deleted from the UID table or a deletion does not complete properly.

.. code-block :: bash

  2014-07-07 15:08:45,057 ERROR [Fsck #0] Fsck: Unable to resolve the metric from the row key.
	Key: 00000150E22700000001000001
	No such unique ID for 'metric': [0, 0, 1]

*Fix:*

If ``--delete-orphans`` is set, then the entire row will be removed from HBase.

Compact Row
-----------

While it's not strictly an error, fsck can be used to compact rows into a single column. Compacting rows saves storage space by merging multiple columns into one. This cuts down on HBase overhead. If a TSD that is configured to compact columns crashes, some rows may be missed and remain in stand-alone data point form. As compaction can consume resources, you can use fsck to compact rows when the load on your cluster is reduced.

Specifying the ``--compact`` flag along with ``--fix`` will compact any row that has stand-alone data points within the query range. During compaction, any data points from old OpenTSDB versions that qualify for VLE will be re-encoded.

.. NOTE:: If a row is repaired for any reason and has one or more compacted columns, the row will be re-compacted regardless of the ``--compact`` flag.

Bad Compacted Column Error
--------------------------

These errors occur when compacted column is found that cannot be parsed into individual data points. This can happen if the qualifier appears correct but the number of bytes in the value array do not match the lengths encoded in the qualifier. Compacted columns with their data points out of order are not considered bad columns. Instead, the column will be sorted properly and re-written if the ``--fix`` or ``--fix-all`` flags are present.

.. code-block :: bash

  2014-07-07 13:29:40,251 ERROR [Fsck #0] Fsck: Corrupted value: couldn't break down into individual values (consumed 20 bytes, but was expecting to consume 24): [k '00000150E22700000001000001' q '000700270033' v '00000000000000040000000000000005000000000000000600'], cells so far: [Cell([0, 7], [0, 0, 0, 0, 0, 0, 0, 4]), Cell([0, 39], [0, 0, 0, 0, 0, 0, 0, 5]), Cell([0, 51], [0, 0, 0, 0])]

*Fix:*

The only fix for this error is to delete the column by specifying the ``--delete-bad-compacts`` flag.

Compacted Last Byte Error
-------------------------

The last byte of a compacted value is for storing meta data. It will usually be ``0`` if all of the data points are encoded in seconds or milliseconds. If there is a mixture of seconds and milliseconds will be set to ``1``. If the value is something else then it may be from a future version of OpenTSDB or the column may be invalid.

.. code-block :: bash

  18:13:35.979 [main] ERROR net.opentsdb.tools.Fsck - The last byte of a compacted should be 0 or 1. Either this value is corrupted or it was written by a future version of OpenTSDB.
	[k '00000150E22700000001000001' q '00070027' v '00000000000000040000000000000005']

*Fix:*

Currently this is not repaired. You can manually set the last byte to 0 or 1 to prevent the error from being thrown. The ``--delete-bad-compacts`` flag will not remove these columns.

Value Too Long Or Short
-----------------------

This may occur if a value is recorded on greater than 8 bytes for a single data point column. Individual data points are stored on 2 or 4 byte qualifiers. This error cannot happen for a data point within a compacted column. If it was compacted, the column would throw a bad compacted column error as it wouldn't be parseable.

.. code-block :: bash

  2014-07-07 14:50:44,022 ERROR [Fsck #0] Fsck: This floating point value must be encoded either on 4 or 8 bytes, but it's on 9 bytes.
	[k '00000150E22700000001000001' q 'F000020B' v '000000000000000005']

*Fix:*

``--delete-bad-values`` will remove the column.

Old Version Floats
------------------

Early OpenTSDB versions had a bug in the floating point value storage where the first 4 bytes of an 8 byte value were written with all bits set to 1. The value should be on the last four bytes as the qualifier encodes the length as four bytes. However if the invalid data was compacted, the data cannot be parsed properly and an error will be recorded.

.. code-block :: bash

  18:43:35.297 [main] ERROR net.opentsdb.tools.Fsck - Floating point value with 0xFF most significant bytes, probably caused by sign extension bug present in revisions [96908436..607256fc].
	[k '00000150E22700000001000001' q '002B' v 'FFFFFFFF43FA6666']

*Fix:*

The ``--fix`` flag will repair these errors by rewriting the value without the first four bytes. The qualifier remains unchanged.

4 Byte Floats with 8 Byte Value OK
----------------------------------

Some versions of OpenTSDB may have encoded floating point values on 8 bytes when setting the qualifier length to 4 bytes. The first four bytes should be 0. If the value was compacted, the compacted column will be invalid as parsing is no longer possible.

.. code-block :: bash

  2014-07-07 14:33:34,498 WARN  [Fsck #0] Fsck: Floating point value was marked as 4 bytes long but was actually 8 bytes long
	[k '00000150E22700000001000001' q '000B' v '0000000040866666']

*Fix:*

The ``--fix`` flag will repair these errors by rewriting the value without the first four bytes. The qualifier remains unchanged.

4 Byte Floats with 8 Byte Value Bad
-----------------------------------

In this case a value was encoded on 8 bytes with the first four bytes set to a non-zero value. It could be that the value is an 8 byte double since OpenTSDB never actually encoded on 8 bytes, the value is likely corrupt. If the value was compacted, the compacted column will be invalid as parsing is no longer possible.

.. code-block :: bash

  2014-07-07 14:37:02,717 ERROR [Fsck #0] Fsck: Floating point value was marked as 4 bytes long but was actually 8 bytes long and the first four bytes were not zeroed
	[k '00000150E22700000001000001' q '002B' v 'FB02F40F43FA6666']

*Fix:*

The ``--delete-bad-values`` flag will remove the column. You could try parsing the value as a Double manually and see if it looks valid, otherwise it's likely a corrupt column.

Unknown Object
--------------

OpenTSDB 2.0 supports objects such as annotations in the data table. If a column is found that doesn't match an OpenTSDB object, a compacted column or a stand-alone data point, it is considered an unknown object and can likely be deleted.

.. code-block :: bash

  2014-07-07 14:55:03,019 ERROR [Fsck #0] Fsck: Unknown qualifier, must be 2, 3, 5 or an even number of bytes.
	[k '00000150E22700000001000001' q '00270401010101' v '0000000000000005']

*Fix:*

The ``--delete-unknown-columns`` flag will remove this column from the row.

Future Object
-------------

Objects are encoded on 3 or 5 byte qualifiers and the type is determined by a prefix. If a prefix is found that OpenTSDB doesn't recognize, then it will report the object but it will not be deleted. Note that this may actually be an unknown or corrupted column as fsck only looks at the qualifier length and the first byte of the qualifier. If that is the case, you can safely delete this column manually.

.. code-block :: bash

  2014-07-07 14:57:15,858 WARN  [Fsck #0] Fsck: Found an object possibly from a future version of OpenTSDB
	[k '00000150E22700000001000001' q '042704' v '467574757265204F626A656374']

*Fix:*

Future objects are left alone during fsck. Querying over the data with a TSD that doesn't support the object will throw an exception but versions that do support the object should procede normally.

Duplicate Timestamps
--------------------

Due to the use of encoding length and type for datapoints in qualifiers, it's possible to record a data point for the same timestamp with two different qualifiers. For example if you post an integer value for time ``1`` and then post a float value for time ``1``, two different columns will be created. Duplicates can also happen if a row has been compacted and the TSD writes a new stand-alone column that matches a timestamp in the compacted column. At query time, an exception will be thrown as TSD does not know which value is the correct one. 

.. code-block :: bash

  2014-07-07 15:22:43,231 ERROR [Fsck #0] Fsck: More than one column had a value for the same timestamp: (1356998400000)
    row key: (00000150E22700000001000001)
    write time: (1388534400000)  compacted: (false)  qualifier: [0, 7]  <--- Keep oldest
    write time: (1388534400001)  compacted: (false)  qualifier: [0, 11]
    write time: (1388534400002)  compacted: (false)  qualifier: [0, 3]
    write time: (1388534400003)  compacted: (false)  qualifier: [0, 1]

*Fix:*

If ``--resolve-duplicates`` is set, then all data points except for the latest or the oldest value will be deleted. The fix applies to both stand-alone and compacted data points. If the ``--last-write-wins`` flag is set, then the latest value is saved. Without the ``--last-write-wins`` flag, then the oldest value is saved.

.. NOTE:: If the ``tsd.storage.fix_duplicates`` configuration value is set to ``true`` then the latest value will be saved regardless of ``--last-write-wins``.

.. NOTE:: With compactions enabled, it is possible (though unlikely) that a data point is written while a row is being compacted. In this case, the compacted column will have a *later* timestamp than a data point written during the compaction. Therefore the default result of ``--resolve-duplicates`` will keep the stand-alone data point or, if last writes win, then the compacted value.

Variable-Length Encoding
------------------------

Early OpenTSDB implementations always encoded integer values on 8 bytes. With 2.0, integers were written on the smallest number of bytes possible, either 1, 2, 4 or 8. During fsck, any 8 byte encoded integers detected will be re-written with VLE if the ``--fix`` or ``--fix-all`` flags are specified. This includes stand-alone and compacted values. At the end of a run, the number of bytes saved with VLE are displayed.