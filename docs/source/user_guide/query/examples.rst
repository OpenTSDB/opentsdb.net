Query Examples
==============

The following is a list of example queries using a fictional data set. We'll illustrate a number of common query types that may be encountered so you can get an understanding of how the query system works. Each time series in the example set has only a single data point stored and the UIDs have been truncated to a single byte to make it easier to read.

Sample Data
-----------

.. csv-table::
   :header: "TS#", "Metric", "Tags", "TSUID"
   :widths: 10, 20, 50, 20
   
   "1", "sys.cpu.system", "dc=dal host=web01", "0102040101"
   "2", "sys.cpu.system", "dc=dal host=web02", "0102040102"
   "3", "sys.cpu.system", "dc=dal host=web03", "0102040103"
   "4", "sys.cpu.system", "host=web01", "010101"
   "5", "sys.cpu.system", "host=web01 owner=jdoe", "0102040101"
   "6", "sys.cpu.system", "dc=lax host=web01", "0102040101"
   "7", "sys.cpu.system", "dc=lax host=web01", "0102040101"
   "8", "sys.cpu.user", "dc=dal host=web01", "0102040101"
   "9", "sys.cpu.user", "dc=dal host=web01", "0102040101"