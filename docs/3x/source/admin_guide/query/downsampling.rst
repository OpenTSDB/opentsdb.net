Downsampling
============
.. index:: Downsampling
Downsampling (or in signal processing, *decimation*) is the process of reducing the sampling rate, or resolution, of data. For example, lets say a temperature sensor is sending data to an OpenTSDB system every second. If a user queries for data over an hour time span, they would receive 3,600 data points, something that could be graphed fairly easily. However now if the user asks for a full week of data they'll receive 604,800 data points and suddenly the graph may become pretty messy. Using a downsampler, multiple data points within a time range for a single time series are aggregated together with a mathematical function into a single value at an aligned timestamp. This way we can reduce the number of values from say, 604,800 to 168. 

Downsamplers require at least two components:

* **Interval** - A time range (or *bucket*) across which to aggregate the values. For example we could aggregate multiple values for 1 minute or 1 hour or even a whole day. Intervals are specified in the format ``<Size><Units>`` such as ``1h`` for 1 hour or ``30m`` for 30 minutes. As of *2.3* the ``all`` interval is now available to downsample all results in the time range to one value. E.g. ``0all-sum`` will sum all values from query start to end. Note that a numeric value is still required but it can be zero or any other value.
* **Aggregation Function** - A mathematical function that determines how to merge the values in the interval. Aggregation functions from the :doc:`aggregators` documentation are used for the function.

For example, take the following time series ``A`` and ``B``. The data points cover a 70 second time span, a value every 10 seconds. Let's say we want to downsample that to 30 seconds since the user is looking at a graph for a wider time span. Additionally we're grouping these two series into one using a sum aggregator. We can specify a downsampler of ``30s-sum`` that will create 30 second buckets and sum all of the data points in each bucket. This will give us three data points for each series:

.. csv-table::
   :header: "Time Series", "t0", "t0+10s", "t0+20s", "t0+30s", "t0+40s", "t0+50s", "t0+60"
   :widths: 30, 10, 10, 10, 10, 10, 10, 10
   
   "A", "5", "5", "10", "15", "20", "5", "1"
   "A ``sum`` Downsampled", "5 + 5 + 10 = 20", "", "", "15 + 20 + 5 = 40", "", "", "1 = 1"
   "B", "10", "5", "20", "15", "10", "0", "5"
   "B ``sum`` Downsampled", "10 + 5 + 20 = 35", "", "", "15 + 10 + 0 = 25", "", "", "5 = 5"
   "``sum`` Aggregated Result", "55", "", "", "65", "", "", "6"

As you can see, for each time series, we generate a synthetic series with a timestamp normalized on interval boundaries (every 30 seconds) so that we'll have a value at ``t0``, ``t0+30s`` and ``t0+60s``. Each interval, or bucket, will contain the data points that are inclusive of the bucket timestamp (the start) and exclusive of the following bucket's timestamp (the end). In this case, the first bucket would extend from ``t0`` to ``t0+29.9999s``. Using the provided aggregator, all of the values are merged into a new one. E.g. for series ``A``, we sum up the values for ``t0``, ``t0+10s`` and ``t0+20s`` to arrive at a new value of ``20`` at ``t0``. Finally, the query is group-by'd using sum so that we add the two synthetic time series. At this time, OpenTSDB always performs group-by aggregation *after* downsampling.

.. NOTE:: For early versions of OpenTSDB, the actual time stamps for the new data points will be an average of the time stamps for each data point in the time span. As of 2.1 and later, the timestamp for each point is aligned to the start of a time bucket based on a modulo of the current time and the downsample interval.

Downsampled timestamps are normalized based on the remainder of the original data point timestamp divided by the downsampling interval in milliseconds, i.e. the modulus. In Java the code is ``timestamp - (timestamp % interval_ms)``. For example, given a timestamp of ``1388550980000``, or ``1/1/2014 04:36:20 UTC`` and an hourly interval that equates to 3600000 milliseconds, the resulting timestamp will be rounded to ``1388548800000``. All data points between 4 and 5 UTC will wind up in the 4 AM bucket. If you query for a day's worth of data downsampling on 1 hour, you will receive 24 data points (assuming there is data for all 24 hours). 

When using the ``0all-`` interval, the timestamp of the result will be the start time of the query.

