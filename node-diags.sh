#!/bin/bash
#

# Run commands, redirect to individual files
nodetool status > `hostname -i`-nodetool_status.out
nodetool describecluster > `hostname -i`-nodetool_describecluster.out
nodetool gossipinfo > `hostname -i`-nodetool_gossipinfo.out
nodetool info > `hostname -i`-nodetool_info.out
nodetool cfstats > `hostname -i`-nodetool_cfstats.out
nodetool tpstats > `hostname -i`-nodetool_tpstats.out
nodetool compactionstats > `hostname -i`-nodetool_compactionstats.out
nodetool netstats > `hostname -i`-nodetool_netstats.out
nodetool ring > `hostname -i`-nodetool_ring.out
dsetool ring > `hostname -i`-dsetool_ring.out
java -version 2> `hostname -i`-java_version.out # always writes to stderr
df -h > `hostname -i`-df_h.out

# Tar up the files
tar zcf `hostname -i`-files.tar.gz `hostname -i`-*
