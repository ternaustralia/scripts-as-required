#Usage: ABSConstructCollectionRIFCS.py [options] arg1

#Options:
#  -h, --help            show this help message and exit
#  --crosswalk=CROSSWALK
#                        e.g ABSCrosswalk.html - HTML crosswalk
#  --catalogue_info=CATALOGUE_INFO
#                        e.g CatalogueInfo.txt of multiline catalogue number
#                        and issue, per line as: 6201.0|9999mar%202012
#
#
#  Takes input --catalogue_info which contains lines of catalogue number and issue date, delimited by |:  
#       3107.0.55.001|9992005
#
#  Takes input --crosswalk with is an html of variable names, values and identifiers to map xpaths with ways to determine values
#  Ways include:  variable values, resolved properties, text from HTML (regular expressions are used to aid extraction)
#  See commit messages to find reference to compatible example CrossWalk.html that you can find in version control, too.

import sys
import urllib2
import httplib2
from BeautifulSoup import BeautifulSoup          # For processing HTML
import re
from optparse import OptionParser
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse
import xml.dom
from xml.dom import getDOMImplementation

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--crosswalk", action="store", dest="crosswalk", help="e.g ABSCrosswalk.html - HTML crosswalk")
parser.add_option("--catalogue_info", action="store", dest="catalogue_info", help="e.g CatalogueInfo.txt of multiline catalogue number and issue, per line as: 6201.0|9999mar%202012")

(options, args) = parser.parse_args()

# Validate options
if not options.crosswalk:
    parser.error("Requires crosswalk.  Try --help for usage")
    sys.exit(-1)
    
if not options.catalogue_info:
    parser.error("Requires file of catalogue info.  Try --help for usage")
    sys.exit(-1)
    
def getCellValue(td):
    assert(td is not None)
    if (td.a is not None):
        if td.a.string is not None:
            return (td.a.string.strip())
    
    if (td.string is not None):
        return td.string.strip()
        
    assert(0) # no value

def getVariables(table, catalogueInfoDict):
    variables = {}
    allRows = table.findAll('tr')
    for tr in allRows:
        all_th = tr.findAll('th')
        if(len(all_th) > 0):
            # Dealing with the first row which contains the column names
            assert(len(all_th) == 2)
            assert(all_th[0].string == 'Name')
            assert(all_th[1].string == 'Value')
            continue 
            
        # Dealing with each subsequent row
        all_td = tr.findAll('td')
        assert(len(all_td) == 2)
        name = getCellValue(all_td[0])
        assert(len(name) > 0)
        value = getCellValue(all_td[1])
        assert(len(value) > 0) # variable value is missing
        variables[name] = value
        
    assert(variables.has_key('PersistentURI'))
   
    catalogueNumber = catalogueInfoDict["Number"]
    assert(catalogueNumber is not None)
    assert(len(catalogueNumber) > 0)
    variables["CatalogueNumber"] = catalogueNumber
    
    issue = catalogueInfoDict["Issue"]
    if issue is not None:
        if(len(issue) > 0):
            variables["Issue"] = issue

    return variables
    
def getCrossWalkDictList(table):
    dictList = list()
    allRows = table.findAll('tr')
    for tr in allRows:
        all_th = tr.findAll('th')
        if(len(all_th) > 0):
            # Dealing with the first row which contains the column names
            assert(len(all_th) == 3)
            assert(all_th[0].string == 'XPath')
            assert(all_th[1].string == 'Property')
            assert(all_th[2].string == 'ExampleValue')                                    
            continue
        
        # Dealing with each subsequent row
        all_td = tr.findAll('td')
        assert(len(all_td) == 3)
        currentDict = {}
        currentDict['xpath'] = getCellValue(all_td[0])        
        currentDict['property'] = getCellValue(all_td[1])

        dictList.append(currentDict)
        
    return dictList

def getDictListValues(xpathValueDictDict, xpath):
    assert(xpathValueDictDict is not None)
    assert(xpath is not None)
    values = list()
    for d in xpathValueDictDict:
        if d.has_key(xpath):
            value = d[xpath]
            if (value is not None):
                if (len(value) > 0):
                    values.append(value)
                    
                    
    return values


def getDictValue(d, key):
    if key in d:
        return d[key]
        
    return None
    
