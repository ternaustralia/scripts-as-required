#Python for converting json at a URL to xml
import json
import dicttoxml
import urllib2
import yaml
from optparse import OptionParser

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--jsonURL", action="store", dest="jsonURL", help="URL to JSON, e.g. https://biocache.ala.org.au/ws/v2/api-docs")

#http://portal.tern.org.au/assets/core/swagger/swagger.yaml



(options, args) = parser.parse_args()

# Validate jsonURL
if not(options.jsonURL):
    parser.error("Requires jsonURL.  Try --help for usage")
    sys.exit(-1)


#print("Opening url ", options.jsonURL)
#req = urllib2.Request(options.jsonURL, None)
#req.add_header('Accept','text/yaml')
#page = urllib2.urlopen(req)
#accept = req.get_header('Accept')

# temp begin

#page = file('/home/ada168/projects/TERN_Project/swagger.yaml', 'r')
#accept = "text/yaml"
page = file('/home/ada168/projects/ALA/api-docs.json', 'r')
accept = "application/json"


# temp end

content = page.read()

xml = None



try:


    if accept == "application/json":
        print('json')
        try:
            obj = json.loads(content)
            print(obj)
            xml = dicttoxml.dicttoxml(obj)
        except Exception:
            print('Failed to parse json')
    elif accept == "text/yaml":
        print('yaml')
        try:
            safeLoad = yaml.safe_load(content)
        except Exception:
            print('Unable to parse yaml')

        try:
            safeLoad = yaml.safe_load(content)
            for key, value in safeLoad.iteritems():
               print key, value
            #print yaml.dump(yaml.load(content))
            xml = dicttoxml.dicttoxml(safeLoad.iteritems())
            #print(xml)
        except Exception:
            print('Unable to convert yaml load to xml')

        try:
            safeDump = yaml.safe_dump(content)
            #print(safeDump)
            xml = dicttoxml.dicttoxml(safeDump)
        except Exception:
            print('Unable to convert yaml dump to xml')
    elif accept == "text/xml":
        print('xml')
    else:
        print(accept)
except Exception:
    print('exception')

if(xml != None):
    print(xml)
    recordFile = open('from_source.xml', 'w+')
    recordFile.write(xml)
    recordFile.close()
    print("xml written to from_source.xml")
else:
    print("xml wasn't generated")


























