General Development
===================

OpenTSDB isn't laid out like a typical Java project, instead it's a bit more like a C or C++ environment. This page is to help folks who want to modify OpenTSDB and provide updates back to the community.

Build System
^^^^^^^^^^^^
.. index:: Build System
There are almost as many build systems as there are developers so it's impossible to satisfy everyone no matter which system or layout is chosen. Autotools and GNU Make were chosen early on for OpenTSDB because of their flexibility, portability, and especially speed and popular usage. It's not the easiest to configure but for our needs, it's really not too difficult. We'll spell out what you need to change below and give tips for IDE users who want to setup an environment. Note that the build script can now compile a ``pom.xml`` file for compiling with Maven and work is underway to provide better Maven support. However you still have to modify ``Makefile.am`` if you add or remove classes or dependencies and such.

Building
^^^^^^^^

OpenTSDB is built using the standard ``./configure && make`` model that is most commonly employed by many open-source projects. Fresh working copies checked out from Git must first be ``./bootstraped``.

Alternatively, there is a ``build.sh`` script you can run that makes as it takes care of all the steps for you. You can give it a Make target in argument, e.g. ``./build.sh distcheck`` (the default target is ``all``).

Build Targets
-------------

The ``build.sh`` script will compile a JAR and the static GWT files for the front-end GUI if no parameters are passed. Additional parameters include:

* **check** - Executes unit tests and reports on the results. You can specify executing the checks in a specific file via ``test_SRC=<path>``, e.g. ``./build.sh check test_SRC=test/uid/TestNoSuchUniqueId.java``
* **pom.xml** - Compile a POM file to compile with Maven.
* **dist** - Downloads dependencies, compiles OpenTSDB and creates a tarball for distribution
* **distcheck** - Same as dist but also runs unit tests. This should be run before issuing pull requests to verify that everything performs correctly.
* **debian** - Compiles OpenTSDB and generates a Debian package


Adding a Dependency
^^^^^^^^^^^^^^^^^^^

*Please try your best not to*. We're extremely picky on the dependencies and will require a code review before we start depending on a new library. The goal isn't to re-invent the wheel either, but we are very mindful about the number and quality of dependent libraries we pull in.
If you absolutely must add a new dependency, here are the steps:

* Find the canonical source to download the dependent JAR file
* Find or create the proper directory under ``third_party/``
* In that directory, create a ``<depdencency>.jar.md5`` file
* Paste the MD5 hash of the entire jar in that file and save it
* Create or edit the ``include.mk`` file and copy the header info from another directory's file
* Add a ``<DEPENDENCY>_VERSION := <version>`` e.g. ``JACKSON_VERSION := 1.9.4``
* Add a ``<DEPENDENCY> := third_parth/<DIR>/<dependency>$(<DEPENDENCY>_VERSION).jar`` line e.g. ``JACKSON_CORE := third_party/jackson/jackson-core-lgpl-$(JACKSON_CORE_VERSION).jar``
* Add the canonical source URL in the format ``<DEPENDENCY>_BASE_URL := <URL>`` e.g. ``JACKSON_CORE_BASE_URL := http://repository.codehaus.org/org/codehaus/jackson/jackson-core-lgpl/$(JACKSON_VERSION)`` and note that the JAR name will be appended to the end of the URL
* Add the following lines
  ::

    $(<DEPENDENCY>): $(J<DEPENDENCY>).md5
    set dummy ``$(<DEPENDENCY>_BASE_URL)`` ``$(<DEPENDENCY>)``; shift; $(FETCH_DEPENDENCY)
  
  e.g.
  ::
  
    $(JACKSON_CORE): $(JACKSON_CORE).md5
    set dummy ``$(JACKSON_CORE_BASE_URL)`` ``$(JACKSON_CORE)``; shift; $(FETCH_DEPENDENCY)

