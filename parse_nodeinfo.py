#!/usr/bin/python
# parses the node_info.json file
# so the values for each node are
# displayed side by side

import os
import json
import re
import sys

# Setup variables etc
path = '.'
name = 'node_info.json'

# Use os.walk to find all the directories under the path
for dirname, dirnames, filenames in os.walk(path):
    for file in filenames:
        matched = re.match(name, file, re.M)
        if matched:
            # load the file
            print dirname+'/'+file
            data = json.loads(open(dirname+'/'+file).read())
            break

if not matched:
    print '\nUnable to find file named ' + name 
    sys.exit(0)

# loop through the first item only to get only one lot of items
for items in data.values()[0]:

    # loop through the first level of items (i.e. all nodes)
    for node in data:
 
        # print out the values for each node
        print "node: ",data[node]['node_ip'],items,": ",data[node][items]
