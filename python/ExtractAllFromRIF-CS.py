# Opens a well-formed (and validated against schema?) RIF-CS document (perhaps the output of Concat_RIF-CS_FromDataSource.py)
#
# Input: File path, e.g.:
#   C:\project\AIHW\ExampleRIF-CS.xml
#
# Extracts registry objects and writes to file in HTML; a table for each object
#
# Output files:
#    party_extracted.html
#    collection_extracted.html
#    service_extracted.html
#    activity_extracted.html
#    all_extracted.html
#              

import os
import string
from types import *
from optparse import OptionParser

import StringIO
from elementtree import ElementTree as ET
from elementtree.ElementTree import parse


def openFile(fileName, mode):
    file  = open(fileName, mode)
    if not file:
        print("Unable to open file %s for %s" % (fileName, mode))
        os.sys.exit(-1)
            
    return file
    
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

    
# Find the registry object with this key and assemble text of info, e.g.:
# (namepart, electronic url)
def lookUp(xpath, keyToMatch):
    # Find all registry objects with this key
    registryObjects = root.findall('.//{0}registryObject'.format(namespace))
    if (registryObjects is None) or (len(registryObjects) < 0):
        assert(0)
        
    for ro in registryObjects:
        # if key matches the key provided
        keyElem = ro.find('{0}key'.format(namespace))
        if keyElem is None:
            print("No key!")
            assert(0)
        
        if keyToMatch == keyElem.text:
            # We have found a registry object that matches the key provided, so: get its name part
            namePartElem = ro.find("*//{0}namePart".format(namespace))
            namePartText = None
            if namePartElem is not None:
                namePartText = namePartElem.text
            return ("%s {%s}" % (toValidString(namePartText), getObjectType(ro)))
 
    #print("No related object found in current feed with key %s" % keyToMatch)
    try:
        index = noRelatedObjectKeys.index(keyToMatch)
    except ValueError: # keyToMatch is not in list, so add it
        noRelatedObjectKeys.append(keyToMatch)

    return "(NO RELATED OBJECT FOUND IN CURRENT FEED)"
    
def optionalText(xpath, value):
    assert((xpath is not None) and (len(xpath) > 0))
    assert((value is not None) and (len(value) > 0))
    if (xpath.find("key") < 0):
        print("Error: no key found for %s" % xpath)
        return ""
    result = lookUp(xpath, value)
    assert(result and len(result) > 0)
    return result
        
# Function to nest entries so that you see children nested under the top-level, such as this example for related object:
# relatedKey                                        : aihw.gov.au/partyOrgId=1
# relatedType                                       : isPartOf
# relatedKey                                        : aihw.gov.au/collDHID=6360
# relatedType                                       : isManagerOf
            
def writeNestedValuesToFile(gen, namespace, objectType, ro, xpathTopElement, xpathDictList, file):
    assert(len(xpathDictList) > 0)
    # Find all top-level elements
    elements = ro.findall(xpathTopElement.format(namespace)) # for each key
    if (elements is None) or (len(elements) < 1):
        for xpathDict in xpathDictList:
            if (isMandatory(("%s/%s" % (xpathTopElement, xpathDict["xpath"])), xpathDict["attribute"], objectType) == 1):
                print("ERROR - mandatory not provided")
    for element in elements:
        # Iterate through xpathDictList, printing each value to file (of element or of attribute)
        for xpathDict in xpathDictList:
            # get subElement which is xpathDict["xpath"] but relative to this related object
            splitXPaths = xpathDict["xpath"].rsplit('}')
            assert(len(splitXPaths) > 0)
            youngestXPath = splitXPaths[len(splitXPaths)-1]
            formattedPath = "./{0}" + youngestXPath
            subElement = element.find(formattedPath.format(namespace))
            lookUp = (1 if (youngestXPath == "key") else 0)
            assert(subElement is not None)
            elementDict = getElementDict(namespace, subElement, xpathDict["attribute"])
            assert(elementDict is not None)
            writeElementToFile(elementDict, gen, xpathDict["xpath"], xpathDict["attribute"], file, lookUp)

def isMandatory(xpath, xmlAttribute, objectType):
    global mandatoryTupleList
    #print("Is mandatory? %s, %s, %s" % (xpath, xmlAttribute, objectType))
    for tuple in mandatoryTupleList:
        if ((tuple["type"] != "all") and (objectType != tuple["type"])):
            continue
            
        if (xpath != tuple["xpath"]):
            continue
        
        if (xmlAttribute != xmlAttribute):
            continue
    
        print("ERROR: No mandatory element: %s, attribute: %s, for type: %s" % (xpath, toValidString(xmlAttribute), objectType))
        return 1
        
    return 0;
    
