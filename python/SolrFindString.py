# Goes through collection records for a datasource storing the name of each (displayTitle in SOLR)
# Then goes looking for other collection records of the same displayTitle but from another datasource
# Prints all results in csv.  Displays details of all record with that displayTitle so you can see from which datasources
#Usage: SolrFindString.py [options] arg1

#Options:
#  -h, --help            show this help message and exit
# --csv_file=CSV_FILE
#                        e.g text.csv containing all text values from
#                        datasource X - you can provide a data_source instead
#                        if you want the text values to be looked up for
#                        you - in format:
#key|originating_source|group|class|type|date_modified|status|reverseLinks|data_source_key|displayTitle|listTitle|alt_listTitle|alt_displayTitle|name_part_type|name_part|location|relatedObject_key|relatedObject_relatedObjectClass|relatedObject_relatedObjectType|relatedObject_relatedObjectListTitle|relatedObject_relatedObjectDisplayTitle|relatedObject_relation|relatedObject_relatedObjectLogo|relatedObject_relation_description|description_value|description_type|subject_value|subject_type|relatedInfo|dateFrom|dateTo|identifier_value|identifier_type|spatial_coverage|spatial_coverage_center|text|fulltext
#  --data_source=DATA_SOURCE
#                        e.g aodn.org.au - the datasource from which all the
#                        text were retrieved
#  --server=SERVER       e.g ands2.anu.edu.au/solr-prod or
#                        test.ands.org.au:8080/solr

import os
import time
import re, htmlentitydefs
import string
from types import *
from optparse import OptionParser
import urllib
import StringIO
from elementtree import ElementTree as ET
from elementtree.ElementTree import parse

import sys

   
def openFile(fileName, mode):
    file  = open(fileName, mode)
    if not file:
        print("Unable to open file %s for %s" % (fileName, mode))
        sys.exit(-1)
            
    return file;
    
def xmlRootFromURI(uri):
    print("Opening uri: %s" % uri)
    try:
        xml = ET.parse(urllib.urlopen(uri))
    except Exception as e:
        print("Unable to parse XML at uri: %s - %s" % (uri, e))
        sys.exit(-1)
    
    return xml.getroot() 

def generator(limit=100000):
    n = 0
    while n < limit:
       n+=1
       yield n
       
      
def getTextLine(element):
    if (element.text is not None) and (len(element.text) > 0):
        return formatText(element.text)
    return None

def fullText(parent):
    rowText = ''
    parentText = getTextLine(parent)
    if(parentText is not None):
        assert(len(parentText) > 0)
        rowText += parentText
        
    for child in parent.getchildren():
        childText = getTextLine(child)
        if(childText is not None):
            assert(len(childText) > 0)
            if len(rowText) > 0:
                rowText += ' '
            rowText += childText
        
    return rowText
       
    
def writeToFile(doc, csvFile, fieldNameList):
    dictForFileLine = dict()
    
    for child in doc.getchildren():
        for attributeName, attributeValue in child.items():
            dictForFileLine[attributeValue] = fullText(child)
            
    
    elemTextAppended = ""
    for field in fieldNameList:
        value = ""
        if dictForFileLine.has_key(field):
            value = dictForFileLine[field]
            
        elemTextAppended += value
        elemTextAppended += '|' # append as placeholder even if no text to follow
            
    if(len(elemTextAppended) > 0):
        assert(elemTextAppended[len(elemTextAppended)-1] == ('|'))
        elemTextAppended = elemTextAppended[0:-1]
        
    csvFile.write("%s\n" % elemTextAppended)
        
    csvFile.flush()
    os.fsync(csvFile)
    
attributeValueDict = {"0":"displayTitle","1":"dateFrom","2":"dateTo"}

def dictHasValue(dictionary, value):
    for k, v in dictionary.iteritems():
        if v == value:
            return 1
    
    return 0
    
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
    
# return substring of first 'size' characters
def sizedPrefix(text, size):
    postFix = '..'
    returnText = (text[:size-len(postFix)] + postFix) if len(text) > size else text
    return returnText
  
def formatText(text):
    if text is None:
        return ""
        
    processed = sizedPrefix(strip_html(text), 2000)
    processed = processed.replace("\r", "")
    processed = processed.replace("\n", "")
    processed = processed.replace("\t", "")
    processed = processed.replace("|", "") # Take these out because they are our delimiters in csv
    
    try:
        processed = processed.encode('utf-8')
        processed = processed.strip() # remove leading and trailing whitespace characters
        if len(processed) > 0:
            return processed;
    except:
        print("Error - exception caught when attempting to encode: %s" % string)
        unencodeableTextFoundFile.write("Unable to encode: %s\n\n" % string)
        return 'Unable to encode'

    assert(0)
    
