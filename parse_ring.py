#!/usr/bin/python
# parses the nodetool ring file

import os
import sys
import re

# Check arguments
# (note 2 includes arg 0 which is this script!)
if len(sys.argv) != 2:
    print "\n***",sys.argv[0], "***\n"
    print 'Incorrect number of arguments, please run script as follows:'
    print '\n\n'+str(sys.argv[0])+' <nodetool ring output file>'
    sys.exit(0)

# Setup variables etc
ring=open (sys.argv[1], 'r')
ips = {}
tokens = {}
totals = {}
glb = globals()
token_list = []
pattern = "(^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"

# create the lists first
#
# we create a dictionary of tokens as keys with the associated ip
# as the dictionary key must be unique
#
for line in ring:
    matched = re.match(pattern, line, re.M)
    if matched:
        words = line.split() # split the line into words
        ipaddr = words[0] # select 1st item (node ip)
        token = words[len(words) - 1] # select last item (token)
        ips[ipaddr]="node" # create dictionary of IPs
        tokens[token] = ipaddr # create a dictionary of tokens with associated ips

# create a sorted list based on the keys
# which in this case are the tokens
token_list = [int(tkn) for tkn in tokens]
token_list.sort()

# loop though all ips and then list each token
#
# we use the dictionary of ips to make our main loop
# then nest the loop for all tokens so we only pull out
# the tokens for the node we're checking
#
# probably not the most efficent way to do this
# but it seemed like a good idea at the time!
#
for ip in ips:
    new_ip = True #set flag if were starting a new ip (as we dont want to calc the diff on the first token)
    diff_total = 0 # reset the total for each node
    for token in token_list: # use the sorted token list
        node_ip = tokens[str(token)] # the token list is int types so we have to stringify it
        if (node_ip == ip): # only select the current ip being checked
            if (new_ip == False): # if its not the first token in the list calc the diff
                token_diff = ((int(token) - int(last_token))) # the current token - last token is the diff
                print node_ip,'\t',token,'\t',token_diff
                last_token = token # update the last token to current one ready for next loop
                diff_total = (diff_total + token_diff) # update running total for each node
            else: # executed first for each node
                print 'ip','\t','token','\t','diff' 
                print node_ip,'\t',token
                last_token = token # update the last token to current one ready for next loop
                new_ip = False # reset flag
    print node_ip,'\t','total','\t',diff_total
    totals[ip] = diff_total

# print out a summary at the end
print "\ntotals summary\n"
print "ip\t\tdiff\n"
for ip, total in totals.iteritems():
    print ip,'\t', total
