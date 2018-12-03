.. OpenTSDB documentation master file, created by
   sphinx-quickstart on Fri Mar 08 18:50:48 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Documentation for OpenTSDB |version|
====================================

Welcome to OpenTSDB |version|, the scalable, distributed time series database. 

.. Warning::
  
  Version 3.0 is still under active development and many features may change before it's release. This documention should reflect the current state of the code at any time but if you see something outdated, please let us know or give us a PR.

3.0 is a massive change for OpenTSDB with improved query performance and flexibility yet it maintains backwards compatibility as much as possible with previous versions. Data written to HBase or Bigtable from previous versions can still be read (though annotations and histograms won't work quite yet, coming soon).

The HTTP API is backwards compatible with 2.x via `/api/query` but note that 1.x querying has been dropped.

And the Telnet style API has not been reimplemented yet. You can write data via the HTTP API for now.

Contents
========

.. toctree::
   :maxdepth: 1
   
   changes
   installation
   api_http/index
   
Indices and tables
==================

* :ref:`genindex`
* :ref:`search`