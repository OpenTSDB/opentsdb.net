uid
===

The UID utility provides various functions to search or modify information in the ``tsdb-uid`` table. This includes UID assignments for metrics, tag names and tag values as well as UID meta data, timeseries meta data and tree definitions or data. 


Use the UID utility with the command line:
::

  uid <subcommands> [arguments]
  
CLI Parameters
^^^^^^^^^^^^^^

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
======

The lookup command is the default for ``uid`` used to lookup the UID assigned to a name or the name assinged to a UID for a given type.

Command Format
^^^^^^^^^^^^^^
::

  <kind> <name>
  <kind> <UID>

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid tagk
  
Example Response
^^^^^^^^^^^^^^^^
::

  tagk host: [0, 0, 1]

grep
====

The grep sub command performs a regular expression search for the given UID type and returns a list of all UID names that match the expression. Fields required for the grep command include:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 10, 10, 50, 10, 20
   
   "kind", "String", "The type of the UID to search for. Must be one of ``metrics``, ``tagk`` or ``tagv``", "", "tagk"
   "expression", "String", "The regex expression to search with", "", "disk.*write"

Command Format
^^^^^^^^^^^^^^
::

  grep <kind> '<expression>'

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid grep metrics 'disk.*write'
  
Example Response
^^^^^^^^^^^^^^^^
::

  metrics iostat.disk.msec_write: [0, 3, -67]
  metrics iostat.disk.write_merged: [0, 3, -69]
  metrics iostat.disk.write_requests: [0, 3, -70]
  metrics iostat.disk.write_sectors: [0, 3, -68]

assign
======

This sub command is used to assign IDs to new unique names for metrics, tag names or tag values. Supply a list of one or more values to assign UIDs and the list of assignments will be returned.

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "kind", "String", "The type of the UID the names represent. Must be one of ``metrics``, ``tagk`` or ``tagv``", "tagk"
   "name", "String", "One or more names to assign UIDs to. Names must not be in quotes and cannot contain spaces.", "owner"

Command Format
^^^^^^^^^^^^^^
::

  assign <kind> <name> [<name>...]

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid assign metrics disk.d0 disk.d1 disk.d2 disk.d3

Example Response
^^^^^^^^^^^^^^^^

rename
======

Changes the name of an already assigned UID. If the UID of the given type does not exist, an error will be returned. 

.. NOTE:: After changing a UID name you must flush the cache or restart all TSDs for the change to take effect. TSDs do not periodically reload UID maps.

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "kind", "String", "The type of the UID the name represent. Must be one of ``metrics``, ``tagk`` or ``tagv``", "tagk"
   "name", "String", "The existing UID name", "owner"
   "newname", "String", "The new name UID name", "server_owner"
   
Command Format
^^^^^^^^^^^^^^
::

  assign <kind> <name> <newname>

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid rename disk.d0 disk.d0.bytes_read

Example Response
^^^^^^^^^^^^^^^^

fsck
====

TODO

metasync
========

This command will run through the entire data table, scanning each row of timeseries data and generate missing TSMeta objects and UIDMeta objects or update the created timestamps for each object type if necessary. Use this command after enabling meta tracking with existing data or if you suspect that some timeseries may not have been indexed properly. The command will also push new or updated meta entries to a search engine if a plugin has been configured. If existing meta is corrupted, meaning the TSD is unable to deserialize the object, it will be replaced with a new entry.

It is safe to run this command at any time as it will not destroy or overwrite valid data. (Unless you modify columns directly in HBase in a manner inconsistent with the meta data formats). The utility will split the data table into chunks processed by multiple threads so the more cores in your processor, the faster the command will complete.

.. WARN:: Because the entire ``tsdb`` table is scanned, this command may take a very long time depending on how much data is in your system.

Command Format
^^^^^^^^^^^^^^
::

  metasync

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid metasync
  
metapurge
=========

This sub command will mark all TSMeta and UIDMeta objects for deletion in the UID table. This is useful for downgrading from 2.0 to a 1.x version or simply flushing all meta data and starting over with a ``metasync``.

Command Format
^^^^^^^^^^^^^^
::

  metapurge

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid metapurge
  
treesync
========

Runs through the list of TSMeta objects in the UID table and processes each through all configured and enabled trees to compile branches. This command may be run at any time and will not affect existing objects.

Command Format
^^^^^^^^^^^^^^
::

  treesync

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid treesync

treepurge
=========

Removes all branches, collision, not matched data and optionally the tree definition itself for a given tree. Parameters include:

.. csv-table::
   :header: "Name", "Data Type", "Description", "Example"
   :widths: 10, 10, 60, 20
   
   "id", "Integer", "ID of the tree to purge", "1"
   "definition", "Flag", "Add this literal after the ID to delete the definition of the tree as well as the data", "definition"
   
Command Format
^^^^^^^^^^^^^^
::

  treepurge <id> [definition]

Example Command
^^^^^^^^^^^^^^^
::

  ./tsdb uid treepurge 1