def getDictDictValue(dictDict, key):
    for k,v in dictDict.iteritems():
        if key in v: # k is an int, v is a dictionary of key, value
            return v[key]
            
    return None
    
def printDictList(dictList):
    for currentDict in dictList:
        printDict(currentDict)

def printDict(currentDict):    
    for k,v in currentDict.iteritems():
            print("%s\n%s" % (k, v))
    print("\n")
     
     
def printDictDict(currentDict):    
    i = 1
    for k,v in currentDict.iteritems():
        print("index: %d" % i)
        i+=1
        printDict(v)
    print("\n")

def getValue(variable, variables):
    # First try to get value from variables
    value = getDictValue(variables, variable)
    if value and len(value) > 0:
        return value
                
    return None
    
def generator(limit=1000000):
    n = 0
    while n < limit:
       n+=1
       yield n
        
# xpathValueDictDict is a dictionary where key increases from 1 and value is a dictionary which has key, value like so:
# dictionary[index] has dictionary:
#                                   ./[@group]          company name
#                                   ./key               uniquekey349578349587345

def populatexpathValueDict(gen, xpathValueDictDict, soup, variables, crosswalkDictList):   
    # Where a property has been specified in crosswalkDictList, grab from soup, considering regex
    results = soup.findAll('meta')
    if (len(results) <= 0):
        print("Error - no meta tags found")  # Nothing will be written to xpathValueDictDict 
        return
    metaDict = dict()
    for result in results:
        name = result['name'].encode('utf-8')
        if (name is None) or (len(name) <= 0):
            print("No name for meta tag")
            continue
        
        content = result['content'] 
        if (name is None) or (len(name) <= 0):
            print("No content for meta tag")
            continue
            
        metaDict[name] = content.encode('utf-8')
        
    # Sometimes the property is combined with a variable, so see if any apply here
    
    for crosswalkDict in crosswalkDictList:
        xpathValueDictionary = dict()
        assert(crosswalkDict['xpath'] is not None)
        assert(len(crosswalkDict['xpath']) > 0)
        resolved = ""
        if (len(crosswalkDict['property']) > 0):
            resolved = resolveProperty(crosswalkDict['property'], soup, variables, metaDict)

        xpathValueDictionary[crosswalkDict['xpath']] = resolved
        index = gen.next()
        xpathValueDictDict[index] = xpathValueDictionary
      
        
# Variable values can only contain variable placeholders - not property or html place holders
# because we haven't retrieved HTML content yet
def resolveValue(prop, variables):
    propertyList = prop.split('^_') # ASCII Unit Separater
            
    valueList = list()
    for prop in propertyList:
        assert(prop is not None)
        assert(len(prop) > 0)
        
        if(prop[0] == '['): # only able to replace variables here because there is no HTML content available yet
            print("Error: unable to resolve property %s - can only resolve variable placeholders within {} because we don't have HTML content yet" % prop)
            assert(0)
          
        if (prop[0] == '{'):  
            value = replaceVariables(prop, variables)
        else:
            value = prop
            
        valueList.append(value)
       
    concatVal = ""
    for val in valueList:
        concatVal += val
   
    return concatVal

def resolveProperty(prop, soup, variables, metaDict):
    propertyList = prop.split('^_') # ASCII Unit Separater
            
    valueList = list()
    for prop in propertyList:
        assert(prop is not None)
        assert(len(prop) > 0)
        if (prop.lower().find('[html]') == 0):
            value = replaceHTML(prop, soup)
        elif (prop[0] == '{'):
            value = replaceVariables(prop, variables)
        elif (prop[0] == '['):
            value = replaceProperties(prop, metaDict)
        else:
            # nothing to resolve, so must just be a value to include
            value = prop
        valueList.append(value)
        
    concatVal = ""
    for val in valueList:
        concatVal += val
   
    return concatVal
  
def extract(string, pattern):
    assert(string is not None)
    assert(len(string) > 0)             
    assert(pattern is not None)
    assert(len(pattern) > 0)   

    result = ""
    print("pattern %s" % pattern)
    regex = re.compile(pattern, re.IGNORECASE)
    for m in regex.finditer(string):
        result += m.group(0)
        result += " "

    if result.rstrip() is not None:
        if len(result.rstrip()) > 0:
            return result.rstrip()
            
    assert(0) # no result extracted

