#!/usr/bin/python
# This script can be used to parse a cqlsh trace
# to show the node it was executed on and the
# request complete time.
#
# Useful if you have a file with many traces from
# different nodes

import os
import re
import sys

# Argument checks
if len(sys.argv) != 2:
    print "\n***",sys.argv[0], "***\n"
    print 'Incorrect number of arguments, please run script as follows:'
    print '\n'+str(sys.argv[0])+' <file name>'
    sys.exit(0)

# Setup variables etc
path = '.'
file_to_parse = sys.argv[1]
time = ''
node = ''
raw_results = [ ]

# open file
current_file = open (file_to_parse, 'r')

# check for patterns
pattern1 = '.*Execute CQL3 query.*'
pattern2 = '.*Request complete.*'

# parse file
for myline in current_file:
    matched1 = re.match(pattern1, myline, re.M)
    matched2 = re.match(pattern2, myline, re.M)
    words = myline.split('|')    
    if matched1: # usually the beginning of the trace
        node = words[2].strip()
    if matched2: # usually the end of the trace
        time = words[3].strip() 
        raw_results.append([node, time]) # only append when the end of trace is seen


# this is the part that sorts the results, the lambda can take several arguments
# the first tuple item is 0 and so on. So were sorting by item 1 then 2 and so on
results = sorted(raw_results, key=lambda tup: (tup[0], int(tup[1])))

# print out to console, allow the user to rrdirect to a file if they want
for row in results:
    print 'node: ' + row[0] + ', time: ' + row[1]
