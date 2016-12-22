#!/bin/sh
#
# Search for large partitions from the output of `nodetool cfstats`.
#
# Author Erick Ramirez, 2015 Jun 26
# Updated 2015 Sep 12 - added fix for cfstats entry "Table (index)" not getting parsed correctly
#

# detect partitions wider than 1GB
giga_byte=$(( 1024 * 1024 * 1024 ))
wide_threshold_size=$giga_byte

# validate input file
if [ "$1" = "" ]
then
    echo "ERROR - Usage: `basename $0` <cfstats_output_file>"
    exit 1
else
    cfstats=$1
fi

# skip if cfstats does not exist
if [ ! -r $cfstats ]
then
    echo "WARNING - [$cfstats] does not exist"
    exit 2
fi

# read contents of cfstats output
egrep "Keyspace: |Table: |Compacted partition maximum bytes" $cfstats | while read line
do
    # parse the line
    attribute=${line%:*}

    # ADDED: 2015 Sep 12 - remove "(index)" in entry "Table (index): ..."
    attribute=`echo $attribute | sed -e 's/ (.*)//'`

    case "$attribute" in
        'Keyspace' )
            keyspace=`echo $line | cut -d: -f2`
            ;;
        'Table' )
            table=`echo $line | cut -d: -f2`
            ;;
        'Compacted partition maximum bytes' )
            max_bytes=`echo $line | cut -d: -f2`
            # check if partition is wide
            if [ $max_bytes -gt $wide_threshold_size ]
            then
                max_MB=$(( $max_bytes / 1024 / 1024 ))
#                echo "Table [${keyspace}.$table] has wide partitions with max $max_bytes bytes ($max_MB MB)"
                printf "%15d bytes max (%5d MB) for large partitions in table [%s.%s]\n" $max_bytes $max_MB $keyspace $table
            fi
            ;;
    esac
done
