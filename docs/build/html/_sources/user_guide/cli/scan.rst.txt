scan
====
.. index:: CLI Scan
The scan command is useful for debugging and exporting data points. Provide a start time, optional end time and one or more queries and the response will be raw byte data from storage or data points in a text format acceptable for use with the **import** command. Scan also provides a rudimentary means of deleting data. The scan command accepts common CLI arguments. Data is emitted to standard out.

Note that while queries require an aggregator, it is effectively ignored. If a query encompasses many time series, the scan output may be extremely large so be careful when crafting queries.

Parameters
^^^^^^^^^^
.. code-block :: bash

  scan [--delete|--import] START-DATE [END-DATE] query [queries...]

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 15, 5, 40, 5, 35
   
   "--delete", "Flag", "Optional flag that deletes data in any row that matches the query. See warning below.", "Not set", "--delete"
   "--import", "flag", "Optional flag that outputs results in a text format useful for importing or storing as a backup.", "Not set", "--import"
   "START-DATE", "String or Integer", "Starting time for the query. This may be an absolute or relative time. See :doc:`../query/dates` for details", "", "1h-ago"
   "END-DATE", "String or Integer", "Optional end time for the query. If not provided, the current time is used. This may be an absolute or relative time. See :doc:`../query/dates` for details", "Current timestamp", "2014/01/01-00:00:00"
   "query", "String", "One or more command line queries", "", "sum tsd.hbase.rpcs type=put"

Example:

.. code-block :: bash

  scan --import 1h-ago now sum tsd.hbase.rpcs type=put sum tsd.hbase.rpcs type=scan

.. WARNING ::

  If you include the ``--delete`` flag, **ALL** data in 'any' row that matches on the query will be deleted permanently. Rows are separated on 1 hour boundaries so that if you issued a scan command with a start and end time that covered 10 minutes within a single hour, the entire hour of data will be deleted.
  
  Deletions will also delete any Annotations or non-TSDB related data in a row.
  
.. NOTE ::

  The scan command returns data on row boundaries (1 hour) so results may include data previous to and after the specified start and end times.

Raw Output
^^^^^^^^^^

The default output for ``scan`` is a raw dump of the rows and columns that match the given queries. This is useful in debugging situations such as data point collisions or encoding issues. As the output includes raw byte arrays and the format changes slightly depending on the data, it is not easily machine paresable.

Row keys, column qualifiers and column values are emitted as Java byte arrays. These are surrounded by square brackets and individual bytes are represented as signed integers (as Java does not have native unsigned ints). Row keys are printed first followed by a new line. Then each column is printed on it's own row and is indented with two spaces to indicate it belongs to the previous row. If a compacted column is found, the raw data and number of compacted values is printed followed by a new line. Each compacted data point is printed on it's own indented line. Annotations are also emitted in raw mode.

The various formats are listed below. The ``\t`` expression represents a tab. ``space`` indicates a space character.

Row Key Format
--------------

.. code-block :: bash

  [<row key>] <metric name> <row timestamp> (<datetime>) <tag/value pairs>
  
Where:

  * **row key** Is the raw byte array of the row key
  * **metric name** Is the decoded name of the metric the row represents
  * **row timestamp** Is the base timestamp of the row in seconds (on 1 hour boundaries)
  * **datetime** Is the system default formatted human readable timestamp
  * **tag/value pairs** Are the tags associated with the time series
  
Example:

.. code-block :: bash

  [0, 0, 1, 80, -30, 39, 0, 0, 0, 1, 0, 0, 1] sys.cpu.user 1356998400 (Mon Dec 31 19:00:00 EST 2012) {host=web01}

Single Data Point Column Format
-------------------------------

.. code-block :: bash

  <two spaces>[<qualifier>]\t[<value>]\t<offset>\t<l|f>\t<timestamp>\t(<datetime>)

Where:

  * **qualifier** Is the raw byte array of the column qualifier
  * **value** Is the raw byte array of the column value
  * **offset** Is the number of seconds or milliseconds (based on timestamp) of offset from the row base timestamp
  * **l|f** Is either ``l`` to indicate the value is an Integer (Java Long) or ``f`` for a floating point value.
  * **timestamp** Is the absolute timestamp of the data point in seconds or milliseconds
  * **datetime** Is the system default formatted human readable timestamp
  
Example:

.. code-block :: bash

  [0, 17]	[0, 17]	[1, 1]	1	l	1356998401	(Mon Dec 31 19:00:01 EST 2012)
  
Compacted Column Format
-----------------------

.. code-block :: bash

  <two spaces>[<qualifier>]\t[<value>] = <number of datapoints> values:

Where:

  * **qualifier** Is the raw byte array of the column qualifier
  * **value** Is the raw byte array of the column value
  * **number of datapoints** Is the number of data points in the compacted column
  
Example:

.. code-block :: bash

  [-16, 0, 0, 7, -16, 0, 2, 7, -16, 0, 1, 7]	[0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 6, 0] = 3 values:
  
Each data point within the compacted column follows the same format as a single column with the addition of two spaces of indentation.

Annotation Column Format
------------------------

.. code-block :: bash

  <two spaces>[<qualifier>]\t[<value>]\t<offset>\t<JSON\>\t<timestamp\>\t(<datetime>)

Where:

  * **qualifier** Is the raw byte array of the column qualifier
  * **value** Is the raw byte array of the column value
  * **offset** Is the number of seconds or milliseconds (based on timestamp) of offset from the row base timestamp
  * **JSON** Is the decoded JSON data stored in the column
  * **timestamp** Is the absolute timestamp of the data point in seconds or milliseconds
  * **datetime** Is the system default formatted human readable timestamp
  
Example:

.. code-block :: bash

  [1, 0, 0]	[123, 34...]	0	{"tsuid":"000001000001000001","startTime":1356998400,"endTime":0,"description":"Annotation on seconds","notes":"","custom":null}	1356998416000	(Mon Dec 31 19:00:16 EST 2012)
  
Import Format
^^^^^^^^^^^^^

The import format is the same as a Telnet style ``put`` command. 

.. code-block :: bash

  <metric> <timestamp> <value> <tagk=tagv>[...<tagk=tagv>]
  
Where:

  * **metric** Is the name of the metric as a string
  * **timestamp** Is the absolute timestamp of the data point in seconds or milliseconds
  * **value** Is the value of the data point
  * **tagk=tagv** Are tag name/value pairs separated by spaces
  
Example:

.. code-block :: bash

  sys.cpu.user 1356998400 42 host=web01 cpu=0
  sys.cpu.user 1356998401 24 host=web01 cpu=0