#!/bin/sh
#
# Lists process limits of each node in the OpsCenter Diagnostics Report
# for easy comparison.
#
# Author Erick Ramirez, 2015 Jul 02
# Updated 2016 Apr 14, Erick Ramirez - ignore errors when grepping non-existent limits file
#

# assume we are in the "nodes" directory
node0=`ls | head -1`

# validate we can find at least 1 process_limits file
if [ -r $node0/process_limits ]
then
    # at least 1 file is readable
    header=`grep Limit $node0/process_limits`
else
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

# get list of limits
grep -v ^Limit $node0/process_limits | while read line
do
    limit=`echo "$line" | sed -e 's/  .*$//'`

    # display header
    echo "Node IP         - $header"
    echo "-----------------------------------------------------------------------------------------------"

    # iterate through all nodes
    for node in *
    do
        printf "%15s - " $node
        grep "$limit" $node/process_limits 2> /dev/null || echo ""
    done
    echo ""
done
echo "NOTE - For the output to be readable, run the rename_node_dirs.sh script."
