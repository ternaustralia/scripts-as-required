import os
import string
from types import *
import urllib
import StringIO
import xml.etree.ElementTree as xml
from elementtree.SimpleXMLWriter import XMLWriter
namespace = "{http://ands.org.au/standards/rif-cs/registryObjects}"  

def addItemToXmlOut(item):
    itemTag = item.tag.split('}')[1]
    xmlOut.target.start(itemTag, dict(item.items()))
    
    if item.text is not None:
        if len(item.text) > 0:
            xmlOut.target.data(item.text)
            
    for child in item.getchildren():
        addItemToXmlOut(child)
        
    xmlOut.target.end(itemTag)
        
    return itemTag
    
    
def sort(tree):
    assert(tree is not None)
    container = tree.findall('.//{0}registryObject'.format(namespace))
    assert(container is not None)
    assert(len(container) > 0)
    print("%d items in container, to sort" % len(container))
    container[:] = sorted(container, key=getKey)
    return container
    
    
def getKey(elem):
    global sortByTagList
    assert(len(sortByTagList) > 0)
    sortTextList = list()
    for sortString in sortByTagList:
        sortText = elem.findtext(sortString, "").lower()
        print("sortString %s, sortingText: %s" % (sortString, sortText))
        sortTextList.append(sortText)
    assert(len(sortTextList) == len(sortByTagList))
    t = tuple(sortTextList)
    assert(len(t) == len(sortTextList))
    return t


namespace = "{http://ands.org.au/standards/rif-cs/registryObjects}"    
xmlIn = xml.parse("../../AIHW/AIHW_RIFCS_20110929_TestSort.xml")   
#xmlOut = XMLWriter("TestSorted.xml") # constructed for output
xmlOut = xml.XMLParser()

root = xmlIn.getroot()
rootTag = root.tag.split('}')[1]
registryObjectsDictionary = {'xmlns': 'http://ands.org.au/standards/rif-cs/registryObjects', \
                             'xsi:schemaLocation': 'http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd', 
                             'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 
                             'xmlns:rif': 'http://ands.org.au/standards/rif-cs/registryObjects'}

startId = xmlOut.target.start(rootTag, registryObjectsDictionary)

sortByTagList = list()
sortByTagList.append('.//%soriginatingSource' % namespace)
sortByTagList.append('.//%skey' % namespace)

container = sort(xmlIn)

for item in container:
    addItemToXmlOut(item)

xmlOut.target.end(rootTag)
root = xmlOut.target.close()

registryObjects = root.getchildren()
registryObjectsRemaining = len(registryObjects)
print("%d registryObjects found" % len(registryObjects))
for ro in registryObjects:
    print("%d registry objects remaining..." % registryObjectsRemaining)
    print("tag: %s" % ro.tag)
    key = ro.find('.//key')
    print(key.text)
    originatingSourceElem = ro.find('.//originatingSource'.format(namespace))
    print(originatingSourceElem.text)
    registryObjectsRemaining -= 1

#print("output is in TestXMLSorted.xml")

    


