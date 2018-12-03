Rate
====
.. index:: rate
Computes the rate of change or first derivative of two values within a time series.

Fields for the rate config include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "interval", "String", "Optional", "A TSDB style duration to use when computing the rate. Defaults to per second.", "1s", "1m"
   "counter", "boolean", "Optional", "Whether or not the underlying series is a monotonically increasing counter and we should expect to handle resets.", "false", "true"
   "dropResets", "Boolean", "Optional", "Whether or not to drop values when resets occur and reset them to zero.", "false", "true"
   "counterMax", "Integer", "Optional", "The value at which we expect the counter to reset. The default is a 64 bit signed maximum integer value.", "Long.MAX_VALUE", "32000"
   "resetValue", "Integer", "A value that, when exceeded, we reset to 0.", "0", "42"
