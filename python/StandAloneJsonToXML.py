#Python for converting json at a URL to xml
import json
import dicttoxml
import urllib
from optparse import OptionParser

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--jsonURL", action="store", dest="jsonURL", help="URL to JSON, e.g. https://biocache.ala.org.au/ws/v2/api-docs")

(options, args) = parser.parse_args()

# Validate jsonURL
if not(options.jsonURL):
    parser.error("Requires jsonURL.  Try --help for usage")
    sys.exit(-1)


print("Opening url ", options.jsonURL)
#page = urllib.urlopen('https://biocache.ala.org.au/ws/v2/api-docs')
page = urllib.urlopen(options.jsonURL)
content = page.read()
obj = json.loads(content)
print(obj)
xml = dicttoxml.dicttoxml(obj)
print(xml)

recordFile = open('from_json.xml', 'w+')
recordFile.write(xml)
recordFile.close()

print("xml written to from_json.xml")
























