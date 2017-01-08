uid
===
.. index:: CLI UID
The UID utility provides various functions to search or modify information in the ``tsdb-uid`` table. This includes UID assignments for metrics, tag names and tag values as well as UID meta data, timeseries meta data and tree definitions or data. 


Use the UID utility with the command line:
::

  uid <subcommands> [arguments]
  
Common CLI Parameters
^^^^^^^^^^^^^^^^^^^^^

Parameters specific to the UID utility include:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 10, 10, 50, 10, 20
   
   "--idwidth", "Integer", "Number of bytes on which the UniqueId is encoded. This allows for an override of the built in UID width.", "3", "--idwidth=4"
   "--ignore-case", "Flag", "Ignore case distinctions when matching on a regular expression using the ``grep`` sub command", "", "--ignore-case"
   "--verbose", "Flag", "Print logging messages at level DEBUG and higher. The default is for ERROR and higher to be displayed.", "", ""--verbose"
   "-i", "Flag", "Short hand for the ``--ignore-case`` flag", "", "-i"
   "-v", "Flag", "Short hand for the ``--verbose`` flag", "", "-v"

Lookup
^^^^^^

The lookup command is the default for ``uid`` used to lookup the UID assigned to a name or the name assinged to a UID for a given type.

Command Format
--------------
::

  <kind> <name>
  <kind> <UID>

Example Command
---------------
::

  ./tsdb uid tagk host
  
Example Response
---------------
::

  tagk host: [0, 0, 1]

grep
^^^^

The grep sub command performs a regular expression search for the given UID type and returns a list of all UID names that match the expression. Fields required for the grep command include:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 10, 10, 50, 10, 20
   
   "kind", "String", "The type of the UID to search for. Must be one of ``metrics``, ``tagk`` or ``tagv``", "", "tagk"
   "expression", "String", "The regex expression to search with", "", "disk.*write"

Command Format
--------------
::

  grep <kind> '<expression>'

Example Command
---------------
::

  ./tsdb uid grep metrics 'disk.*write'
  
Example Response
----------------
::

  metrics iostat.disk.msec_write: [0, 3, -67]
  metrics iostat.disk.write_merged: [0, 3, -69]
  metrics iostat.disk.write_requests: [0, 3, -70]
  metrics iostat.disk.write_sectors: [0, 3, -68]

assign
^^^^^^

This sub command is used to assign IDs to new unique names for metrics, tag names or tag values. Supply a list of one or more values to assign UIDs and the list of assignments will be returned.

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "kind", "String", "The type of the UID the names represent. Must be one of ``metrics``, ``tagk`` or ``tagv``", "tagk"
   "name", "String", "One or more names to assign UIDs to. Names must not be in quotes and cannot contain spaces.", "owner"

Command Format
--------------
::

  assign <kind> <name> [<name>...]

Example Command
---------------
::

  ./tsdb uid assign metrics disk.d0 disk.d1 disk.d2 disk.d3

Example Response
----------------

rename
^^^^^^

Changes the name of an already assigned UID. If the UID of the given type does not exist, an error will be returned. 

.. NOTE:: After changing a UID name you must flush the cache (see :doc:`../../api_http/dropcaches`) or restart all TSDs for the change to take effect. TSDs do not periodically reload UID maps.

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "kind", "String", "The type of the UID the name represent. Must be one of ``metrics``, ``tagk`` or ``tagv``", "tagk"
   "name", "String", "The existing UID name", "owner"
   "newname", "String", "The new name UID name", "server_owner"
   
Command Format
--------------
::

  rename <kind> <name> <newname>

Example Command
---------------
::

  ./tsdb uid rename metrics disk.d0 disk.d0.bytes_read

delete
^^^^^^

Removes the mapping of the UID from the ``tsdb-uid`` table. Make sure all sources are no longer writing data using the UID and that sufficient time has passed so that users would not query for data that used the UIDs.

.. NOTE:: After deleting a UID, it may still remain in the caches of running TSD servers. Make sure to flush their caches after deleting an entry.