def valueAtIndex(i, textList):
    if i < len(textList):
        return textList[i]
    
    return None
 
   
def textDictFromLine(line):
    textDict = dict()
    textList = line.split('|')
    assert(textList is not None)
    assert(len(textList) > 1)
    assert(len(textList) < 4)
    assert(len(textList) == 3) # to remove once tested
    
    for i in range(0,3):
        attributeValue = attributeValueDict[str(i)]
        assert(attributeValue is not None)
        assert(len(attributeValue) > 0)
        text = valueAtIndex(i, textList)
        i = i+1
        if text is not None:
            textDict[attributeValue] = text
        else:
            textDict[attributeValue] = ""
    
    return textDict    

def columnsHeadersMatchFieldNameList(line, fieldNameList):
    columnHeaders = line.split('|')
    assert(len(columnHeaders) == len(fieldNameList))
    for i in range(0, len(columnHeaders)):
        fieldName = fieldNameList[i].strip()
        columnHeader = columnHeaders[i].strip()
        if(fieldName != columnHeader):
            print("Error: fieldNameList[%d] %s != columnHeaders[%d] %s" % (i, fieldName, i, columnHeader))
            assert(0)
            return 0
     
    return 1
     
def textDictListFromFile(fileName, fieldNameList):

    textDictList = list()
    textFile = openFile(fileName, "r")
    confirmed = 0
    lineCount = -1
    for line in textFile:    
        lineCount += 1
        textDict = dict()
        if line is None:
            return textDictList
        
        if len(line) <= 0:
            return textDictList

        if lineCount == 0:
            assert(line is not None)
            assert(len(line) > 0)
            assert(columnsHeadersMatchFieldNameList(line, fieldNameList) == 1)
            if(columnsHeadersMatchFieldNameList(line, fieldNameList) == 0):
                return list()
            confirmed = 1
            continue

        
        textList = line.split('|')
        if(len(textList) != len(fieldNameList)):
            print("Error - number of text values %d is not equal to number of fieldNames %d" % (len(textList), len(fieldNameList)))
            assert(0)
            return list()
            
        index = 0
        for text in textList:
            assert(index < len(fieldNameList))
            textDict[fieldNameList[index]] = text
            index += 1

        assert(textDict is not None)
        textDictList.append(textDict)
       
    assert(lineCount > 0)
    assert(len(textDictList) == lineCount)
    return textDictList
       
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--text", action="store", dest="text", help="e.g text.txt containing all values from datasource X - you can provide a data_source instead with if you want the text to be looked up for you - in format \"{displayTitle}|{dateFrom}|{dateTo}\"")
parser.add_option("--data_source", action="store", dest="data_source", help="e.g aodn.org.au - the datasource from which all the text were retrieved (you can provide --values instead if you prefer that we don't query the data source (one you prepared earlier?)")
parser.add_option("--server", action="store", dest="server", help="e.g ands2.anu.edu.au/solr-prod or test.ands.org.au:8080/solr")


(options, args) = parser.parse_args()

# Validate options
if options.data_source and options.text:
    parser.error("Please provide either values or data_source, but not both.  Try --help for usage")
    sys.exit(-1)

if (not options.data_source) and (not options.text):
    parser.error("Requires either data_source or values.  Try --help for usage")
    sys.exit(-1)

if not options.server:
    parser.error("Requires server.  Try --help for usage")
    sys.exit(-1)


FILE_csv_out_duplicate = openFile("SolrQueryResultsDuplicateTitlesFromQuery.csv", "w")
attrValuesWritten = 0

def schemaFieldNames(server):
    fieldNameList = list()
    uri = "http://" + server + "/admin/file/?contentType=text/xml;charset=utf-8&file=schema.xml"
    root = xmlRootFromURI(uri) 
    assert(root is not None)
        
    fieldList = root.findall('.//field')
    assert(fieldList is not None)
    assert(len(fieldList) > 0)
    for field in fieldList:
        name = field.get('name')
        assert(name is not None)
        assert(len(name) > 0)
        fieldNameList.append(name)
        print("Appending %s to fieldNameList" % name)
        
    assert(len(fieldNameList) > 0)
    return fieldNameList
    
    
