fsck
====

Similar to a file system check, the fsck command will scan and, optionally, attempt to repair problems with data points in OpenTSDB's data table. The fsck command only operates on the ``tsdb`` storage table, scanning any rows of data that match on the given query. Since data tables can be incredibly large, fsck requires a query with a specific timespan so as to avoid taking hours or days to complete. 

By default, running fsck will only report errors found by the query. No changes are made to the underlying data unless you supply the ``--fix`` flag. Not all errors can be repaired automatically.

.. NOTE::

  Running fsck with ``--fix`` may delete data points and deleted data is unrecoverable unless you restore from a backup. (or perform some HBase trickery to restore the data before a major compaction)

Parameters
^^^^^^^^^^

.. code-block :: bash

  fsck [--fix] START-DATE [END-DATE] query [queries...]

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 15, 5, 40, 5, 35
   
   "--fix", "Flag", "Optional flag that will repair errors found within the query span.", "Not set", "--fix"
   "START-DATE", "String or Integer", "Starting time for the query. This may be an absolute or relative time. See :doc:`../query/dates` for details", "", "1h-ago"
   "END-DATE", "String or Integer", "Optional end time for the query. If not provided, the current time is used. This may be an absolute or relative time. See :doc:`../query/dates` for details", "Current timestamp", "2014/01/01-00:00:00"
   "query", "String", "One or more command line queries", "", "sum tsd.hbase.rpcs type=put"
   
Example

.. code-block :: bash

  fsck 1h-ago now sum tsd.hbase.rpcs type=put sum tsd.hbase.rpcs type=scan

Results
^^^^^^^

The results will be printed to standard out with information about what errors were found, how many columns and rows were analyzed and how many errors, if any, were found. Not all errors can be fixed automatically but require user intervention. Below are some examples and whether they can be fixed or not.

When errors are found the output will list the key (k), qualifier (q) and value (v) as hex encoded byte arrays. If you wish to delete the column, use HBase shell and supply the key and qualifier. If using the HBase shell, insert ``\x`` at the beggining and after every other character. E.g. transform the qualifier ``00070027`` to ``\x00\x07\x00\x27``.

No Data
-------

In this situation, no data was found for the given query so there were no errors to repair.

.. code-block :: bash

  0 KVs (in 0 rows) analyzed in 238ms (~0 KV/s)
  No error found.

Compacted Column Error
----------------------

If a compacted column is found that is unparseable or the value  does not end with a zero, an unrecoverable error will be logged. This may mean that data points were dropped or that the value is completely invalid. Instead of deleting the column automatically, the error is flagged and must be removed manually.

.. code-block :: bash

  18:13:35.979 [main] ERROR net.opentsdb.tools.Fsck - The last byte of a compacted should be 0 or 1. Either this value is corrupted or it was written by a future version of OpenTSDB.
	[k '00000150E22700000001000001' q '00070027' v '00000000000000040000000000000005']
  1 KVs (in 1 rows) analyzed in 230ms (~4 KV/s)
  Found 1 errors.

.. NOTE :: If you other kinds of data in the same column family and table as OpenTSDB (not recommended!) those data may appear as compacted column errors. 

Value Too Long
--------------

This may occur if a value is recorded on greater than 8 bytes for a single data point column. Individual data points are stored on 2 or 4 byte qualifiers. his error cannot be fixed automatically.

.. code-block :: bash

  18:19:51.007 [main] ERROR net.opentsdb.tools.Fsck - Value more than 8 byte long with a 2-byte qualifier.
	[k '00000150E22700000001000001' q '0027' v '000000000000000005']
  2 KVs (in 1 rows) analyzed in 227ms (~8 KV/s)
  Found 1 errors.
  
Old Version Floats
------------------

Early OpenTSDB versions had a bug in the floating point value storage. This error can be fixed automatically without loss of data. However if the invalid data was compacted, the data cannot be parsed properly and an error will be recorded.

.. code-block :: bash

  18:43:35.297 [main] ERROR net.opentsdb.tools.Fsck - Floating point value with 0xFF most significant bytes, probably caused by sign extension bug present in revisions [96908436..607256fc].
	[k '00000150E22700000001000001' q '002B' v 'FFFFFFFF43FA6666']
  2 KVs (in 1 rows) analyzed in 239ms (~8 KV/s)
  Found 1 errors.
  1 of these errors are automatically correctable, re-run with --fix.
  Make sure you understand the errors above and you know what you're doing before using --fix.
  
Duplicate Timestamps
--------------------

Due to the use of encoding length and type for datapoints in qualifiers, it's possible to record a data point for the same timestamp with two different qualifiers. For example if you post an integer value for time 1 and then post a float value for time 1, two different columns will be created. At query time, an exception will be thrown as TSD does not know which value is the correct one. If fsck is run with the fix flag, the **oldest** value ``or`` the **compacted** value will be maintained and other values deleted.

.. NOTE :: 
  
  Future versions of OpenTSDB may include the option of choosing the value with the most recent write timestamp. However implementation is tricky due to compaction.

.. code-block :: bash

  18:55:02.247 [main] ERROR net.opentsdb.tools.Fsck - More than one column had a value for the same timestamp: timestamp: (1356998400000)
    [0, 7]
    [0, 11]

  2 KVs (in 1 rows) analyzed in 229ms (~8 KV/s)
  Found 1 errors.
  1 of these errors are automatically correctable, re-run with --fix.
  Make sure you understand the errors above and you know what you're doing before using --fix.