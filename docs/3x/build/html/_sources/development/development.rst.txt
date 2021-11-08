General Development
===================

OpenTSDB 1.x and 2.x used Make to compile in a non-Java'y way. 3.x uses straight Maven with modules and is compatible with IDEs. This page goes over general dev and building guidelines.

Building
^^^^^^^^

Standard ``mvn`` commands work fine. E.g. ``mvn clean package`` will cleanout existing builds, build each module and run it's unit test, and create a distribution tarball in ``distribution/target/``. 

Project Layout
^^^^^^^^^^^^^^

The TSDB code base now uses modules with the primary focus being on adding features via plugins. Note that this is still Java 8 modules and we haven't started the ugly migration process of using the Java 9x module system wherein packages should not overlap. In general, interfaces are in the common module while implementations of those same classes are in other modules. We could use some help with organization.

The modules or directories include:

* **common** - The common interfaces and utilities along with implementations that do not require dependencies. The goal is to keep this generically applicable and only include dependencies other modules may not require (though Netty and Jackson snuck in unfortunately). This is just a library.
* **core** - This is the core write and read module of OpenTSDB in that it handles the routing of data, query planning, etc. It's just a library and still needs another module to turn up a useful daemon (generally the ``server-undertow`` module with ``TSDMain.java``). This is just a library.
* **Executors** - This is a directory that was meant to hold various RPC implementations to communicate between TSDB components. It only has the ``http`` implementation right now so we'll probably reorganize this at some point.
* **Implementations** - A catch-all module directory for now that has all kinds of plugins and utilities like the ``servlet`` module to handle JAX-RS servlets for an HTTP server and ``server-undertow`` that can spin up a TSD server using the servlets. It also has Prometheus and Influx query/data converters.
* **Storage** - A directory with storage implentations like the HBase integration and Google Bigtable. Also some queue/pubsub modules.
* **Distribution** - The module that is responsible for building a distributable tarball and Docker container(s).

.. NOTE:: There are still directories (``src``, ``test``) and files from the 2.x code path. This is so we can ``git mv ...`` files from the old to the new, make changes and maintain contribution history.

Contributing
^^^^^^^^^^^^

* Please file `issues on GitHub <https://github.com/OpenTSDB/opentsdb/issues>`_ after checking to see if anyone has posted a bug already. Make sure your bug reports contain enough details so they can be easily understood by others and quickly fixed.
* The best way to contribute code is to fork the main repo and `send a pull request <https://help.github.com/articles/using-pull-requests>`_ on GitHub.

  * Bug fixes should be done in the ``master`` branch
  * New features or major changes should be done in the ``next`` branch

* Alternatively, you can send a plain-text patch to the `mailing list <https://groups.google.com/forum/#!forum/opentsdb>`_.
* Before your code changes can be included, please file the `Contribution License Agreement <https://docs.google.com/spreadsheet/embeddedform?formkey=dFNiOFROLXJBbFBmMkQtb1hNMWhUUnc6MQ>`_.
* Unlike, say, the Apache Software Foundation, we do not require every single code change to be attached to an issue. Feel free to send as many small fixes as you want.
* Please break down your changes into as many small commits as possible.
* Please *respect the coding style of the code* you're changing (as much as possible. We're less picky about this now).

  * Indent code with 2 spaces, no tabs
  * Keep code to 80 columns
  * Curly brace on the same line as ``if``, ``for``, ``while``, etc
  * Variables need descriptive names ``like_this`` (instead of the typical Java style of ``likeThis``)
  * Methods named ``likeThis()`` starting with lower case letters
  * Classes named ``LikeThis``, starting with upper case letters
  * Use the ``final`` keyword as much as you can, particularly in method parameters and returns statements.
  * Avoid checked exceptions as much as possible
  * Always provide the most restrictive visibility to classes and members
  * Javadoc all of your classes and methods. Some folks make use the Java API directly and we'll build docs for the site, so the more the merrier
  * Don't add dependencies to the core OpenTSDB library unless absolutely necessary
  * Add unit tests for any classes/methods you create and verify that your change doesn't break existing unit tests. We know UTs aren't fun, but they are useful

Dependencies
^^^^^^^^^^^^

Do not add dependencies to the `common` or `core` modules if at all possible. If you have a dependency you can't bypass, try writing a plugin.

