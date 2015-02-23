# Input examples:
# --server 'services.ands.org.au/sandbox'
# --search_string bom,meteorology (optional - can be delimited by comma) 
# --data_source_key 'www.ala.org.au','aimsmest' (can be delimited by comma)
# --sort_by_tag 'originatingSource'
#
# For each datasource, runs:
#   https://services.ands.org.au/sandbox/orca/services/getRegistryObjects.php?source_key={datasource}&collections=collection&parties=party&activities=activity&services=service
#
#   and creates an output html file such as aimsmest_bom.html which contains details of each registry object for that
#   data source.  If a search_string was provided it only shows registry objects that contain that search string.
#
# Usage: python.exe FindStringinORCA --server services.ands.org.au/sandbox --data_source ala,'atlas of living australia' --search_string bom,meteorology
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
import re, htmlentitydefs
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse

def rifcsForDataSource(server, source):
    assert(source is not None)
    assert(len(source) > 0)

    uri = "https://%s/orca/services/getRegistryObjects.php?source_key=%s&activities=activity&collections=collection&parties=party&services=service"% (server, source)
            
    print(uri)
    xml = ET.parse(urllib.urlopen(uri))
    root = xml.getroot()  
    return root
    
def formatXpath(xpath):
    if xpath is None or (len(xpath) < 1):
        assert(0)
    
    xpath = xpath.replace('{0}', "")
    xpath = xpath.replace("./", "")
    return xpath
   
def writeElementToFile(searchList, root, gen, parent, child, outFile):
    assert(child is not None)
    assert(parent is not None)
    assert(searchList is not None)
    assert(gen is not None)
    assert(outFile is not None)
    
    assert(child.tag is not None)
    assert(len(child.tag) > 0)
    
    assert(parent.tag is not None)
    assert(len(parent.tag) > 0)
    
    nodeText = child.text
    
    optional = None
    if child.tag.find("key") > -1:
        if parent.tag.find("relatedObject") > -1:
           optional = optionalText(root, child)
           assert(optional is not None)
           assert(len(optional) > 0)
    
    if(len(child.items()) > 0):
        for attrName, attrVal in child.items():
            writeElementItemToFile(gen, searchList, ("%s/%s" % (parent.tag, child.tag)), attrName, attrVal, nodeText, None, outFile)            
    else:
       writeElementItemToFile(gen, searchList, ("%s/%s" % (parent.tag, child.tag)), None, None, nodeText, optional, outFile)            

def requiredInFile(tag, attrName, attrText, nodeText, optional):
    if tag.find("key") > -1:
        return 1
    
    if tag.find("originatingSource") > -1:
        return 1
        
    if tag.find("relation") > -1:
        return 1

    if optional is not None and len(optional) > 0:
        return 1
        
    if (tag == "registryObjects/registryObject") and (attrName == "group"):
        return 1
    
    return 0
    

# matchConcat: [collection/description/brief#This dataset contains meteorological and sea temperature data from the weather station moored on Myrmidon Reef on the Great Barrier Reef.][collection/description/full#Meteorological data pertaining to the ......]
    
def writeElementItemToFile(gen, searchList, tag, attrName, attrText, nodeText, optional, outfile):
    
    textToTest = {attrText, nodeText, optional}
    matchFound = 0
    for text in textToTest:
        matchFound = containsSearchString(searchList, text)

    # return if (searchList contains entries and match not found) and not required
    
    # If there are search strings:  only write the element if: it contains the search string; or it is required to be displayed
    # if there is no search list:  write every element (so that the html can be used to see all element information - not just for search-matching)
    
    # So: return if there's: a search list and no match; and this element is not required in the file
    if ((len(searchList) > 0) and (matchFound == 0)) and (requiredInFile(tag, attrName, attrText, nodeText, optional) == 0):
        return
        
    if ((gen.next() % 2) == 0):
        outfile.write("<tr class=\"alt\">")
    else:
        outfile.write("<tr>")

    outfile.write("<td class=\"col1\">%s</td>                 \
                <td class=\"col2\">%s</td>                 \
                <td class=\"col3%s\">%s</td>                 \
                <td class=\"col4%s\">%s</td>                 \
                <td class=\"col5%s\">%s</td>                 \
                </tr>\n" % ( \
                toValidString(tag), \
                toValidString(attrName), \
                classTypePostfix(searchList, attrText), toValidString(attrText), \
                classTypePostfix(searchList, nodeText), toValidString(nodeText), \
                classTypePostfix(searchList, optional), toValidString(optional))) 