Normalization works very well for common queries such as a day's worth of data downsampled to 1 minute or 1 hour. However if you try to downsample on an odd interval, such as 36 minutes, then the timestamps may look a little strange due to the nature of the modulus calculation. Given an interval of 36 minutes and our example above, the interval would be ``2160000`` milliseconds and the resulting timestamp ``1388549520`` or ``04:12:00 UTC``. All data points between ``04:12`` and ``04:48`` would wind up in a single bucket.

Calendar Boundaries
^^^^^^^^^^^^^^^^^^^
.. index:: Calendars
Starting with OpenTSDB 2.3, users can specify calendar based downsampling instead of the quick modulus method. This is much more useful for reporting purposes such as looking at values relating to human times such as months, weeks or days. Additionally downsampling can account for timezones and incorporate daylight savings time shifts and zone offsets.

To use calendar boundaries, check the documentation for the endpoint you're making a query from. For example, the V2 URI endpoint has a specific timezone parameter to be used such as ``&timezone=Asia/Kabul`` and calendar based downsampling is enabled by appending a ``c`` to the interval time units as in ``&m=sum:1dc-sum:my.metric``. For JSON queries, a separate ``timezone`` field is used at the top level along with a ``useCalendar`` boolean flag. If no timezone is provided, calendars use UTC time.

With calendar downsampling, the first interval is snapped to January 1st at 00:00:00 of the query year in the timezone specified. From there, the interval buckets are calculated until the end of the query. Each bucket is marked with the timestamp of the start of the bucket, inclusive, and includes all values until the start of the next bucket, exclusive.

Fill Policies
^^^^^^^^^^^^^
.. index:: Fill Policy
Downsampling is often used to align timestamps to avoid interpolation when performing a group-by. Because OpenTSDB does not impose constraints on time alignment or when values are supposed to exist, such constraints must be specified at query time. When performing a group-by aggregation with downsampling, if all series are missing values for an expected interval, nothing is emitted. For example, if a series is writing data every minute from ``t0`` to ``t0+6m``, but for some reason the source fails to write data at ``t0+3m``, only 5 values will be serialized when the user may expect 6. With fill policies in 2.2 and later, you can now choose what value is emitted for ``t0+3m`` so that the user (or application) will *see* that a value was missing for a specific timestamp instead of having to figure out which timestamp was missing. Fill policies simply emit a pre-defined value any time a downsample bucket is empty.

Available polices include:

* None (``none``) - The default behavior that does not emit missing values during serialization and performs linear interpolation (or otherwise specified interpolation) when aggregating series.
* NaN (``nan``) - Emits a ``NaN`` in the serialization output when all values are missing in a series. Skips series in aggregations when the value is missing instead of converting an entire group-by calculation to NaN.
* Null (``null``) - Same behavior as NaN except that during serialization it emits a ``null`` instead of a ``NaN``.
* Zero (``zero``) - Substitutes a zero when a timestamp is missing. The zero value will be incorporated in aggregated results.

To use a fill policy, append the policy name (the terms in parentheses) to the end of the downsampling aggregation function separated by a hyphen. E.g. ``1h-sum-nan`` or ``1m-avg-zero``.

In this example we have data reported every 10 seconds and we want to enforce a query-time policy of 10 seconds reporting by downsampling every 10 seconds and filling missing values with NaNs via ``10s-sum-nan``:

.. csv-table::
   :header: "Time Series", "t0", "t0+10s", "t0+20s", "t0+30s", "t0+40s", "t0+50s", "t0+60s"
   :widths: 20, 10, 10, 10, 10, 10, 10, 10
   
   "A", "", "", "", "15", "", "5", ""
   "B", "10", "", "20", "", "", "", "20"
   "A ``sum`` Downsampled", "NaN", "NaN", "NaN", "15", "NaN", "5", "NaN"
   "B ``sum`` Downsampled", "10", "NaN", "20", "NaN", "NaN", "NaN", "20"
   "``sum`` Aggregated Result", "10", "NaN", "20", "15", "NaN", "5", "20"

If we requested the output without a fill policy, no value or timestamp at ``t0+20s`` or ``t0+40s`` would be emitted. Additionally, values at ``t0+30s`` and ``t0+50s`` for series ``B`` would be linearly interpolated to fill in values to be summed with series ``A``.