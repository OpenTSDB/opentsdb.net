HBase
=====

Data Table Schema
-----------------

All OpenTSDB data points are stored in a single, massive table. This is to take advantage of HBases ordering and region distribution. All values are stored in the ``t`` column family.

Row Key
^^^^^^^

Row keys are byte arrays comprised of the metric UID, a base timestamp and the UID for tagk/v pairs:  ``<metric_uid><timestamp><tagk1><tagv1>[...<tagkN><tagvN>]``. By default, UIDs are encoded on 3 bytes. 

The timestamp is a Unix epoch value in seconds encoded on 4 bytes. Rows are broken up into hour increments, reflected by the timestamp in each row. Thus each timestamp will be normalized to an hour value, e.g. *2013-01-01 08:00:00*. This is to avoid stuffing too many data points in a single row that would affect region distribution. Also, since HBase sorts on the row key, data for the same metric and time bucket, but with different tags, will be grouped together for efficient queries.

Some example row keys, represented as hex are:

::
  
  00000150E22700000001000001
  00000150E22700000001000001000002000004
  00000150E22700000001000002
  00000150E22700000001000003
  00000150E23510000001000001
  00000150E23510000001000001000002000004
  00000150E23510000001000002
  00000150E23510000001000003
  00000150E24320000001000001
  00000150E24320000001000001000002000004
  00000150E24320000001000002
  00000150E24320000001000003

where:

::
  
  00000150E22700000001000001
  '----''------''----''----'
  metric  time   tagk  tagv

This represents a single metric but four time series across three hours. Note how there is one time series with two sets of tags: 

::

  00000150E22700000001000001000002000004
  '----''------''----''----''----''----'
  metric  time   tagk  tagv  tagk  tagv
  
Tag names (tagk) are sorted alphabetically before storage, so the "host" tag will always appear first in the row key/TSUID ahead of "owner".

Columns
^^^^^^^

There are currently three types of columns in the data table. All column qualifiers are byte arrays. In general, data point qualifiers will always have an even number of bytes while meta data have odd numbers.

**Data Points**

By far the most common column are data points. These are the actual values recorded when data is sent to the TSD for storage. 

Qualifier:

The qualifier is comprised of 2 bytes that encode an offset from the row's base time and flags to determine if the value is an integer or a decimal value. The first 12 bits of the qualifer represent an integer that is a delta from the timestamp in the row key. For example, if the row key is normalized to ``1292148000`` and a data point comes in for ``1292148123 ``, the recorded delta will be ``123``. The last 4 bits are flags that describe the data. ``0100`` means the column value is an 8 byte, signed integer. ``1011`` indicates the column value is a 4 byte floating point value TODO ____floatToRawIntBits____ So the qualifier for the data point at ``1292148123`` with an integer value of 42 would have a qualifier of ``0000011110110100`` or ``07B4`` in hex.

Value:

8 or 4 bytes encoded as indicated by the qualifier flag. E.g. our integer of ``42`` would be encoded as ``0000002A``.

**Compactions**

If compactions have been enabled for a TSD, a row may be compacted after it's base hour has passed or a query has run over the row. Compacted columns simply squash all of the data points together to reduce the amount of overhead consumed by disparate data points. Data is initially written to individual columns for speed, then compacted later for storage efficiency. Once a row is compacted, the individual data points are deleted. Data may be written back to the row and compacted again later.

.. Note:G The OpenTSDB compaction process is entirely separate in scope and definition than the HBase idea of compactions.

Qualifier:

The qualifier for a compacted column will always be an even number of bytes and is simply a concatenation of the qualifiers for every data point that was in the row. Since we know each data point qualifier is 2 bytes, it's simple to split this up. A qualifier in hex with 2 data points may look like ``07B407D4``.

Value:

The value is also a concatenation of all of the individual data points. The qualifier is split first and the flags for each data point determine if the parser consumes 4 or 8 bytes 

**Annotations**

A row may have annotations, notes about the timeseries represented by the row.

Qualifier:

The qualifier is on 3 bytes with the first byte an ID that denotes the column as a qualifier. The first byte will always have a hex value of ``01``. The second two bytes encode the timestamp delta, in seconds, from the row base time in a manner similar to a data point, though without the flags. Thus if we record an annotation at ``1292148123``, the delta will be ``123`` and the qualifier, in hex, will be ``01007B``. 

Value:

Annotation values are UTF-8 encoded JSON objects. Do not modify this value directly. The order of the fields is important, affecting CAS calls.