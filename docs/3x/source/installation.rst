Installation and Quick Start
============================
.. index:: Installation
OpenTSDB, so far, must be compiled from source. You can use the compiled libs directly or build a Docker image. The source is at `https://github.com/OpenTSDB/opentsdb/tree/3.0 <https://github.com/OpenTSDB/opentsdb/tree/3.0>`_, just make sure to checkout the 3.0 branch.

Runtime Requirements
^^^^^^^^^^^^^^^^^^^^
.. index:: Requirements
To actually run OpenTSDB, you'll need to meet the following:

* A Linux system (or Windows with manual building)
* Java Runtime Environment 1.8 or later
* A data store such as:
    * HBase 0.92 or later
    * Google Bigtable
    * The dummy in-memory built-in store

Installation
^^^^^^^^^^^^

3.0 has a built-in super simple and inefficient in-memory data store that you can read and write from. If the ``MockBase`` plugin is loaded, you can query some data as soon as you start the process and write using the ``/api/put`` HTTP API.

If you have data in HBase (TODO, Bigtable support is kinda working but it's slow right now) then you can query it without problem. If you want to test with HBase, follow the 2.x documentation to install HBase and configure the tables.

Compile
^^^^^^^

From the root directory, run ``mvn package`` (append `-Dmaven.test.skip=true` if you don't want to run tests) and look in the ``distribution/target/`` directory. There will be a tarball you can move around and uncompress, e.g. to some place like ``/opt/opentsdb/`` or ``/usr/share/opentsdb``. That directory will contain sub directories including `bin` where the exec script is located, ``conf`` where configurations lie and `lib` where the JARs are located. 

Docker
^^^^^^

To build the Docker image, from the root directory run ``mvn package -Pdocker`` and it should build and install an image in your local docker repo (assuming Docker is installed). NOTE: We could use some help on properly building docker and getting instructions together on how to upload the image somewhere).

Quickstart
----------

Local
^^^^^

* Create a logging directory named `/var/log/opentsdb`. If you're on a Mac, run `sudo mkdir /var/log/opentsdb` then run `sudo chown <your username> /var/log/opentsdb`. If you can't create that directory due to permissions, modify the `conf/logback.xml` file to write to a different directory.
* Change to `cd distribution/target/opentsdb-3.0.90-SNAPSHOT/opentsdb/` or the properly versioned directory.
* To start a TSD, run ``bin/tsdb tsd --config.providers=file://conf/opentsdb_dev.yaml`` to run the in-memory store or ``bin/tsdb tsd --config.providers=file://conf/opentsdb.yaml`` to run it with HBase (and make sure to modify the config for your HBase settings).
* Make sure the TSD is running by loading `http://localhost:4242/api/registry/plugins` in your browser or via a CLI tool.

Docker
^^^^^^

* To start the docker image, run ``docker run --name opentsdb -d -p 4242:4242 opentsdb``. 
* Make sure the TSD is running by loading `http://localhost:4242/api/registry/plugins` in your browser or via a CLI tool.

Querying
^^^^^^^^
.. Note ::

  This section assumes you are using the in-memory store. At startup, some dummy time series are written with dummy data using a timestamp around the startup time.

Using a CLI tool like CURL or a Restful API GUI tool like Postmane, make an HTTP POST V3 query to `http://localhost:4242/api/query/graph` with the following JSON:

.. code-block:: javascript

    {
    	"start": "1h-ago",
    	"mode": "SINGLE",
    	"timezone": "America/Denver",
    	"executionGraph": [{
    		"id": "m1",
    		"type": "TimeSeriesDataSource",
    		"metric": {
    			"metric": "sys.if.in",
    			"type": "MetricLiteral"
    		},
    		"filter": {
    			"type": "chain",
    			"filters": [{
    				"type": "TagValueLiteralOr",
    				"filter": "web02",
    				"key": "host"
    			},{
    				"type": "TagValueLiteralOr",
    				"filter": "DEN",
    				"key": "dc"
    			}]
    		}
    	}, {
    		"id": "ds",
    		"type": "downsample",
    		"aggregator": "avg",
    		"interval": "auto",
    		"runAll": false,
    		"fill": true,
    		"interpolatorConfigs": [{
    			"dataType": "numeric",
    			"fillPolicy": "NAN",
    			"realFillPolicy": "NONE"
    		}],
    		"sources": ["m1"]
    	}, {
    		"id": "m2",
    		"type": "TimeSeriesDataSource",
    		"metric": {
    			"metric": "sys.if.out",
    			"type": "MetricLiteral"
    		},
    		"filter": {
    			"type": "chain",
    			"filters": [{
    				"type": "TagValueLiteralOr",
    				"filter": "web02",
    				"key": "host"
    			},{
    				"type": "TagValueLiteralOr",
    				"filter": "DEN",
    				"key": "dc"
    			}]
    		}
    	}, {
    		"id": "ds2",
    		"type": "downsample",
    		"aggregator": "avg",
    		"interval": "1m",
    		"runAll": false,
    		"fill": true,
    		"interpolatorConfigs": [{
    			"dataType": "numeric",
    			"fillPolicy": "NAN",
    			"realFillPolicy": "NONE"
    		}],
    		"sources": ["m2"]
    	}, {
    		"id": "e1",
    		"type": "expression",
    		"expression": " m1 + m2 ",
    		"join": {
    			"type": "Join",
    			"joinType": "NATURAL_OUTER",
    			"joins": {}
    		},
    		"interpolatorConfigs": [{
    			"dataType": "numeric",
    			"fillPolicy": "NAN",
    			"realFillPolicy": "NONE"
    		}],
    		"infectiousNan": true,
    		"substituteMissing": true,
    		"variableInterpolators": {},
    		"sources": ["ds", "ds2"]
    	}],
    	"serdesConfigs": [{
    		"id": "JsonV3QuerySerdes",
    		"type": "JsonV3QuerySerdes",
    		"filter": ["e1"]
    	}],
    	"logLevel": "TRACE"
    }


For a V2 query, use the endpoint `http://localhost:4242/api/query/` and post:

.. code-block:: javascript
    
    {
      "start": "2h-ago",
      "queries": [
        {
          "aggregator": "zimsum",
          "metric": "sys.if.in",
          "rate": true,
          "rateOptions": {
            "counter": true,
            "resetValue": 1
          },
          "explicitTags": false,
          "tags": {},
          "downsample": "60s-avg-nan",
          "tot": [],
          "filters": [
            {
              "type": "wildcard",
              "tagk": "dc",
              "filter": "*",
              "groupBy": true
            }
          ]
        }
      ],
      "showQuery": false
    }

You should see some time series in the output and this will confirm that the TSD is up and running.

Write Data
----------

Now that you can query data, try writing something. Currently we only have the HTTP JSON API available. As an example, **POST** the following JSON to `http://localhost:4242/api/put/`:

.. code-block:: javascript

    [{
        "metric": "my.test.metric",
        "timestamp": 1546300800,
        "value": 18,
        "tags": {
           "host": "web01"
        }
    },
    {
        "metric": "my.test.metric",
        "timestamp": 1546300800,
        "value": 14,
        "tags": {
           "host": "web02"
        }
    },{
        "metric": "my.test.metric",
        "timestamp": 1546300860,
        "value": 2,
        "tags": {
           "host": "web01"
        }
    },
    {
        "metric": "my.test.metric",
        "timestamp": 1546300860,
        "value": 32.5,
        "tags": {
           "host": "web02"
        }
    }
    ]

You should get a `204` response code without any content. This means the data was written successfully to the in-memory store. Turn around an **POST** the following query to ``:

.. code-block:: javascript

    {
    	"start": "1546300000",
    	"end":"1546344000",
    	"mode": "SINGLE",
    	"timezone": "America/Denver",
    	"executionGraph": [{
    		"id": "m1",
    		"type": "TimeSeriesDataSource",
    		"metric": {
    			"metric": "my.test.metric",
    			"type": "MetricLiteral"
    		}
    	}, {
    		"id": "gb",
    		"type": "groupby",
    		"aggregator": "sum",
    		"tagKeys": ["host"],
    		"interpolatorConfigs": [{
    			"dataType": "numeric",
    			"fillPolicy": "NAN",
    			"realFillPolicy": "NONE"
    		}],
    		"sources": ["m1"]
    	}],
    	"serdesConfigs": [{
    		"id": "JsonV3QuerySerdes",
    		"type": "JsonV3QuerySerdes",
    		"filter": ["gb"]
    	}],
    	"logLevel": "TRACE"
    }

You should see a result like:

.. code-block:: javascript

    {
        "results": [
            {
                "source": "gb:m1",
                "data": [
                    {
                        "NumericType": {
                            "1546300800": 18,
                            "1546300860": 2
                        },
                        "metric": "my.test.metric",
                        "tags": {
                            "host": "web01"
                        }
                    },
                    {
                        "NumericType": {
                            "1546300800": 14,
                            "1546300860": 32.5
                        },
                        "metric": "my.test.metric",
                        "tags": {
                            "host": "web02"
                        }
                    }
                ]
            }
        ],
        "log": [
            "23:31:10,993  TRACE  CTX:1458874482 Q:8843409259624131098  [None] -  -------------------------\n[V] QueryContext (ContextNodeConfig)\n[V] m1 (DefaultTimeSeriesDataSourceConfig)\n[V] gb (GroupByConfig)\n\n[E] QueryContext => gb\n[E] gb => m1\n -------------------------\n",
            "23:31:10,994  DEBUG  CTX:1458874482 Q:8843409259624131098  [m1] - [MockDataStore@68857875] DONE with filtering. net.opentsdb.storage.MockDataStore$LocalNode@2bfb5dae  Results: 4",
            "23:31:10,995  TRACE  CTX:1458874482 Q:8843409259624131098  [gb] - Received response: gb:m1",
            "23:31:10,995  TRACE  CTX:1458874482 Q:8843409259624131098  [None] - Query serialization complete."
        ]
    }

Now you're good to try out alternative configurations, different queries and more. Thanks!
