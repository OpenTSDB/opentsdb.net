Anomaly Detection
=================

Forecasting or anomaly detection is useful when working over time series data that involves "seasonality" or cyclical patterns usually related to human behavior, e.g. people streaming content at the end of a work day. OpenTSDB supports plugins that can analyze stored time series data and process it through algorithms to predict what should happen next. Users can then plot the data to compare against real values or alerting systems can notify users when thresholds have been exceeded.

Plugins available for anomaly processing include:

.. toctree::
   :maxdepth: 1
   
   plugins/olympicscoring
   plugins/prophet

Query Flow
----------

Predicting the future behavior of time series data is a non-trivial task whether it's via a simple statistical algorithm or training machine learning models. To compute the forecast, a fair amount of historical data is needed, ranging from weeks to possibly years or more of information. Caching plays an important role in maintaining the performance of the query layer, thus there are multiple modes of anomaly query execution. OpenTSDB has support for various caching systems and strategies. See _TODO_

Query Modes
-----------

In the query config, these are the possible values for the ``mode`` field.

CONFIG
^^^^^^

In this mode, the prediction is not cached as it is intended for a user with a UI to modify algorithm settings until they find a fit that works for their use case. Each time a query is made the historical data is fetched and passed through the algorithms, thus this can be a heavy query. 

A prediction for the entire query range is generated using historical data. The prediction can then be compared against the current data in the same query and anomalies can be serialized.

In the future we expect to cache the historical data (as long as the base query is not modified) for performance improvements but we'll still have to train with the new settings.

EVALUATE
^^^^^^^^

This is used for alerting where the prediction cache is read and/or populated for future calls. Similar to the config call, historical data is fetched on a prediction cache miss. Caches are populated for a day or an hour of data in segments. Current data within the query time range is compared against the predictions and anomalies detected can be serialized.

PREDICT
^^^^^^^

This mode can be used to pre-populate the cache instead of relying on the evaluate command. This is useful for very expensive queries where an evaluate call may timeout on a cache miss. (In that case the query keeps running in the background and the next call with an evaluate will hopfully find the cache populated.) Predict queries will return a 204 (or empty data set, TODO verify this).

Common Semantic Query Fields
----------------------------

Currently these anomaly algorithms are only supported in the semantic query layer and configuration nodes must be added to the execution graph. The following fields are common across all implementations. 

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "mode", "String", "Required", "One of ``CONFIG``, ``EVALUATE`` or ``PREDICT`` to determine the behavior of the query.", "null", "CONFIG"
   "trainingInterval", "String", "Optional", "A TSDB resolution that determines how far back in time to fetch historical data to train the model with.", "null", "3w"
   "serializeObserved", "Boolean", "Optional", "Whether or not to serialize the current or observed data. The metric and tag sets are unmodified.", "false", "true"
	"serializeThresholds", "Boolean", "Optional", "Whether or not to serialize time series with computed thresholds applied. The ``_anomalyModel`` tag is added and the metric is suffixed with a period and the threshold, e.g. ``.upperBad``. Only thresholds with values configured are serialized.", "false", "true"
	"serializeAlerts", "Boolean", "Optional", "Whether or not to serialize the anomalies. See the section below.", "false", "true"
	"serializeDeltas", "Boolean", "Optional", "Whether or not to serialize the delta of the observed data from the predicted data. Tags include the ``_anomalyModel`` and the metric is suffixed with ``.delta``.", "false", "true"
	"upperThresholdBad", "Numeric", "Optional", "For anomaly detection, a numeric threshold that, when the delta of observed and predicted data exceeds the threshold, a ``bad`` anomaly is emitted.", "null", "25"
	"upperThresholdWarn", "Numeric", "Optional", "For anomaly detection, a numeric threshold that, when the delta of observed and predicted data exceeds the threshold, a ``warn`` anomaly is emitted.", "null", "15"
	"upperIsScalar", "Boolean", "Optional", "When true, the upper bad and warn thresholds are considered as absolute values above the prediction. When false, the thresholds are considered percentages.", "false", "true"
	"lowerThresholdBad", "Numeric", "Optional", "For anomaly detection, a numeric threshold that, when the delta of observed and predicted data is lower than the threshold, a ``bad`` anomaly is emitted.", "null", "25"
	"lowerThresholdWarn", "Numeric", "Optional", "For anomaly detection, a numeric threshold that, when the delta of observed and predicted data is lower than the threshold, a ``warn`` anomaly is emitted.", "null", "15"
	"lowerIsScalar", "Boolean", "Optional", "When true, the lower bad and warn thresholds are considered as absolute values below the prediction. When false, the thresholds are considered percentages.", "false", "true"

Output
------

The output of an anomaly plugin will often consist of multiple time series even if only one is fed into the node. By default the prediction is serialized and the metric name is modified with a suffix of ``.prediction`` and a tag is added with the key ``_anomalyModel`` and a value of the model used, e.g. ``Prophet``.

If ``serializeAlerts`` is enabled, and ``AlertType`` is emitted in the same result set as the prediction. This a list of time stamps where the observed data exceeded the configured thresholds against the prediction. For example:

.. code-block:: javascript

  "1611860520": {
    "level": "BAD",
    "message": "** TEMP 1.8054497E7 is greater than 1.7681267183127187E7 which is > than 15.0%",
    "value": 1.8054497E7,
    "threshold": 1.7681267183127187E7,
    "type": "upperBad"
  }

Field definitions:

.. csv-table::
   :header: "Name", "Data Type", "Description"
   :widths: 20, 15, 75
   
   "level", "String", "The threshold level, either ``BAD`` or ``WARN``."
   "message", "String", "A message that can be sent to the end user. Note that right now it's prefixed by ``** TEMP``. We'll find a way to template that eventually."
   "value", "Numeric", "The observed value"
   "threshold", "Numeric", "The computed threshold based off the prediction."
   "type", "String", "The thresold exceeded. If a ``bad`` threshold is exceeded, the ``warn`` is skipped."

