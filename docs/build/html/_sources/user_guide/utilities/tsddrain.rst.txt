tsddrain.py
===========

This is a simple utility for consuming data points from collectors while a TSD, HBase or HDFS is underoing maintenance. The script should be run on the same port as a TSD and accepts data in the ``put`` Telnet style. Data points are then written directly to disk in a format that can be used with the :doc:`../cli/import` command once HBase is back up.

Parameters
^^^^^^^^^^

.. code-block :: bash

  tsddrain.py <port> <directory>
  
.. csv-table::
   :header: "Name", "Data Type", "Description", "Default", "Example"
   :widths: 15, 5, 40, 5, 35
   
   "port", "Integer", "The TCP port to listen on", "", "4242"
   "directory", "String", "Path to a directory where data files should be written. A file is created for each client with the IP address of the client as the file name,", "", "/opt/temptsd/"

Example

.. code-block :: bash

  ./tsddrain.py 4242 /opt/temptsd/
  
Results
^^^^^^^

On succesfully binding to the default IPv4 address ``0.0.0.0`` and port it will simply print out the line below and start writing. When you're ready to resume using a TSD, simply kill the process.

.. code-block :: bash

  Use Ctrl-C to stop me.

.. WARNING:: Tsddrain does not accept HTTP input at this time.

.. WARNING:: Test throughput on your systems to make sure it handles the load properly. Since it writes each point to disk immediately this can result in a huge disk IO load so very large OpenTSDB installations may require a larger number of drains than TSDs.