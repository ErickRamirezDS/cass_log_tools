#!/bin/sh
#
# Search for values that are over specified thresholds from the output of `nodetool cfstats`.
#
#

# detect max partitions wider than 100MB, or mean wider than 50MB
one_hundred_mb=$(( 100 * 1024 * 1024 ))
fifty_mb=$(( 50 * 1024 * 1024 ))

max_partition_size_threshold=$one_hundred_mb
mean_partition_size_threshold=$fifty_mb



# validate input file
if [ "$1" == "" ]
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
while read line
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
            if [ $max_bytes -gt $max_partition_size_threshold ]
            then
                max_MB=$(( $max_bytes / 1024 / 1024 ))
#                echo "Table [${keyspace}.$table] has wide partitions with max $max_bytes bytes ($max_MB MB)"
                printf "%15d bytes max (%5d MB) for large partitions in table [%s.%s]\n" $max_bytes $max_MB $keyspace $table
            fi
            ;;
        'Compacted partition mean bytes' )
            mean_bytes=`echo $line | cut -d: -f2`
            # check if mean partition is wide
            printf "hello"
            if [ $mean_bytes -gt $mean_partition_size_threshold ]
            then
                mean_MB=$(( $mean_bytes / 1024 / 1024 ))
#                echo "Table [${keyspace}.$table] has wide partitions with mean $mean_bytes bytes ($mean_MB MB)"
                printf "%15d bytes mean (%5d MB) for large partitions in table [%s.%s]\n" $mean_bytes $mean_MB $keyspace $table
            fi
            ;;
    esac
done < $cfstats
