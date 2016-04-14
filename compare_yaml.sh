#!/bin/sh
#
# Lists properties of each node in the cassandra.yaml
# for easy comparison.
#
# Author Erick Ramirez, 2015 Jul 02
# Updated 2016 Apr 14, Erick Ramirez - ignore errors when grepping non-existent yaml
#

# assume we are in the "nodes" directory
node0=`ls | head -1`

# validate we can find at least 1 cassandra.yaml
if [ -r $node0/conf/cassandra/cassandra.yaml ]
then
    # at least 1 file is readable
    echo "===== `basename $0` ====="
else
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

# get list of properties
egrep -v "^$|^#" $node0/conf/cassandra/cassandra.yaml | grep : | while read line
do
    property=`echo "$line" | cut -d: -f1`

    # iterate through all nodes
    for node in *
    do
        printf "%15s - " $node
        grep "^${property}:" $node/conf/cassandra/cassandra.yaml 2> /dev/null

        # if property was not found, just print the property name
        [ $? -ne 0 ] && echo "[$property]"
    done
    echo ""
done
echo "NOTE - For the output to be readable, run the rename_node_dirs.sh script."