def classTypePostfix(searchList, text):
    if containsSearchString(searchList, text) == 1:
        return "highlighted"

    return ""

def containsSearchString(searchList, text):
    if text is not None:
        for searchText in searchList:
            if text.lower().find(searchText.lower()) > -1:
                return 1

    return 0
       
def openFile(fileName, mode):
    file  = open(("output/"+fileName), mode)
    if file is None:
        print("Unable to open file %s for %s" % (fileName, mode))
        os.sys.exit(-1)
            
    print("Opened file %s for %s" % (fileName, mode))
    filesOpened.append(file)
    return file
    
    
def closeAllFiles():
    for openedFile in filesOpened:
        print("Closing file: %s" % openedFile)
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

    print("Error:  calling getObjectType on tag: %s" % ro.tag)        
    assert(0)

def isObjectType(ro, objectType):
    element = ro.find(('.//%s' % objectType))
    if element is None:
        return 0
        
    return 1
    
def iterparent(tree):
    for parent in tree.getiterator():
        for child in parent:
            yield parent, child

def writeToHTMLFile(count, searchlist, root, ro, outFile):
    outFile.write("<p>%d</p>" % count)
    outFile.write("<table id=\"objects\">           \
                    <tr>                            \
                        <th>node xPath</th>         \
                        <th>attribute name</th>     \
                        <th>attribute value</th>    \
                        <th>node value</th>         \
                        <th>related</th>            \
                    </tr>\n")

    gen = generator()    
    writeElementToFile(searchList, root, gen, root, ro, outFile) 
    for parent, child in iterparent(ro):
        #work on parent/child tuple    for c, p in parentMap:
        assert(child.tag is not None)
        assert(len(child.tag) > 0)
        assert(parent.tag is not None)
        assert(len(parent.tag) > 0)
        #print("%s, %s" % (parentTag, child.tag))
        writeElementToFile(searchList, root, gen, parent, child, outFile) 
        
    outFile.write("</table>")       
    outFile.write("<br></br>")  
    
    
# relatedObjectsConcat: [isManagedBy#AODN:adc@aims.gov.au#Data Manager, AIMS Data Centre {party}][owner#AODN:Australian Bureau of Statistics, National Information and Referral Service (NIRS)#NO RELATED OBJECT FOUND]

def getRelatedObjectConcat(ro, docRoot):
    #for all related objects
    
    concat = ""
    relatedObjects = ro.findall("./%s/relatedObject" % getObjectType(ro))
    for relatedObject in relatedObjects:
        concat += "["
        concat += getAttrVal(relatedObject, "./relation", "type")
        concat += "#"
        relatedKey = getElemText(relatedObject, "./key")
        assert(relatedKey is not None)
        concat += relatedKey
        concat += "#"
        concat += lookUp(docRoot, relatedKey)
        concat += "]"
        
    return concat

# elemDict is: {"tag" : val, "text": val, "attrName" : val, "attrValue" : val}
# elemDictList is a list of elemDict(s)
def getText(ro, searchList):
    dictList = list()
    for element in ro.getiterator():
        assert(element.tag is not None)
        assert(len(element.tag) > 0)

        #if there's a search list, only deal with ROs that contain text or attribute values 
        #containing the search text - otherwise, include everything
        if (searchList is not None) and (len(searchList) > 0):
            if containsMatch(element, searchList) == 0:
                continue

        assert(((searchList is None) or (len(searchList) <= 0)) or (containsMatch(element, searchList) == 1))
        dictionary = getElemDict(element)
        if dictionary is not None:
            dictList.append(dictionary)
    
    return dictList
  
# Stolen from  http://effbot.org/zone/re-sub.htm#unescape-html   

