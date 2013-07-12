Trees
=====

Along with metadata, OpenTSDB 2.0 introduces the concept of **trees**, a hierarchical method of organizing timeseries into an easily navigable structure that can be browsed similar to a file system on a computer. Users can define a number of trees with various rule sets that organize TSMeta objects into a tree structure. Then users can browse the resulting tree via an HTTP API endpoint. See :doc:`../api_http/tree/index` for details.

Tree Termanology
^^^^^^^^^^^^^^^^

* **Branch** - Each branch is one node of a tree. It contains a list of child branches and leaves as well as a list of parent branches.
* **Leaf** - The end of a branch and represents a unique timeseries. The leaf will contain a TSUID value that can be used to generate a TSD query. A branch can, and likely will, have multiple leaves
* **Root** - The root branch is the start of the tree and all branches reach out from this root. It has a depth of 0.
* **Depth** - Each time a branch is added to another branch, the depth increases
* **Strict Matching** - When enabled, a timeseries must match a rule in every level of the rule set. If one or more levels fail to match, the timeseries will not be included in the tree.
* **Path** - The name and level of each branch above the current branch in the hierarchy.

Branch
^^^^^^

Each node of a tree is recorded as a *branch* object. Each branch contains information such as:

* **Branch ID** - The ID of the branch. This is a hexadecimal value described below.
* **Display Name** - A name for the branch, parsed from a TSMeta object by the tree rule set.
* **Depth** - How deep within the hierarchy the branch resides.
* **Path** - The depth and name of each parent branch (includes the local branch).
* **Branches** - Child branches one depth level below this branch.
* **Leaves** - Leaves that belong to this branch.

Navigating a tree starts at the **root** branch which always has an ID that matches the ID of the tree the branch belongs to. The root should have one or more child branches that can be used to navigate down one level of the tree. Each child can be used to navigate to their children and so on. The root does not have any parent branches and is always at a depth of 0. If a tree has just been defined or enabled, it may not have a root branch yet, and by extension, there won't be any child branches.

Each branch will often have a list of child branches. However if a branch is at the end of a path, it may not have any child branches, but it should have a list of leaves. 

Branch IDs and Paths
--------------------

Branch IDs are hexadecimal encoded byte arrays similar to TSUIDs but with a different format. Branch IDs always start with the ID of the tree encoded on 2 bytes. Root branches have a branch ID equal to the tree ID. Thus the root for tree ``1`` would have a branch ID of ``0001``. 

Each child branch has a ``DisplayName`` value and the hash of this value is used to generate a 32 bit integer ID for the branch. The hash function used is the Java ``java.lang.String`` hash function. The 4 bytes of the integer value are then encoded to 8 hexadecimal characters. For example, if we have a display name of ``sys`` for a branch, the hash returned will be 102093. The TSD will convert that value to hexadecimal ``0001BECD``. 

A branch ID is composed of the tree ID concatenated with the ID of each parent above the current branch, concatenated with the ID of the current branch. Thus, if our child branch ``sys`` is a child of the root, we would have a branch ID of ``00010001BECD``. 

Lets say there is a branch with a display name of ``cpu`` off of the ``sys`` child branch. ``cpu`` returns a hash of 98728 which converts to ``000181A8`` in hex. The ID of this child would be ``00010001BECD000181A8``. 

IDs are created this way primarily due to the method of branch and leaf storage but also as a way to navigate back up a tree from a branch anywhere in the tree structure. This can be particularly useful if you know the end branch of a path and want to move back up one level or more. Unfortunately a deep tree can create very long branch IDs, but a well designed tree really shouldn't be more than 5 to 10 levels deep. Most URI requests should support branches up to 100 levels deep before the URI character constraints are reached.

Leaves
^^^^^^

A unique timeseries is represented as a *leaf* on the tree. A leaf can appear on any branch in the structure, including the root. But they will usually appear at the end of a series of branches in a branch that has one or more leaves but no child branches. Each leaf contains the TSUID for the timeseries to be used in a query as well as the metric and tag name/values. It also contains a *display name* that is parsed from the rule set but may not be identical to any of the metric, tag names or tag values.

Ideally a timeseries will only appear once on a tree. But if the TSMeta object for a timeseries, OR the UIDMeta for a metric or tag is modified, it may be processed a second time and a second leaf added. This can happen particularly in situations where a tree has a *custom* rule on the metric, tag name or tag value where the TSMeta has been processed then a user adds a custom field that matches the rule set. In these situations it is recommended to enable *strict matching* on the tree so that the timeseries will not show up until the custom data has been added.

