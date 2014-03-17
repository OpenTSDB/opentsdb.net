Development
===========

OpenTSDB has a strong and growing base of users running TSDs in production. There are also a number of talented developers creating tools for OpenTSDB or contributing code directly to the project. If you are interested in helping, by adding new features, fixing bugs, adding tools or simply updating documentation, please read the guidelines below. Then sign the contributors agreement and send us a pull request!

Guidelines
^^^^^^^^^^

* Please file `issues on GitHub <https://github.com/OpenTSDB/opentsdb/issues>`_ after checking to see if anyone has posted a bug already. Make sure your bug reports contain enough details so they can be easily understood by others and quickly fixed.
* Read the Development page for tips
* The best way to contribute code is to fork the main repo and `send a pull request <https://help.github.com/articles/using-pull-requests>`_ on GitHub.

  * Bug fixes should be done in the ``master`` branch
  * New features or major changes should be done in the ``next`` branch

* Alternatively, you can send a plain-text patch to the `mailing list <https://groups.google.com/forum/#!forum/opentsdb>`_.
* Before your code changes can be included, please file the `Contribution License Agreement <https://docs.google.com/spreadsheet/embeddedform?formkey=dFNiOFROLXJBbFBmMkQtb1hNMWhUUnc6MQ>`_.
* Unlike, say, the Apache Software Foundation, we do not require every single code change to be attached to an issue. Feel free to send as many small fixes as you want.
* Please break down your changes into as many small commits as possible.
* Please *respect the coding style of the code* you're changing.

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

Details
^^^^^^^

.. toctree::
   :maxdepth: 1
   
   development
   plugins
   http_api