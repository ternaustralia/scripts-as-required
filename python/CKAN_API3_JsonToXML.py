import urllib2
import json
import codecs
import sys
import json
import traceback
import getopt
import numbers
import JsonToXML
import exceptions
import string
import os
import shutil

from optparse import OptionParser
from xml.dom.minidom import Document


def processList(value):
    if isinstance(value, list):
        print("%d datasets to retrieve" % (len(value)))
        for dataSetName in value:
            try:
                outFileName = (outputDirectory + '/%s.xml' % string.replace(dataSetName, '/', ''))
                dataSetUri = (descriptionByIdentifierURI % dataSetName)
                JsonToXML.writeXmlFromJson(dataSetUri, outFileName)
            except exceptions.KeyboardInterrupt:
                print "Interrupted - ", sys.exc_info()[0]
                sys.exit(0)
            except:
                traceback.print_exc(file=sys.stdout)
                print "Exception - ", sys.exc_info()[0]

# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--identifierListURI", action="store", dest="identifierListURI", help="uri of all identifiers in JSON, e.g. http://data.gov.au/api/3/action/package_list")
parser.add_option("--descriptionByIdentifierURI", action="store", dest="descriptionByIdentifierURI", help="uri of description per identifier, in JSON, e.g. http://data.gov.au/api/3/action/package_show?id=%s")
parser.add_option("--outputDirectory", action="store", dest="outputDirectory", help="output directory for JSON files to be written to")

(options, args) = parser.parse_args()

# Validate data source uri
if not(options.identifierListURI):
    parser.error("Requires identifierListURI.  Try --help for usage")
    sys.exit(-1)

if len(options.identifierListURI) < 1:
    parser.error("Requires identifierListURI.  Try --help for usage")
    sys.exit(-1)
    
if not(options.descriptionByIdentifierURI):
    parser.error("Requires descriptionByIdentifierURI.  Try --help for usage")
    sys.exit(-1)

if len(options.descriptionByIdentifierURI) < 1:
    parser.error("Requires descriptionByIdentifierURI.  Try --help for usage")
    sys.exit(-1)

if not(options.outputDirectory):
    parser.error("Requires outputDirectory.  Try --help for usage")
    sys.exit(-1)

if len(options.outputDirectory) < 1:
    parser.error("Requires outputDirectory.  Try --help for usage")
    sys.exit(-1)

identifierListURI = options.identifierListURI
descriptionByIdentifierURI = options.descriptionByIdentifierURI
outputDirectory = options.outputDirectory


if os.path.exists(outputDirectory):
    shutil.rmtree(outputDirectory)
print("Constructing directory " + outputDirectory)
os.makedirs(outputDirectory)

print ("Reading datasets names from "+identifierListURI)
openedFile = urllib2.urlopen(identifierListURI, timeout=5)
loadedJson = json.loads(openedFile.read())

if loadedJson is None:
    exit

if(isinstance(loadedJson, dict)):
    for key in loadedJson.keys():
      value = loadedJson[key]
      processList(value)
else:
    if (isinstance(loadedJson, list)):
        processList(loadedJson)
    else:
        print ("Not a dict or list, so not sure what to do")
        assert(1)






