def formatXpath(xpath):
    if xpath is None or (len(xpath) < 1):
        assert(0)
    
    xpath = xpath.replace("{0}", "")
    xpath = xpath.replace("./", "")
    return xpath

def generator(limit=100000):
    n = 0
    while n < limit:
       n+=1
       yield n
       
       
def writeElementToFile(element, gen, xpath, xmlAttribute, file, lookUp=0):
    optional = None
    nodeText = element["nodeText"]
    attrText = element["attrText"]
    if nodeText:
        if lookUp and xpath:
            optional = optionalText(xpath, nodeText)

    if ((gen.next() % 2) == 0):
        file.write("<tr class=\"alt\">")
    else:
        file.write("<tr>")

    file.write("<td class=\"col1\">%s</td>                 \
                <td class=\"col2\">%s</td>                 \
                <td class=\"col3\">%s</td>                 \
                <td class=\"col4\">%s</td>                 \
                <td class=\"col5\">%s</td>                 \
                </tr>\n" % (formatXpath(xpath), toValidString(xmlAttribute), toValidString(attrText), toValidString(nodeText), toValidString(optional))) 
       
# (relative to namespace) set value of xpath element (or attribute (if provided)) on object.objectAttribute)
def writeValueToFile(gen, namespace, objectType, ro, xpath, xmlAttribute, file, lookUp = 0):
    elementDict = getValues(namespace, ro, xpath, xmlAttribute)
    if (elementDict is None) or (len(elementDict) < 1):
        if (isMandatory(xpath, xmlAttribute, objectType) == 1):
            assert(0)
        return
        
    for element in elementDict:
        writeElementToFile(element, gen, xpath, xmlAttribute, file, lookUp)

def getValues(namespace, ro, xpath, xmlAttribute):
    elements = ro.findall(xpath.format(namespace))
    elementDictList = list()
    for element in elements:
        elementDictList.append(getElementDict(namespace, element, xmlAttribute))
    return elementDictList
    
def toValidString(string):
    if string is None or (len(string) < 1):
        return '-'
    
    assert(isinstance(string, StringTypes))
    
    temp = None
    try:
        temp = string.encode('utf-8')
        temp = temp.strip() # remove leading and trailing whitespace characters
        if len(temp) > 0:
            return temp;
    except:
        print("Error - exception caught when attempting to encode: %s" % string)
        unencodeableTextFoundFile.write("Unable to encode: %s\n\n" % string)
        return 'Unable to encode'

    return '-'; 
    
#elementDict = {"attrText": val, "nodeText" : val}
#def getElementDict(element, xmlAttribute):
#    assert(element is not None)
#    if element.tag is None:
#        assert(0) # element has no tag?!
#        return None
        
#    elementDict = {}    
#    elementDict["nodeText"] = toValidString(element.text)
        
    # an attribute is defined
#    attrText = None
#    if xmlAttribute and (len(xmlAttribute) > 0):
#        attrText = toValidString(element.get(xmlAttribute))

#    elementDict["attrText"] = attrText
        
#    return elementDict

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
    
def isObjectType(ro, objectType):
    element = ro.find(('.//{0}%s' % objectType).format(namespace))
    if element is None:
        return 0
        
    return 1


def writeHeadToFile(file):
    
    file.write(" \
    <head> \
        <title></title> \
        <style type=\"text/css\"> \
#objects \
{ \
font-family:\"Trebuchet MS\", Arial, Helvetica, sans-serif; \
width:100%; \
border-collapse:collapse; \
} \
#objects td, #objects th \
{ \
font-size:1em; \
border:1px solid #218BBF; \
padding:3px 7px 2px 7px; \
} \
#objects th \
{ \
font-size:1.1em; \
text-align:left; \
padding-top:5px; \
padding-bottom:4px; \
background-color:#2179BF; \
color:#ffffff; \
} \
#objects tr.alt td \
{ \
color:#000000; \
background-color:#EAF2D3; \
} \
#objects td.col1 \
{ \
width:25% \
} \
#objects td.col2 \
{ \
width:5% \
} \
#objects td.col3 \
{ \
width:10% \
} \
#objects td.col4 \
{ \
width:30% \
} \
#objects td.col5 \
{ \
width:30% \
} \
</style> \
</head>")
    
