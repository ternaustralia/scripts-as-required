# usage: python Seek_Identifier_Within_OAI_PHM_Feed.py --input http://portal.auscope.org/geonetwork/srv/env/oaipmh --identifier weoriehewruhi --metadataprefix iso19139.mcp

# Process:
# Takes OAI-PMH data source original link e.g. http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh
# Loads as http://portal.auscope.org/geonetwork/srv/env/oaipmh?verb=ListRecords&metadataPrefix=iso19139.mcp (using uri and metadataprefix provided)
# Writes starting root node registryObjects to output file
# Writes children nodes per registryObject to output file
# Reads resumption token value at end of file 
# Loads next uri as http://portal.auscope.org/geonetwork/srv/env/oaipmh?verb=ListRecords&resumptionToken={resumptionTokenValue}
# Continues, loading all files until no more resumption token - stops when identifier found
# Writes closing root node registryObjects to output file


import sys
import os
from optparse import OptionParser
import StringIO
import urllib2
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse
import operator


def seekIdentifier(identifierToFind, uri):
    assert(uri is not None)

    try:
        proxy_handler = urllib2.ProxyHandler({})
        opener = urllib2.build_opener(proxy_handler)
	print("Opening uri: %s" % uri)
        req = urllib2.Request(uri)
        req.add_header('Accept-Language', 'en-gb')
        req.add_header('Accept', 'application/xml')
        result = opener.open(req)
	#content = result.read()
	#assert(content != 0)
 	#print(content)
    except Exception as e:
        print("Unable to open uri %s - exception: %s" % (uri, e))
	sys.exit(-1)
    
    assert(result != 0)

    try:
	xml = ET.parse(result)
    except Exception as e:
        print("Unable to parse xml at uri %s - exception: %s" % (uri, e))
	sys.exit(-1)
    
    oaipmhRoot = xml.getroot() # get OAI-PMH
    identifiers = oaipmhRoot.findall('.//%sidentifier' % namespace)
    if(len(identifiers) < 1):
        assert(0)
        return
    
    print("%d identifier(s) found" % len(identifiers))	

    for identifier in oaipmhRoot.findall('.//%sidentifier' % namespace):
      print("identifier: %s" % identifier.text)
      if identifier.text == identifierToFind:
        print("found identifier that we are looking for: %s" % identifierToFind)
        return None

    resumptionTokenElement = oaipmhRoot.find('.//%sresumptionToken' % namespace)
    if(resumptionTokenElement is None):
        return None
        
    return resumptionTokenElement.text
    
     
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
    
# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--input", action="store", dest="data_source_uri", help="uri of OAI-PMH data source, e.g. http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh")
parser.add_option("--metadataPrefix", action="store", dest="metadata_prefix", help="metadata prefix, e.g. iso19139")
parser.add_option("--identifier", action="store", dest="identifier_to_find", help="identifier that you are looking for, e.g. 19a7cec7-4336-4b9f-a693-b82bb2a87449")

(options, args) = parser.parse_args()

# Validate data source uri
if not options.data_source_uri:
    parser.error("Requires input.  Try --help for usage")
    sys.exit(-1)
    
if len(options.data_source_uri) < 1:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)

if not options.identifier_to_find:
    parser.error("Requires identifier.  Try --help for usage")
    sys.exit(-1)
    
if len(options.identifier_to_find) < 1:
    parser.error("Requires identifier.  Try --help for usage")
    sys.exit(-1)

if not options.metadata_prefix:
    parser.error("Requires metadataPrefix.  Try --help for usage")
    sys.exit(-1)
    
if len(options.metadata_prefix) < 1:
    parser.error("Requires metadataPrefix.  Try --help for usage")
    sys.exit(-1)
    
identifierToFind = options.identifier_to_find
dataSourceURI = options.data_source_uri
metadataPrefix = options.metadata_prefix

namespace = '{http://www.openarchives.org/OAI/2.0/}'

# Call function accessRegistryObjects(dataSourceURI+"verb=ListRecords&metadataPrefix=rif") for first page load
# When it encounters resumptionToken tag, it will store the value in resumptionToken
resumptionToken = seekIdentifier(identifierToFind, dataSourceURI+"?verb=ListRecords&metadataPrefix="+metadataPrefix)
   
while resumptionToken is not None:
   assert(len(resumptionToken) > 1)
   resumptionToken = seekIdentifier(identifierToFind, dataSourceURI+"?verb=ListRecords&resumptionToken="+resumptionToken)