def replaceHTML(string, soup):
    if(string is None) or (len(string) <= 0):
        return string

    assert(string.lower().find("html") > 0)
    
    valueDict = subValues(string, '[', ']')
    assert(valueDict.has_key('identifier'))
    identifier = valueDict['identifier']
    assert(identifier.lower() == 'html')
    
    assert(valueDict.has_key('criteria'))
    criteria = valueDict['criteria']
    
    assert(identifier is not None)
    assert(criteria is not None) # need criteria to know which bit of html we need
    
    
    tag = soup.find(criteria)
    if tag is not None:
        if tag.text is not None:
            return tag.text

    return ""

def replaceVariables(value, variables):
    assert(value is not None)
    assert(len(value) > 0)
    assert(value[0] == "{")
    # format will be: {variable}regex or just {variable}
    value = resolve('{', '}', value, variables)        
    
    return value
    
def replaceProperties(value, metaDict):
    assert(value is not None)
    assert(len(value) > 0)
    assert(value[0] == "[")
    # format will be: [property]regex or just [property]
    value = resolve('[', ']', value, metaDict)    
    return value
    
def resolve(cBegin, cEnd, value, dictionary):
    assert(value is not None)
    assert(len(value) > 0)

    valueDict = subValues(value, cBegin, cEnd)
    assert(valueDict.has_key('identifier'))
    assert(valueDict['identifier'] is not None)
    identifier = valueDict['identifier']
    
    assert(identifier is not None)
    
    assert(dictionary is not None)
    assert(len(dictionary) > 0)
    if (dictionary.has_key(identifier) == 0):
        print("Error: dictionary does not have key %s" % identifier)
        assert(0)
        
    dictVal = dictionary[identifier]
    assert(dictVal is not None)
    assert(len(dictVal) > 0)
    
    # Replace variable name with dictionary value
    value = dictVal
        
    # if there is a regex pattern extract from value
    if (valueDict.has_key('criteria')):
       if (valueDict['criteria'] is not None):
        criteria = valueDict['criteria']
        if (len(criteria) > 0):
            extracted = extract(value, criteria)
            print("Criteria: %s, identifier: %s, value: %s, extracted: %s" % (criteria, identifier, value, extracted))
            return extracted
    
    return value


def subValues(value, cBegin, cEnd):
    valueDict = dict()
    l = value.split(cEnd, 1)
    assert(len(l) > 0)
    assert(len(l) <= 2)
    identifier = l[0]
    assert(identifier[0] == cBegin)
    identifier = identifier.replace(cBegin, '')
    valueDict['identifier'] = identifier
    if(len(l) == 2):
        temp = l[1].strip()
        if (len(temp) > 0):
            valueDict['criteria'] = l[1]
            
            
    return valueDict
    
def countXPathInCrosswalk(crosswalkDictList, xpath):
    count = 0
    for crosswalkDict in crosswalkDictList:
        if (crosswalkDict['xpath'] == xpath):
            count += 1
            
    return count
    
def countXPathInxpathValueDictDict(xpathValueDictDict, xpath):
    count = 0
    for k,v in xpathValueDictDict.iteritems():
        if xpath in v: # k is an int, v is a dictionary of key, value
            if (v[xpath] is not None): # there is a value for this xpath
                count = count + 1
    
    return count

def printStats(xpathValueDictDict, crosswalkDictList):
    for crosswalkDict in crosswalkDictList:
        xpath = crosswalkDict['xpath']
        if(countXPathInCrosswalk(crosswalkDictList, xpath) != (countXPathInxpathValueDictDict(xpathValueDictDict, xpath))):
            print("XPath %s occurs %d time(s) in crosswalk which is inconsistent with %d time(s) in xml values" % (xpath, \
                countXPathInCrosswalk(crosswalkDictList, xpath), \
                countXPathInxpathValueDictDict(xpathValueDictDict, xpath)))
        

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
    
def attributeName(xpath):
    assert(xpath.find('@') == xpath.rfind('@')) # ensure only one attribute
    assert(xpath.find('[') == xpath.rfind('[')) # ensure only one attribute
    assert(xpath.find(']') == xpath.rfind(']')) # ensure only one attribute
    startIndex = xpath.find('@')
    endIndex = xpath.find(']')
    return xpath[startIndex+1:endIndex]

