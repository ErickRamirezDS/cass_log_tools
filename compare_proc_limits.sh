#!/bin/sh
#
# Lists process limits of each node in the OpsCenter Diagnostics Report
# for easy comparison.
#
# Author Erick Ramirez, 2015 Jul 02
#

# assume we are in the "nodes" directory
node0=`ls | head -1`

# validate we can find at least 1 process_limits file
plfiles=$(find . -name "process_limits" -type f)

#if no files found
if [ $plfiles = "" ]
then
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

#get the first directory
for plfile in $plfiles
do
    node0=$(dirname $plfile)
    break
done

#get the header from the first file
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
#echo "DEBUG >>>>> limit=[$limit]"

    # display header
    echo "Node IP         - $header"
    echo "-----------------------------------------------------------------------------------------------"

    # iterate through all nodes
    for node in $plfiles
    do
        printf "%15s - " $node
        grep "$limit" $node
    done
    echo ""
done
echo "NOTE - For the output to be readable, run the rename_node_dirs.sh script."
