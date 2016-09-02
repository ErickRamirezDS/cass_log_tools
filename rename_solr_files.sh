#!/bin/bash
#
# Copy the solr config and schema files
# appending the core names to them

#---confirm we are in the "nodes" directory
pwd=`pwd`
dir_name=`basename $pwd`
if [ "$dir_name" != "nodes" ]
then
    echo "ERROR - Script must be run in the [nodes] directory of the diagnostics report"
    exit 1
fi

for myf in $(find . -name "solrconfig.xml")
do
    new_name=`echo $myf | awk -F"/" '{print $(NF-4)"/"$(NF-1)"-"$NF}'`
    printf "Copying [$myf] to [$new_name]... "
    cp $myf $new_name && printf "OK\n" || printf "Failed\n"
done

for myf in $(find . -name "schema.xml")
do
    new_name=`echo $myf | awk -F"/" '{print $(NF-4)"/"$(NF-1)"-"$NF}'`
    printf "Copying [$myf] to [$new_name]... "
    cp $myf $new_name && printf "OK\n" || printf "Failed\n"
done
