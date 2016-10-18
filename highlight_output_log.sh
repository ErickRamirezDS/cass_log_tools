#!/bin/sh
#
# Gets a list of support-relevant entries from the output.log
#
# Author Erick Ramirez, 2015 Jul 14
#


logs=*/logs/cassandra/output.log
#logs=*/logs/cassandra/system.log

# validate script is run in nodes/ directory
this_pwd=`pwd`
this_dir=`basename "$this_pwd"`
#echo "DEBUG >>>>> this_dir [$this_dir]"
if [ ! "$this_dir" = "nodes" ]
then
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

echo "===== DSE version ====="
grep "DSE version" $logs 2> /dev/null
echo ""

echo "===== Cassandra version ====="
grep "Cassandra version" $logs 2> /dev/null
echo ""

echo "===== JNA ====="
grep "JNA" $logs 2> /dev/null
echo ""

echo "===== Heap size ====="
grep "Heap size" $logs 2> /dev/null
echo ""

echo "===== Java version ====="
grep "JVM vendor" $logs 2> /dev/null
echo ""

echo "===== Workload ====="
grep "etting my workload" $logs 2> /dev/null
echo ""

echo "===== Snitch ====="
grep "Snitch" $logs 2> /dev/null | grep Initialized
echo ""

echo "===== Topology ====="
grep "cassandra-topology.properties" $logs 2> /dev/null
echo ""

echo "NOTE - For the output to be readable, run the rename_node_dirs.sh script."