##
# Removes HTML markup from a text string.
#
# @param text The HTML source.
# @return The plain text.  If the HTML source contains non-ASCII
#     entities or character references, this is a Unicode string.
def strip_html(text):
    def fixup(m):
        text = m.group(0)
        if text[:1] == "<":
            return "" # ignore tags
        if text[:2] == "&#":
            try:
                if text[:3] == "&#x":
                    return unichr(int(text[3:-1], 16))
                else:
                    return unichr(int(text[2:-1]))
            except ValueError:
                pass
        elif text[:1] == "&":
            import htmlentitydefs
            entity = htmlentitydefs.entitydefs.get(text[1:-1])
            if entity:
                if entity[:2] == "&#":
                    try:
                        return unichr(int(entity[2:-1]))
                    except ValueError:
                        pass
                else:
                    return unicode(entity, "iso-8859-1")
        return text # leave as is
    return re.sub("(?s)<[^>]*>|&#?\w+;", fixup, text)
    
    
def formatText(text):
    text = toValidString(text)
    processed = sizedPrefix(strip_html(text), 2000)
    processed = processed.replace("\r", "")
    processed = processed.replace("\n", "")
    processed = processed.replace("\t", "")
    return processed

# return substring of first 'size' characters
def sizedPrefix(text, size):
    postFix = '..'
    returnText = (text[:size-len(postFix)] + postFix) if len(text) > size else text
    return returnText
    
def containsMatch(elem, searchList):
    if elem.items(): # has attributes
        if elem.text is not None:
            if (containsSearchString(searchList, elem.text) == 1):
                return 1

        for name, value in elem.items(): # for each attribute name and value
            if (containsSearchString(searchList, name) == 1) or (containsSearchString(searchList, value) == 1):
                return 1
    else: # has no attributes
        if(elem.text is not None):
            elemDict = dict()
            if (containsSearchString(searchList, elem.text) == 1):
                return 1                    
    
    return 0
    
def getElemDict(elem):
    # format is:  [tag#attrName:attrVal;attrName:attrVal...#text][...]
    if elem.items(): # has attributes
        elemDict = dict()
        elemDict["tag"] = toValidString(elem.tag)
        if elem.text is not None:
            elemDict["text"] = formatText(elem.text)
        
        numElems = len(elem.items())
        concatAttrNameVal = ""
        for name, value in elem.items(): # for each attribute name and value
            concatAttrNameVal += name
            concatAttrNameVal += ":"
            concatAttrNameVal += value
            numElems -= 1
            if numElems > 0:
                concatAttrNameVal += ";"
            
        elemDict["attrNameValConcat"] = toValidString(concatAttrNameVal)
        return elemDict
        
    # if this element has been matched, the match must be in the text if there are no attributes
    
    elemDict = dict()
    elemDict["text"] = formatText(elem.text)
    elemDict["tag"] = toValidString(elem.tag)
    return elemDict
                    
    assert(0)
                
         
def getDictVal(dictionary, key):
    assert(dictionary is not None)
    assert(key is not None)    
    try:
        value = dictionary[key]
    except KeyError:
        return " "
    else:
        return value
    return " "
    

def getMatchedTextConcat(dictList):
    assert(dictList is not None)
    assert(len(dictList) > 0)
    concat = ""
    for dictionary in dictList:
        concat += "["
        concat += getDictVal(dictionary, "tag")
        concat += '#'
        concat += getDictVal(dictionary, "attrNameValConcat")
        concat += '#'
        concat += getDictVal(dictionary, "text")
        concat += "]"
    return concat

def writeToCSVFile(searchList, docRoot, ro, csvFile):
    dictList = list()
    dictList = getText(ro, searchList)
    if (dictList is None) or len(dictList) == 0:
        return
    
    csvFile.write("%s|" % getElemText(ro, "./key"))
    csvFile.write("%s|" % getAttrVal(ro, ".", "group"))
    csvFile.write("%s|" % getElemText(ro, "./originatingSource"))
    csvFile.write("%s|" % getElemText(ro, ".//namePart"))
    csvFile.write("%s|" % getAttrVal(ro, ".//location", "dateFrom"))
    csvFile.write("%s|" % getAttrVal(ro, ".//location", "dateTo"))
    csvFile.write("%s|" % getRelatedObjectConcat(ro, docRoot))
    if searchList and len(searchList) > 0:
        assert(dictList is not None)
        assert(len(dictList) > 0)
        csvFile.write("%s|" % getMatchedTextConcat(dictList))
    csvFile.write("\n")
    
