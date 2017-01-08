/api/config/filters
===================
.. index:: HTTP /api/config/filters
**(Version 2.2 and later)**
This endpoint lists the various filters loaded by the TSD and some information about how to use them.

Verbs
-----

* GET
* POST

Requests
--------

This endpoint does not require any parameters via query string or body.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  http://localhost:4242/api/config/filters
   
Response
--------
   
The response is a map of filter names or types and sub maps of examples and descriptions. The examples show how to use them in both URI and JSON queries.

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  {
    "iliteral_or": {
        "examples": "host=iliteral_or(web01),  host=iliteral_or(web01|web02|web03)  {\"type\":\"iliteral_or\",\"tagk\":\"host\",\"filter\":\"web01|web02|web03\",\"groupBy\":false}",
        "description": "Accepts one or more exact values and matches if the series contains any of them. Multiple values can be included and must be separated by the | (pipe) character. The filter is case insensitive and will not allow characters that TSDB does not allow at write time."
    },
    "wildcard": {
        "examples": "host=wildcard(web*),  host=wildcard(web*.tsdb.net)  {\"type\":\"wildcard\",\"tagk\":\"host\",\"filter\":\"web*.tsdb.net\",\"groupBy\":false}",
        "description": "Performs pre, post and in-fix glob matching of values. The globs are case sensitive and multiple wildcards can be used. The wildcard character is the * (asterisk). At least one wildcard must be present in the filter value. A wildcard by itself can be used as well to match on any value for the tag key."
    },
    "not_literal_or": {
        "examples": "host=not_literal_or(web01),  host=not_literal_or(web01|web02|web03)  {\"type\":\"not_literal_or\",\"tagk\":\"host\",\"filter\":\"web01|web02|web03\",\"groupBy\":false}",
        "description": "Accepts one or more exact values and matches if the series does NOT contain any of them. Multiple values can be included and must be separated by the | (pipe) character. The filter is case sensitive and will not allow characters that TSDB does not allow at write time."
    },
    "not_iliteral_or": {
        "examples": "host=not_iliteral_or(web01),  host=not_iliteral_or(web01|web02|web03)  {\"type\":\"not_iliteral_or\",\"tagk\":\"host\",\"filter\":\"web01|web02|web03\",\"groupBy\":false}",
        "description": "Accepts one or more exact values and matches if the series does NOT contain any of them. Multiple values can be included and must be separated by the | (pipe) character. The filter is case insensitive and will not allow characters that TSDB does not allow at write time."
    },
    "not_key": {
        "examples": "host=not_key()  {\"type\":\"not_key\",\"tagk\":\"host\",\"filter\":\"\",\"groupBy\":false}",
        "description": "Skips any time series with the given tag key, regardless of the value. This can be useful for situations where a metric has inconsistent tag sets. NOTE: The filter value must be null or an empty string."
    },
    "iwildcard": {
        "examples": "host=iwildcard(web*),  host=iwildcard(web*.tsdb.net)  {\"type\":\"iwildcard\",\"tagk\":\"host\",\"filter\":\"web*.tsdb.net\",\"groupBy\":false}",
        "description": "Performs pre, post and in-fix glob matching of values. The globs are case insensitive and multiple wildcards can be used. The wildcard character is the * (asterisk). Case insensitivity is achieved by dropping all values to lower case. At least one wildcard must be present in the filter value. A wildcard by itself can be used as well to match on any value for the tag key."
    },
    "literal_or": {
        "examples": "host=literal_or(web01),  host=literal_or(web01|web02|web03)  {\"type\":\"literal_or\",\"tagk\":\"host\",\"filter\":\"web01|web02|web03\",\"groupBy\":false}",
        "description": "Accepts one or more exact values and matches if the series contains any of them. Multiple values can be included and must be separated by the | (pipe) character. The filter is case sensitive and will not allow characters that TSDB does not allow at write time."
    },
    "regexp": {
        "examples": "host=regexp(.*)  {\"type\":\"regexp\",\"tagk\":\"host\",\"filter\":\".*\",\"groupBy\":false}",
        "description": "Provides full, POSIX compliant regular expression using the built in Java Pattern class. Note that an expression containing curly braces {} will not parse properly in URLs. If the pattern is not a valid regular expression then an exception will be raised."
    }
}