Rules
^^^^^

Each tree is dynamically built from a set of rules defined by the user. A rule set must contain at least one rule and usually will have more than one. Each set has multiple *levels* that determine the order of rule processing. Rules located at level 0 are processed first, then rules at level 1, and so on until all of the rules have been applied to a given timeseries. Each level in the rule set may have multiple rules to handle situations where metrics and tags may not have been planned out ahead of time or some arbitrary data may have snuck in. If multiple rules are stored in a level, the first one with a successful match will be applied and the others ignored. These rules are also ordered by the *order* field so that a rule with order 0 is processed first, then a rule with order 1 and so on. In logs and when using the test endpoint, rules are usually given IDs in the format of "[<treeId>:<level>:<order>:<type>]" such as "[1:0:1:0]" indicates the rule for tree 1, at level 0, order 1 of the type ``METRIC``.

Rule Types
----------

Each rule acts on a single component of the timeseries data. Currently available types include:

.. csv-table::
   :header: "Type", "ID", "Description"
   :widths: 20, 10, 70
   
   "METRIC", "0", "Processes the name of the metric associated with the timeseries"
   "METRIC_CUSTOM", "1", "Searches the metric metadata custom tag list for the given secondary name. If matched, the value associated with the tag name will be processed."
   "TAGK", "2", "Searches the list of tagks for the given name. If matched, the tagv value associated with the tag name will be processed"
   "TAGK_CUSTOM", "3", "Searches the list of tagks for the given name. If matched, the tagk metadata custom tag list is searched for the given secondary name. If that matches, the value associated with the custom name will be processed."
   "TAGV_CUSTOM", "4", "Searches the list of tagvs for the given name. If matched, the tagv metadata custom tag list is searched for the given secondary name. If that matches, the value associated with the custom name will be processed."

Rule Config
-----------

A single rule can either process a regex, a separator, or none. If a regex and a separator are defined for a rule, only the regex will be processed and the separator ignored. 

All changes to a rule are validated to confirm that proper fields are filled out so that the rule can process data. The following fields must be filled out for each rule type:

.. csv-table::
   :header: "Type", "field", "customField"
   :widths: 50, 25, 25
   
   "Metric", "", ""
   "Metric_Custom", "X", "X"
   "TagK", "X", ""
   "TagK_Custom", "X", "X"
   "TagV_Custom", "X", "X"

   
Display Formatter
-----------------

Occasionally the data extracted from a tag or metric may not be very descriptive. For example, an application may output a timeseries with a tag pair such as "port=80" or "port=443". With a standard rule that matched on the tagk value "port", we would have two branches with the names "80" and "443". The uninitiated may not know what these numbers mean. Thus users can define a token based formatter that will alter the output of the branch to display useful information. For example, we could declare a formatter of "{tag_name}: {value}" and the branches will now display "port: 80" and "port: 443".

Tokens are case sensitive and must appear only one time per formatter. They must also appear exactly as deliniated in the table below:

.. csv-table::
   :header: "Token", "Description", "Applicable Rule Type"
   :widths: 20, 40, 30
   
   "{ovalue}", "Original value processed by the rule. For example, if the rule uses a regex to extract a portion of the value but you do not want the extracted value, you could use the original here.", "All"
   "{value}", "The processed value. If a rule has an extracted regex group or the value was split by a separator, this represents the value after that processing has occured.", "All"
   "{tag_name}", "The name of the tagk or custom tag associated with the value.", "METRIC_CUSTOM, TAGK_CUSTOM, TAGV_CUSTOM, TAGK"
   "{tsuid}", "the TSUID of the timeseries", "All"
   
Regex Rules
-----------

In some situations, you may want to extract only a component of a metric, tag or custom value to use for grouping. For example, if you have computers in mutiple data centers with fully qualified domain names that incorporate the name of the DC, but not all metrics include a DC tag, you could use a regex to extract the DC for grouping.

The ``regex`` rule parameter must be set with a valid regular expression that includes one or more extraction operators, i.e. the parentheses. If the regex matches on the value provided, the extracted data will be used to build the branch or leaf. If more than one extractions are provided in the regex, you can use the ``regex_group_index`` parameter to choose which extracted value to use. The index is 0 based and defaults to 0, so if you want to choose the output of the second extraction, you would set this index to 1. If the regex does not match on the value or the extraction fails to return a valid string, the rule will be considered a no match.

