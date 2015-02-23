# Input examples:
# --server 'services.ands.org.au/sandbox'
# --data_source_key 'www.ala.org.au','aimsmest' (delimited by comma)
# --type party (or collection, service, activity) (optional - for when you only want a diagram of related parties)
#
# For each datasource, runs:
#   https://services.ands.org.au/sandbox/orca/services/getRegistryObjects.php?source_key={datasource}&collections=collection&parties=party&activities=activity&services=service
#
#   and creates a .diag file for python blockdiag, representing relationships between registry objects.
# When finished, run something like:
# > blockdiag {/home/createdByThisScript.diag}
# Then: view generated createdByThisScript.png in a web browser (or graphics applications) to see what was created.
#
# Usage: python.exe ConstructBlockDiag --server services.ands.org.au/sandbox --data_source ala,'atlas of living australia'
#
#    {data_source_key}_bom.html
#
# To avoid using services altogether, supply the RIFCS xml that you've loaded from web services, e.g:
# --input_xml registryObjectsAODN.xml
#
#  Example RIFCS may be the results from uri: 
#   https://services.ands.org.au/sandbox/orca/services/getRegistryObjects.php?source_key=aimsmest&collections=collection&parties=party&activities=activity&services=service
#              
#

import os
import string
from types import *
from optparse import OptionParser
import urllib
import StringIO
from elementtree import ElementTree as ET
from elementtree.ElementTree import parse

def rifcsForDataSource(server, source):
    assert(source is not None)
    assert(len(source) > 0)

    uri = "https://%s/orca/services/getRegistryObjects.php?source_key=%s&activities=activity&collections=collection&parties=party&services=service"% (server, source)
            
    print(uri)
    xml = ET.parse(urllib.urlopen(uri))
    root = xml.getroot()  
    return root
    
def openFile(fileName, mode):
    file  = open(fileName, mode)
    if not file:
        print("Unable to open file %s for %s" % (fileName, mode))
        os.sys.exit(-1)
            
    print("Opened file %s for %s" % (fileName, mode))
    filesOpened.append(file)
    return file
    
    
def closeAllFiles():
    for openedFile in filesOpened:
        openedFile.close()
        
def generator(limit=100000):
    n = 0
    while n < limit:
       n+=1
       yield n
       
def getObjectType(ro):
    if isObjectType(ro, "party"):
        return "party"
    
    if isObjectType(ro, "collection"):
        return "collection"
        
    if isObjectType(ro, "activity"):
        return "activity"
    
    if isObjectType(ro, "service"):
        return "service"
        
    assert(0)

def isObjectType(ro, objectType):
    element = ro.find(('.//{0}%s' % objectType).format(namespace))
    if element is None:
        return 0
        
    return 1

def colour(objectType):
    if objectType == 'party':
        return 'green'

    return 'black'
        
def writeToFile(currentDSRIFCS, ro, outFile):  
    xpath = ('{0}%s/{0}name/{0}namePart' % getObjectType(ro))
    namePart = ro.findtext(xpath.format(namespace))
    namePart = (namePart[:250] + '..') if len(namePart) > 250 else namePart
    outFile.write("'%s' [label = \"%s\", textcolor=\"%s\"];\n" % ( \
        toValidString(ro.findtext('{0}key'.format(namespace))), \
        toValidString(namePart), \
        colour(getObjectType(ro))))

# 'isManagedBy' [label = "isManagedBy", textcolor="red"];
   
#   'A' -> 'isManagedBy' -> 'B';

def newRelationship(value):
    global relationshipsSoFar
    for relationship in relationshipsSoFar:
        if relationship == value:
            return 0
    
    relationshipsSoFar.append(value) 
    return 1   
    
def relatedIsRequiredType(currentDSRIFCS, relatedKey, objectTypes):
    # Find all registry objects with this key
    registryObjects = currentDSRIFCS.findall('.//{0}registryObject'.format(namespace))
    if (registryObjects is None) or (len(registryObjects) < 0):
        assert(0)
        
    for relatedObject in registryObjects:
        # if key matches the key provided
        keyElem = relatedObject.find('{0}key'.format(namespace))
        if keyElem is None:
            print("No key!")
            assert(0)
        
        if relatedKey == keyElem.text:
            # We have found a registry object that matches the key provided
            # if it is the required type, return 1
            if typeRequired(relatedObject, objectTypes) == 1:
                return 1

    return 0
    
