#!/bin/sh
#
# Lists properties of each node in the cassandra.yaml
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
checkForFiles cassandra-env.sh

# validate we can find at least 1 cassandra.yaml
if [ -r $node0 ]
then
    # at least 1 file is readable
    echo "===== `basename $0` ====="
else
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

# get list of properties
egrep -v "^$|^#" $node0 | grep : | while read line
do
    property=`echo "$line"`

    # iterate through all nodes
    for node in $files
    do
        printf "%15s - " $node
        grep "^${property}:" $node

        # if property was not found, just print the property name
        [ $? -ne 0 ] && echo "[$property]"
    done
    echo ""
done
echo "NOTE - For the output to be readable, run the rename_node_dirs.sh script."
