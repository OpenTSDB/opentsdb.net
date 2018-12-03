search
======
.. index:: CLI Search
.. NOTE::

  Available in 2.1

The search command allows for searching OpenTSDB to reteive a list of time series or associated meta data. Search does not return actual data points or time series objects stored in the data table. Use the query tools to access that data. Currently only the ``lookup`` command is implemented.

Lookup
^^^^^^

Lookup queries use either the meta data table or the main data table to determine what time series are associated with a given metric, tag name, tag value, tag pair or combination thereof. For example, if you want to know what metrics are available for a tag pair ``host=web01`` you can execute a lookup to find out.

.. NOTE::

  By default lookups are performed against the ``tsdb-meta`` table. You must enable real-time meta data creation or perform a ``metasync`` using the ``uid`` command in order to retreive data from a lookup. Alternatively you can lookup against the raw data table but this can take a very long time depending on how much data is in your system.

Command Format
--------------

.. code-block :: bash

  search lookup <query>

Parameters
--------------

.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 15, 5, 40, 5, 35
   
   "query", "String", "One or more command line queries similar to a data CLI query. See the query section below.", "", "tsd.hbase.rpcs type="
   "--use_data_table", "Flag", "Optional flag that will cause the lookup to run against the main ``tsdb-data`` table. *NOTE:* This can take a very long time to complete.", "Not set", "--use_data_table"

Query Format
------------

For details on crafting a query, see :doc:`../../api_http/search/lookup`. The CLI query is similar to an API query but spaces are used as separators instead of commas and curly braces are not used.

.. code-block :: bash

  [<metric>] [[tagk]=[tagv]] ...[[tagk]=[tagv]]
  
At least one metric, tagk or tagv is required.

Example Command
--------------
.. code-block :: bash

  search lookup tsd.hbase.rpcs type=

Output
--------------

During a lookup, the results will be printed to standard out. Note that if you have logging enabled, messages may be interspersed with the results. Set the logging level to WARN or ERROR in the ``logback.xml`` configuration to supress these warnings. You may want to run the lookup in the background and capture standard out to a file, particularly when running lookups against the data table as these may take a long time to complete.

.. code-block :: bash

  <tsuid> <metric name> <tag/value pairs>
  
Where:

  * **tsuid** Is the hex encoded UID of the time series
  * **metric name** Is the decoded name of the metric the row represents
  * **tag/value pairs** Are the tags associated with the time series
  
Example Response
--------------
.. code-block :: bash

  0023E3000002017358000006017438 tsd.hbase.rpcs type=openScanner host=tsdb-1.mysite.com

.. NOTE::

  During scanning, if the UID for a metric, tag name or tag value cannot be resolved to a name, an exception will be thrown.