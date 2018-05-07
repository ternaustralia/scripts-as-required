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
    dataSetName_list = list()
    if isinstance(value, list):
        print("%d datasets to retrieve" % (len(value)))

        for entry in value:
            print("Dataset: ", entry)
            dataSetName = None
            if isinstance(entry, dict):
                if(entry.has_key(u'data')):
                    data = entry.get(u'data')
                    if isinstance(data, dict):
                        package = data.get('package')
                        if isinstance(package, dict):
                            dataSetName = package.get(u'name')
                            print("Found datasetname: ", dataSetName)
                            dataSetName_list.append(dataSetName)
                elif(entry.has_key(u'dataset_uris')):
                    dataset_uris = entry.get(u'dataset_uris')
                    if isinstance(dataset_uris, list):
                        print('dataset_uris is a list of len %d' % len(dataset_uris))
                        for dataset_uri in dataset_uris:
                            dataSetName = dataset_uri
                            print("Found datasetname: ", dataSetName)
                            dataSetName_list.append(dataSetName)

            else:
                print("Length of entry: %d " % (len(entry)))
                print("Entry: %s" % (entry))
                dataSetName = entry
                print("Found datasetname: ", dataSetName)
                dataSetName_list.append(dataSetName)
    else:
        print("Not list")

    return dataSetName_list

def processDataset(dataSetName):
            print("dataSetName: %s" % (dataSetName))
            try:
                #outFileName = (outputDirectory + '/%s.xml' % string.replace(string.replace(dataSetName, ':', ''), '/', ''))
                dataSetUri = (descriptionByIdentifierURI % dataSetName)
                JsonToXML.writeXmlFromJson(dataSetUri, dataSetName, outputDirectory)
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
      dataSetName_list = processList(value)
      print("Obtained %d dataset names, now in list" % len(dataSetName_list))
      for dataSetName in dataSetName_list:
          processDataset(dataSetName)
else:
    if (isinstance(loadedJson, list)):
        dataSetName_list = processList(loadedJson)
        print("Obtained %d dataset names, now in list" % len(dataSetName_list))
        for dataSetName in dataSetName_list:
            processDataset(dataSetName)
            #exit(0) # for testing only

    else:
        print ("Not a dict or list, so not sure what to do")
        assert(1)






















