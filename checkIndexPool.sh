#!/usr/bin/env bash
#
# Simple script to pull back all the Solr
# IndexPool mbean attributes

function useage {
    echo
    echo "Usage: $0 <solr core name>"
    echo
    echo "Example: ./$0 wiki.solr"
    echo
    exit
}

function check {
BEAN="nodetool sjk mx -b \"com.datastax.bdp:index=$CORE,name=IndexPool,type=search\" -mi"

for ATTR in $($BEAN | grep \( | awk '{print $2}')
    do
    VALUE=$(nodetool sjk mx -b "com.datastax.bdp:index=$CORE,name=IndexPool,type=search" -f $ATTR -mg --quiet)
    echo "$ATTR: $VALUE"
done
}

if [ $# -ne 1 ]; then
   echo $#
   useage
   exit
fi

CORE=$1
check

exit
