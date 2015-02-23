# Uses ABS Webservice to obtain TimeSeries CatalogueNumbers, then retrieves latest issue date from ABS Web Site www.abs.gov.au
#
# dictCatCatalogueNumbers e.g. {1 : ListOfCatalogueNumbersStartingWith1, 2 : ListOfCatalogueNumbersStartingWith2, ... }
# For each catNum in range (1 to 9)
#   catalogueNumbers - list for one cat num only, e.g. for catNum 6: {6321.0.55.001, 6354.0, 6416.0}
#   topRootXML = open http://ausstats.abs.gov.au/servlet/TSSearchServlet?&catno={catNum}* 
#   numPages = readNumPages(topRootXML)
#   for pageNum in range (1 to numPages)
#       pageRootXML = open http://ausstats.abs.gov.au/servlet/TSSearchServlet?&catno={catNum}*&pg=pageNum 
#       appendCatalogueNumbers(pageRootXML, catalogueNumbers)
# 

import os
import sys
import StringIO
import urllib
import httplib2
from BeautifulSoup import BeautifulSoup, SoupStrainer         # For processing HTML
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse
import re

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

def xmlRootFromURI(uri):
    print("Opening uri: %s" % uri)
    try:
        xml = ET.parse(urllib.urlopen(uri))
    except Exception as e:
        print("Unable to parse XML at uri: %s - %s" % (uri, e))
        return None
    
    return xml.getroot() 

def readNumPages(rootXML):
    numPagesText = rootXML.findtext("NumPages")
    
    if(numPagesText is not None):
        if(len(numPagesText) > 0):
            return int(numPagesText)

    return 0
    
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
            extracted = result.rstrip()
            print("extracted %s" % extracted)
            return extracted
            
    print("Error - nothing extracted from %s for pattern %s" % (string, pattern))
    assert(0) # no result extracted
    
# Get the issueDate for this product
def issueDate(catalogueNumber):
    http = httplib2.Http()
    status, response = http.request("http://abs.gov.au/%2Fausstats%2Fabs%40.nsf%2Fmf%2F" + catalogueNumber)
    
    for link in BeautifulSoup(response, parseOnlyThese=SoupStrainer('a')):
        assert(link is not None)
        if link.text is None:
            continue
            
        if (link.text.find("About this Release") >= 0):
            if link.has_key("href"):
                href = link.get("href")
                assert(href is not None)
                return extract(href, "(?<=Features)([\w.@\-%\s,]+)(?=\?open)")
    
    print("Error - no \"About this Release\" found for catalogue number " + catalogueNumber)
    return None
    
def duplicate(catalogueInfoList, catalogueNumber):
    for catalogueInfo in catalogueInfoList:
        if catalogueInfo.find(catalogueNumber) >= 0:
            return 1
            
    return 0
    
def appendCatalogueNumbers(pageRootXML, catalogueNumberList):
    assert(pageRootXML is not None)
    catalogueNumberElementsList = pageRootXML.iter("ProductNumber")
    for catalogueNumberElement in catalogueNumberElementsList:
        catalogueNumber = catalogueNumberElement.text
        assert(catalogueNumber is not None)
        if catalogueNumber is not None:
            if catalogueNumber not in catalogueNumberList:
                issue = issueDate(catalogueNumber)
                catalogueNumberList.append(catalogueNumber)
                catalogueInfo = catalogueNumber
                if issue is not None:
                    catalogueInfo += "|" 
                    catalogueInfo += issue
                writeToFile(catalogueNumbersFILE, catalogueInfo)

def writeToFile(f, string):
    f.write("%s\n" % string)   
    f.flush()
    os.fsync(f)


# dictCatCatalogueNumbers e.g. {1 : "ListOfProductsForCatNum1", 2 : ListOfProductsForCatNum2, 3 : ListOfProductsForCatNum3}...
# For each catNum in range (1 to 9)
catalogueNumbersFILE = openFile("CatalogueNumbers.txt", "w")
for catNum in range(1, 10):
    catalogueNumberList = list()
    uriCat = ("http://ausstats.abs.gov.au/servlet/TSSearchServlet?&catno=%s*" % catNum)
    topRootXML = xmlRootFromURI(uriCat)
    if topRootXML is None:
        continue

    numPages = readNumPages(topRootXML)
    print("%s pages for catalogue number %d" % (numPages, catNum))
    if numPages <= 0:
        continue
    
    for pageNum in range (1, numPages):
        uriPage = ("http://ausstats.abs.gov.au/servlet/TSSearchServlet?&catno=%s*&pg=%s" % (catNum, pageNum))
        pageRootXML = xmlRootFromURI(uriPage)
        if pageRootXML is None:
            continue
        appendCatalogueNumbers(pageRootXML, catalogueNumberList)
    
    
    
catalogueNumbersFILE.close()

