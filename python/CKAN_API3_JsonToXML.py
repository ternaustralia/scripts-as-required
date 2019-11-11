import urllib
import json
import codecs
import sys
import json
import traceback
import getopt
import numbers
import JsonToXML
import string
import os
import shutil
import array

from optparse import OptionParser
from xml.dom.minidom import Document


def processList(value):
    dataSetName_list = list()
    if isinstance(value, list):
        print("%d dataset names in json list" % (len(value)))

        for entry in value:
            print("Dataset: ", entry)
            dataSetName = None
            if isinstance(entry, dict):
                if('data' in entry):
                    data = entry.get(u'data')
                    if isinstance(data, dict):
                        package = data.get('package')
                        if isinstance(package, dict):
                            dataSetName = package.get(u'name')
                            print("Found datasetname: ", dataSetName)
                            dataSetName_list.append(dataSetName)
                elif('dataset_uris' in entry):
                    dataset_uris = entry.get(u'dataset_uris')
                    if isinstance(dataset_uris, list):
                        print('dataset_uris is a list of len %d' % len(dataset_uris))
                        for dataset_uri in dataset_uris:
                            dataSetName = dataset_uri
                            print("Found datasetname: ", dataSetName)
                            dataSetName_list.append(dataSetName)
                elif ('id' in entry):
                    print(type(entry.get(u'id')).__name__)
                    dataSetName = entry.get(u'id')
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
        print(type(value).__name__)

    return list(dataSetName_list)

def processDataset(dataSetName, fullDirectoryPath):
            print("dataSetName: %s" % (dataSetName))
            try:
                #outFileName = (outputDirectory + '/%s.xml' % string.replace(string.replace(dataSetName, ':', ''), '/', ''))
                dataSetUri = (descriptionByIdentifierURI % dataSetName)
                JsonToXML.writeXmlFromJson(dataSetUri, dataSetName, fullDirectoryPath)
            except KeyboardInterrupt:
                print("Interrupted - ", sys.exc_info()[0])
                sys.exit(0)
            except:
                #traceback.print_exc(file=sys.stdout)
                print("Exception - ", sys.exc_info()[0])

# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--identifierListURI", action="store", dest="identifierListURI", help="uri of all identifiers in JSON, e.g. http://data.gov.au/api/3/action/package_list")
parser.add_option("--descriptionByIdentifierURI", action="store", dest="descriptionByIdentifierURI", help="uri of description per identifier, in JSON, e.g. http://data.gov.au/api/3/action/package_show?id=%s")
parser.add_option("--outputDirectory", action="store", dest="outputDirectory", help="output directory for JSON files to be written to")
parser.add_option("--customPaginateIdentifierList", action="store", dest="customPaginateIdentifierList", help="custom pagination token for getting identifier list")

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
customPaginateIdentifierList = options.customPaginateIdentifierList

if os.path.exists(outputDirectory):
    shutil.rmtree(outputDirectory)
print("Constructing directory " + outputDirectory)
os.makedirs(outputDirectory)

fullDirectoryPath = outputDirectory + '/' + 'Records'
if os.path.exists(fullDirectoryPath):
    shutil.rmtree(fullDirectoryPath)
os.makedirs(fullDirectoryPath)

print("OutputDirectory directory requested: " + outputDirectory)
print("Created full directory path %s? %s " % (fullDirectoryPath, os.path.exists(fullDirectoryPath)))

getMore = bool(1)
paginationValue = 0

if (customPaginateIdentifierList != None):
    print('Using customPaginateIdentifierList ', customPaginateIdentifierList)


while(getMore and (paginationValue > -1)):

    if (customPaginateIdentifierList != None):
        urlPaginate = identifierListURI+'?'+customPaginateIdentifierList+'='+str(paginationValue)
        print ("Reading datasets names from "+urlPaginate)
        openedFile = urllib.request.urlopen(urlPaginate, timeout=5)
    else:
        print ("Reading datasets names from " + identifierListURI)
        openedFile = urllib.request.urlopen(identifierListURI, timeout=5)

    loadedJson = json.loads(openedFile.read())

    if loadedJson is None:
        print('loadedJson is None')
        exit

    getMore = bool(0)

    if(isinstance(loadedJson, dict)):
        if('hasMore' in loadedJson):
            print(type(loadedJson.get(u'hasMore')).__name__)
            hasMorejSON = loadedJson.get(u'hasMore')
            print("Found hasMore: ", hasMorejSON)
            if(hasMorejSON == True):
                getMore = bool(1)
                print("Found hasMore set to 1")

        if (customPaginateIdentifierList != None):
            print("customPaginateIdentifierList provided:")
            print(customPaginateIdentifierList)
            resultList = [val for key, val in loadedJson.items() if customPaginateIdentifierList.lower() in key.lower()]
            print(str(resultList))
            print(len(resultList))

            if (len(resultList) > 0):
                print(customPaginateIdentifierList+' found')
                print(type(loadedJson.get(customPaginateIdentifierList)).__name__)
                customPaginateIdentifierListJSON = loadedJson.get(customPaginateIdentifierList)
                print("Found customPaginateIdentifierList", customPaginateIdentifierListJSON)
                #paginationValue = paginationValue + 100
                paginationValue = int(resultList[0])
                print("Setting pagination value", paginationValue)
            else:
                # If pagination requested, but value not found
                print(customPaginateIdentifierList + ' not found')
                paginationValue = -1

        print(loadedJson)
        for key in loadedJson.keys():
            value = loadedJson[key]
            print(value)
            dataSetName_list = processList(value)
            for dataSetName in dataSetName_list:
                processDataset(dataSetName, fullDirectoryPath)
    elif (isinstance(loadedJson, list)):
        dataSetName_list = processList(loadedJson)
        for dataSetName in dataSetName_list:
            processDataset(dataSetName, fullDirectoryPath)
            #exit(0) # for testing only

    else:
        print ("Not a dict or list, so not sure what to do")
        assert(1)























