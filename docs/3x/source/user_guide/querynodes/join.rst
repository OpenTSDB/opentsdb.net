Join
====
.. index:: join
This configuration is not a stand-alone node (yet), rather it's part of another node such as the expression. It controls how various time series sources are aligned for combination. 

Join configs expect two and only two sources of data. A "left" series and a "right" series, separated by an operator.

Whenever an interpolator config is required, the following fields can be supplied:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "type", "String", "Required", "The type of join to perform. See below.", "null", "OUTER_DISJOINT"
   "joins", "List", "Required", "A list of one or more key pairs to join on. Required for all but ``NATURAL`` or ``CROSS`` join types. E.g. if the left series has "Host" as a tag key but the right series has "host" (case sensitive) then make sure to link them per the example:", "null", "[{""host"": ""Host""}]"
   "explicitTags", "Boolean", "Optional", "If a series does not have all of the tags, and only the tags, present in the ``joins`` list, it will be omitted from the result.", "false", "true"

Join Types
^^^^^^^^^^
Possible values include:

* **INNER** - A series must be present in **L AND R**, performing a cross join when one side or the other has multiple matches.
* **OUTER** - A series must be present in **L OR R**, performing a cross when one side or the other has multiple matches.
* **OUTER_DISJOINT** - A series must be present in **L XOR R**,. No cross as there are no multiples.
* **LEFT** - Returns series from the left, joining only when the right has the same series.
* **LEFT_DISJOINT** - A series must be present in **L NOT R**, no cross.
* **RIGHT** - Returns series from the right, joining only when the left has the same series.
* **RIGHT_DISJOINT** - A series must be present in the **R NOT L**, no cross.
* **NATURAL** - Joins all tags exactly for the series in **L AND R**, no cross product.
* **CROSS** - A full cross join of the left and right sides. **WARNING** Will have a hard limit to avoid blowing up the system.