def getAttrVal(ro, xpathElem, attrName):
    elemList = ro.findall(xpathElem) # will sometimes be the same element
    attrValConcat = ""
    if elemList is not None:
        for elem in elemList:
            for name, val in elem.items():
                if name == attrName:
                    if val is not None:
                        if len(val) > 0:
                            attrValConcat += val
                            attrValConcat += "#"
                            
    if (len(attrValConcat) > 0):
        attrValConcat = attrValConcat.rstrip("#")
        
    return attrValConcat
   
def getElemText(ro, xpathElem):
    elemList = ro.findall(xpathElem) # will sometimes be the same element
    elemTextConcat = ""
    if elemList is not None:
        for elem in elemList:
            if elem.text is not None:
                if len(elem.text) > 0:
                    elemTextConcat += formatText(elem.text)
                    elemTextConcat += "#"
    
    if (len(elemTextConcat) > 0):
        elemTextConcat = elemTextConcat.rstrip("#")
        
    return elemTextConcat
      
# Find the registry object with this key and assemble text of info, e.g.:
# (namepart, electronic url)
def lookUp(docRoot, keyToMatch):
    # Find all registry objects with this key
    registryObjects = docRoot.findall(".//registryObject")
    assert(len(registryObjects) > 0)
    for ro in registryObjects:
        # if key matches the key provided
        keyElem = ro.find('key')
        if keyElem is None:
            print("No key!")
            assert(0)
        
        if keyToMatch == keyElem.text:
            # We have found a registry object that matches the key provided, so: get its name part
            return ("%s {%s}" % (getElemText(ro, ".//namePart"), getObjectType(ro)))
 
#    print("No related object found with key %s" % keyToMatch)
    try:
        index = noRelatedObjectKeys.index(keyToMatch)
    except ValueError: # keyToMatch is not in list, so add it
        noRelatedObjectKeys.append(keyToMatch)
        
    result = "NO RELATED OBJECT FOUND"
    return result.encode('utf-8')
    
def optionalText(docRoot, element):
    assert(element is not None)
    assert(element.text is not None)
    assert(len(element.text) > 0)
    assert(element.tag is not None)
    assert(element.tag.find("key") > -1)
    result = lookUp(docRoot, element.text)
    assert(result and len(result) > 0)
    return result
    
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

def extractAlphanumeric(inputString):
    from string import ascii_letters, digits
    return "".join([ch for ch in inputString if ((ch == '.') or (ch in (ascii_letters + digits)))])

def writeHeaderPerRO(ro):
    key = ro.findtext('./{0}key'.format(namespace))
    group = ro.get('group')
    originatingSource = ro.findtext('./{0}originatingSource'.format(namespace))
    
def constructOutputFileName(source, localSearchList, localSortList):

    if (source is None): 
        source = 'Source_InputXML'

    # strip the 'https:' or 'http:' bit
    if source.find(':') > -1:
        source = source.split(':')[1]
        assert(source is not None)
        assert(len(source) > 0)
    fileName = extractAlphanumeric(source)
    
    if localSearchList is not None:
        if len(localSearchList) > 0:
            fileName += "_SEARCH"
        for searchString in localSearchList:
            if searchString and len(searchString) > 0:
                fileName += ('_%s' % searchString)
                
    if localSortList is not None:
        if len(localSortList) > 0:
            fileName += "_SORT"
        for sortString in localSortList:
            if sortString and len(sortString) > 0:
                fileName += ('_%s' % sortString.split('}')[1])                
    
    return fileName
    
def createFiles(localSearchList, localSortList, source, server, ext):
    fileList = {}
    fileName = constructOutputFileName(source, localSearchList, localSortList)
    for objectType in objectTypes:
        print("Creating file for object type: %s" % objectType)
        tempFile = openFile(('%s_%s.%s' % (fileName, objectType.upper(), ext)), "w")
        assert(tempFile is not None)
        fileList[objectType] = tempFile
        
    return fileList
    
