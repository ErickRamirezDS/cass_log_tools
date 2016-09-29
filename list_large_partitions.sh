#!/bin/sh

# Lists all logged partition keys across all nodes found in the system log
# Results are sorted by the max size of each occurance of partiton keys.
# Duplicate keys are removed and only the max size of each is returned
#
# Author Brad Vernon, 2016 Sep 29 - Initial Release
#

pwd=`pwd`
dir_name=`basename $pwd`
if [ "$dir_name" != "nodes" ]
then
    echo "ERROR - Script must be run in the [nodes] directory of the diagnostics report"
    exit 1
fi

FORMAT="%-15s %-20s %-30s %-50s %10s\n"

printf "$FORMAT" "IP" "Keyspace" "Table" "Partition Key" "Size in MB"
printf "$FORMAT" "--" "--------" "-----" "-------------" "----------"

RES=$(grep "Compacting large" */logs/cassandra/system.log | awk '{print $1,$10,$11}' |\
awk -F/ '{print $1,$4,$5}' | sed "s/ system.log:WARN//g" | sed "s/(//g" | sort -k4,4 -nr |\
sort -uk3,3 | sort -k4,4 -nr | awk -F":" '{print $1,$2}' | awk '{print $1,$2,$3,$4,($5/1024/1024)}' 'OFMT=%.2f')

printf "$FORMAT" $RES
