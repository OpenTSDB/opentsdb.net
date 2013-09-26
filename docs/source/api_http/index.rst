HTTP API
========

OpenTSDB provides an HTTP based application programming interface to enable integration with external systems. Almost all OpenTSDB features are accessiable via the API such as querying timeseries data, managing metadata and storing data points. Please read this entire page for important information about standard API behavior before investigating individual endpoints.

Overview
--------

The HTTP API is RESTful in nature but provides alternative access through various overrides since not all clients can adhere to a strict REST protocol. The default data exchange is via JSON though plugable ``formatters`` may be accessed, via the request, to send or receive data in different formats. Standard HTTP response codes are used for all returned results and errors will be returned as content using the proper format.

Version 1.X to 2.x
------------------

OpenTSDB 1.x had a simple HTTP API that provided access to common behaviors such as querying for data, auto-complete queries and static file requests. OpenTSDB 2.0 introduces a new, formalized API as documented here. The 1.0 API is still accessible though most calls are deprecated and may be removed in version 3. All 2.0 API calls start with ``/api/``.

Serializers
-----------

2.0 introduces plugable serializers that allow for parsing user input and returning results in different formats such as XML or JSON. Serializers only apply to the 2.0 API calls, all 1.0 behave as before. For details on Serializers and options supported, please read :doc:`serializers/index`

All API calls use the default JSON serializer unless overridden by query string or ``Content-Type`` header. To override:

* **Query String** - Supply a parameter such as ``serializer=<serializer_name>`` where ``<serializer_name>`` is the hard-coded name of the serializer as shown in the ``/api/serializers`` ``serializer`` output field.
  
  .. WARNING:: If a serializer isn't found that matches the ``<serializer_name>`` value, the query will return an error instead of processing further.
  
* **Content-Type** - If a query string is not given, the TSD will parse the ``Content-Type`` header from the HTTP request. Each serializer may supply a content type and if matched to the incoming request, the proper serializer will be used. If a serializer isn't located that maps to the content type, the default serializer will be used.
* **Default** - If no query string parameter is given or the content-type is missing or not matched, the default JSON serializer will be used.

The API documentation will display requests and responses using the JSON serializer. See plugin documentation for the ways in which serializers alter behavior.

.. NOTE:: The JSON specification states that fields can appear in any order, so do not assume the ordering in given examples will be preserved. Arrays may be sorted and if so, this will be documented.

Authentication/Permissions
--------------------------

As of yet, OpenTSDB lacks an authentication and access control system.
Therefore no authentication is required when accessing the API. If you wish to
limit access to OpenTSDB, use network ACLs or firewalls to block access.
We do not recommend running OpenTSDB on a machine with a public IP Address.

Response Codes
--------------

Every request will be returned with a standard HTTP response code. Most responses will include content, particularly error codes that will include details in the body about what went wrong. Successful codes returned from the API include:

.. csv-table::
   :header: "Code", "Description"
   :widths: 10, 90
   
   "200", "The request completed successfully"
   "204", "The server has completed the request successfully but is not returning content in the body. This is primarily used for storing data points as it is not necessary to return data to caller"
   "301", "This may be used in the event that an API call has migrated or should be forwarded to another server"
   
Common error response codes include:

.. csv-table::
   :header: "Code", "Description"
   :widths: 10, 90
   
   "400", "Information provided by the API user, via a query string or content data, was in error or missing. This will usually include information in the error body about what parameter caused the issue. Correct the data and try again."
   "404", "The requested endpoint or file was not found. This is usually related to the static file endpoint."
   "405", "The requested verb or method was not allowed. Please see the documentation for the endpoint you are attempting to access"
   "406", "The request could not generate a response in the format specified. For example, if you ask for a PNG file of the ``logs`` endpoing, you will get a 406 response since log entries cannot be converted to a PNG image (easily)"
   "408", "The request has timed out. This may be due to a timeout fetching data from the underlying storage system or other issues"
   "413", "The results returned from a query may be too large for the server's buffers to handle. This can happen if you request a lot of raw data from OpenTSDB. In such cases break your query up into smaller queries and run each individually"
   "500", "An internal error occured within OpenTSDB. Make sure all of the systems OpenTSDB depends on are accessible and check the bug list for issues"
   "501", "The requested feature has not been implemented yet. This may appear with formatters or when calling methods that depend on plugins"
   "503", "A temporary overload has occurred. Check with other users/applications that are interacting with OpenTSDB and determine if you need to reduce requests or scale your system."
   
Errors
------

If an error occurs, the API will return a response with an error object formatted per the requested response type. Error object fields include:

