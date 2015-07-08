#!/bin/sh
#
# Lists process limits of each node in the OpsCenter Diagnostics Report
# for easy comparison.
#
# Author Erick Ramirez, 2015 Jul 02
#

# Added function to search for files using
# find command.
function checkForFiles {
    # validate we can find at least 1 file
    files=$(find . -name "$1" -type f)

    # check if no files found
    if [ -z "$files" ]
    then
        echo "Couldn't find any files named $1 from here. Exiting"
        exit 1
    fi

    # get the first directory
    for file in $files
    do
        node0=$file
        break
    done
}

# Check for the files first
checkForFiles process_limits

#get the header from the first file
if [ -r $node0 ]
then
    # at least 1 file is readable
    header=`grep Limit $node0`
else
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

# get list of limits
grep -v ^Limit $node0 | while read line
do
    limit=`echo "$line" | sed -e 's/  .*$//'`
#echo "DEBUG >>>>> limit=[$limit]"

    # display header
    echo "Node IP         - $header"
    echo "-----------------------------------------------------------------------------------------------"

    # iterate through all nodes
    for node in $files
    do
        printf "%15s - " $node
        grep "$limit" $node
    done
    echo ""
done
echo "NOTE - For the output to be readable, run the rename_node_dirs.sh script."
