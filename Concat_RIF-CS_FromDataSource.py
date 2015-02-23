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
        
def populateObjectLists(registryObjects, nonCollections, collections, keyInstances):   
    assert(registryObjects is not None)
    assert(nonCollections is not None)
    assert(collections is not None)
    assert(keyInstances is not None)
    
    assert(len(registryObjects) > 0)
    for registryObject in registryObjects:
        key = getKey(registryObject, namespace)
        # Collect nonCollections and collections separately so that we can merge nonCollection
        # details in xmlOutWithNonCollectionsMerged a bit further down
        if(isObjectType(registryObject, "collection", namespace) == 1):
            collections.append(registryObject)
        else:
            nonCollections.append(registryObject)
            
        # Accumulate instance count of current key
        keyInstances[key] = keyInstances.get(key, 0) + 1
        
def accessRegistryObjects(keyInstances, gen, uri):
    assert(keyInstances is not None)
    assert(gen is not None)
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
    print('Seeking all %sregistryObject' % namespace)
    registryObjects = oaipmhRoot.findall('.//%sregistryObject' % namespace)
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
    
def mergeNonCollections(allNonCollectionRegObjs):
    assert(allNonCollectionRegObjs is not None)
    
    assert(len(allNonCollectionRegObjs) > 0)
    mergedNonCollections = dict()
    
    for nonCollectionRegObj in allNonCollectionRegObjs:
        nonCollectionKey = getKey(nonCollectionRegObj, namespace)
        # Create list of nonCollections with unique keys (grab all relatedObject nodes and append to the one nonCollection object)
        if nonCollectionKey in mergedNonCollections:
            destNonCollectionRegObj = mergedNonCollections[nonCollectionKey]
            mergeNonCollection(destNonCollectionRegObj, nonCollectionRegObj)
        else:
            mergedNonCollections[nonCollectionKey] = nonCollectionRegObj
            
    return mergedNonCollections
    
def getKeys(subObject, namespace):
    assert(subObject is not None)
    assert(namespace is not None)
    
    validateObjectType(subObject.tag, namespace)
    keys = list()
    relatedObjects = subObject.findall("%srelatedObject" % namespace)
    for relatedObj in relatedObjects:
        keys.append(getKey(relatedObj, namespace))
   
    assert(len(keys) == len(relatedObjects))
    return keys   

def getType(relObj, namespace):
    assert(relObj.tag == ("%srelatedObject" % namespace))
    relObjRelationElem = relObj.find('%srelation' % namespace)
    assert(relObjRelationElem is not None)
    
    # Find type attribute
    assert(len(relObjRelationElem.items()) > 0)
    relTypeValue = relObjRelationElem.get('type')
    assert(relTypeValue is not None)
    assert(len(relTypeValue) > 0)    
    return relTypeValue
    
def getKey(obj, namespace):
    assert(obj is not None)
    assert(namespace is not None)
    
    key = obj.find("%skey" % namespace)
    assert(key is not None)
    assert(key.text is not None)
    return key.text
    
   
def mergeNonCollection(destNonCollectionRegObj, sourceNonCollectionRegObj):
    assert(destNonCollectionRegObj is not None)
    assert(sourceNonCollectionRegObj is not None)

    assert(getKey(destNonCollectionRegObj, namespace) == getKey(sourceNonCollectionRegObj, namespace))

    assert(destNonCollectionRegObj.tag == ('%sregistryObject' % namespace))
    assert(sourceNonCollectionRegObj.tag == ('%sregistryObject' % namespace))
    
    sourcenonCollectionRelObjs = getRelatedObjects(sourceNonCollectionRegObj, namespace) 
    if (len(sourcenonCollectionRelObjs) <1):
        return
        
    objectType = getObjectType(destNonCollectionRegObj, namespace)
    destNonCollection = destNonCollectionRegObj.find("%s" % objectType)
    assert(destNonCollection is not None)
    #print("Before merge...")
    #printAll(destNonCollection)
    totalAppended = 0
    for sourceRelObj in sourcenonCollectionRelObjs:
        # If related object with this key is not already on the object.. merge
        sourceRelObjKey = getKey(sourceRelObj, namespace)
        sourceRelObjType = getType(sourceRelObj, namespace)
        if (containsRelatedObject(destNonCollection, sourceRelObjKey, sourceRelObjType) == 0):
            print("Appending related object of key [%s], type [%s] to %s with key %s" % \
                (sourceRelObjKey, sourceRelObjType, objectType.split('}')[1], getKey(destNonCollectionRegObj, namespace)))
            destNonCollection.append(sourceRelObj)
            totalAppended += 1
        
    if(totalAppended > 0):       
        print("After merge...")
        printAll(destNonCollection)

def containsRelatedObject(subObject, key, relationType):
    assert(subObject is not None)
    assert(namespace is not None)
    
    validateObjectType(subObject.tag, namespace)
    relatedObjects = subObject.findall("%srelatedObject" % namespace)
    if(len(relatedObjects) <= 0):
        return 0
        
    for relatedObj in relatedObjects:    
        if (getKey(relatedObj, namespace) == key):
            if (getType(relatedObj, namespace) == relationType):
                return 1
                
    return 0
    
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

