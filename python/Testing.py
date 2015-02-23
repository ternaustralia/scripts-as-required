import sys
import os
from optparse import OptionParser
import StringIO
import urllib2
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import parse
import operator

uri = "http://localhost:8080/geonetwork/srv/eng/oaipmh?verb=ListRecords&metadataPrefix=rif"
print("Opening uri: %s" % uri)
namespace = '{http://ands.org.au/standards/rif-cs/registryObjects}' # default


f = urllib2.urlopen(uri)
data = f.read()
print data
    
