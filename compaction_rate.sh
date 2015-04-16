#!/bin/sh
#
# A crude script which extracts the compaction rate from a Cassandra system.log.
#
# Author Erick Ramirez, 2015 Mar 31
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

# data size must be at least 10MB
# smaller sizes are skewed
min_size=30000000

grep "Compacted" $system_log | grep Compacted | while read line
do
    # extract the data size
    data_size=`echo $line | awk '{print $13}' | sed -e 's/,//g'`

    if [ $data_size -gt $min_size ]
    then
        # data size meets min threshold
        # extract throughput
        rate=`echo $line | awk '{print $23}'`

        # extract sstables count
        sstables_count=`echo $line | awk '{print $9}'`

        # calculate size in MB
        data_size_MB=$(( $data_size / 1024 / 1024 ))

        # print results
        printf "  Throughput: $rate | Data size: $data_size ($data_size_MB MB) | SSTables count: $sstables_count\n"
    fi
done
