Query Examples
==============
.. index:: Query Examples
The following is a list of example queries using an example data set. We'll illustrate a number of common query types that may be encountered so you can get an understanding of how the query system works. Each time series in the example set has only a single data point stored and the UIDs have been truncated to a single byte to make it easier to read. The example queries are all *Metric* queries from the HTTP API and only show the ``m=`` component. See :doc:`../../api_http/query/index` for details. If you are using a CLI tool, the query format will differ slightly so read the documentation for the particular command.

Sample Data
-----------

**Time Series**

.. csv-table::
   :header: "TS#", "Metric", "Tags", "TSUID"
   :widths: 10, 20, 50, 20
   
   "1", "sys.cpu.system", "dc=dal host=web01", "0102040101"
   "2", "sys.cpu.system", "dc=dal host=web02", "0102040102"
   "3", "sys.cpu.system", "dc=dal host=web03", "0102040103"
   "4", "sys.cpu.system", "host=web01", "010101"
   "5", "sys.cpu.system", "host=web01 owner=jdoe", "0101010306"
   "6", "sys.cpu.system", "dc=lax host=web01", "0102050101"
   "7", "sys.cpu.system", "dc=lax host=web02", "0102050102"
   "8", "sys.cpu.user", "dc=dal host=web01", "0202040101"
   "9", "sys.cpu.user", "dc=dal host=web02", "0202040102"
   
**UIDs**

.. csv-table::
   :header: "Name", "UID"
   :widths: 30, 30
   
   "**Metrics**", ""
   "cpu.system", "01"
   "cpu.user", "02"
   "**Tagks**", ""
   "host", "01"
   "dc", "02"
   "owner", "03"
   "**Tagvs**", ""
   "web01", "01"
   "web02", "02"
   "web03", "03"
   "dal", "04"
   "lax", "05"
   "jdoe", "06"
   
.. WARNING:: This isn't necesarily the best way to setup your metrics and tags, rather it's meant to be illustrative of how the query system works. In particular, TS #4 and 5, while legitimate timeseries, may screw up your queries unless you know how they work. In general, try to maintain the same number and type of tags for each timeseries.

Under the Hood
--------------

You may want to read up on how OpenTSDB stores timeseries data here: :doc:`../backends/index`. Otherwise, remember that each row in storage has a unique key formatted:

::

  <metricID><normalized_timestamp><tagkID1><tagvID1>[...<tagkIDN><tagvIDN>]
  
The data table above would be stored as:
 
::

  01<ts>0101
  01<ts>01010306
  01<ts>02040101
  01<ts>02040102
  01<ts>02040103
  01<ts>02050101
  01<ts>02050102
  02<ts>02040101
  02<ts>02040102

When you query OpenTSDB, here's what happens under the hood.

* The query is parsed and verified to make sure that the format is correct and that the metrics, tag names and tag values exist. If a single metric, tag name or value doesn't exist in the system, it will kick back an error.
* Then it sets up a scanner for the underlying storage system.

  * If the query doesn't have any tags or tag values, then it will grab any rows of data that match ``<metricID><timestamp>``, so if you have a ton of time series for a particular metric, this could be many, many rows.
  * If the query does have one or more tags defined, then it will still scan all of the rows matching ``<metricID><timestamp>``, but also perform a regex to return only the rows that contain the requested tag.

* Once all of the data has been returned, OpenTSDB organizes it into groups, if required
* If downsampling was requested, each individual time series is down sampled into smaller time spans using the proper aggregator
* Then each group of data is aggregated using the specific aggregation function
* If the ``rate`` flag was detected, each aggregate will then be adjusted to get the rate.
* Results are returned to the caller

Query 1 - All Time Series for a Metric
--------------------------------------
::

  m=sum:cpu.system
  
This is the simplest query to make. TSDB will setup a scanner to fetch all data points for the metric UID ``01`` between *<start>* and *<end>*. The result will be the a single dataset with time series #1 through #7 summed together. If you have thousands of unique tag combinations for a given metric, they will all be added together into one series.

.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {},
          "aggregated_tags": [
              "host"
          ],
          "tsuids": [
              "010101",
              "0101010306",
              "0102050101",
              "0102040101",
              "0102040102",
              "0102040103",
              "0102050102"
          ],
          "dps": {
              "1346846400": 130.29999923706055
          }
      }
  ]

Query 2 - Filter on a Tag
-------------------------

Usually aggregating all of the time series for a metric isn't particularly useful. Instead we can drill down a little by filtering for time series that contain a specific tagk/tagv pair combination. Simply put the pair in curly braces:

::

  m=sum:cpu.system{host=web01}
  
This will return an aggregate of time series #1, #4, #5 and #6 since they're the only series that include ``host=web01``. 

.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {
              "host": "web01"
          },
          "aggregated_tags": [],
          "tsuids": [
              "010101",
              "0101010306",
              "0102040101",
              "0102050101"
          ],
          "dps": {
              "1346846400": 63.59999942779541
          }
      }
  ]
  
Query 3 - Specific Time Series
------------------------------

What if you want a specific timeseries? You have to include every tag and coresponding value.

::

  m=sum:cpu.system{host=web01,dc=lax}
  
This will return the data from timeseries #6 only.

.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {
              "dc": "lax",
              "host": "web01"
          },
          "aggregated_tags": [],
          "tsuids": [
              "0102050101"
          ],
          "dps": {
              "1346846400": 15.199999809265137
          }
      }
  ]
  
