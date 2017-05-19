#!/bin/bash
#
# Lists start and end of each log file
#
# Author Mark Curtis, 2015 Jul 08
#
# Changes:
# Ian Ilsley : 2017 May 18 :  changed searchStr to not hard code year
#                          :  added option to pass filename to search for
#                          :  removed redudant code


# searchStr is the date-time in the format YYYY-MM-DD HH:MM:SS,SSS
searchStr="[0-9][0-9][0-9][0-9]-[0-9]*-[0-9]*.[0-9]*:[0-9]*:[0-9]*,[0-9]*"

function checkForFiles {
        
    # validate we can find at least 1 file
    files=$(find . -name "$1" -type f)

    # check if no files found
    if [ -z "$files" ]
    then
        echo "Couldn't find any files named $1 from here. Exiting"
        exit 1
    fi

}

#if no argument then default to system.log
if [ -z $1 ]
then
FILE="system.log"
else
FILE=$1
fi

# Check for the files first
checkForFiles "*$FILE*"

echo "===== `basename $0` for $FILE ====="

# iterate through all logs
for logfile in $files
do
    grep -Ho $searchStr $logfile | head -1 | awk '{print "START: "$0}'
    grep -Ho $searchStr $logfile | tail -1 | awk '{print "END  : "$0}'
    echo ""
done
