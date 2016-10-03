#!/bin/bash
# A shell script to check if all their repair sessions are complete.
# The following arguments are optional, the default is cwd and system.log* 
# The first argument is the path to the files
# The second argument is the file pattern

# Setup defaults
SYSTEM_LOG_PATH=/var/log/cassandra/
LOG_FILE_PATTERN="system.log*"

# Check arguments
if [ $# -eq 1 ];then
 if [ "$1" = "-h" ] || [ "$1" = "-?" ] ; then
 echo "Usage: $0 [optional-path] [optional log pattern]" 
 echo 'By default the path is . and the pattern is system.log*'
 exit
 fi
SYSTEM_LOG_PATH=$1
fi

# Setup log files and path if given
if [ $# -eq 2 ];then
SYSTEM_LOG_PATH=$1
LOG_FILE_PATTERN=$2
fi

# cd to given directory, error if not exists
cd $SYSTEM_LOG_PATH 2>/dev/null 
if [ $? -ne 0 ] ;  then
 echo ""
 echo "Could not change to directory $SYSTEM_LOG_PATH"
 exit 1
fi

# Load files into list for checking
for FILE in `ls -C1 $LOG_FILE_PATTERN | egrep -v 'system.log(\.[0-9]{2}\.zip)' 2>/dev/null`
do
 FILES="$FILES $FILE"
done

if [ "x$FILES" = "x" ] ; then
 echo ""
 echo "No files matching pattern $LOG_FILE_PATTERN found"
 exit 1
fi

# Temp files for putting new and completed sessions (uses pid as suffix)
NEW_SES="/tmp/new-session.$$"
COMP_SUC="/tmp/completed-successfully.$$" 

# Grep patterns for initiation and completion
for FILE in $FILES
do
  echo "parsing $FILE..."
  zgrep -e '\[repair .* new session' $FILE | cut -d\# -f2 | cut -d] -f1 >> ${NEW_SES}.tmp
  zgrep -e '\[repair .* session completed successfully' $FILE | cut -d\# -f2 | cut -d] -f1 >> ${COMP_SUC}.tmp
done

cat ${NEW_SES}.tmp | sort | uniq > ${NEW_SES}
cat ${COMP_SUC}.tmp | sort | uniq > ${COMP_SUC}

echo "Finished parsing all log files"

# Incomplete - sessions started but no seen with completion message
INCOMPLETE_SESSIONS=$(diff $COMP_SUC  $NEW_SES | grep "^> " | cut -f2 -d" ")

# Complete - sessions seen with completion message
COMPLETE_SESSIONS=$(diff $NEW_SES $COMP_SUC | grep "^> " | cut -f2 -d" ")

COMPLETED=`cat $COMP_SUC| wc -l`
INITIATED=`cat $NEW_SES| wc -l`

# Comment this line out if you want to retain the temp files
rm $COMP_SUC $NEW_SES ${COMP_SUC}.tmp ${NEW_SES}.tmp

# cd back to previous directory and print out results
cd - >/dev/null
if [ -z "$INCOMPLETE_SESSIONS" ]; then
    echo All sessions complete, total: $COMPLETED
    echo ""
    exit 0
else
    echo Initiated: $INITIATED Completed: $COMPLETED
    echo ""
    echo The following sessions were initiated in these logs but not complete:
    echo $INCOMPLETE_SESSIONS
    echo ""
    echo The following sessions were completed but not initated in these logs:
    echo $COMPLETE_SESSIONS
    echo ""
    exit 255
fi
