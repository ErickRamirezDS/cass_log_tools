#!/bin/sh
#
# A script for displaying entries in logs with large rows.
#
# Author Erick Ramirez, 2015 Apr 14
# Updated 2016 Jan 07 - Changed pattern from "large row" to "Compacting large " as a result of CASSANDRA-9643
#

# validate input file
if [ "$1" = "" ]
then
    echo "ERROR - Usage: `basename $0` <system_log>"
    exit 1
else
    system_log=$1
    echo "========== `basename $0`: $system_log =========="
fi

# check for minimum size
if [ "$2" = "" ]
then
    # minimum size not set so default to 1MB
    min_size_bytes=999999
else
    min_size_bytes=$2
fi

grep "Compacting large " $system_log | while read line
do
    # extract the row size
    #row_size=`echo $line | awk '{print $(NF-2)}' | sed -e 's/(//'`
    row_size=`echo $line | sed -e 's/.* (\([0-9]*\) bytes.*/\1/'`

    if [ $row_size -gt $min_size_bytes ]
    then
        # calculate size in MB
        row_size_MB=$(( $row_size / 1024 / 1024 ))

        # display line
        echo "$line | $row_size_MB MB"
    fi
done
