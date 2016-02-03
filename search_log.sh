#!/bin/bash
#
# Search for pattern in logs and display it
#

#---validate arguments
if [ $# -ne 2 ];then
	echo "Find log files and search for an expression"
	echo ""
	echo "Useage: $0 <log file> <expression>"
	echo ""
	exit 1
fi

system_log=$1
expression=$2

for myf in $(find . -name $system_log)
do
    echo -e "\n>>> $myf <<<\n"
    grep -H $expression $myf
done

