/api/uid
========

Every metric, tag name and tag value is associated with a unique identifier (UID). Internally, the UID is a binary array assigned to a text value the first time it is encountered or via an explicit assignment request. This endpoint provides utilities for managing UIDs and their associated data. Please see the UID endpoint TOC below for information on what functions are implemented.

UIDs exposed via the API are encoded as hexadecimal strings. The UID ``42`` would be expressed as ``00002A`` given the default UID width of 3 bytes.

You may also edit meta data associated with timeseries or individual UID objects via the UID endpoint.

UID API Endpoints
-----------------

.. toctree::
   :maxdepth: 1
   
   assign
   tsmeta
   uidmeta
