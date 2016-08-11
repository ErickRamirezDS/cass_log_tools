#!/bin/bash
#
# The xargs removes any leading / training spaces

HOST=$(hostname -I | xargs)

# Grab logs etc

cp /var/log/cassandra/system.log ./$HOST-system.log
cp /var/log/cassandra/output.log ./$HOST-output.log

# Grab nodetool commands

nodetool status > ./$HOST-nodetool_status.out
nodetool describecluster > ./$HOST-nodetool_describecluster.out
nodetool gossipinfo > ./$HOST-nodetool_gossipinfo.out
nodetool info > ./$HOST-nodetool_info.out
nodetool cfstats > ./$HOST-nodetool_cfstats.out
nodetool tpstats > ./$HOST-nodetool_tpstats.out
nodetool compactionstats > ./$HOST-nodetool_compactionstats.out
nodetool netstats > ./$HOST-nodetool_netstats.out
nodetool ring > ./$HOST-nodetool_ring.out
dsetool ring > ./$HOST-dsetool_ring.out
java -version 2> ./$HOST-java_version.out # always writes to stderr
df -h > ./$HOST-df_h.out

# Tar up the files
tar zcf ./$HOST-files.tar.gz ./$HOST-*
