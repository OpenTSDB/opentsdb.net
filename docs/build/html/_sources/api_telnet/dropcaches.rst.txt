dropcaches
==========
.. index:: Telnet dropcaches
Purges the metric, tag key and tag value UID to string and string to UID maps.

.. NOTICE::
  On a busy server this may cause multiple hits to the UID table in storage.

Request
^^^^^^^

The command format is:

::
  
  dropcaches

Response
^^^^^^^^

An acknowledgement after the caches have been purged.

Example
-------

::
  
  Caches dropped.
 