# Input:  
# File e.g. --input ../../EXAMPLE.xml 

# Process:
# Takes an XML file: removes all HTML Markup; and converts all text to utf-8.

# Output:  
# XML that reflects the original except all HTML Markup rendered and text converted to utf-8

import sys
from optparse import OptionParser
import sys
from elementtree import ElementTree as ET
import StringIO
import urllib
import HTMLParser
from elementtree.ElementTree import parse
from elementtree.SimpleXMLWriter import XMLWriter
import re, htmlentitydefs
#ET.XMLTreeBuilder = SimpleXMLTreeBuilder.TreeBuilder

htmlParser = HTMLParser.HTMLParser()

def addObjectToTree(child, close=1):
    global xmlWriter 
    global FILE_out_debug
    
    if child is None:
        return
        
    if child.tag is None:
        return
        
    if len(child.tag) < 1:
        return
        
    #remove namespace from tag
    tag = child.tag.split('}')[1]
        
    FILE_out_debug.write("Tag: <%s>\n" % tag)
    
    childDictionary = {}
    for k, v in child.items():
        FILE_out_debug.write("Dictionary - k:%s, v:%s\n" % (k,v))
        if v != "en":
            childDictionary[k] = v
        
    
    #Write object to tree
    xmlWriter.start(tag, childDictionary)
    
    if child.text is not None:
        if len(child.text) > 0:
            text = strip_html(child.text)
            #text = text.encode('ascii', 'xmlcharrefreplace')
            text = child.text.encode('utf-8')
            xmlWriter.data(text)
            FILE_out_debug.write("Text: <%s>\n" % text)

    grandChildren = child.getchildren()
    for grandChild in grandChildren:
        #recurse
        addObjectToTree(grandChild)
    if close == 1:
        xmlWriter.end(tag)
    
def writeObjects(inputFile):
    global xmlWriter 
    print("Opening inputFile: %s" % inputFile)
    xml = ET.parse(inputFile)
    root = xml.getroot() # get 
    assert(root)
    rootTag = root.tag.split('}')[1]
    addObjectToTree(root, 0)
    children = root.getchildren()
    
    for child in children:
        print("ChildTag: %s" % child.tag)
        global countObjects
        countObjects += 1
        addObjectToTree(child)
   
    xmlWriter.end(rootTag)

def openFile(fileName, mode):
    print("Opening: %s" % fileName)
    file  = open(fileName, mode)
    if not file:
        print("Unable to open file %s for %s" % (fileName, mode))
        sys.exit(-1)
            
    return file;
    

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
    
# define globals (_I_ know; but it's Python and it's not hurting anyone)            
listIndex = 0
countObjects = 0

# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--input", action="store", dest="file_input", help="uri of OAI-PMH data source, e.g. http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh")

(options, args) = parser.parse_args()

# Validate data source uri
if not options.file_input:
    parser.error("Requires input file.  Try --help for usage")
    sys.exit(-1)
    
if len(options.file_input) < 1:
    parser.error("Requires input file.  Try --help for usage")
    sys.exit(-1)
    
inputFile = options.file_input

# Open outputFiles    

outputFileName = inputFile.split('.')[0]+"_HTMLMarkupRendered.xml"
FILE_out_tree = openFile(outputFileName, "w")
FILE_out_debug = openFile("RenderHTMLMarkupWithinXMLDebug.xml", "w")

xmlWriter = XMLWriter(FILE_out_tree) # constructed for output

writeObjects(inputFile)
   
FILE_out_tree.close()
FILE_out_debug.close()

print("Found %d objects" % countObjects)
print("Output is in %s" % outputFileName)




