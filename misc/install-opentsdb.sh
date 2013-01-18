#!/bin/bash
set -xe
HBASE_VERSION=0.94.4
export TMPDIR=${TMPDIR-'/tmp'}/opentsdb
mkdir -p "$TMPDIR"
cd "$TMPDIR"

# 1. Download and unpack HBase.
wget http://www.apache.org/dist/hbase/hbase-$HBASE_VERSION/hbase-$HBASE_VERSION.tar.gz
tar xfz hbase-$HBASE_VERSION.tar.gz
cd hbase-$HBASE_VERSION

# 2. Configure HBase.
hbase_rootdir=${TMPDIR-'/tmp'}/tsdhbase
iface=lo`uname | sed -n s/Darwin/0/p`
cat >conf/hbase-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>file:///$hbase_rootdir/hbase-\${user.name}/hbase</value>
  </property>
  <property>
    <name>hbase.zookeeper.dns.interface</name>
    <value>$iface</value>
  </property>
  <property>
    <name>hbase.regionserver.dns.interface</name>
    <value>$iface</value>
  </property>
  <property>
    <name>hbase.master.dns.interface</name>
    <value>$iface</value>
  </property>
</configuration>
EOF

# 3. Start HBase.
./bin/start-hbase.sh

# 4. Download and build OpenTSDB
cd ..
git clone git://github.com/OpenTSDB/opentsdb.git
cd opentsdb
./build.sh
env COMPRESSION=none HBASE_HOME=../hbase-$HBASE_VERSION ./src/create_table.sh
tsdtmp=${TMPDIR-'/tmp'}/tsd    # For best performance, make sure
mkdir -p "$tsdtmp"             # your temporary directory uses tmpfs
./build/tsdb tsd --port=4242 --staticroot=build/staticroot --cachedir="$tsdtmp"
