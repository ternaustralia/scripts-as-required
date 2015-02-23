# usage: python Concat_RIF-CS_FromDataSource.py --input http://portal.auscope.org/geonetwork/srv/env/oaipmh --namespace

# Process:
# Takes OAI-PMH data source original link e.g. http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh
# Loads as http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh?verb=ListRecords&metadataPrefix=rif
# Writes starting root node registryObjects to output file
# Writes children nodes per registryObject to output file
# Reads resumption token value at end of file 
# Loads next uri as http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh?verb=ListRecords&resumptionToken={resumptionTokenValue}
# Continues, loading all files until no more resumption token
# Writes closing root node registryObjects to output file

# Output:  
# ConcatRIF-CSTree.xml - RIF-CS xml that represents all registry objects loaded at original data source link
# Output will only be as well-formed as the input (no validation or correction is made)
# 
# ConcatRIF-CSTree_nonCollectionsMerged.xml - RIF-CS xml where nonCollections are unique (per key) - relatedObjects have been maintained
#

import sys
import os
from optparse import OptionParser
import StringIO
import urllib2
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse
import operator

def generator(limit=1000000):
    n = 0
    while n < limit:
       n+=1
       yield n
    
def addItemToTree(xmlOut, item):
    assert(xmlOut is not None)
    assert(item is not None)

    itemTag = item.tag.split('}')[1]
    xmlOut.target.start(itemTag, dict(item.items()))
    
    if item.text is not None:
        if len(item.text) > 0:
            xmlOut.target.data(item.text)
            
    for child in item.getchildren():
        addItemToTree(xmlOut, child)
        
    xmlOut.target.end(itemTag)
   
  
def writeRegistryObjectsToXml(registryObjects, xmlOutAll):   
    assert(registryObjects is not None)
    assert(xmlOutAll is not None)
    
    assert(len(registryObjects) > 0)
    print("%d registryObject instances" % len(registryObjects))
        
    for registryObject in registryObjects:
        gen.next() # accumulate count of registryObject instances
        # Add registryObject to xmlOutAll just as they occur
        addItemToTree(xmlOutAll, registryObject)
        
def accessRegistryObjects(uri):
     assert(uri is not None)

    try:
        proxy_handler = urllib2.ProxyHandler({})
        opener = urllib2.build_opener(proxy_handler)
        print("Opening uri: %s" % uri)
        req = urllib2.Request(uri)
        req.add_header('Accept-Language', 'en-gb')
        req.add_header('Accept', 'application/xml')
        #result = opener.open(req)
        result = urllib2.urlopen(req)
	#content = result.read()
	#assert(content != 0)
 	#print(content)
    except Exception as e:
        print("Unable to open uri %s - exception: %s" % (uri, e))
        sys.exit(-1)
    
    assert(result != 0)
    #print(result.read())
	
    try:
      xml = ET.parse(result)
    except Exception as e:
        print("Unable to parse xml at uri %s - exception: %s" % (uri, e))
        sys.exit(-1)
    
    oaipmhRoot = xml.getroot() # get OAI-PMH
    print('Seeking all metadata' % namespace)
    registryObjects = oaipmhRoot.findall('.//metadata' % namespace)
    if(len(registryObjects) < 1):
        errors = oaipmhRoot.findall(".//{http://www.openarchives.org/OAI/2.0/}error")
        for error in errors:
            assert(error is not None)
            print("ERROR (exiting): %s" % error.text)
        print(ET.tostring(oaipmhRoot))
        sys.exit(-1)

    writeRegistryObjectsToXml(registryObjects, xmlOutAll)    
    populateObjectLists(registryObjects, allNonCollectionRegObjs, collections, keyInstances)
    
    resumptionTokenElement = oaipmhRoot.find('.//{http://www.openarchives.org/OAI/2.0/}resumptionToken')
    if(resumptionTokenElement is None):
        return None
        
    return resumptionTokenElement.text
    