For example, if we have a host tagk with a tagv of ``web1.nyc.mysite.com``, we could use a regex similar to ``.*\.(.*)\..*\..*`` to extract the "nyc" portion of the FQDN and group all of the servers in the "nyc" data center under the "nyc" branch.

Separator Rules
---------------

The metrics for a number of systems are generally strings with a separator, such as a period, to deliniate components of the metric. For example, "sys.cpu.0.user". To build a useful tree, you can use a separator rule that will break apart the string based on a character sequence and create a branch or leaf from each individual value. Setting the separator to "." for the previous example would yield three branches "sys", "cpu", "0" and one leaf "user".

Order of Precedence
-------------------

Each rule can only process a regex, a separator, or neither. If the rule has both a "regex" and "separator" value in their respective fields, only the "regex" will be executed on the timeseries. The "separator" will be ignored. If neither "regex" or "separator" are defined, then when the rule's "field" is matched, the entire value for that field will be processed into a branch or leaf.

Tree Building
^^^^^^^^^^^^^

First, you must create the ``tsdb-tree`` table in HBase if you haven't already done so. If you enable tree processing and the table does not exist, the TSDs will not start.

A tree can be built in two ways. The ``tsd.core.tree.enable_processing`` configuration setting enables real-time tree creation. Whenever a new TSMeta object is created or edited by a user, the TSMeta will be passed through every configured and enabled tree. The resulting branch will be recorded to storage. If a collision occurs or the TSUID failed to match on any rules, a warning will be logged and if the tree options configured, may be recorded to storage.

Alternatively you can periodically synchronize all TSMeta objects via the CLI ``uid`` tool. This will scan through the ``tsdb-uid`` table and pass each discovered TSMeta object through configured and enabled trees. See :doc:`cli/uid` for details.

.. NOTE:: For real-time tree building you need to enable the ``tsd.core.meta.enable_tracking`` setting as well so that TSMeta objects are created when a timeseries is received.

The general process for creating and building a tree is as follows:

#. Create a new tree via the HTTP API
#. Assign one or more rules to the tree via the HTTP API
#. Test the rules with some TSMeta objects via the HTTP API
#. After veryfing the branches would appear correctly, set the tree's ``enable`` flat to ``true``
#. Run the ``uid`` tool with the ``treesync`` sub command to synchronize existing TSMeta objects in the tree

.. NOTE:: When you create a new tree, it will be disabled by default so TSMeta objects will not be processed through the rule set. This is so you have time to configure the rule set and test it to verify that the tree would be built as you expect it to.

Rule Processing Order
---------------------

A tree will usually have more than one rule in order for the resulting tree to be useful. As noted above, rules are organized into levels and orders. A TSMeta is processed through the rule set starting at level 0 and order 0. Processing proceedes through the rules on a level in increasing order. After the first rule on a level that successfully matches on the TSMeta data, processing skips to the next level. This means that rules on a level are effectively ``or``ed. If level 0 has rules at order 0, 1, 2 and 3, and the TSMeta matches on the rule with an order of 1, the rules with order 2 and 3 will be skipped.

When editing rules, it may happen that some levels or orders are skipped or left empty. In these situations, processing simply skips the empty locations. You should do your best to keep things organized properly but the rule processor is a little forgiving.

Strict Matching
---------------

All TSMeta objects are processed through every tree. If you only want a single, monolithic tree to organize all of your OpenTSDB timeseries, this isn't a problem. But if you want to create a number of trees for specific subsets of information, you may want to exclude some timeseries entries from creating leaves. The ``strictMatch`` flag on a tree helps to filter out timeseries that belong on one tree but not another. With strict matching enabled, a timeseries must match a rule on every level (that has one or more rules) in the rule set in order for it to be included in the tree. If the meta fails to match on any of the levels with rules, it will be recorded as a not matched entry and no leaf will be generated. 

By default strict matching is disabled so that as many timeseries as possible can be captured in a tree. If you change this setting on a tree, you may want to delete the existing branches and run a re-sync.

Collisions
^^^^^^^^^^