def rstripAttributeName(xpath):
    if(xpath.count('@') < 0): # Contains attribute
        return xpath
    
    assert(xpath.count('@') == 1) # Expecting one only
        
    return xpath[0:xpath.find('@')]
    
    
def youngestElement(xpath):
    if(xpath.count('@') > 0): # Contains attribute
        assert(xpath.count('@') == 1) # Ought only be one
        nameElemAndAttr = None
        if(xpath.count('/') > 0):
            # We have something like:
            # elementName1/elementName[@attributeName]
            # elementName2/elementName1/elementName[@attributeName]
            elementNames = xpath.split('/')
            assert(len(elementNames) > 1)
            nameElemAndAttr = elementNames[len(elementNames)-1] # contains just elementName[@attributeName]
        else:
            # We have: elementName[@attributeName]
            nameElemAndAttr = xpath 
                   
        
        assert(nameElemAndAttr.find('[') == nameElemAndAttr.find('@')-1)
        
        if(nameElemAndAttr.count('/') == 0):   # elementName[@attributeName]
            return nameElemAndAttr[0:(nameElemAndAttr.find('['))] # return elementName
    else:
        # Element only - no attribute
        if xpath.find('/') < 0:
            return xpath # No slashes so this must be the element name only

        # assert if forward slash is at the end
        assert(xpath.rfind('/') < (len(xpath) -1))
        
        return(xpath[(xpath.rfind('/')+1):len(xpath)]) # return the text after the last forward slash
  
# Go through xpath, value pairs in xpathValueDictDict and aggregate element information by accumulate element 
# info for each element at each level, accumulating attribute values per element found in attributeDict.
# Write it out to xmlOutParser in the structure required
#
# name      registryObject/collection/identifier
# value     379752345/455345.ere
# attrDict  { "type" : "local"} { "lang" : "en" } 
#
# name      registryObject/collection/identifier
# value     www.gov.au/379752345/455345.ere
# attrDict  { "type" : "PURL"}
#
def populate(doc, namespace, xpathValueDictDict, xmlOutFILE):

    level = 0
    for i in range (1, len(xpathValueDictDict)+1):
        assert(i in xpathValueDictDict)
        currentDict = xpathValueDictDict[i]
        assert(len(currentDict) == 1)
        for k, v in currentDict.iteritems():
            if(k.count('@') > 0): # Skip the attributes - just looking for elements here
                print("Populate - Skipping (attribute) - [%s] = [%s]" % (k, v))  
                continue
            
            if(k.count('/') != (level)): # Not the level that we are looking for on this iteration
                print("Populate - Skipping (not current level) - [%s] = [%s]" % (k, v))                
                continue

            # Forward slash will occur at 'level' times for this element
            assert(k.count('/') == level) 
            # Found an element at the level specified
            
            name = youngestElement(k)
            currentElem = doc.createElementNS(namespace, name)
            doc.documentElement.appendChild(currentElem)
            
            assert((name is not None) and (len(name) > 0))
            attrDict = attributeDict(level, name, i, xpathValueDictDict)
            for attrName, attrVal in attrDict.iteritems():
                appendAttribute(doc, currentElem, namespace, attrName, attrVal)
            
            if(k.count('@') == 0): # This is the element, not the attribute, so grab the value
                if((v is not None) and (len(v) > 0)):
                    print("Populate - Adding Node - [%s] = [%s]" % (k, v))                
                    description = doc.createTextNode(v)
                    currentElem.appendChild(description)
                        
            processChildren(level+1, i+1, namespace, doc, currentElem, xpathValueDictDict, k)
    
