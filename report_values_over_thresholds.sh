#!/bin/sh
#
# Searches the output of `nodetool cfstats` for values that are over specified thresholds.
# Thresholds are defined in the variables at the top of the file, so they can be easily modified at your liking.
#
# Usage: report_values_over_thresholds.sh <cfstats_output>
#
# At the moment it looks at:
#    - Max and mean partition size
#    - Read and write latencies
#    - Bloom filter false positives (count and ratio)
#    - Average and max tombstones per slice
#    - SSTable compression ratio (truncated to five decimal places)
#
# Author: Alice Lottini (based on report_wide_partitions.sh by Erick Ramirez and with the help of Mark Curtis)

one_hundred_mb=$(( 100 * 1024 * 1024 ))
fifty_mb=$(( 50 * 1024 * 1024 ))

max_partition_size_threshold_mb=$one_hundred_mb
mean_partition_size_threshold_mb=$fifty_mb

read_latency_threshold_ms=15
write_latency_threshold_ms=5

false_positives_threshold=0
false_ratio_threshold=0

avg_tombstones_threshold=10
max_tombstones_threshold=100

compression_ratio_threshold=0.25000

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

    # remove anything in brackets e.g. "(index), (last five minutes), ..."
    attribute=`echo $attribute | sed -e 's/ (.*)//'`

    case "$attribute" in
        'Keyspace' )
            keyspace=`echo $line | cut -d: -f2`
            ;;
        'Table' )
            table=`echo $line | cut -d: -f2`
            ;;
        'Local read latency' )
            high_read_latency=`echo $line | awk -v rlt="$read_latency_threshold_ms" '{ print ($4 > rlt) ? $4 : -1}'`
            if [ $high_read_latency != -1 ]
            then
                printf "Local read latency %0.4f in table [%s.%s]\n" $high_read_latency $keyspace $table
            fi
            ;;
        'Local write latency' )
            high_write_latency=`echo $line | awk -v rlt="$write_latency_threshold_ms" '{ print ($4 > rlt) ? $4 : -1}'`
            if [ $high_write_latency != -1 ]
            then
                printf "Local write latency %0.4f in table [%s.%s]\n" $high_write_latency $keyspace $table
            fi
            ;;
        'Bloom filter false positives' )
            false_positives=`echo $line | cut -d: -f2`
            if [ $false_positives -gt 0 ]
            then
                printf "Bloom filter false positives %5d in table [%s.%s]\n" $false_positives $keyspace $table
            fi
            ;;
        'Bloom filter false ratio' )
            false_ratio=`echo $line | awk -v fr="$false_ratio_threshold" '{ print ($5 > fr) ? $5 : -1}'`
            if [ $false_ratio != -1 ]
            then
                printf "Bloom filter false ratio %0.5f in table [%s.%s]\n" $false_ratio $keyspace $table
            fi
            ;;
        'Compacted partition maximum bytes' )
            max_bytes=`echo $line | cut -d: -f2`
            if [ $max_bytes -gt $max_partition_size_threshold_mb ]
            then
                max_MB=$(( $max_bytes / 1024 / 1024 ))
                printf "%15d bytes max (%5d MB) for large partitions in table [%s.%s]\n" $max_bytes $max_MB $keyspace $table
            fi
            ;;
        'Compacted partition mean bytes' )
            mean_bytes=`echo $line | cut -d: -f2`
            if [ $mean_bytes -gt $mean_partition_size_threshold_mb ]
            then
                mean_MB=$(( $mean_bytes / 1024 / 1024 ))
                printf "%15d bytes mean (%5d MB) for large partitions in table [%s.%s]\n" $mean_bytes $mean_MB $keyspace $table
            fi
            ;;
        'Average tombstones per slice' )
            avg_tombstones=`echo $line | awk -v avgt="$avg_tombstones_threshold" '{ print ($8 > avgt) ? $8 : -1}'`
            if [ $avg_tombstones != -1 ]
            then
                printf "Average tombstones per slice %0.5f in table [%s.%s]\n" $avg_tombstones $keyspace $table
            fi
            ;;
        'Maximum tombstones per slice' )
            max_tombstones=`echo $line | awk -v maxt="$max_tombstones_threshold" '{ print ($8 > maxt) ? $8 : -1}'`
            if [ $max_tombstones != -1 ]
            then
                printf "Maximum tombstones per slice %0.5f in table [%s.%s]\n" $max_tombstones $keyspace $table
            fi
            ;;   
        'SSTable Compression Ratio' )
            compression_ratio=`echo $line | awk -v cr="$compression_ratio_threshold" '{ print ($4 > cr) ? $4 : -1}'`
            if [ $compression_ratio != -1 ]
            then
                printf "SSTable Compression Ratio %0.5f (truncated) in table [%s.%s]\n" $compression_ratio $keyspace $table
            fi
            ;; 
    esac
done < $cfstats
