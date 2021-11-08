Query Configurations
====================

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
 
   "tsd.query.skip_unresolved_tagks", "Boolean", "Optional", "Whether or not to continue querying when the query includes a tag key that hasn’t been assigned a UID yet and may not exist.", "false", "true"
   "tsd.query.skip_unresolved_tagvs", "Boolean", "Optional", "Whether or not to continue querying when the query includes a tag value that hasn’t been assigned a UID yet and may not exist.", "false", "true"
   "tsd.query.skip_unresolved_ids", "Boolean", "Optional", "Whether or not to ignore series returned from storage that UIDs without a string mapping.", "false", "true"