def processChildren(level, xpathValueDictIndex, namespace, doc, parentElem, xpathValueDictDict, xpathParent=None):
    
    for i in range (xpathValueDictIndex, len(xpathValueDictDict)+1):
        print("Populate - processChildren - next dictionary")
        assert(i in xpathValueDictDict)
        currentDict = xpathValueDictDict[i]
        assert(len(currentDict) == 1)
        print("Populate - Level %d - Index %d - processChildren" % (level, i))
        for k, v in currentDict.iteritems():
            if(k.count('@') > 0): # Skip the attributes - just looking for elements here
                print("Populate - Children - Skipping (attribute) - [%s] = [%s]" % (k, v))  
                continue
                
                
            if(k.count('/') != (level)): # Not the level that we are looking for on this iteration
                print("Populate - Children - Skipping (not current level) - [%s] = [%s]" % (k, v))
                continue                
                
            assert (k.count('/') == (level))
            
            # Forward slash will occur at 'level' times for this element
            assert(k.count('/') == level) 
            # Found an element at the level specified
            
            if(xpathParent is not None):
                # We are looking for children only, so continue if k (xpath) is not within xpathParent
                if(k.count(xpathParent) == 0):
                    return # We have come to the end of children for this element
            
            name = youngestElement(k)
            nameForNode = name
            if (name.find("_") > 0): # Has a postfix to distinguish between multiple elements of same name and level
                print("_ found at index: %d" % name.find("_"))
                nameForNode = name.split("_")[0] # Strip the postfix "_n"
            
            currentElem = doc.createElementNS(namespace, nameForNode)
            parentElem.appendChild(currentElem)
            nodeAddedForCurrentLevel = 1
            
            assert((name is not None) and (len(name) > 0))
            attrDict = attributeDict(level, name, i, xpathValueDictDict)
            for attrName, attrVal in attrDict.iteritems():
                appendAttribute(doc, currentElem, namespace, attrName, attrVal)
            
            assert (k.count('@') <= 0)
            if((v is not None) and (len(v) > 0)):
                print("Populate - Children - Adding Node - [%s] = [%s]" % (k, v))                
                description = doc.createTextNode(v)
                currentElem.appendChild(description)
                    
            # Recurse at next level.  Start looking for values from this point in xpathValues, onward because children will be
            # directly beneath.  We will break when we stop finding children so that we get them at the right parent.
            # (If we didn't do it we wouldn't be able to work out which children belonged to whom (e.g. electronic/value
            # may occur twice but we only want one value per electronic element instance)
            processChildren(level+1, i+1, namespace, doc, currentElem, xpathValueDictDict, k)
 
            
    
def appendAttribute(doc, elem, namespace, name, value):
    print("Adding Attribute to Node [%s] - [%s] = [%s]" % (elem.tagName, name, value))
    attrNode = doc.createAttributeNS(namespace, name)
    elem.setAttributeNodeNS(attrNode)
    elem.setAttributeNS(namespace, name, value)        
  
# accumulate attributes for this name at this level - they will be at the index after the parentIndex and beyond, 
# all in a row (break when you aren't dealing with attribute for this element anymore)
def attributeDict(level, name, parentIndex, xpathValueDictDict):
    attrDict = dict()
    recordedNames = list() # to test for repeated attribute names (error)
    for i in range (parentIndex+1, len(xpathValueDictDict)+1):
        assert(i in xpathValueDictDict)
        currentDict = xpathValueDictDict[i]
        assert(len(currentDict) == 1)
        for k, v in currentDict.iteritems():
            if(k.count('@') <= 0): # Not an attribute, so continue
                return attrDict # there are no attributes, or we have handled them all
                
            if(k.count('/') != (level)): # Not the level that we are looking for on this iteration
                return attrDict # there are no attributes, or we have handled them all
            
            elementName = youngestElement(k)
            if(name == elementName):
                # this is the element that we are interested in, so grab this attribute
                attrName = attributeName(k)
                assert(attrName is not None)
                assert(len(attrName) > 0)
                attrDict[attrName] = v
                assert(attrName not in recordedNames) # error if we have multiple attribute names for one element
                recordedNames.append(attrName)
               
    return attrDict                
                
    
def writeXmlOutParserToFile(xmlOutParser, endTag, filename):
    xmlOutParser.target.end(endTag)
    rootOut = xmlOutParser.target.close() # returns root element
    xmlOutFILE = openFile(filename, "w")
    xmlOutFILE.write(ET.tostring(rootOut))
    xmlOutFILE.close()

