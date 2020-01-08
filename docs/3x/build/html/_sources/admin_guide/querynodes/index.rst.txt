QueryNodes
==========
.. index:: querynodes
This is a list of the built-in query nodes in OpenTSDB. Other nodes may be available via plugins so be sure to check the plugin documentation or the registry endpoint for more information.

The nodes in the following documents ommit the default fields:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25

   "id", "String", "Required", "A unique ID for the graph, i.e. no other node in the graph array can have the same ID. This can either be a descriptive name for the node such as ``downsample_metric1`` wherein the ``type`` field is the ID or name of a query node in the Registry, or it can be the ID of a node in the Registry and the ``type`` field can be missing.", "null", "m1"
   "type", "String", "Optional", "The ID or name of a query node in the Registry. If there is only one node in the list of the given type and the ``id`` is the name in the Registry, this field may be omitted.", "null", "timeseriesdatasource"
   "sources", "List", "Optional", "A list of ``id`` s that should pass data into this node. This is how the graph is formed. *Note* that data source nodes cannot have sources.", "null", "[""m1"", ""m2""]"

.. toctree::
   :maxdepth: 1
   
   downsample
   expression
   filters
   groupby
   interpolator
   join
   rate
   slidingwindow
   summarizer
   timeseriesdatasource
   topn