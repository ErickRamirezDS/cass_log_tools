#!/usr/bin/python
# parses the nodetool info file

import os
import sys
import re

# Setup variables etc
name='info'
files = [ ]
directories = [ ]
path = '.'
raw_results = [ ]
results= [ ]
uptime =''
attribute=''
value=''

# function to calc dd:hh:mm:ss from seconds
def time_f(t_secs):
    try:
        val = int(t_secs)
    except ValueError:
        return "!!!ERROR: ARGUMENT NOT AN INTEGER!!!"
    pos = abs( int(t_secs) )
    day = pos / (3600*24)
    rem = pos % (3600*24)
    hour = rem / 3600
    rem = rem % 3600
    mins = rem / 60
    secs = rem % 60
    res = '%03d:%02d:%02d:%02d' % (day, hour, mins, secs)
    if int(t_secs) < 0:
                res = "-%s" % res
    return res

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
            values = line.strip().split(': ')
            if 'Uptime' in values[0]: # if its uptime, we change the format
                attribute='Uptime (ddd:hh:mm:ss)'
                value=time_f(values[1])
            else : # otherwise its a normal attribute line
                attribute=values[0]
                if len(values)==2:
                    value=values[1]
                else:
                    value='n/a'
            # put all results into the list as tuples
            raw_results.append([node,attribute,value])

# this is the part that sorts the results, the lambda can take several arguments
# the first tuple item is 0 and so on. So were sorting by item 1 then 2 and so on
results = sorted(raw_results, key=lambda tup: (tup[1], tup[2]))

# print out to console, allow the user to redirect to a file if they want
for row in results:
    print row
