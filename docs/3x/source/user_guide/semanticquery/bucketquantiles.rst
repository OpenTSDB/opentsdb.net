Bucket Quantile
===============
.. index:: bucketquantile
Aggregating quantiles (or percentiles) across multiple sources gives an imprecise and inaccurate estimation of the actual value. To solve this, a number of metric storage systems support bucketed histograms where the source slices up a measurement range into upper and lower boundaries then sends the count of measurements that fall within each bucket. The query layer can then sum the counts across multiple sources and accurately compute a quantile. For more information about histograms see _TODO_.

.. NOTE::

    The node currently only supports buckets in the metric name. We'll support buckets as tag values in the future.

Fields include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 55, 10, 15
   
   "bucketRegex", "String", "Required", "A regular expression used to extract bucket boundaries from metric names.", ".*?[\.\-_](\-?[0-9\.]+[eE]?\-?[0-9]*)[_\-](\-?[0-9\.]+[eE]?\-?[0-9]*)$", ""
   "histograms", "List", "Required", "A list of one or more metric IDs from TimeSeriesDataSourceConfig nodes that represent bounded histogram bucket metrics. The order does not matter but all buckets must be included in order for the calculation to complete.", "null", "[""m1"": ""m2""]"
   "quantiles", "List", "Required", "A list of one or more quantiles (``0.999``) or percentiles (``99.9``) as floating point numbers. The order does not matter. At this time, quantiles are converted to percentiles (i.e. if the value is < 1 we multiply it by 100).", "null", "[99.0, 99.9, 99.99]"
   "as", "String", "Required", "A string used to label the metrics that are output from the node. Tags are preseved", "null", "latency.percentile"
   "overflow", "String", "Optional", "The metric ID for a TimeSeriesDataSourceConfig node that measures the overflow bucket, i.e. measurements beyond the bucketed histogram bounds.", "null", "m_4"
   "underflow", "String", "Optional", "The metric ID for a TimeSeriesDataSourceConfig node that measures the under bucket, i.e. measurements less than the bucketed histogram bounds.", "null", "m_3"
   "overflowMax", "Float", "Optional", "When an overflow bucket is present and it's count satisfies the quantile, this value can be used to substitute for the reporting value instead of the maximum Double value in Java.", "Java's Double.MAX_VALUE", "1024.5"
   "underflowMin", "Float", "Optional", "When an underflow bucket is present and it's count satisfies the quantile, this value can be used to substitute for the reporting value instead of ``0``.", "0", "1"
   "outputOfBucket", "String", "Optional", "Determines the value to report for a given bucket when the quantile calculation selects it for reporting. Possible values are ``MEAN`` to report the average of the bucket upper and lower boundaries, ``TOP`` to report the upper boundary, or ``BOTTOM`` to report the lower boundary.", "MEAN", "TOP"
   "cumulativeBuckets", "boolean", "Optional", "Whether or not this histogram contains cumulative bucket counts or separated bucket counts. See :ref:`Cumulative and Counter Bucket`.", "false", "true"
   "counterBuckets", "boolean", "Optional", "Whether or not the counts in the buckets are monotonically increasing counters. See :ref:`Cumulative and Counter Bucket`.", "false", "true"
   "nanThreshold", "Float", "Optional", "If the number of missing counts across histogram buckets at a given timestamp is greater than the given percentage, the output will be a NaN instead of a calculated quantile. This can be used to avoid giving errant results. When set to 0, the threshold is ignored and missing values are skipped during calculation.", "0", "25.5"
   "missingMetricThreshold", "Float", "Optional", "If the number of missing histogram time series for the query range is greater than the given threshold, the node will skip calculating quantiles and return an empty result. This can be used to avoid giving errant results. If set to 0, quantiles are computed despite the missing buckets.", "0", "15.5"

Parsing Buckets
---------------

Currently the node only supports bucket boundaries in the metric name. The default regular expression to capture the buckets expects the boundaries to be at the end of the metric string separated by an under score ``_`` or hyphen ``-``. E.g. ``tsdb.query.user.latency.250.50_500.50`` would parse the lower bucket boundary as ``250.5`` and the upper bucket boundary as ``500.5``. All metrics for the histogram must share the same format to satisfy the same regex (with the exception of the underflow and overflow buckets that are provided in the configuration separately).

Cumulative and Counter Buckets
------------------------------

Some systems report histogram counts as the number of measurements that fell within that bucket at that time, e.g.

.. csv-table::
   :header: "Bucket Boundaries", "Count"
   :widths: 25, 25
   
	"0-100", "0"
	"100-200", "2"
	"200-300", "0"
	"300-400", "1"

In this case the total number of measurements across all buckets is ``3``. However some systems report a ``cumulative`` count across buckets, in which case you need to set the ``cumulativeBuckets`` flag to ``true``. E.g.

.. csv-table::
   :header: "Bucket Boundaries", "Count"
   :widths: 25, 25
   
	"0-100", "0"
	"100-200", "2"
	"200-300", "2"
	"300-400", "3"

In this case the total number of measurements across buckets is still ``3`` but each bucket reports the count of buckets lower than it's range as well as it's own count.

Additionally some systems will report bucket counts as monotonically increasing counters over time instead of restting counts to 0 at each reporting interval. In those cases make sure to set ``counterBuckets`` to ``true``.

Query Example
-------------

The following is an example query node configuration that uses the default thresholds and computes three quantiles across 13 histogram metrics and an overflow and underflow bucket.

.. code-block:: javascript
  

  {
      "id":"ptile",
      "type":"BucketQuantile",
      "as":"tsdb.query.user.latency.percentile",
      "quantiles": [75, 90, 99.9],
      "histograms": ["q1_m1", "q1_m2", "q1_m3", "q1_m4", "q1_m5", "q1_m6", "q1_m7", "q1_m8", "q1_m9", "q1_m10", "q1_m11", "q1_m12", "q1_m13"],
      "overflow": "q1_m14",
      "underflow": "q1_m15",
      "interpolatorConfigs": [{
         "dataType": "numeric",
         "fillPolicy": "NAN",
         "realFillPolicy": "NONE"
      }],
      "sources": ["q1_m1_groupby", "q1_m2_groupby", "q1_m3_groupby", "q1_m4_groupby", "q1_m5_groupby", "q1_m6_groupby", "q1_m7_groupby", "q1_m8_groupby", "q1_m9_groupby", "q1_m10_groupby", "q1_m11_groupby", "q1_m12_groupby", "q1_m13_groupby", "q1_m14_groupby", "q1_m15_groupby"]
  }

Output
------

The output of the node will be a set of metrics with the ``as`` string substituted the metric name and the quantile appended to the existing tag set with the key as ``_quantile`` and the value as the given quantile to be calculated with the decimals rounded to 3 places, e.g.:

.. code-block:: javascript

   "metric": "tsdb.query.user.latency.percentile",
   "tags": {
     "colo": "gq1",
     "_quantile": "75.000"
   },