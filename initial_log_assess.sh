#!/bin/sh
#
# A crude script I use to perform an initial assessment of a Cassandra system.log
# by mainly showing only errors, warnings, GC behaviour, etc.
#
# Author Erick Ramirez, 2015 Apr 11
#

#---validate arguments
if [ "$1" = "" ]
then
    echo "ERROR - Usage: `basename $0` <system_log>"
    exit 1
else
    system_log="$1"
fi



# verify that log is readable
if [ -r $system_log ]
then
    egrep "ERROR|WARN|GCInspector|Logging initialized|shutting down|messages dropped|HintedHandoffManager|large row" $system_log
else
    # cannot open the log file
    echo "ERROR - Unable to read or open [$system_log]"
    exit 2
fi