def initDoc(namespace):
    impl = getDOMImplementation()
    doc = impl.createDocument(namespace, 'registryObjects', None)

    appendAttribute(doc, doc.documentElement, namespace, 'xmlns', 'http://ands.org.au/standards/rif-cs/registryObjects')
    appendAttribute(doc, doc.documentElement, namespace, 'xsi:schemaLocation', \
        'http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd')
    appendAttribute(doc, doc.documentElement, namespace, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    appendAttribute(doc, doc.documentElement, namespace, 'xmlns:rif', 'http://ands.org.au/standards/rif-cs/registryObjects')
    return doc

def populateCatalogueInfo(catalogueInfoFileName):
    
    catalogueInfoDictList = list()
    
    catalogueInfoFILE = openFile(catalogueInfoFileName, "r")
    assert(catalogueInfoFILE is not None)
    
    #catalogueInfoList = list()
    #catalogueInfoList.append("6401.0|9999mar%202012")
    #catalogueInfoList.append("6202.0|9999mar%202012")

    for catalogueInfo in catalogueInfoFILE:
        catalogueInfo = catalogueInfo.strip()
        if(len(catalogueInfo) <= 0):
            continue
            
        print("Line from file: " + catalogueInfo)
        catalogueInfoDict = dict()    
        assert(catalogueInfo.count("|") > 0)
        
        number = catalogueInfo.split("|")[0]
        assert(number is not None)
        assert(len(number) > 0)
        catalogueInfoDict["Number"] = number

        issue = catalogueInfo.split("|")[1]
        if issue is not None:
            if len(issue) > 0:
                catalogueInfoDict["Issue"] = issue

        catalogueInfoDictList.append(catalogueInfoDict)
        
    return catalogueInfoDictList
    
crosswalkPage = urllib2.urlopen("file:///%s" % options.crosswalk)
crosswalkSoup = BeautifulSoup(crosswalkPage)
crosswalkSoup.prettify()

tables = crosswalkSoup.findAll('table')
tableCount = len(tables)
print("%d tables" % tableCount)
assert((tableCount % 2) == 0)

topLevelTag = 'registryObjects'

# catalogueInfoDict - dictionary of {"Number" : 6401.0, "Issue" : 9999mar%202012}
catalogueInfoDictList = populateCatalogueInfo(options.catalogue_info)
assert(catalogueInfoDictList is not None)

xmlOutFILE = openFile("ABS_RIFCS.xml", "w")

namespace = 'http://ands.org.au/standards/rif-cs/registryObjects'
doc = initDoc(namespace)
assert(doc is not None)

for catalogueInfoDict in catalogueInfoDictList:
    # Each set of two tables pertains to one web page, so deal with a set of two tables at a time
    # variables will contain data from the odd numbered tables - a dictionary of name, value pairs
    # crossWalk will contain data from the even numbered tables - a list of dictionaries where each dictionary is xpath, variable, property, regex
    xpathValueDictDict = dict()

    tableIndex = 0
    gen = generator()    
    while (tableIndex < (tableCount-1)):
        assert(catalogueInfoDict.has_key("Number"))
        
        if not catalogueInfoDict.has_key("Issue"):
            print("Error - unable to retrieve issue for catalogue number " + catalogueInfoDict["Number"])
            continue
        
        variables = getVariables(tables[tableIndex], catalogueInfoDict)
        #printDict(variables)
        persistentURI = variables["PersistentURI"]
        assert(persistentURI is not None)
        persistentURIResolved = resolveValue(persistentURI, variables)
        crosswalkDictList = getCrossWalkDictList(tables[tableIndex+1])
        print("crosswalkDictList - begin")
        printDictList(crosswalkDictList)
        print("crosswalkDictList - end")
        print("Opening %s" % persistentURIResolved)
        http = httplib2.Http()
        status, response = http.request(persistentURIResolved)
        print(status)
        soup = BeautifulSoup(response)
        populatexpathValueDict(gen, xpathValueDictDict, soup, variables, crosswalkDictList)
        print("xpathValueDictDict - begin")
        printDictDict(xpathValueDictDict)
        print("xpathValueDictDict - end")
        printStats(xpathValueDictDict, crosswalkDictList)
        tableIndex += 2

    populate(doc, namespace, xpathValueDictDict, xmlOutFILE)
    
print(doc.writexml(xmlOutFILE))
print("See ABS_RIFCS.xml for output")






























