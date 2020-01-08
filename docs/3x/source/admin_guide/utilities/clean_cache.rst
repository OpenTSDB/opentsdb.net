clean_cache.sh
==============

OpenTSDB uses a directory for caching graphs and gnuplot scripts. Unfortunately it doesn't clean up after itself at this time so a simple shell script is included to purge all files in the directory if drive where the directory resides drops below 10% of free space. Simply add this script as a cron entry and set it to run as often as you like.

.. WARNING::
  
  This script will purge all files in the directory. Don't store anything important in the temp directory.