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

def findAndParse(name):
    # Reset variables etc
    found = False
    data = { }
    # Use os.walk to find all the directories under the path
    for dirname, dirnames, filenames in os.walk(path):
        for file in filenames:
            # Check if the file name matches
            matched = re.match(name, file, re.M)
            if matched:
                # Set flag
                found = True
                # load the file
                currentfile = dirname+'/'+file
                # load the data into a dictionary
                data[currentfile] = json.loads(open(currentfile).read())
                # break once complete (theres only one file per diretory)
                break

    # If the file is not found anywhere then exit function
    # So we can continue with the next file
    if not found:
        print '\nUnable to find file named ' + name + '\n'
        return

    # loop through the first item only to get only one lot of items
    for items in data.values()[0]:

        # loop through the first level of items (i.e. all nodes)
        for node in data:
 
            # print out the values for each node
            print "node: ", node, items, data[node][items]

        # Add seperator for cleaner output 
        print ''

# Add your files in here you need to parse
# Comment out the ones you dont want
findAndParse('os-info.json')
findAndParse('cpu.json')
findAndParse('memory.json')
findAndParse('disk.json')
findAndParse('disk_space.json')
#findAndParse('load_avg.json') # parsing this one throws an error so leaving out for now


