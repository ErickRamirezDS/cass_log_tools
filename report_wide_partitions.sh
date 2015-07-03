#!/bin/sh
#
# Search for wide partitions from the output of `nodetool cfstats`.
#
# Author Erick Ramirez, 2015 Jun 26
#

# detect partitions wider than 100MB
wide_threshold_size=100000000

# validate input file
if [ "$1" == "" ]
then
    echo "ERROR - Usage: `basename $0` <cfstats_output_file>"
    exit 1
else
    cfstats=$1
fi

# read contents of cfstats output
while read line
do
    # parse the line
    attribute=${line%:*}
    case "$attribute" in
        'Keyspace' )
            keyspace=`echo $line | awk '{print $2}'`
            ;;
        'Table' )
            table=`echo $line | awk '{print $2}'`
            ;;
        'Compacted partition maximum bytes' )
            max_bytes=`echo $line | cut -d: -f2`
            # check if partition is wide
            if [ $max_bytes -gt $wide_threshold_size ]
            then
                max_MB=$(( $max_bytes / 1024 / 1024 ))
#                echo "Table [${keyspace}.$table] has wide partitions with max $max_bytes bytes ($max_MB MB)"
                printf "%15d bytes max (%5d MB) for wide partitions in table [%s.%s]\n" $max_bytes $max_MB $keyspace $table
            fi
            ;;
    esac
done < $cfstats
