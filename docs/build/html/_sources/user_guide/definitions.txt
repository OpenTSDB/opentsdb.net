Definitions
===========

When it comes to timeseries data, there are lots of terms tossed about that can lead to some confusion. This page is a sort of glossary that helps to define words related to the use of OpenTSDB.

Metric
  A metric is simply the name of a quantitative measurement. Metrics include things like:
  
  * hours worked by an employee
  * webserver downloads of a file
  * snow accumulation in a region
  
  .. NOTE::  
    Notice that the ``metric`` did not include a specific number or a time. That is becaue a ``metric`` is just a label of what you are measuring. The actual measurements are called ``datapoints``, as you'll see later.
  
  Unfortunately OpenTSDB requires metrics to be named as a single, long word without spaces. Thus metrics are usually recorded using "dotted notation". For example, the metrics above would have names like:
  
  * hours.worked
  * webserver.downloads
  * accumulation.snow
  
Tags
  A ``metric`` should be descriptive of what is being measured, but with OpenTSDB, it should not be too specific. Instead, it is better to use ``tags`` to differentiate and organize different items that may share a common metric. Tags are pairs of words that provide a means of associating a metric with a specific item. Each pair consists of a ``tagk`` that represents the group or category of the following ``tagv`` that represents a specific item, object, location or other noun.
  
  Expanding on the metric examples above:
  
  * A business may have four employees, Sue, John, Kelly and Paul. Therefore we may configure a ``tagk`` of ``employee`` with their names as the ``tagv``. These would be recorded as ``employee=sue``, ``employee=john`` etc.
  * Webservers usually have many files so we could have a ``tagk`` of ``file`` to arrive at ``file=logo.jpg`` or ``file=index.php``
  * Snow falls in many regions so we may record a ``tagk`` of ``region`` to get ``region=new_england`` or ``region=north_west``
  
Value
  A value represents the actual numeric measurement of the given metric. One of our employees, Sue, worked 8 hours yesterday, thus the value would be ``8``. There were 1,024 downloads of ``logo.jpg`` from our webserver in the past hour. And 12 inches of snow fell in New England today. 
  
Timestamp
  Timestamps are simply the absolute time when a value for a given metric was recorded. 
  
Datapoint
  Each of the metrics above can be recorded as a number at a specific time. For example, we could record that Sue worked 8 hours at the end of each day. Or that "mylogo.jpg" was downloaded 400 times in the past hour. Thus a datapoint consists of:
  
  * A metric
  * A numeric value
  * A timestamp when the value was recorded
  * One or more sets of tags
    