/api/query/gexp
===============

Graphite is an excellent storage system for time series data with a number of built in functions to manipulate the data. To support transitions from Graphite to OpenTSDB, the ``/api/query/gexp`` endpoint supports URI queries *similar* but not *identical* to Graphite's expressions. Graphite functions are generally formatted as ``func(<series>[, param1][, paramN])`` with the ability to nest functions. TSD's implementation follows the same pattern but uses an ``m`` style query (e.g. ``sum:proc.stat.cpu{host=foo,type=idle}``) in place of the ``<series>``. Nested functions are supported.

TSDB implements a subset of Graphite functions though we hope to add more in the future. For a list of Graphite functions and descriptions, see the `Documentation <http://graphite.readthedocs.org/en/latest/functions.html>`_. TSD supported functions appear below.

Verbs
-----

* GET

Requests
--------

Queries can only be executed via GET using the URI at this time. (In the future, the :doc:`exp` endpoint will support more flexibility.) This is an extension of the main :doc:`index` endpoint so parameters in the request table are also supported here. Additional parameters include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Example"
   :widths: 10, 5, 5, 55, 25
   
   "exp", "String", "Required", "The Graphite style expression to execute. The first parameter of a function must either be another function or a URI formatted **Sub Query**", "scale(sum:if.bytes_in{host=*},1024)"

Example Query String Requests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  http://localhost:4242/api/query?start=1h-ago&exp=scale(sum:if.bytes_in{host=*},1024)

Response
--------

The output is identical to :doc:`index`.