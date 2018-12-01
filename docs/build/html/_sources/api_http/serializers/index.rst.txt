HTTP Serializers
================

OpenTSDB supports common data formats via Serializers, plugins that can parse different data formats from an HTTP request and return data in the same format in an HTTP response. Below is a list of formatters included with OpenTSDB, descriptions and a list of formatter specific parameters.

* :doc:`json` - The default formatter for OpenTSDB handles parsing JSON requests and returns all data as JSON.

Please see :doc:`../index` for details on selecting a serializer.