def writeRelationshipToFile(gen, currentDSRIFCS, ro, objectTypes, outFile): 
    # for each related object key, write relationship
    xpath = ('{0}%s/{0}relatedObject' % getObjectType(ro))
    allRelatedObjects = ro.findall(xpath.format(namespace)) # for each key
    for relatedObject in allRelatedObjects:
        key = relatedObject.findtext('{0}key'.format(namespace))
        # only present this relationship if the related object is of the right type
        if relatedIsRequiredType(currentDSRIFCS, key, objectTypes) == 0:
            continue
        relation = relatedObject.find('{0}relation'.format(namespace))
        if relation is not None:
            typeVal = toValidString(relation.get("type"))
            
        if (key is not None) and (len(key) > 0):
            if (typeVal is not None) and (len(typeVal) > 0):
                typeValKey = typeVal + ('%s' % gen.next())
                #outFile.write("'{0}' [label = \"{0}\", textcolor=\"red\"];\n".format(typeVal))
                outFile.write("'%s' [label = \"%s\", textcolor=\"red\"];\n" % ( \
                    toValidString(typeValKey), \
                    toValidString(typeVal)))
                    
                outFile.write("'%s' -> '%s' -> '%s';\n" % ( \
                    toValidString(ro.findtext('{0}key'.format(namespace))), \
                    toValidString(typeValKey), \
                    toValidString(key)))
    
def extractAlphanumeric(inputString):
    from string import ascii_letters, digits
    return "".join([ch for ch in inputString if ((ch == '.') or (ch in (ascii_letters + digits)))])
    
def toValidString(string):
    if string is None or (len(string) < 1):
        return 'xx'.encode('utf-8') 
    
    assert(isinstance(string, StringTypes))
    
    temp = string.encode('utf-8') 
    temp = temp.strip() # remove leading and trailing whitespace characters
    if len(temp) < 1:
        return '-'.encode('utf-8') ;
        
    return extractAlphanumeric(temp)

def getElementDict(namespace, element, xmlAttribute):
    assert(element is not None)
    if element.tag is None:
        assert(0) # element has no tag?!
        return None
        
    elementDict = {}    
    elementDict["nodeText"] = toValidString(element.text)
        
    # an attribute is defined
    attrText = None
    if xmlAttribute and (len(xmlAttribute) > 0):
        attrText = toValidString(element.get(xmlAttribute))

    elementDict["attrText"] = attrText
        
    return elementDict
    
def extractAlphanumeric(inputString):
    from string import ascii_letters, digits
    return "".join([ch for ch in inputString if ((ch == '.') or (ch in (ascii_letters + digits)))])

 
def getValues(namespace, ro, xpath, xmlAttribute):
    elements = ro.findall(xpath.format(namespace))
    elementDictList = list()
    for element in elements:
        elementDictList.append(getElementDict(namespace, element, xmlAttribute))
    return elementDictList  
    
def writeHeaderPerRO(ro):
    key = ro.findtext('./{0}key'.format(namespace))
    group = ro.get('group')
    originatingSource = ro.findtext('./{0}originatingSource'.format(namespace))
    
def searchTextMatching(ro, searchList):    
    allDescendants = ro.findall('.//*'.format(namespace))
    found = 0
    for descendant in allDescendants:
        text = descendant.text
        if text is not None:
            if len(text) > 0:
                for searchString in searchList:
                    if text.find(searchString) > -1:
                        if found == 0:
                            writeHeaderPerRO(ro)
                            found = 1
                        tag = None
                        if descendant.tag and (len(descendant.tag) > 0):
                            if descendant.tag.find('}') > -1:
                                tag = descendant.tag.split('}')[1]
                            else: 
                                tag = descendant.tag
                        
    return found

relationshipsSoFar = list()

def typeRequired(ro, objectTypes):
    for objectType in objectTypes:
        if isObjectType(ro, objectType):
            return 1
    return 0
    
