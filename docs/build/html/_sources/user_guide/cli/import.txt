import
======
.. index:: CLI Import
The import command enables bulk loading of time series data into OpenTSDB. You provide one or more files and OpenTSDB will parse and load the data. Data must be formatted in the Telnet ``put`` style with one data point per line in a text file. Each file may optionally be compressed with GZip and if so, must end with the ``.gz`` extension.

For more information on storing data in OpenTSDB, please see :doc:`../writing`

Parameters
^^^^^^^^^^
.. code-block :: bash

  import path [...paths]
  
Paths may be absolute or relative

Example

.. code-block :: bash

  import /home/hobbes/timeseries1.gz /home/hobbes/timeseries2.gz
  
Input Format
^^^^^^^^^^^^

The format is the same as the Telnet ``put`` interface.

..

  <metric> <timestamp> <value> <tagk=tagv> [<tagkN=tagvN>]
  
Where:

  * **metric** Is the name of the metric. Note that the metric name may not include spaces.
  * **timestamp** Is the absolute timestamp of the data point in seconds or milliseconds
  * **value** Is the value to store
  * **tagk=tagv** Is a pair of one or more space sparate tag name and value pairs. Note that the tags may not have spaces in them.

Example:

..

  sys.cpu.user 1356998400 42 host=web01 cpu=0

Successful processing will result in responses like:

..

  23:07:05.323 [main] INFO  net.opentsdb.tools.TextImporter - Processed file in 22 ms, 2 data points (90.9 points/s)
  
However if an error occurs, the importer will stop and the errant line will be printed. For example:

..

  23:07:06.375 [main] ERROR net.opentsdb.tools.TextImporter - Exception caught while processing file timeseries1.gz line=sys.cpu.system 1356998400 42 host=web02 novalue=
  
.. WARNING ::

  Data points processed up to the error are written to storage. You should edit the file and clear all data points up to the line where the error occurred. If you fix the line and restart the import, conflicts may occur with the existing data. Future updates to OpenTSDB will handle this situation gracefully.