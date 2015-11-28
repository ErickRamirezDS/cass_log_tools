#!/usr/bin/python
# parses the node_info.json file
# so the values for each node are
# displayed side by side

import os
import json

# load the file
data = json.loads(open("./disk.json").read())

# loop through the first item only to get only one lot of items
for items in data:
 
    # print out the values for each node
    print items,": ",data[items]