def writePreFileContent(fileList):
    for k, v in fileList.iteritems():
        v.write("<html>\n");
        writeHeadToFile(v)
        v.write("<body>\n");

def writePostFileContent(fileList):
    for k, v in fileList.iteritems():
        v.write("</body>\n");
        v.write("</html>\n");

def writeHeader(ro, csvFileList):
    if (headerWritten[getObjectType(ro)] == 0):
        csvFileList[getObjectType(ro)].write("key|group|originatingSource|namePart|dateFrom|dateTo|[relatedType#relatedKey#relatedName]|[tag#attrName#attrVal#text]\n")
        headerWritten[getObjectType(ro)] = 1

def parseRIFCSForSearchString(docRoot, searchList, sortByTagList, source=None, server=None):   
    assert(docRoot is not None)
    htmlFileList = createFiles(searchList, sortByTagList, source, server, "html")
    csvFileList = createFiles(searchList, sortByTagList, source, server, "csv")
    writePreFileContent(htmlFileList)
    
    registryObjects = docRoot.findall(".//registryObject")
    totalRegistryObjects = len(registryObjects)
    registryObjectsRemaining = len(registryObjects)
    
    countPerType = {'party' : 0, 'collection' : 0, 'activity' : 0, 'service' : 0}
    
    print("%d registryObjects found" % len(registryObjects))
    for ro in registryObjects:
        writeHeader(ro, csvFileList)
        print("%d registry objects remaining..." % registryObjectsRemaining)
        roType = getObjectType(ro)
        countPerType[roType] = countPerType[roType] + 1
        writeToHTMLFile(countPerType[roType], searchList, docRoot, ro, htmlFileList[roType])
        writeToCSVFile(searchList, docRoot, ro, csvFileList[getObjectType(ro)])
        registryObjectsRemaining -= 1
        
    writePostFileContent(htmlFileList)
    print("%d registryObjects processed" % totalRegistryObjects)
        
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
font-size:1em; \
text-align:left; \
padding-top:2px; \
padding-bottom:2px; \
background-color:#2179BF; \
color:#ffffff; \
} \
#objects tr.alt td \
{ \
background-color:#EAF2D3; \
} \
#objects td.col1 \
{ \
width:15% \
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
width:35% \
} \
#objects td.col5 \
{ \
width:35% \
} \
#objects td.col3highlighted \
{ \
color:red \
} \
#objects td.col4highlighted \
{ \
color:red \
} \
#objects td.col5highlighted \
{ \
color:red \
} \
</style> \
</head>")


def getKey(elem):
    global sortByTagList
    assert(len(sortByTagList) > 0)
    sortTextList = list()
    for sortString in sortByTagList:
        sortText = elem.findtext(sortString, "").lower()
        if sortText.find("http://") > -1:
            sortText = sortText.replace("http://", "")
        if sortText.find("www.") > -1:
            sortText = sortText.replace("www.", "")
        print("sortString %s, sortingText: %s" % (sortString, sortText))
        sortTextList.append(sortText)
    assert(len(sortTextList) == len(sortByTagList))
    t = tuple(sortTextList)
    assert(len(t) == len(sortTextList))
    return t

def getSortByTagList(sort_by_tag_list):
    if sort_by_tag_list is None:
        print("No sort required")
        return None

    if len(sort_by_tag_list) < 1:
        print("No sort required")
        return None
        
    tempList = sort_by_tag_list.split(',')
    for temp in tempList:
        temp = ('.//{0}%s' % temp.strip()).format(namespace)
        sortByTagList.append(temp) # strip leading and trailing whitespace
        print("Sorting on: %s" % temp)

    assert(len(sortByTagList) == len(tempList))
    return sortByTagList
    
def addItemToXmlOut(xmlOut, item):
    itemTag = item.tag.split('}')[1]
    xmlOut.target.start(itemTag, dict(item.items()))
    
    if item.text is not None:
        if len(item.text) > 0:
            xmlOut.target.data(item.text)
            
    for child in item.getchildren():
        addItemToXmlOut(xmlOut, child)
        
    xmlOut.target.end(itemTag)

