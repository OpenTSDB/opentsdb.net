HTTP API
========

OpenTSDB provides an HTTP based application programming interface to enable integration with external systems. Almost all OpenTSDB features are accessiable via the API such as querying timeseries data, managing metadata and storing data points. Please read this entire page for important information about standard API behavior before investigating individual endpoints.

Overview
--------

The HTTP API is RESTful in nature but provides alternative access through various overrides since not all clients can adhere to a strict REST protocol. The default data exchange is via JSON though plugable ``formatters`` may be accessed, via the request, to send or receive data in different formats. Standard HTTP response codes are used for all returned results and errors will be returned as content using the proper format.

Authentication/Permissions
--------------------------

As of yet, OpenTSDB lacks an authentication and access control system. Therefore no authentication is required when accessing the API. If you wish to limit access to OpenTSDB, uer network ACLs or firewalls to block access. NEVER run OpenTSDB on a machine with a public IP Address.

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
   
Example Error Result
^^^^^^^^^^^^^^^^^^^^
::

  {
    "error": {
        "code": 400,
        "message": "Missing required parameter",
        "details": "Missing value: type"
    }
  }
  
This is the default error object as JSON. Different formatters may change the layout but must present all of the information.

Verbs
-----


   

API Endpoints
-------------

.. toctree::
   :maxdepth: 2
   
   tree