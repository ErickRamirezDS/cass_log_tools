#!/usr/bin/python
# This script can be used to parse most
# json files in the diagnostics output.
#
# Its useful if you wanted to compare settings or values
# across several nodes at a time to make it a bit easier
# then looking through multiple json files 

import os
import json
import re
import sys

if len(sys.argv) != 2:
    print "\n***",sys.argv[0], "***\n"
    print 'Incorrect number of arguments, please run script as follows:'
    print '\n'+str(sys.argv[0])+' <file name>'
    sys.exit(0)

# Setup variables etc
path = '.'
file_to_parse = sys.argv[1]

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

    # ** debug **
    # comment in to debug
    #print data

    # loop through the first item only to get only one lot of items
    for item in data.values()[0]:

        # loop through the first level of items (i.e. all nodes)
        for node in data:
 
            # print out the values for each node
            # in some cases the item might be missing
            # in this case just print that and move on
            if item in data[node]:
                print "node: ", node, item, data[node][item]
            else:
                print "node: ", node, item, '<not found>'

        # Add seperator for cleaner output 
        print ''

# Call the function with the given file
findAndParse(file_to_parse)
