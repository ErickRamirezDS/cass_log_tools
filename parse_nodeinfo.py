# parses the node_info.json file
# so the values for each node are
# displayed side by side

import os
import json

# load the file
data = json.loads(open("./node_info.json").read())

# loop through the first item only to get only one lot of items
for items in data.values()[0]:

    # loop through the first level of items (i.e. all nodes)
    for node in data:
 
        # print out the values for each node
        print "node: ",data[node]['node_ip'],items,": ",data[node][items]