* Add a line ``THIRD_PARTY += $(<DEPENDENCY>)`` e.g. ``THIRD_PARTY += $(JACKSON_CORE)``
* Next, back in the ``third_party/`` directory, edit the ``include.mk`` file and if you added a new directory for your dependency, insert a reference to the ``.mk`` file in the proper alphabetical position.
* Edit ``Makefile.am``

  * Find the ``tsdb_DEPS = \`` line
  * Add your new dependency in the proper alphabetical position in the format ``$(<DEPENDENCY>)``, e.g. ``$(JACKSON_CORE>``. Note that if you put it the middle of the list, you must finish with the line continuation character, the backslash ``\``. If your dependency goes at the end, do not add the backslash.

    .. Note:: 
  
      If the dependency is only used for unit tests, then add it to the ``test_DEPS = \`` list
    
  * Find the ``pom.xml: pom.xml.in Makefile`` line in the file
  * Add a sed line such as ``-e 's/@<DEPENDENCY>_VERSION@/$(<DEPENDENCY>_VERSION)/' \`` e.g. ``-e 's/@JACKSON_VERSION@/$(JACKSON_VERSION)/' \``

    .. Note::
   
      Unit test dependencies go here as well as regular items
    
* Edit ``pom.xml.in``

  * Find the ``<dependencies>`` XML section
  * Copy and paste an existing dependency section and modify it for your variables

* Now run a build via ``./build.sh`` and verify that it fetches your dependency and builds without errors. * Then run ``./build.sh pom.xml`` to verify that the POM is compiled properly and run a ``mvn compile`` to verify the Maven build works correctly.

Adding/Removing/Moving a Class
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is much easier than dealing with a dependency. You only need to modify ``Makefile.am`` and edit the ``tsdb_SRC := \`` or the ``test_SRC := \`` lists. If you're adding a class, put it in the proper alphabetical position and account for the proper directory and class name. It is case sensitive so make sure to get that right. If removing a class, just delete the line. If moving a class, add the new line and delete the old one. Be careful to handle the line continuation ``\`` backslashes. The last class in each list should NOT end with a backslash, the rest need it.

After editing, rebuild with ``./build.sh`` and verify that your class was compiled and included properly.

IDEs
^^^^
.. index:: IDEs
Many devs use an IDE to work on Java projects and despite OpenTSDB's non-java-standard directory layout, working with an IDE is pretty easy. Here are some steps to get up and running with Eclipse though they should work with other environments. This example assumes you're using Eclipse.

* Clone the GIT repo to a location such as ``/home/$USER/opentsdb``
* Build the repo with ``./build.sh`` from the directory
* Fire up Eclipse or your favorite IDE
* Create a new Java project with a name like ``opentsdb_dev`` so that it winds up in ``/home/$USER/opentsdb_dev``
* Your dev directory should now have a ``./src`` directory
* Create a ``net`` directory under ``./src`` so that you have ``./src/net`` (some IDEs may create a ``./src/java`` dir, so add ``./src/java/net``)
* Create a symlink to the GIT repo's ``./src`` directory from ``./src/net/opentsdb``. E.g. ``ln -s /home/$USER/opentsdb/src /home/$USER/opentsdb_dev/src/net/opentdsb``
* Also, create a ``tsd`` directory under ``./src`` so that you have ``./src/tsd``
* Create a symlink to the GIT repo's ``./src/tsd/client`` directory from ``./src/tsd/client``. E.g. ``ln -s /home/$USER/opentsdb/src/tsd/client /home/$USER/opentsdb_dev/src/tsd/client``
* If your IDE didn't, create a ``./test`` directory under your dev project folder. This will be used for unit tests.
* Add a ``net`` directory under ``./test`` so you have ``./test/net``
* Create a symlink to the GIT repo's ``./test`` directory from ``./test/net/opentsdb``. E.g. ``ln -s /home/$USER/opentsdb/test /home/$USER/opentsdb_dev/test/net/opentdsb``
* Refresh the directory lists in Eclipse and you should see all of the source files
* Right click the ``net.opentsdb.tsd.client`` package under SRC and select ``Build Path`` then ``Exclude`` from the menu
* Now add the downloaded dependencies by clicking Project -> Properties, click the ``Java Build Path`` menu item and click ``Add External JARs`` button.
* Do that for each of the dependencies that were downloaded by the build script
* Copy the file ``./build/src/BuildData.java`` from the GIT repo, post build, to your ``./src/net/opentsdb/`` directory
* Now click Run (or Debug) -> Manage Configurations
* Under Java Application, right click and select New from the pop-up
* Under the Main tab, brows to your ``opentsdb_dev`` project
* For the Main Class, search for ``net.opentsdb.tools.TSDMain``
* Under Arguments, add the runtime arguments to select your Zookeeper quorum and the static and cache directories
* Run or Debug it and hopefully it worked
* Now edit away and when you're ready to publish changes, follow the directions above about modifying the build system (if necessary), publish to your own GitHub fork, and issue a pull request.

.. Note:: 

  This won't compile the GWT UI. If you want to do UI work and have made changes, recompile OpenTSDB or export it as a JAR from your IDE, then execute the following command (assuming the directory structure above):

  ::

    java -cp ``<PATH_TO>gwt-dev-2.4.0.jar;<PATH_TO>gwt-user-2.4.0.jar;<PATH_TO>tsdb-1.1.0.jar;/home/$USER/opentsdb/src/net/opentsdb;/home/$USER/opentsdb/src`` com.google.gwt.dev.Compiler -ea -war <PATH_TO_STATIC_DIRECTORY> tsd.Queryui
