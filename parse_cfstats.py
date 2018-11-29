#!/usr/bin/python
# parses the cfstats file

import os
import sys
import re

# Setup variables etc
name='.*cfstats'
files = [ ]
directories = [ ]
path = '.'
raw_results = [ ]
results= [ ]
keyspace=''
table=''
attribute=''
value=''

# Need to add a check that we're in the nodes directory
# of the diagnostics report

# Use os.walk to find all the directories under the path
for dirname, dirnames, filenames in os.walk(path):
    for file in filenames:
        matched = re.match(name, file, re.M)
        if matched:
            # put file names into list
            files.append (matched.group(0))
            # put dirctory paths into list
            directories.append (dirname+"/"+file)

# Parse one file at a time and then put the results
# into a list
for dir in directories:
    node_dir = dir.split('/')
    node = node_dir[1] # node ip from the path
    current_file = open (dir, 'r')
    for line in current_file:
        if ": " in line: # check for the lines with attr: values
            values = line.strip().split(':')
            if values[0][:8]=='Keyspace': # if its a keyspace line, get the name of the new keyspace
                keyspace=values[1]
                table=''
                attribute=''
                value=''
            elif values[0][:13]=='Column Family': # if its a table line, get the name of the new table
                table=values[1]
                attribute=''
                value=''
            elif values[0][:5]=='Table': # if its a table line, get the name of the new table
                table=values[1]
                attribute=''
                value=''
            else : # otherwise its a normal attribute line
                attribute=values[0]
                if len(values)==2:
                    value=values[1]
                else:
                    value='n/a'
            # put all results into the list as tuples
            raw_results.append([node,keyspace,table,attribute,value])
    
# this is the part that sorts the results, the lambda can take several arguments
# the first tuple item is 0 and so on. So were sorting by item 1 then 2 and so on
results = sorted(raw_results, key=lambda tup: (tup[1], tup[2], tup[3]))

# print out to console, allow the user to redirect to a file if they want
for row in results:
    print row
