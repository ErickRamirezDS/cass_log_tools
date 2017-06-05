#!/bin/bash
#
# Find a date range of sstables under 
# a given directory
#

if [ $# -ne 1 ];then
        echo "fimd date range of sstables"
        echo ""
        echo "Useage: $0 <path>"
        echo ""
        exit 1
fi

path=$1
mysearch="*Data*"

for myfile in $(find $path -maxdepth 1 -name "$mysearch")
do
    mints=$(sstablemetadata $myfile | grep "Minimum timestamp:")
    maxts=$(sstablemetadata $myfile | grep "Maximum timestamp:")
    mintsnorm=$(echo $mints | awk '{print substr($3,0,length($3)-6)}')
    maxtsnorm=$(echo $maxts | awk '{print substr($3,0,length($3)-6)}')
    mindate=$(date -d @$mintsnorm)
    maxdate=$(date -d @$maxtsnorm)
    echo -e "$myfile\t$mindate\t$maxdate"
done

