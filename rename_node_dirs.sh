#!/bin/sh
#
# A simple script for renaming the long directory names of nodes in the diagnostic report.
#
# Author Erick Ramirez, 2014 Oct 24
#

#---confirm we are in the "nodes" directory
pwd=`pwd`
dir_name=`basename $pwd`
if [ "$dir_name" != "nodes" ]
then
    echo "ERROR - Script must be run in the [nodes] directory of the diagnostics report"
    exit 1
fi

for node in *
do
    new_name=`echo $node | awk -F"-" '{print $(NF)}'`
    printf "Renaming [$node] to [$new_name]... "
    mv $node $new_name && printf "OK\n" || printf "Failed\n"
done
