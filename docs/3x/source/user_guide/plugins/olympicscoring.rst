EGADS: Olympic Scoring
======================
.. index:: olympicscoring
`EGADs <https://github.com/yahoo/egads>` is an open source time series analysis module for Java for forecasting future time series behavior. A useful model in the library is the Olympic Scoring algorithm that takes the average of multiple periods spaced in time to compute an expected value. For example, it will align the timestamps for the past 5 Mondays, optionally remove outlier values (the smallest or largest) then average the results to predict will be observed next Monday. 

It is a simple algorithm but works fairly well at handling "seasonal" trends for human behavior.

Fields for the config include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "baselineQuery", "SemanticQuery", "Required", "A full Semantic query to fetch the training data. This allows for a different set of smoothing to feed into the algorithm while comparing against the observed data.", "null", ""
   "baselinePeriod", "String", "Required", "A duration for how wide the traning period should be to match period-over-period. Typically ``1h`` for hourly cycles or ``1w`` for daily cycles.", "null", "1w"
   "baselineNumPeriods", "Numeric", "Required", "The number of periods to look back for training data. E.g. for 7 weeks of history, use ``7``.", "0", "7"
   "baselineAggregator", "String", "Optional", "An aggregator to use when merging the historical periods. It should almost always be ``avg`` but could be ``max`` or ``min``.", "avg", "avg"
   "excludeMax", "Numeric", "Optional", "How many of the highest values to exclude from the baseline calculation.", "0", "1"
   "excludeMin", "Numeric", "Optional", "How many of the smallest values to exclude from the baseline calculation.", "0", "1"
   