.. WARNING:: This is where a tagging scheme will stand or fall. Let's say you want to get just the data from timeseries #4. With the current system, you are unable to. You would send in query #2 ``m=sum:cpu.system{host=web01}`` thinking that it will return just the data from #4, but as we saw, you'll get the aggregate results for #1, #4, #5 and #6. To prevent such an occurance, you would need to add another tag to #4 that differentiates it from other timeseries in the group. Or if you've already commited, you can use TSUID queries.

Query 4 - TSUID Query
---------------------

If you know the exact TSUID of the timeseries that you want to retrieve, you can simply pass it in like so:

::

  tsuids=sum:0102040102
  
The results will be the data points that you requested.

.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {
              "dc": "lax",
              "host": "web01"
          },
          "aggregated_tags": [],
          "tsuids": [
              "0102050101"
          ],
          "dps": {
              "1346846400": 15.199999809265137
          }
      }
  ]
  
Query 5 - Multi-TSUID Query
---------------------------

You can also aggregate multiple TSUIDs in the same query, provided they share the same metric. If you attempt to aggregate multiple metrics, the API will issue an error.

::

  tsuids=sum:0102040101,0102050101
  
.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {
              "host": "web01"
          },
          "aggregated_tags": [
              "dc"
          ],
          "tsuids": [
              "0102040101",
              "0102050101"
          ],
          "dps": {
              "1346846400": 33.19999980926514
          }
      }
  ]
  
Query 6 - Grouping
------------------

::

  m=sum:cpu.system{host=*}
  
The ``*`` (asterisk) is a grouping operator that will return a data set for each unique value of the tag name given. Every timeseries that includes the given metric and the given tag name, regardless of other tags or values, will be included in the results. After the individual timeseries results are grouped, they'll be aggregated and returned.

In this example, we will have 3 groups returned:

.. csv-table::
   :header: "Group", "Time Series Included"
   :widths: 30, 30
   
   "web01", "#1, #4, #5, #6"
   "web02", "#2, #7"
   "web03", "#3"
   
TSDB found 7 total timeseries that included the "host" tag. There were 3 unique values for that tag (web01, web02, and web03).

.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {
              "host": "web01"
          },
          "aggregated_tags": [],
          "tsuids": [
              "010101",
              "0101010306",
              "0102040101",
              "0102050101"
          ],
          "dps": {
              "1346846400": 63.59999942779541
          }
      },
      {
          "metric": "cpu.system",
          "tags": {
              "host": "web02"
          },
          "aggregated_tags": [
              "dc"
          ],
          "tsuids": [
              "0102040102",
              "0102050102"
          ],
          "dps": {
              "1346846400": 24.199999809265137
          }
      },
      {
          "metric": "cpu.system",
          "tags": {
              "dc": "dal",
              "host": "web03"
          },
          "aggregated_tags": [],
          "tsuids": [
              "0102040103"
          ],
          "dps": {
              "1346846400": 42.5
          }
      }
  ]
  
Query 7 - Group and Filter
--------------------------

Note that the in example #2, the ``web01`` group included the odd-ball timeseries #4 and #5. We can filter those out by specifying a second tag ala:

::

  m=sum:cpu.nice{host=*,dc=dal}
  
Now we'll only get results for #1 - #3, but we lose the ``dc=lax`` values.

.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {
              "dc": "dal",
              "host": "web01"
          },
          "aggregated_tags": [],
          "tsuids": [
              "0102040101"
          ],
          "dps": {
              "1346846400": 18
          }
      },
      {
          "metric": "cpu.system",
          "tags": {
              "dc": "dal",
              "host": "web02"
          },
          "aggregated_tags": [],
          "tsuids": [
              "0102040102"
          ],
          "dps": {
              "1346846400": 9
          }
      },
      {
          "metric": "cpu.system",
          "tags": {
              "dc": "dal",
              "host": "web03"
          },
          "aggregated_tags": [],
          "tsuids": [
              "0102040103"
          ],
          "dps": {
              "1346846400": 42.5
          }
      }
  ]
  
Query 8 - Grouping With OR
--------------------------

The ``*`` operator is greedy and will return *all* values that are assigned to a tag name. If you only want a few tag values, you can use the ``|`` (pipe) operator instead.

::

  m=sum:cpu.nice{host=web01|web02}
  
This will find all of the timeseries that include "host" values for "web01" OR "web02", then group them by value, similar to the ``*`` operator. Our groups, this time, will look like this:

.. csv-table::
   :header: "Group", "Time Series Included"
   :widths: 30, 30
   
   "web01", "#1, #4, #5, #6"
   "web02", "#2, #7"

.. code-block :: javascript

  [
      {
          "metric": "cpu.system",
          "tags": {
              "host": "web01"
          },
          "aggregated_tags": [],
          "tsuids": [
              "010101",
              "0101010306",
              "0102040101",
              "0102050101"
          ],
          "dps": {
              "1346846400": 63.59999942779541
          }
      },
      {
          "metric": "cpu.system",
          "tags": {
              "host": "web02"
          },
          "aggregated_tags": [
              "dc"
          ],
          "tsuids": [
              "0102040102",
              "0102050102"
          ],
          "dps": {
              "1346846400": 24.199999809265137
          }
      }
  ]
