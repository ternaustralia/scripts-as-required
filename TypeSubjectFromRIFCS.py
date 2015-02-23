# TypeSubjectFromRIFCS.py takes input xml in RIFCS format and outputs subjectType and subjectText to .csv file per line as:
# subjectType|subjectText
#
#
#Usage: TypeSubjectFromRIFCS.py [options] arg1
#
#Options:
#  -h, --help            show this help message and exit
#  --input_xml=INPUT_XML
#                        e.g ExampleRIFCS.xml - xml in RIFCS format


import os
import string
from types import *
from optparse import OptionParser
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse


def openFile(fileName, mode):
    file  = open(("output/"+fileName), mode)
    if file is None:
        print("Unable to open file %s for %s" % (fileName, mode))
        os.sys.exit(-1)
            
    print("Opened file %s for %s" % (fileName, mode))
    return file

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--input_xml", action="store", dest="input_xml", help="e.g ExampleRIFCS.xml - xml in RIFCS format")

(options, args) = parser.parse_args()

# Validate options
if not options.input_xml:
    parser.error("Requires input_xml.  Try --help for usage")
    sys.exit(-1)
 
assert(options.input_xml.count(".") > 0)   # expect a . in a file name
outputFileName = ("Subjects.csv")
outputCSV_FILE = openFile(outputFileName, "w")

elementTree = ET.parse(options.input_xml) 
assert(elementTree is not None)

namespace = "{http://ands.org.au/standards/rif-cs/registryObjects}"    
#allSubjects = elementTree.findall('.//{0}subject'.format(namespace))
allSubjects = list(elementTree.iterfind('.//{0}subject'.format(namespace)))
assert(len(allSubjects) > 0)
for subject in allSubjects:
    print("%s|%s" % (subject.get("type", ""), subject.text))
    outputCSV_FILE.write("%s|%s\n" % (subject.get("type", ""), subject.text))

outputCSV_FILE.close()
print("See output//%s for output" % outputFileName)
