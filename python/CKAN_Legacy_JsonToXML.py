import urllib2
import json
import codecs
import sys
import json
import traceback
import getopt
import numbers
import JsonToXML

from optparse import OptionParser
from xml.dom.minidom import Document

# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--URI", action="store", dest="URI", help="uri of all metadata in JSON, e.g. https://www.opengov.nsw.gov.au/publication.json")

(options, args) = parser.parse_args()

# Validate data source uri
if not(options.URI):
    parser.error("Requires URI.  Try --help for usage")
    sys.exit(-1)

if len(options.URI) < 1:
    parser.error("Requires URI.  Try --help for usage")
    sys.exit(-1)
    
if not(options.outputDirectory):
    parser.error("Requires outputDirectory.  Try --help for usage")
    sys.exit(-1)

if len(options.outputDirectory) < 1:
    parser.error("Requires outputDirectory.  Try --help for usage")
    sys.exit(-1)

dataSetUri = options.URI
outputDirectory = options.outputDirectory

outFileName = "JsonOut.xml"
print("Out file: %s" % outFileName)
JsonToXML.writeXmlFromJson(dataSetUri, outFileName)