def printAll(element):
    assert(element is not None)
    assert(element.tag is not None)
    
    if(len(element) < 1):
        print("%s has no sub elements" % element.tag)
        return
        
    for subElem in element.iter():
        assert(subElem.tag is not None)
        print("Tag [%s]" % (subElem.tag))
        text = ''
        if subElem is not None:
            if subElem.text is not None:
                text = subElem.text.strip()
        print("Text [%s]" % text)
        attrConcat = ''
        for k,v in subElem.items():
            attrConcat += ("\t (Name [%s], Value [%s]), " % (k, v))
            print("Attributes [%s]" % attrConcat)

def openFile(fileName, mode):
    assert(fileName is not None)
    
    print("Opening %s in mode %s" % (fileName, mode))
    try:    
        file  = open(fileName, mode)
    except Exception as e:
        print("Unable to open file %s in mode %s - %s" % (fileName, mode, e))
        sys.exit(-1)
    
    if not file:
        print("Unable to open file %s for %s" % (fileName, mode))
        sys.exit(-1)
            
    return file;

namespace = '{http://ands.org.au/standards/rif-cs/registryObjects}' # default
    
# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--input", action="store", dest="data_source_uri", help="uri of OAI-PMH data source, e.g. http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh")
parser.add_option("--namespace", action="store", dest="namespace", help="namespace for rif-cs - uses http://ands.org.au/standards/rif-cs/registryObjects if not provided")
parser.add_option("--metadataprefix", action="store", dest="metadata_prefix", help="metadata prefix, e.g. 'rif' or 'oai_dc' or 'iso19139.anzlic' or 'iso19139.mcp' ")

(options, args) = parser.parse_args()

# Validate data source uri
if not options.data_source_uri:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)
    
if len(options.data_source_uri) < 1:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)

if not options.metadata_prefix:
    parser.error("Requires metadata prefix.  Try --help for usage")
    sys.exit(-1)

if len(options.metadata_prefix) < 1:
    parser.error("Requires metadata prefix.  Try --help for usage")
    sys.exit(-1)   

if not options.namespace:
    parser.error("Requires namespace.  Try --help for usage")
    sys.exit(-1)

if len(options.namespace) < 1:
    parser.error("Requires namespace.  Try --help for usage")
    sys.exit(-1)    
 

   
metadataPrefix = options.metadata_prefix
dataSourceURI = options.data_source_uri
namespace = options.namespace

# Open outputFiles    
xmlOutFILE = openFile("ConcatMetadataTree.xml", "w")

xmlOutAll = ET.XMLParser()
xmlOutWithNonCollectionsMerged = ET.XMLParser()    
registryObjectsDictionary = {'xmlns': namespace, \
                                 'xsi:schemaLocation': 'http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd', 
                                 'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 
                                 'xmlns:rif': 'http://ands.org.au/standards/rif-cs/registryObjects'}

startId = xmlOutAll.target.start('registryObjects', registryObjectsDictionary)
startId = xmlOutWithNonCollectionsMerged.target.start('registryObjects', registryObjectsDictionary)                                            

gen = generator()    

# collect instances of registryObjects of same key
keyInstances = dict()
allNonCollectionRegObjs = list()
collections = list()

# Call function accessRegistryObjects(dataSourceURI+"verb=ListRecords&metadataPrefix="+metadataPrefix) for first page load
# When it encounters resumptionToken tag, it will store the value in resumptionToken
resumptionToken = accessRegistryObjects(keyInstances, gen, dataSourceURI+"?verb=ListRecords&metadataPrefix="+metadataPrefix)
   
while resumptionToken is not None:
   assert(len(resumptionToken) > 1)
   resumptionToken = accessRegistryObjects(dataSourceURI+"?verb=ListRecords&resumptionToken="+resumptionToken)
  
numRegistryObjectInstances = gen.next() - 1
print("%d registryObject instances found" % numRegistryObjectInstances)

  
# write end root node for registryObjects 
xmlOutAll.target.end('registryObjects')
rootOut = xmlOutAll.target.close() # returns root element
xmlOutFILE.write(ET.tostring(rootOut))
xmlOutFILE.close()



print("\n\nAll registryObjects written to ConcatRIF-CSTree.xml")
print("\nThose registryObjects with unique nonCollection instances (all related objects merged into one nonCollection) written to ConcatRIF-CSTree_nonCollectionsMerged.xml")
print("\nTotal instances of each key is in KeyInstances.txt")