Due to the flexibility of rule sets and the wide variety of metric, tag name and value naming, it is almost inevitable that two different TSMeta entries would try to create the same leaf on a tree. Each branch can only have one leaf with a given display name. For example, if a branch has a leaf named ``user`` with a tsuid of ``010101`` but the tree tries to add a new leaf named ``user`` with a tsuid of ``020202``, the new leaf will not be added to the tree. Instead, a *collision* entry will be recorded for the tree to say that tsuid ``0202020`` collided with an existing leaf for tsuid ``010101``. The HTTP API can then be used to query the collision list to see if a particular TSUID did not appear in the tree due to a collision.

Not Matched
^^^^^^^^^^^

When *strict matching* is enabled for a tree, a TSMeta must match on a rule on every level of the rule set in order to be added to the tree. If one or more levels fail to match, the TSUID will not be added. Similar to *collisions*, a not matched entry will be recorded for every TSUID that failed to be written to the tree. The entry will contain the TSUID and a brief message about which rule and level failed to match.

Examples
^^^^^^^^

Assume that our TSD has the following timeseries stored:

.. csv-table::
   :header: "TS#", "Metric", "Tags", "TSUID"
   :widths: 10, 20, 40, 30
   
   "1", "cpu.system", "dc=dal, host=web1.dal.mysite.com", "0102040101"
   "2", "cpu.system", "dc=dal, host=web2.dal.mysite.com", "0102040102"
   "3", "cpu.system", "dc=dal, host=web3.dal.mysite.com", "0102040103"
   "4", "app.connections", "host=web1.dal.mysite.com", "010101"
   "5", "app.errors", "host=web1.dal.mysite.com, owner=doe", "0101010306"
   "6", "cpu.system", "dc=lax, host=web1.lax.mysite.com", "0102050101"
   "7", "cpu.system", "dc=lax, host=web2.lax.mysite.com", "0102050102"
   "8", "cpu.user", "dc=dal, host=web1.dal.mysite.com", "0202040101"
   "9", "cpu.user", "dc=dal, host=web2.dal.mysite.com", "0202040102"
   
Note that for this example we won't be using any custom value rules so we don't need to show the TSMeta objects, but assume these values populate a TSMeta. Also, the TSUIDs are truncated with 1 byte per UID for illustration purposes.   

Now let's setup a tree with ``strictMatching`` disabled and the following rules: 

.. csv-table::
   :header: "Level", "Order", "Rule Type", "Field (value)", "Regex", "Separator"
   :widths: 10, 10, 20, 20, 20, 20
   
   "0", "0", "TagK", "dc", "", ""
   "0", "1", "TagK", "host", ".*\\.(.*)\\.mysite\\.com", ""
   "1", "0", "TagK", "host", "", "\\\\."
   "2", "0", "Metric", "", "", "\\\\."

The goal for this set of rules is to order our timeseres by data center, then host, then by metric. Our company may have thousands of servers around the world so it doesn't make sense to display all of them in one branch of the tree, rather we want to group them by data center and let users drill down as needed.

In our example data, we had some old timeseries that didn't have a ``dc`` tag name. However the ``host`` tag does have a fully qualified domain name with the data center name embedded. Thus the first level of our rule set has two rules. The first will look for a ``dc`` tag, and if found, it will use that tag's value and the second rule is skipped. If the ``dc`` tag does not exist, then the second rule will scan the ``host`` tag's value and attempt to extract the data center name from the FQDN. The second level has one rule and that is used to group on the value of the ``host`` tag so that all metrics belonging to that host can be displayed in branches beneath it. The final level has the metric rule that includes a separator to further group the timeseries by the data contained. Since we have multiple CPU and application metrics, all deliniated by a period, it makes sense to add a separator at this point.

Result
------

The resulting tree would look like this:


* dal

  * web1.dal.mysite.com
  
    * app
      
      * connections (tsuid=010101)
      * errors (tsuid=0101010306)
    
    * cpu
      
      * system (tsuid=0102040101)
      * user (tsuid=0202040101)
    
    * web2.dal.mysite.com
      
      * cpu
        
        * system (tsuid=0102040102)
        * user (tsuid=0202040102)
        
    * web3.dal.mysite.com
      
      * cpu
        
        * system (tsuid=0102040103)

* lax

  * web1.lax.mysite.com
    
    * cpu
      
      * system (tsuid=0102050101)
      
  * web2.lax.mysite.com
    
    * cpu
      
      * system (tsuid=0102050102)
