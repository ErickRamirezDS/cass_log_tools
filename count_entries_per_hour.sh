#!/bin/sh
#
# A crude script which counts the occurrences of a string for each hour
# in the Cassandra system.log.
#
# Author Erick Ramirez, 2015 Mar 31
# Updated by Erick Ramirez, 2015 Aug 20 - changed the way date/time is getting tokenized to account for variations in log entries
#

# validate arguments
if [ "$#" -ne 2 ]
then
    echo "ERROR - Usage: `basename $0` <query_string> <system_log>"
    exit 1
elif [ ! -r $2 ]
then
    echo "ERROR - Log file [$2] not readable"
    exit 2
else
    query_string="$1"
    system_log="$2"
fi

# obtain the unique list of hours where there's a match in the log
grep "$query_string" $system_log | sed -e 's/.* \([0-9]*-[0-9]*-[0-9]* [0-9]*\):.*/\1/' | sort -u | while read hour
do
    # count number of occurences of query_string for given hour
    count=`grep -a "$query_string" $system_log | grep -c "$hour:"`

    # print the result
    echo "$hour:00 - $count"
done