def constructBlockDiag(rifcsXML, objectTypes, source=None, server=None):   
    assert(rifcsXML is not None)
    
    if (source is None): 
        source = 'Source_InputXML'
    
    if (server is None):
        server = 'Server_InputXML'
    
    # strip the 'https:' or 'http:' bit
    if source.find(':') > -1:
        source = source.split(':')[1]
        assert(source is not None)
        assert(len(source) > 0)

    outputFileName = extractAlphanumeric(source)
    outFile = openFile(('blockdiag/%s.diag' % outputFileName), "w")
    outFile.write("diagram {\n")

    count = 0  # how many times the searchStrings in searchList is found for this datasource
    registryObjects = rifcsXML.findall('.//{0}registryObject'.format(namespace))
    print("%d registryObjects found" % len(registryObjects))
    
    processed = 0
    for ro in registryObjects:
        if typeRequired(ro, objectTypes) == 0:
            continue
        processed += 1
        writeToFile(rifcsXML, ro, outFile)

    outFile.write("\n\n\n")
          
    gen = generator()      
    for ro in registryObjects:
        if typeRequired(ro, objectTypes) == 0:
            continue
        writeRelationshipToFile(gen, rifcsXML, ro, objectTypes, outFile)
        
    print("%d registryObjects processed" % processed)
    outFile.write("}")
    
# Get server and string from command line
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--server", action="store", dest="server", help="server (required if input_xml not supplied), e.g. 'services.ands.org.au/sandbox'")
parser.add_option("--input_xml", action="store", dest="input_xml", help="input_xml (required if server and data_source_key not supplied), rifcs output from web services")
parser.add_option("--data_source_key", action="store", dest="data_source_key", help="data source string (required if input_xml not supplied), e.g. 'ALA,Atlas of Living Australia'")
parser.add_option("--type", action="store", dest="type", help="type (optional), e.g. 'party,collection' if you only want parties and collections depicted")

(options, args) = parser.parse_args()
    
namespace = "{http://ands.org.au/standards/rif-cs/registryObjects}"    
filesOpened = list()

noRelatedObjectFoundFile = openFile("output/construct_block_diag_summary_no_related_object_found.txt", "a")

objectTypes = list()
if options.type:
        if len(options.type) > 0:
            objectTypes = options.type.split(',')

if not objectTypes or (len(objectTypes) < 1):
    print("Processing objects of type: collection")
    print("Processing objects of type: party")
    print("Processing objects of type: service")
    print("Processing objects of type: activity")
else:
    for objectType in objectTypes:
        print("Processing objects of type: %s" % objectType)
   
# Validate and store server
# server and data_source_key are required if input_xml is not supplied
if not options.input_xml:
    if not options.server:
        parser.error("Requires server.  Try --help for usage")
        sys.exit(-1)
    
    if len(options.server) < 1:
        parser.error("Requires server.  Try --help for usage")
        sys.exit(-1)
    
    # Validate data_source_key
    if not options.data_source_key:
        parser.error("Requires data_source_key.  Try --help for usage")
        sys.exit(-1)
    
    if len(options.data_source_key) < 1:
        parser.error("Requires data_source_key.  Try --help for usage")
        sys.exit(-1)
    server = options.server  
    
    requiredDataSourceList = list() # empty listo
    # Store data_source_key
    if options.data_source_key:
        if len(options.data_source_key) > 0:
            requiredDataSourceList = options.data_source_key.split(',')
            
    for source in requiredDataSourceList:
        assert(source)
        assert(len(source) > 0)
   
        print("Processing DataSource: %s\n" % source)
        noRelatedObjectFoundFile.write("DataSource: %s\n" % source)
        currentDSRIFCS = rifcsForDataSource(server, source)
        if (currentDSRIFCS is not None) and (len(currentDSRIFCS) > 0):
            constructBlockDiag(currentDSRIFCS, objectTypes, source, server)
        
            
# input_xml supplied
if options.input_xml:
    if options.server:
        print("Ignoring server because input_xml supplied")

    if options.data_source_key:
        print("Ignoring data_source_key because input_xml supplied")
    
    input_XML = options.input_xml

    inputRIFCS = ET.parse(options.input_xml)    
    assert(inputRIFCS is not None)
    constructBlockDiag(inputRIFCS, objectTypes)


    
closeAllFiles()

#outFile_tree = openFile("ConcatRIF-CSTree.xml", "w")

