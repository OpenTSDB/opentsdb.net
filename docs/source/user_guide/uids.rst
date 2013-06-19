UIDs and TSUIDs
===============

In OpenTSDB, when you write a timeseries data point, it is always associated with a metric and at least one tag name/value pair. Each metric, tag name and tag value is assigned a unique identifier (UID) the first time it is encountered or when explicitly assigned via the API or a CLI tool. The combination of metric and tag name/value pairs create a timeseries UID or TSUID.

UID
^^^

Types of UID objects include:

* **metric** - A metric such as ``sys.cpu.0`` or ``trades.per.second``
* **tagk** - A tag name such as ``host`` or ``symbol``. This is always the "key" (the first value) in a tag key/value pair.
* **tagv** - A tag value such as ``web01`` or ``goog``. This is always the "value" (the second value) in a tag key/value pair.

Assignment
----------

The UID is a positive integer that is unique to the name of the UID object and it's type. Within the storage system there is a counter that is incremented for each ``metric``, ``tagk`` and ``tagv``. When you create a new ``tsdb-uid`` table, this counter is set to 0 for each type. So if you put a new data point with a metric of ``sys.cpu.0`` and a tag pair of ``host=web01`` you will have 3 new UID objects, each with a UID of 1.

UIDs are assigned automatically for new ``tagk`` and ``tagv`` objects when data points are written to a TSD. ``metric`` objects also receive new UIDs but only if the *auto metric* setting has been configured to ``true``. Otherwise data points with new metrics are rejected. The UIDs are looked up in a cached map for every incoming data point. If the lookup fails, then the TSD will attempt to assign a new UID. 

Storage
-------

By default, UIDs are encoded on 3 bytes in storage, giving a maximum unique ID of 16,777,215 for each UID type. This is done to reduce the amount of space taken up in storage and to reduce the memory footprint of a TSD. For the vast majority of users, 16 million unique metrics, 16 million unique tag names and 16 million unique tag values should be enough. But if you do need more of a particular type, you can modify the OpenTSDB source code and recompile with 4 bytes or more. 

.. WARN:: If you do adjust the byte encoding number, you must start with a fresh ``tsdb`` and fresh ``tsdb-uid`` table, otherwise the results will be unexpected. If you have data in an existing setup, you must export it, drop all tables, create them from scratch and re-import the data.

Display
-------

UIDs can be displayed in a few ways. The most common method is via the HTTP API where the 3 bytes of UID data are encoded as a hexadecimal string. For example, the UID of ``1`` would be written in binary as ``000000000000000000000001``. As an array of unsigned byte values, you could imagine it as ``[0, 0, 1]``. Encoded as a hex string, the value would be ``000001`` where the string is padded with 0s for each byte. The UID of 255 would result in a hex value of ``0000FF`` (or as a byte array, ``[0, 0, 255]``. To convert between a decimal UID to a hex, use any kind of hex conversion tool you prefer and put 0s in front of the resulting value until you have a total of 6 characters. To convert from a hex UID to decimal, simply drop any 0s from the front, then use a tool to convert the hex string to a decimal.

In some CLI tools and log files, a UID may be displayed as an array of signed bytes (thanks to Java) such as the above example of ``[0, 0, 1]`` or ``[0, 0, -28]``. To convert from this signed array to an an array of unsigned bytes, then to hex. For example, ``-28`` would be binary ``10011100`` which results in a decimal value of ``156`` and a hex value of ``9C``.

Why UIDs?
---------

This question is asked often enough it's worth laying out the reasons here. Looking up or assigning a UID takes up precious cycles in the TSD so folks wonder if it wouldn't be faster to use the raw name of the metric or computer a hash. Indeed, from a write perspective it would be slightly faster, but there are a number of drawbacks that become apparent.

Raw Names
^^^^^^^^^

Since OpenTSDB uses HBase as the storage layer, you could use strings as the row key. Following the current schema, you may have a row key that looked like ``sys.cpu.0.user 1292148000 host=websv01.lga.mysite.com owner=operations``. Ordering would be similar to the existing schema, but now you're using up 72 bytes of storage each hour instead of 40. Additionally, the row key must be written and returned with every query to HBase, so you're increasing your network usage as well. So resorting to UIDs can help save space.

Hashes
^^^^^^

Another idea is to simply bump up the UIDs to 4 bytes then calculate a hash on the strings and store the hash with forward and reverse maps as we currently do. This would certainly reduce the amount of time it takes to assign a UID, but there are a few problems. First, you will encounter collisions where different names return the same hash. You could try different algorithms and even try increasing the hash to 8 bytes, but you'll always have the issue of colliding hashes. Second, you are now adding a hash calculation to every data put since it would have to determine the hash, then lookup the hash in the UID table to see if it's been mapped yet. Right now, each data point only performs the lookup. Third, you can't pre-split your HBase regions as easily. If you know you will have roughly 800 metrics in your system (the tags are irrelevant for this purpose), you can pre-split your HBase table to evenly distribute those 800 metrics and increase your initial write performance. 

TSUIDs
^^^^^^

When a data point is written to OpenTSDB, the row key is formatted as ``<metric_UID><timestamp><tagk1_UID><tagv1_UID>[...<tagkN_UID><tagvN_UID>]``. By simply dropping the timestamp from the row key, we have a long array of UIDs that combined, form a unique timeseries ID. Encoding the bytes as a hex string will give us a useful TSUID that can be passed around various API calls. Thus from our UID example above where each metric, tag name and value has a UID of 1, our TSUID, encoded as a hexadecimal string, would be ``000001000001000001``. 

While this TSUID format may be long and ugly, particularly with all of the 0s for early UIDs, there are a few reasons why this is useful:

* If you know the width of each UID (by default 3 bytes as stated above), then you can easily parse the UID for each metric, tag name and value from the UID string. 
* Assigning a unique numeric ID for each timeseries creates issues with lock contention and/or synchronization issues where a timeseries may be missed if the UID could not be incremented.