.. csv-table::
   :header: "Field Name", "Data Type", "Always Present", "Description", "Example"
   :widths: 10, 10, 10, 50, 20
   
   "code", "Integer", "Yes", "The HTTP status code", "400"
   "message", "String", "Yes", "A descriptive error message about what went wrong", "Missing required parameter"
   "details", "String", "Optional", "Details about the error, often a stack trace", "Missing value: type"
   "trace", "String", "Optional", "A JAVA stack trace describing the location where the error was generated. This can be enabled via the ``tsd.http.show_stack_trace`` configuration option. The default for TSD is to hide the stack trace.", "`See below`"

All errors will return with a valid HTTP status error code and a content body with error details. The default formatter returns error messages as JSON with the ``application/json`` content-type. If a different formatter was requested, the output may be different. See the formatter documentation for details.
   
Example Error Result
^^^^^^^^^^^^^^^^^^^^
.. code-block :: javascript

  {
      "error": {
          "code": 400,
          "message": "Missing parameter <code>type</code>",
          "trace": "net.opentsdb.tsd.BadRequestException: Missing parameter <code>type</code>\r\n\tat net.opentsdb.tsd.BadRequestException.missingParameter(BadRequestException.java:78) ~[bin/:na]\r\n\tat net.opentsdb.tsd.HttpQuery.getRequiredQueryStringParam(HttpQuery.java:250) ~[bin/:na]\r\n\tat net.opentsdb.tsd.SuggestRpc.execute(SuggestRpc.java:63) ~[bin/:na]\r\n\tat net.opentsdb.tsd.RpcHandler.handleHttpQuery(RpcHandler.java:172) [bin/:na]\r\n\tat net.opentsdb.tsd.RpcHandler.messageReceived(RpcHandler.java:120) [bin/:na]\r\n\tat org.jboss.netty.channel.SimpleChannelUpstreamHandler.handleUpstream(SimpleChannelUpstreamHandler.java:75) [netty-3.5.9.Final.jar:na]\r\n\tat org.jboss.netty.channel.DefaultChannelPipeline.sendUpstream(DefaultChannelPipeline.java:565) [netty-3.5.9.Final.jar:na]
          ....\r\n\tat java.lang.Thread.run(Unknown Source) [na:1.6.0_26]\r\n"
      }
  }
  
Note that the stack trace is truncated. Also, the trace will include system specific line endings (in this case ``\r\n`` for Windows). If displaying for a user or writing to a log, be sure to replace the ``\n`` or ``\r\n`` and ``\r`` characters with new lines and tabs.

Verbs
-----
   
The HTTP API is RESTful in nature, meaning it does it's best to adhere to the REST protocol by using HTTP verbs to determine a course of action. For example, a ``GET`` request should only return data, a ``PUT`` or ``POST`` should modify data and ``DELETE`` should remove it. Documentation will reflect what verbs can be used on an endpoint and what they do. 

However in some situations, verbs such as ``DELETE`` and ``PUT`` are blocked by firewalls, proxies or not implemented in clients. Furthermore, most developers are used to using ``GET`` and ``POST`` exclusively. Therefore, while the OpenTSDB API supports extended verbs, most requests can be performed with just ``GET`` by adding the query string parameter ``method_override``. This parameter allows clients to pass data for most API calls as query string values instead of body content. For example, you can delete an annotation by issuing a ``GET`` with a query string ``/api/annotation/start_time=1369141261&tsuid=010101&method_override=delete``. The following table describes verb behavior and overrides.

.. csv-table::
   :header: "Verb", "Description", "Override"
   :widths: 10, 70, 20
   
   "GET", "Used to retrieve data from OpenTSDB. Overrides can be provided to modify content. **Note**: Requests via GET can only use query string parameters; see the note below.", "N/A"
   "POST", "Used to update or create an object in OpenTSDB using the content body from the request. Will use a formatter to parse the content body", "method_override=post"
   "PUT", "Replace an entire object in the system with the provided content", "method_override=put"
   "DELETE", "Used to delete data from the system", "method_override=delete"
   
If a method is not supported for a given API call, the TSD will return a 405 error.

.. NOTE:: The HTTP specification states that there shouldn't be an association between data passed in a request body and the URI in a ``GET`` request. Thus OpenTSDB's API does not parse body content in ``GET`` requests. You can, however, provide a query string with data and an override for updating data in certain endpoints. But we recommend that you use ``POST`` for anything that writes data.
   
API Versioning
---------------