def extractToFile(input_XML, objectType):
    outputFile = "%s_%s.html" % (input_XML.replace(".xml", ""), objectType)
    FILE_out = openFile(outputFile, "w")
    
    FILE_out.write("<html>\n");
    writeHeadToFile(FILE_out)
    
    FILE_out.write("<body>\n");
    
    count = 0
    for ro in registryObjects:
        if not isObjectType(ro, objectType):
            continue
        count += 1

        FILE_out.write("<table id=\"objects\"           \
                        <tr>                            \
                            <th>node xPath</th>         \
                            <th>attribute name</th>     \
                            <th>attribute value</th>    \
                            <th>node value</th>         \
                            <th>related</th>            \
                        </tr>\n")

        gen = generator()
        writeValueToFile(gen, namespace, objectType, ro, ".", "group", FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}key", None, FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}originatingSource", None, FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}%s" % objectType, "type", FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}%s/{0}identifier" % objectType, "type", FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}%s/{0}name" % objectType, "type", FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}%s/{0}name/{0}namePart" % objectType, None, FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}%s/{0}location/{0}address/{0}electronic" % objectType, "type", FILE_out)
        writeValueToFile(gen, namespace, objectType, ro, "./{0}%s/{0}location/{0}address/{0}electronic/{0}value" % objectType, None, FILE_out)
    
        xpathDictRelation = {"xpath" : "./{0}%s/{0}relatedObject/{0}relation" % objectType, "attribute" : "type"}
        xpathDictKey = {"xpath" : "./{0}%s/{0}relatedObject/{0}key" % objectType, "attribute" : ""}
        xpathDictList = [xpathDictKey, xpathDictRelation]
        writeNestedValuesToFile(gen, namespace, objectType, ro, "./{0}%s/{0}relatedObject" % objectType, xpathDictList, FILE_out)

        writeValueToFile(gen, namespace, objectType, ro, "./{0}%s/{0}description" % objectType, "type", FILE_out)
        
        FILE_out.write("</table>")
        FILE_out.write("<br />")
        
    print("Wrote %d %s(s) to %s" % (count, objectType, outputFile))
    
    FILE_out.write("</body>\n");
    FILE_out.write("</html>\n");
    FILE_out.close()
      
# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--input", action="store", dest="inputRIFCS_XML", help="path to RIF-CS, e.g. \"C:\projects\AIHW\ExampleRIF-CS.xml\"")

(options, args) = parser.parse_args()

# mandatory - generic
mandatoryTupleList = list()
mandatoryTupleList.append({"xpath" : "./{0}originatingSource", "attribute" : None, "type" : "all"})
mandatoryTupleList.append({"xpath" : ".", "attribute" : "group", "type" : "all"})
mandatoryTupleList.append({"xpath" : "./{0}key", "attribute" : None, "type" : "all"})
mandatoryTupleList.append({"xpath" : "./{0}key", "attribute" : None, "type" : "all"})
#todo - is one type of name required (mandatory not per item but per at least one per group)

# mandatory - collection
mandatoryTupleList.append({"xpath" : "./{0}collection", "attribute" : "type", "type" : "collection"})
mandatoryTupleList.append({"xpath" : "./{0}%s/{0}relatedObject/{0}key", "attribute" : None, "type" : "collection"})
mandatoryTupleList.append({"xpath" : "./{0}%s/{0}relatedObject/{0}relation", "attribute" : "type", "type" : "collection"})

# mandatory - service

# mandatory - activity

# mandatory - party


# Validate data source uri
if not options.inputRIFCS_XML:
    parser.error("Requires inputRIFCS_XML.  Try --help for usage")
    os.sys.exit(-1)
    
if len(options.inputRIFCS_XML) < 1:
    parser.error("Requires inputRIFCS_XML.  Try --help for usage")
    os.sys.exit(-1)
    
input_XML = options.inputRIFCS_XML

tree = ET.parse(input_XML)
root = tree.getroot()


noRelatedObjectFoundFile = openFile("summary_no_related_object_found.txt", "a")
unencodeableTextFoundFile = openFile("summary_unencodeable_text_found.txt", "a")

noRelatedObjectKeys = list() # contains all keys for which no related object could be found in the current feed

# Find all registry objects
namespace = "{http://ands.org.au/standards/rif-cs/registryObjects}"    
registryObjects = root.findall('.//{0}registryObject'.format(namespace))
print("%d registryObjects found" % len(registryObjects))

extractToFile(input_XML, "party")
extractToFile(input_XML, "collection")
extractToFile(input_XML, "activity")
extractToFile(input_XML, "service")

for key in noRelatedObjectKeys:
    noRelatedObjectFoundFile.write("%s\n" % key)
  
noRelatedObjectFoundFile.close()
unencodeableTextFoundFile.close()

print("See summary_no_related_object_found.txt for where related objects could not be found for key specified")
print("See unencodeableTextFoundFile.txt for text that could not be encoded to utf-8")

#tree.write("TreeRead.xml")


