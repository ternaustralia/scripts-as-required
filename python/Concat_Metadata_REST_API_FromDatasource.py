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
from xml.dom.minidom import parse, Document, Node

from optparse import OptionParser
from xml.dom.minidom import Document


def retrieveXML(count, filePath, uri):
    assert (uri is not None)

    #print (count)
    try:
        proxy_handler = urllib2.ProxyHandler({})
        opener = urllib2.build_opener(proxy_handler)
        print("Opening uri: %s" % uri)
        req = urllib2.Request(uri)
        req.add_header('Accept-Language', 'en-gb')
        req.add_header('Accept', 'application/xml')
        result = urllib2.urlopen(req)
    except Exception as e:
        print("Unable to open uri %s - exception: %s" % (uri, e))
        sys.exit(-1)

    assert (result != 0)

    try:
        doc = parse(result)
        print(doc.__class__.__name__)
        print(doc.toxml(encoding='utf-8'))
    except Exception as e:
        print("Error: Unable to parse xml at uri %s - exception: %s" % (uri, e))
        return None

    assert (doc is not None)
    errors = doc.getElementsByTagName("error")
    for error in errors:
        assert (error is not None)
        print("Error: %s" % error.nodeValue)

    try:
        filePath = filePath + ('_%d.xml' % count)
        outFile = codecs.open(filePath, 'w')
        #print(outFile.__class__.__name__)
        print('Constructed file: ' + filePath)
    except Exception as e:
        print("Unable to open file %s - exception: %s" % (filePath, e))
        sys.exit(-1)

    outFile.write(doc.toprettyxml(indent="  ",encoding='utf-8'))
    outFile.close()


# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--identifierListURI", action="store", dest="identifierListURI", help="uri of all identifiers in JSON, e.g. http://source.edu.au/api/3/action/package_list")
parser.add_option("--descriptionByIdentifierURI", action="store", dest="descriptionByIdentifierURI", help="uri of description per identifier, in JSON, e.g. http://source.edu.au/api/3/action/package_show?id=%s")
parser.add_option("--outputDirectory", action="store", dest="outputDirectory", help="output directory for JSON files to be written to")
parser.add_option("--identifier_prefix", action="store", dest="identifier_prefix", help="oai identifier prefix (will be appended with incremented count)")
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
identifierPrefix = options.identifier_prefix if options.identifier_prefix != None else 'API'

if os.path.exists(outputDirectory):
    print("Removing existing directory " + outputDirectory)
    shutil.rmtree(outputDirectory)

print("Constructing directory " + outputDirectory)
os.makedirs(outputDirectory)

print ("Reading datasets names from "+identifierListURI)
openedFile = urllib2.urlopen(identifierListURI, timeout=5)
loadedJson = json.loads(openedFile.read())

if loadedJson is None:
    exit

assert(isinstance(loadedJson, list))

filePath = outputDirectory + '/' + identifierPrefix
count = 0

for dataSetName in loadedJson:
    count = count + 1
    try:
        outFileName = (outputDirectory + '/%s.xml' % string.replace(dataSetName, '/', ''))
        metadataUri = (descriptionByIdentifierURI % dataSetName)
        retrieveXML(count, filePath, metadataUri)
    except exceptions.KeyboardInterrupt:
        print "Interrupted - ", sys.exc_info()[0]
        sys.exit(0)
    except:
        traceback.print_exc(file=sys.stdout)
        print "Exception - ", sys.exc_info()[0]






