def writeFieldNamesToFile(FILE, fieldNameList):
    fieldsConcat = ""
    for field in fieldNameList:
        fieldsConcat += field
        fieldsConcat += '|'

    if(len(fieldsConcat) > 0):
        assert(fieldsConcat[len(fieldsConcat)-1] == ('|'))
        fieldsConcat = fieldsConcat[0:-1]

    FILE.write("%s\n" % fieldsConcat)
    
def numFound(root):
    result = root.find('./result')
    assert(result is not None)
    numFound = result.get('numFound')
    assert(numFound is not None)
    total = int(numFound)
    print("total: %d" % total)
    return total
    
total = -1
rowsRetrieved = 0
textDictList = list()
schemaFieldNameList = schemaFieldNames(options.server)
assert(schemaFieldNameList is not None)
assert(len(schemaFieldNameList) > 0)
    
if (options.data_source is not None) and (len(options.data_source) > 0):
    FILE_csv_out = openFile("SolrQueryResults.csv", "w")
    writeFieldNamesToFile(FILE_csv_out, schemaFieldNameList)
    while (total == -1) or (rowsRetrieved < total):
        uri = "http://" + str(options.server) + "/select/?q=class%3Acollection+%0D%0Adata_source_key%3A\"" + str(options.data_source) + "\"&version=2.2&start=" + str(rowsRetrieved) + "&rows=" + str(10) + "&indent=on"
        
        root = xmlRootFromURI(uri) 
        assert(root is not None)
        
        if rowsRetrieved == 0:
            total = numFound(root)

        docList = root.findall('.//doc')
        assert(docList is not None)
        assert(len(docList) > 0)
        
        rowsRetrieved = len(docList)
        for doc in docList:
            writeToFile(doc, FILE_csv_out, schemaFieldNameList)
            textDict = dict()
            for child in doc.getchildren():
                for attributeName, attributeValue in child.items():
                    text = fullText(child)
                    textDict[attributeValue] = text

            textDictList.append(textDict)
            
        print("Remaining: %d" % (total - rowsRetrieved))
else:
    # no data_source provided, so populate list from text file instead
    textDictList = textDictListFromFile(options.text, schemaFieldNameList)
    
totalCollectionsThatRepeat = 0
if (textDictList is None) or (len(textDictList) <= 0): 
    print("No values in file")
    sys.exit(-1)
 
total = -1
rowsRetrieved = 0
repeatingCollectionTitles = list()  
totalRepeatingCollections = 0 # total number of collections (per displayTitle) that appear more than once
print("Num values: " + str(len(textDictList)))
writeFieldNamesToFile(FILE_csv_out_duplicate, schemaFieldNameList)
for textDict in textDictList:
    print("Processing displayTitle: %s" % textDict["displayTitle"])
    rowsRetrieved = 0
    totalTimeThisCollectionAppears = 0
    
    # Loop through all pages to get all collections with this displayTitle
    while (total == -1) or (rowsRetrieved < total):
        uri = "http://" + str(options.server) + "/select/?q=class%3Acollection%0D%0AdisplayTitle%3A\"" + textDict["displayTitle"] + "\"&version=2.2&start=" + str(rowsRetrieved) + "&rows=" + str(10) + "&indent=on"
        
        root = xmlRootFromURI(uri) 
        
        if rowsRetrieved == 0:
            total = numFound(root)

        docList = root.findall('.//doc')
        assert(docList is not None)
        assert(len(docList) > 0)
        
        rowsRetrieved = len(docList)
        if (rowsRetrieved > 1): # more than one collection with this displayTitle
            totalTimeThisCollectionAppears += len(docList)
        
            for doc in docList:
                writeToFile(doc, FILE_csv_out_duplicate, schemaFieldNameList)
            
        print("Remaining: %d" % (total - rowsRetrieved))
        

    assert(textDict.has_key("displayTitle"))
    if textDict["displayTitle"] in repeatingCollectionTitles:
        totalRepeatingCollections += 1
        print("Collection with name [%s] appears %s time(s)" % (textDict["displayTitle"] , totalTimeThisCollectionAppears))
        print("%s collections appear more than once (so far)" % totalRepeatingCollections)
            

FILE_csv_out_duplicate.close()
FILE_csv_out.close()

if (options.data_source is not None) and (len(options.data_source) > 0):
    print("See SolrQueryResults.csv for collections from datasource " + str(options.data_source))
    
print("See SolrQueryResultsDuplicateTitlesFromQuery.csv for any duplicate collection in RDA")
    