def isObjectType(ro, objectType, namespace):
    assert(ro is not None)
    assert(objectType is not None)
    assert(namespace is not None)
    
    element = ro.find('.//%s%s' % (namespace, objectType))
    if element is None:
        return 0
        
    return 1
            
def getObjectType(regObj, namespace):
    assert(regObj is not None)
    assert(namespace is not None)
    
    if isObjectType(regObj, "party", namespace):
        return ("%sparty" % namespace)
    
    if isObjectType(regObj, "collection", namespace):
        return ("%scollection" % namespace)
        
    if isObjectType(regObj, "activity", namespace):
        return ("%sactivity" % namespace)
    
    if isObjectType(regObj, "service", namespace):
        return ("%sservice" % namespace)
        
    assert(0)

def validateObjectType(objType, namespace):
    assert(objType is not None)
    assert(namespace is not None)
    
    if objType == ("%sparty" % namespace):
        return 1
   
    if objType == ("%scollection" % namespace):
        return 1
    
    if objType == ("%sservice" % namespace):
        return 1
    
    if objType == ("%sactivity" % namespace):
        return 1

    print("Invalid object type: %s" % objType)        
    assert(0)
    return 0
        
def getRelatedObjects(regObj, namespace):
    assert(regObj is not None)
    assert(namespace is not None)
    
    objType = getObjectType(regObj, namespace)
    validateObjectType(objType, namespace)

    assert(regObj.tag == ('%sregistryObject' % namespace))
    relatedObjects = regObj.findall('%s/%srelatedObject' % (objType, namespace)) # for each key
    return relatedObjects
     
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

(options, args) = parser.parse_args()

# Validate data source uri
if not options.data_source_uri:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)
    
if len(options.data_source_uri) < 1:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)

if options.namespace:
    if len(options.namespace) > 1:
        namespace = ('{%s}' % options.namespace)
    
    
if len(options.data_source_uri) < 1:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)
    
dataSourceURI = options.data_source_uri


schemaLocation = namespace + ' http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd'

# Open outputFiles    
xmlOutFILE = openFile("ConcatRIF-CSTree.xml", "w")
xmlOutWithNonCollectionsMergedFILE = openFile("ConcatRIF-CSTree_nonCollectionsMerged.xml", "w")
uniqueKeyInstancesFILE = openFile("KeyInstances.txt", "w")

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

uniqueKeyInstancesFILE.write("Total occurrences per key for data source: %s\n\n" % dataSourceURI)

# Call function accessRegistryObjects(dataSourceURI+"verb=ListRecords&metadataPrefix=rif") for first page load
# When it encounters resumptionToken tag, it will store the value in resumptionToken
resumptionToken = accessRegistryObjects(keyInstances, gen, dataSourceURI+"?verb=ListRecords&metadataPrefix=rif")
   
while resumptionToken is not None:
   assert(len(resumptionToken) > 1)
   resumptionToken = accessRegistryObjects(keyInstances, gen, dataSourceURI+"?verb=ListRecords&resumptionToken="+resumptionToken)
   #resumptionToken = accessRegistryObjects(keyInstances, gen, dataSourceURI+"?verb=ListRecords&metadataPrefix=rif&resumptionToken="+resumptionToken)

for key in sorted(keyInstances, key=keyInstances.get, reverse=True):
  uniqueKeyInstancesFILE.write("Total occurrences: %d, key: %s\n" % (keyInstances[key], key.encode("utf-8")))
   
numRegistryObjectInstances = gen.next() - 1
print("%d registryObject instances found" % numRegistryObjectInstances)

  
# write end root node for registryObjects 
xmlOutAll.target.end('registryObjects')
rootOut = xmlOutAll.target.close() # returns root element
xmlOutFILE.write(ET.tostring(rootOut))
xmlOutFILE.close()

# Ensure unique instances or nonCollection objects with merged relatedObject nodes

if(len(allNonCollectionRegObjs) > 0):
    print("\n\nAll nonCollection registyrObject keys...")
    for nonCollection in allNonCollectionRegObjs:
        print("%s" % getKey(nonCollection, namespace))
        
    nonCollectionsMerged = mergeNonCollections(allNonCollectionRegObjs)
    for key in iter(nonCollectionsMerged):
        addItemToTree(xmlOutWithNonCollectionsMerged, nonCollectionsMerged[key])
    print("\n\nUnique nonCollection registryObject keys...")
    for key in iter(nonCollectionsMerged):
        print("%s" % key)

# Add all non nonCollections 
for nonNonCollection in collections:
    addItemToTree(xmlOutWithNonCollectionsMerged, nonNonCollection)

xmlOutWithNonCollectionsMerged.target.end('registryObjects')
rootOutNonCollectionsMerged = xmlOutWithNonCollectionsMerged.target.close() # returns root element
xmlOutWithNonCollectionsMergedFILE.write(ET.tostring(rootOutNonCollectionsMerged))
xmlOutWithNonCollectionsMergedFILE.close()


uniqueKeyInstancesFILE.close()

print("\n\nAll registryObjects written to ConcatRIF-CSTree.xml")
print("\nThose registryObjects with unique nonCollection instances (all related objects merged into one nonCollection) written to ConcatRIF-CSTree_nonCollectionsMerged.xml")
print("\nTotal instances of each key is in KeyInstances.txt")




