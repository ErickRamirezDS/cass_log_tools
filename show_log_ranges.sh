#!/bin/sh
#
# Lists start and end of each log file
#
# Author Mark Curtis, 2015 Jul 08
#

# Enter your date string here
searchStr="2015-"

function checkForFiles {
    # validate we can find at least 1 file
    files=$(find . -name "$1" -type f)

    # check if no files found
    if [ -z "$files" ]
    then
        echo "Couldn't find any files named $1 from here. Exiting"
        exit 1
    fi

    # get the first directory
    for file in $files
    do
        node0=$file
        break
    done
}

# Check for the files first
checkForFiles system.log

# validate we can find at least 1 file
if [ -r $node0 ]
then
    # at least 1 file is readable
    echo "===== `basename $0` ====="
else
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

# iterate through all logs
for logfile in $files
do
    grep -H $searchStr $logfile | head -1 | awk '{print $1,"Start",$4, $5}'
    grep -H $searchStr $logfile | tail -1 | awk '{print $1, "End",$4, $5}'
    echo ""
done
