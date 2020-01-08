Load Balancing with Varnish
===========================

`Varnish <https://www.varnish-cache.org/>`_ is a powerful HTTP load balancer (reverse proxy), which is also very good at caching. When running multiple TSDs, Varnish comes in handy to distribute the HTTP traffic across the TSDs. Bear in mind that write traffic doesn't use the HTTP protocol by default, and as such you can only use Varnish for read queries. Using Varnish will help you easily scale the amount of read capacity of your TSD cluster.

The following is a sample Varnish configuration recommended for use with OpenTSDB. It uses a slightly custom load balancing strategy to achieve optimal cache hit rate at the TSD level. This configuration requires at least Varnish 2.1.0 to run, but using Varnish 3.0 or above is strongly recommended.

This sample configuration is for 2 backends, named ``foo`` and ``bar``. You need to substitute at least the host names.

::

  # VCL configuration for OpenTSDB.

  backend foo {
      .host = "foo";
      .port = "4242";
      .probe = {
          .url = "/version";
          .interval = 30s;
          .timeout = 10s;
          .window = 5;
          .threshold = 3;
      }
  }

  backend bar {
      .host = "bar";
      .port = "4242";
      .probe = {
          .url = "/version";
          .interval = 30s;
          .timeout = 10s;
          .window = 5;
          .threshold = 3;
      }
  }

  # The `client' director will select a backend based on `client.identity'.
  # It's normally used to implement session stickiness but here we abuse it
  # to try to send pairs of requests to the same TSD, in order to achieve a
  # higher cache hit rate.  The UI sends queries first with a "&json" at the
  # end, in order to get meta-data back about the results, and then it sends
  # the same query again with "&png".  If the second query goes to a different
  # TSD, then that TSD will have to fetch the data from HBase again.  Whereas
  # if it goes to the same TSD that served the "&json" query, it'll hit the
  # cache of that TSD and produce the PNG directly without using HBase.
  #
  # Note that we cannot use the `hash' director here, because otherwise Varnish
  # would hash both the "&json" and the "&png" requests identically, and it
  # would thus serve a cached JSON response to a "&png" request.
  director tsd client {
      { .backend = foo; .weight = 100; }
      { .backend = bar; .weight = 100; }
  }

  sub vcl_recv {
      set req.backend = tsd;
      # Make sure we hit the same backend based on the URL requested,
      # but ignore some parameters before hashing the URL.
      set client.identity = regsuball(req.url, "&(o|ignore|png|json|html|y2?range|y2?label|y2?log|key|nokey)\b(=[^&]*)?", "");
  }

  sub vcl_hash {
      # Remove the `ignore' parameter from the URL we hash, so that two
      # identical requests modulo that parameter will hit Varnish's cache.
      hash_data(regsuball(req.url, "&ignore\b(=[^&]*)?", ""));
      if (req.http.host) {
          hash_data(req.http.host);
      } else {
          hash_data(server.ip);
      }
      return (hash);
  }

On many Linux distros (including Debian and Ubuntu), you need to put the configuration above in ``/etc/varnish/default.vcl``. We also recommend tweaking the command-line parameters of ``varnishd`` in order to use a memory-backed cache of about 1GB if you can afford it. On Debian/Ubuntu systems, this is done by editing ``/etc/default/varnish`` to make sure that ``-s malloc,1G`` is passed to ``varnishd``.

Read more about Varnish:

* `The VCL configuration language <http://www.varnish-cache.org/docs/trunk/reference/vcl.html>`_
* `Health checking backends <http://www.varnish-cache.org/trac/wiki/BackendPolling>`_
* `Tweaking the load balancing strategy <http://www.varnish-cache.org/trac/wiki/LoadBalancing>`_

.. Note:: 

  if you're using Varnish 2.x (which is not recommended as we would strongly encourage you to migrate to 3.x) you have to replace each function call ``hash_data(foo);`` to set ``req.hash += foo;`` in the VCL configuration above.