Interpolators
=============
.. index:: interpolator
Interpolators handle filling missing values when performing operations on time series such as filling in a value when grouping multiple series or substituting a value for an empty downsampling bucket.

While OpenTSDB 1.x and 2.x offered linear interpolation, 3.0 offers more options for greater control over results.

Whenever an interpolator config is required, the following fields can be supplied:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "type", "String", "Optional", "The type of interpolator to use. If null or empty, the **default** interpolator is used meaning it will only use the ``fillPolicy`` and ``realFillPolicy`` fields. Others may be available, see below.", "null", "LERP"
   "dataType", "String", "Required", "The data type this interpolator is to act on. There can be interpolators for numeric data and summary data with different configs for each.", "null", "Numeric"
   "fillPolicy", "String", "Required", "The ID of a fill policy when interpolation cannot occur (e.g. there aren't enough values to interpolate or the interpolator doesn't actually interpolate). See below for details.", "null", "ZERO"
   "realFillPolicy", "String", "Required", "An optional policy to use when real data is available and we would prefer to fill with that instead of synthetic data.", "null", "NONE"
   "value", "Number", "Optional", "A value to substitute when the ``SCALAR`` ``FillPolicy`` is selected.", "null", "42"

As seen above, there are a number of configurations available when interpolating data. The order of these settings is:

1. **Interpolation** - Real data is present and enough values are present to compute a fill value. E.g. the LERP interpolator requires a value on either side of the timestamp. Note that the default interpolator does not actually interpolate.
2. **RealFillPolicy** - At least one real value is present on one side of the timestamp and the policy can choose to use that va lue.
3. **FillPolicy** - No data is available and a completely synthetic value must be chosen.

RealFillPolicy
^^^^^^^^^^^^^^
Possible values include:

* **NONE** - Skip filling with real values and fall through to the ``FillPolicy``.
* **PREVIOUS_ONLY** - If a value earlier than the timestamp is available, fill with that previous value. Ignore values later than the timestamp.
* **PREFER_PREVIOUS** - If a value earlier than the timestamp is available, fill with that previous value. However if a value later is available, fill with that.
* **NEXT_ONLY** - If a value later than the timestamp is available, fill with that next value. Ignore values earlier than the timestamp.
* **PREFER_NEXT** - If a value later than the timestamp is available, fill with that next value. However if a value earlier is available, fill with that.

FillPolicy
^^^^^^^^^^
Possible values include:

* **NAN** - Fill with ``NaN`` values (floating point).
* **ZERO** - Fill with ``0``.
* **NULL** - Fill with null values. Some operations may treat this as a NaN or 0.
* **MIN** - Fill with the minimum value for the type (either 64 bit signed integer or 64 bit signed floating point).
* **MAX** - Fill with the maximum value for the type (either 64 bit signed integer or 64 bit signed floating point).
* **SCALAR** - Fill with a fixed integer or floating point value. Must set the ``value`` field.

Example:

.. code-block:: javascript
  
  "interpolatorConfigs": [{
    "dataType": "numeric",
    "fillPolicy": "NAN",
    "realFillPolicy": "NONE"
  }]

LERP
----
Linear interpolation. For now, see the old 2x docs till we port them over here.