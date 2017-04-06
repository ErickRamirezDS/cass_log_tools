#!/bin/sh
#
# Reports on node OS-type information collected by OpsCenter.
#
# Author Erick Ramirez, 2015 Jul 14
#



# validate script is run in nodes/ directory
this_pwd=`pwd`
this_dir=`basename "$this_pwd"`
#echo "DEBUG >>>>> this_dir [$this_dir]"
if [ ! "$this_dir" = "nodes" ]
then
    echo "USAGE - Please run script in the nodes directory of a Diagnostics Report"
    exit 1
fi

# iterate through the files
for file in machine-info.json os-metrics/load_avg.json os-info.json
do
    echo "===== $file ====="
    for node in *
    do
        echo "$node \t- `sed ':a;N;$!ba;s/\n/ /g' $node/$file 2> /dev/null`"
    done
    echo ""
done

# report NTP stats
echo "===== ntp/ntpstat ====="
for node in *; do echo "$node - `grep correct $node/ntp/ntpstat 2> /dev/null`"; done
echo ""

# report disk space on 1 node
for node in *
do
    if [ -r $node/os-metrics/disk_space.json ]
    then
        echo "===== $node/os-metrics/disk_space.json ====="
        cat $node/os-metrics/disk_space.json
        break
    fi
done
echo ""
echo ""

echo "NOTE - For the output to be readable, run the rename_node_dirs.sh script."
