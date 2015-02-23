# usage: python ConfirmConcatMerge.py --source_xml "example_source.xml" --merged_xml "example_merged.xml"

# Process:
# Ensures that ConcatRIF-CSTree_PartiesMerged.xml has all of the elements that are in ConcatRIF-CSTree.xml
# 

import sys
from optparse import OptionParser
import StringIO
import string
import urllib
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse
import operator

# Get server and string from command line
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--source_xml", action="store", dest="source_xml", \
    help="e.g ConcatRIF-CSTree.xml - output from Concat_RIF-CS_FromDataSource.py")
parser.add_option("--merged_xml", action="store", dest="merged_xml", \
    help="e.g ConcatRIF-CSTree_PartiesMerged.xml - output from Concat_RIF-CS_FromDataSource.py")

(options, args) = parser.parse_args()

# Validate options
if not options.source_xml:
    parser.error("Requires source_xml.  Try --help for usage")
    sys.exit(-1)

if not options.merged_xml:
    parser.error("Requires merged_xml.  Try --help for usage")
    sys.exit(-1)

def parseXML(xmlFileName):
    assert(xmlFileName is not None)
    try:
        return ET.parse(xmlFileName)   
    except Exception as e:
        print("Unable to parse XML %s - %s" % (xmlFileName, e))
        sys.exit(-1)
        
    assert(0)
    
def isObjectType(ro, objectType, namespace):
    assert(ro is not None)
    assert(objectType is not None)
    assert(namespace is not None)
    
    element = ro.find('.//%s%s' % (namespace, objectType))
    if element is None:
        return 0
        
    return 1
    
def getKey(registryObject, namespace):
    assert(registryObject is not None)
    assert(namespace is not None)
    
    keyElem = registryObject.find('./%skey' % namespace)
    assert(keyElem is not None)
    assert(keyElem.text is not None)
    assert(len(keyElem.text) > 0)
    return keyElem.text
    
def getMatchingRegObjs(mergedRegistryObjects, sourceRegObj, namespace):
    assert(mergedRegistryObjects is not None)
    assert(sourceRegObj is not None)
    assert(namespace is not None)
    
    foundRegObjs = list()
    for regObj in mergedRegistryObjects:
        if (getKey(sourceRegObj, namespace) == getKey(regObj, namespace)):
            foundRegObjs.append(regObj)
    
    if(len(foundRegObjs) <= 0):
        print("Error - unable to find registryObject with key [%s]" % key)      
        assert(0)
        
    assert(len(foundRegObjs) == 1)
    
    return foundRegObjs
    
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

    
sourceET = parseXML(options.source_xml)   
mergedET = parseXML(options.merged_xml)

namespace = '{http://ands.org.au/standards/rif-cs/registryObjects}'

sourceRegistryObjects = sourceET.getroot().findall('.//%sregistryObject' % namespace)
assert(len(sourceRegistryObjects) > 0)

mergedRegistryObjects = mergedET.getroot().findall('.//%sregistryObject' % namespace)
assert(len(mergedRegistryObjects) > 0)

# Element names at level under object type
elementNames = {'identifier', \
                'name', \
                'location', \
                'relatedObject', \
                'subject', \
                'description', \
                'coverage', \
                'citationInfo', \
                'relatedInfo', \
                'accessPolicy'}

for sourceRegObj in sourceRegistryObjects:
    objType = getObjectType(sourceRegObj, namespace)
    validateObjectType(objType, namespace)

    if (objType != ("%sparty" % namespace)):
        continue;

    assert(isObjectType(sourceRegObj, "party", namespace) == 1)
    
    mergedRegObjs = getMatchingRegObjs(mergedRegistryObjects, sourceRegObj, namespace)
    assert(len(mergedRegObjs) == 1)
    
    print("\n\nProcessing party with key %s" % getKey(sourceRegObj, namespace))
    
    key = getKey(sourceRegObj, namespace)
    assert(key is not None)
    assert(len(key) > 0)
    
    for mergedRegObj in mergedRegObjs:
        assert(getObjectType(mergedRegObj, namespace) == getObjectType(sourceRegObj, namespace))
        assert(getKey(mergedRegObj, namespace) == getKey(sourceRegObj, namespace))
        for elementName in elementNames:
            xpath = ('%s/%s%s' % (getObjectType(sourceRegObj, namespace), namespace, elementName))
            sourceElem = sourceRegObj.find(xpath)
            if sourceElem is None:
                continue
            
            assert(sourceElem is not None)
            # Source object has element of this name, so ensure that it exists on the mergedObject
            mergedElems = mergedRegObj.findall(xpath)
            contained = 0
            for mergedElem in mergedElems:
                if (ET.tostring(sourceElem).translate(None, string.whitespace) == ET.tostring(mergedElem).translate(None, string.whitespace)):
                    contained = 1
            if (contained == 0):
                print("\nError - did not find source elem...")
                print(ET.tostring(sourceElem).translate(None, string.whitespace))
                print("\n... in merged regObj...")
                for mergedElem in mergedElems:
                    print(ET.tostring(mergedElem).translate(None, string.whitespace))                
                
print("Done")

