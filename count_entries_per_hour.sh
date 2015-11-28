#!/bin/sh
#
# A crude script which counts the occurrences of a string for each hour
# in the Cassandra system.log.
#
# Author Erick Ramirez, 2015 Mar 31
#

#q=ParNew
#for node in *; do echo "===== $node ====="; log=$node/system-20150317.log; for x in `grep "$q" $log | awk '{print $4}' | cut -d: -f1 | sort -u`; do y=`grep "$q" $log | grep -c "2015-03-17 $x:"`; echo "${x}:00 - $y"; done; echo ""; done

# validate arguments
if [ "$#" -ne 2 ]
then
    echo "ERROR - Usage: `basename $0` <query_string> <system_log>"
    exit 1
else
    query_string="$1"
    system_log="$2"
fi

# obtain the unique list of hours where there's a match in the log
grep -a "$query_string" $system_log | awk '{print $3, $4}' | cut -d: -f1 | sort -u | while read hour
do
    # count number of occurences of query_string for given hour
    count=`grep -a "$query_string" $system_log | grep -c "$hour:"`

    # print the result
    echo "$hour:00 - $count"
done