def createXMLOut(tree):
    assert(tree is not None)
    
    # Contain all registryObject entities
    container = tree.findall('.//{0}registryObject'.format(namespace))
    assert(container is not None)
    assert(len(container) > 0)
    print("%d items in container, to sort" % len(container))
    
    xmlOut = ET.XMLParser()

    root = tree.getroot()
    rootTag = root.tag.split('}')[1]
    registryObjectsDictionary = {'xmlns': 'http://ands.org.au/standards/rif-cs/registryObjects', \
                                 'xsi:schemaLocation': 'http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd', 
                                 'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 
                                 'xmlns:rif': 'http://ands.org.au/standards/rif-cs/registryObjects'}

    startId = xmlOut.target.start(rootTag, registryObjectsDictionary)
    
    # Sort registryObject entities if necessary
    if (sortByTagList is not None):
        if (len(sortByTagList) > 0):
            container[:] = sorted(container, key=getKey)

    # Construct xmlOut from container entities (sorted or not)
    for item in container:
        addItemToXmlOut(xmlOut, item)
        
    xmlOut.target.end(rootTag)
    return xmlOut.target.close() # returns root element
    
def processTree(tree, server=None, source=None):
    assert(tree is not None)
    sortByTagList = getSortByTagList(options.sort_by_tag)
    tree = createXMLOut(tree)
    parseRIFCSForSearchString(tree, searchList, sortByTagList, source, server)

# Get server and string from command line
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--server", action="store", dest="server", help="server, e.g. 'services.ands.org.au/sandbox'")
parser.add_option("--input_xml", action="store", dest="input_xml", help="input_xml, rifcs output from web services")
parser.add_option("--data_source_key", action="store", dest="data_source_key", help="data source string, e.g. ALA,Atlas of Living Australia")
parser.add_option("--search_string", action="store", dest="search_string", help="string(s) that you are searching for, delimited by comma e.g. bom,meteorology")
parser.add_option("--sort_by_tag", action="store", dest="sort_by_tag", help="tag of element by which you'd like the registry objects to be sorted e.g. 'originatingSource'")

(options, args) = parser.parse_args()

# Store search_string
searchList = list()
if options.search_string:
    if len(options.search_string) > 0:
        tempList = options.search_string.split(',')
        for temp in tempList:
            searchList.append(temp.strip()) # strip leading and trailing whitespace

for searchString in searchList:
    print("searching for: %s" % searchString)
    
    
namespace = "{http://ands.org.au/standards/rif-cs/registryObjects}"    
filesOpened = list()

noRelatedObjectFoundFile = openFile("summary_no_related_object_found.txt", "a")
unencodeableTextFoundFile = openFile("summary_unencodeable_text_found.txt", "a")

noRelatedObjectKeys = list() # contains all keys for which no related object could be found in the current feed
sortByTagList = list()

objectTypes = {'party', 'collection', 'service', 'activity'}

headerWritten = {'party' : 0, 'collection': 0, 'service' : 0, 'activity' : 0}

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
    
    requiredDataSourceList = list() # empty list
    # Store data_source_key
    if options.data_source_key:
        if len(options.data_source_key) > 0:
            tempList = options.data_source_key.split(',')
            for temp in tempList:
               requiredDataSourceList.append(temp.strip()) # strip leading and trailing whitespace
            
    for source in requiredDataSourceList:
        assert(source)
        assert(len(source) > 0)
   
        print("Processing DataSource: %s\n" % source)
        searchStringFoundFile.write("DataSource: %s\n" % source)
        noRelatedObjectFoundFile.write("DataSource: %s\n" % source)
        tree = rifcsForDataSource(server, source)
        processTree(tree, server, source)
        
        searchStringFoundFile.write("\n")
            
# input_xml supplied
if options.input_xml:
    if options.server:
        print("Ignoring server because input_xml supplied")

    if options.data_source_key:
        print("Ignoring data_source_key because input_xml supplied")
    
    input_XML = options.input_xml

    tree = ET.parse(options.input_xml)   
    processTree(tree)

for key in noRelatedObjectKeys:
    noRelatedObjectFoundFile.write("%s\n" % key)
    
closeAllFiles()