.. WARNING:: Deleting a UID will not delete the underlying data associated with the UIDs (we're working on that). For metrics this is safe, it won't affect queries. But for tag names and values, if a query scans over data containing the old UID, the query will fail with an exception because it can no longer find the name mapping.

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "kind", "String", "The type of the UID the name represent. Must be one of ``metrics``, ``tagk`` or ``tagv``", "tagk"
   "name", "String", "The existing UID name", "owner"
   
Command Format
--------------
::

  delete <kind> <name>

Example Command
---------------
::

  ./tsdb uid delete disk.d0

fsck
^^^^

The UID FSCK command will scan the entire UID table for errors pertaining to name and UID mappings. By default, the run will scan every column in the table and log any errors that were found. With version 2.1 it is possible to fix errors in the table by passing the "fix" flag. UIDMeta objects are skipped during scanning. Possible errors include:

.. csv-table::
   :header: "Error", "Description", "Fix"
   :widths: 33, 34, 33
   
   "Max ID for metrics is 42 but only 41 entries were found.  Maybe 1 IDs were deleted?", "This indicates one or more UIDs were not used for mapping entries. If a UID was deleted, this message is normal. If UIDs were not deleted, this can indicate wasted UIDs due to auto-assignments by TSDs where data was coming in too fast. Try assigning UIDs up-front as much as possible.", "No fix necessary"
   "We found an ID of 42 for metrics but the max ID is only 41!  Future IDs may be double-assigned!", "If this happens it is usually due to a corruption and indicates the max ID row was not updated properly.", "Set the max ID row to the largest detected value"
   "Invalid maximum ID for metrics: should be on 8 bytes", "Indicates a corruption in the max ID row.", "No fix yet."
   "Forward metrics mapping is missing reverse mapping: foo -> 000001", "This may occur if a TSD crashes before the reverse map is written and would only prevent queries from executing against time series using the UID as they would not be able to lookukp the name.", "The fix is to restore the missing reverse map."
   "Forward metrics mapping bar -> 000001 is different than reverse mapping: 000001 -> foo", "The reverse map points to a different name than the forward map and this should rarely happen. It will be paired with another message.", "Depends on the second message"
   "Inconsistent forward metrics mapping bar -> 000001 vs bar -> foo / foo -> 000001", "With a forward/reverse miss-match, it is possible that a UID was assigned to multiple names for the same type. If this occurs, then data for two different names has been written to the same time series and that data is effectively corrupt.", "The fix is to delete the forward maps for all names that map to the same UID. Then the UID is given a new name that is a dot seperated concatenation of the previous names with an ""fsck"" prefix. E.g. in the example above we would have a new name of ""fsck.bar.foo"". This name may be used to access data from the corrupt time series. The next time data is written for the errant names, new UIDs will be assigned to each and new time series created."
   "Duplicate forward metrics mapping bar -> 000002 and null -> foo", "In this case the UID was not used more than once but the reverse mapping was incorrect.", "The reverse map will be restored, in this case: 000002 -> bar"
   "Reverse metrics mapping is missing forward mapping: bar -> 000002", "A reverse map was found without a forward map. The UID may have been deleted.", "Remove the reverse map"
   "Inconsistent reverse metrics mapping 000003 -> foo vs 000001 -> foo / foo -> 000001", "If an orphaned reverse map points to a resolved forward map, this error occurs.", "Remove the reverse map"

**Options**

* fix - Attempts to fix errors per the table above
* delete_unknown - Removes any columns in the UID table that do not belong to OpenTSDB

Command Format
--------------
::

  fsck [fix] [delete_unknown]
  
Example Command
---------------
::

  ./tsdb uid fsck fix
  
Example Response
----------------
::

  INFO  [main] UidManager: ----------------------------------
  INFO  [main] UidManager: -    Running fsck in FIX mode    -
  INFO  [main] UidManager: -      Remove Unknowns: false    -
  INFO  [main] UidManager: ----------------------------------
  INFO  [main] UidManager: Maximum ID for metrics: 2
  INFO  [main] UidManager: Maximum ID for tagk: 4
  INFO  [main] UidManager: Maximum ID for tagv: 2
  ERROR [main] UidManager: Forward tagk mapping is missing reverse mapping: bar -> 000004
  INFO  [main] UidManager: FIX: Restoring tagk reverse mapping: 000004 -> bar
  ERROR [main] UidManager: Inconsistent reverse tagk mapping 000003 -> bar vs 000004 -> bar / bar -> 000004
  INFO  [main] UidManager: FIX: Removed tagk reverse mapping: 000003 -> bar
  ERROR [main] UidManager: tagk: Found 2 errors.
  INFO  [main] UidManager: 17 KVs analyzed in 334ms (~50 KV/s)
  WARN  [main] UidManager: 2 errors found.
  
metasync
^^^^^^^^

This command will run through the entire data table, scanning each row of timeseries data and generate missing TSMeta objects and UIDMeta objects or update the created timestamps for each object type if necessary. Use this command after enabling meta tracking with existing data or if you suspect that some timeseries may not have been indexed properly. The command will also push new or updated meta entries to a search engine if a plugin has been configured. If existing meta is corrupted, meaning the TSD is unable to deserialize the object, it will be replaced with a new entry.

It is safe to run this command at any time as it will not destroy or overwrite valid data. (Unless you modify columns directly in HBase in a manner inconsistent with the meta data formats). The utility will split the data table into chunks processed by multiple threads so the more cores in your processor, the faster the command will complete.

.. WARN:: Because the entire ``tsdb`` table is scanned, this command may take a very long time depending on how much data is in your system.

Command Format
--------------
::

  metasync

Example Command
---------------
::

  ./tsdb uid metasync
  
metapurge
^^^^^^^^^

This sub command will mark all TSMeta and UIDMeta objects for deletion in the UID table. This is useful for downgrading from 2.0 to a 1.x version or simply flushing all meta data and starting over with a ``metasync``.

Command Format
--------------
::

  metapurge

Example Command
---------------
::

  ./tsdb uid metapurge
  
treesync
^^^^^^^^

Runs through the list of TSMeta objects in the UID table and processes each through all configured and enabled trees to compile branches. This command may be run at any time and will not affect existing objects.

Command Format
--------------
::

  treesync

Example Command
---------------
::

  ./tsdb uid treesync

treepurge
^^^^^^^^^

Removes all branches, collision, not matched data and optionally the tree definition itself for a given tree. Parameters include:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "id", "Integer", "ID of the tree to purge", "1"
   "definition", "Flag", "Add this literal after the ID to delete the definition of the tree as well as the data", "definition"
   
Command Format
--------------
::

  treepurge <id> [definition]

Example Command
---------------
::

  ./tsdb uid treepurge 1