OpenTSDB 2.0's API call calls are versioned so that users can upgrade with gauranteed backwards compatability. To access a specific API version, you craft a URL such as ``/api/v<version>/<endpoint>`` such as ``/api/v2/suggest``. This will access version 2 of the ``suggest`` endpoint. Versioning starts at 1 for OpenTSDB 2.0.0. Requests for a version that does not exist will result in calls to the latest version. Also, if you do not supply an explicit version, such as ``/api/suggest``, the latest version will be used.

Query String Vs. Body Content
-----------------------------

Most of the API endpoints support query string parameters, particularly those that fetch data from the system. However due to the complexities of encoding some characters, and particularly Unicode, all endpoints also support access via POST content using formatters. The default format is JSON so clients can use their favorite means of generating a JSON object and send it to the OpenTSDB API via a ``POST`` request. ``POST`` requests will generally provided greater flexibility in the fields offered and fully Unicode support than query strings. 

CORS
----

OpenTSDB provides simple and preflight support for Cross-Origin Resource Sharing (CORS) requests. To enable CORS, you must supply either a wild card ``*`` or a comma separated list of specific domains in the ``tsd.http.request.cors_domains`` configuration setting and restart OpenTSDB. For example, you can supply a value of ``*`` or you could provide a list of domains such as ``beeblebrox.com,www.beeblebrox.com,aurtherdent.com``. The domain list is case insensitive but must fully match any value sent by clients.

When a ``GET``, ``POST``, ``PUT`` or ``DELETE`` request arrives with the ``Origin`` header set to a valid domain name, the server will compare the domain against the configured list. If the domain appears in the list or the wild card was set, the server will add the ``Access-Control-Allow-Origin`` and ``Access-Control-Allow-Methods`` headers to the response after processing is complete. The allowed methods will always be ``GET, POST, PUT, DELETE``. It does not change per end point. If the request is a CORS preflight, i.e. the ``OPTION`` method is used, the response will be the same but with an empty content body and a 200 status code.

If the ``Origin`` domain did not match a domain in the configured list, the response will be a 200 status code and an Error (see above) for the content body stating that access was denied, regardless of whether the request was a preflight or a regular request. The request will not be processed any further.

By default, the ``tsd.http.request.cors_domains`` list is empty and CORS is diabled. Requests are passed through without appending CORS specific headers. If an ``Options`` request arrives, it will receive a 405 error message.

.. NOTE:: Do not rely on CORS for security. It is exceedingly easy to spoof a domain in an HTTP request and OpenTSDB does not perform reverse lookups or domain validation. CORS is only implemented as a means to make it easier JavaScript developers to work with the API.

Documentation
-------------

The documentation for each endpoint listed below will contain details about how to use that endpoint. Eahc page will contain a description of the endpoint, what verbs are supported, the fields in a request, fields in a respone and examples. 

Request Parameters are a list of field names that you can pass in with your request. Each table has the following information:

* Name - The name of the field
* Data Type - The type of data you need to supply. E.g. ``String`` should be text, ``Integer`` must be a whole number (positive or negative), ``Float`` should be a decimal number. The data type may also be a complex object such as an array or map of values or objects. 
  If you see ``Present`` in this column then simply adding the parameter to the query string sets the value to ``true``, the actual value of the parameter is ignored. For example ``/api/put?summary`` will effectively set ``summary=true``. If you request ``/api/put?summary=false``, the API will still consider the request as ``summary=true``.
* Required - Whether or not the parameter is required for a successful query. If the parameter is required, you'll see ``Required`` otherwise it will be ``Optional``. 
* Description - A detailed description of the parameter including what values are allowed if applicable.
* Default - The default value of the ``Optional`` parameter. If the data is required, this field will be blank.
* QS - If the parameter can be supplied via query string, this field will have a ``Yes`` in it, otherwise it will have a ``No`` meaning the parameter can only be supplied as part of the request body content.
* RW - Describes whether or not this parameter can result in an update to data stored in OpenTSDB. Possible values in this column are:

  * *empty* - This means that the field is for queries only and does not, necessarily, represent a field in the response.
  * **RO** - A field that appears in the response but is read only. The value passed along with a request will not alter the output field. 
  * **RW** or **W** - A field that **will** result in an update to the data stored in the system
  
* Example - An example of the parameter value

Deprecated API
--------------

Read :doc:`deprecated`

API Endpoints
-------------

.. toctree::
   :maxdepth: 1
   
   s
   aggregators
   annotation
   config
   dropcaches
   put
   query/index
   search
   serializers
   stats
   suggest
   tree/index
   uid/index
   version
