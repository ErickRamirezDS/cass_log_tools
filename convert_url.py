# Convert URL for Solr testing
# make sure to surround the URL with single quotes

import sys
import urllib2

# Check arguments
# (note 2 includes arg 0 which is this script!)
if len(sys.argv) != 2:
    print "\n***",sys.argv[0], "***\n"
    print 'Incorrect number of arguments, please run script as follows:'
    print '\n\n'+str(sys.argv[0])+' <url to convert>'
    sys.exit(0)

print "Converted URL:"
print ""
print urllib2.unquote(sys.argv[1])
print ""
