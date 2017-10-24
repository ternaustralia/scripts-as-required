import urllib2
import json
import io
import sys
import json
import traceback
import getopt
import numbers
import codecs
import os
import exceptions
from xml.dom.minidom import parseString, Document, DOMImplementation

def json2xml(json_obj, line_padding=""):
    result_list = list()

    json_obj_type = type(json_obj)

    if json_obj_type is list:
        for sub_elem in json_obj:
            result_list.append(json2xml(sub_elem, line_padding))

        return "\n".join(result_list)

    if json_obj_type is dict:
        for tag_name in json_obj:
            sub_obj = json_obj[tag_name]
            result_list.append("%s<%s>" % (line_padding, tag_name))
            result_list.append(json2xml(sub_obj, "\t" + line_padding))
            result_list.append("%s</%s>" % (line_padding, tag_name))

        return "\n".join(result_list)

    return "%s%s" % (line_padding, json_obj)


def parse_element(doc, root, j):
  if j is None:
    return
  if isinstance(j, dict):
    for key in j.keys():
      
      value = j[key]
      if isinstance(value, list):
        for e in value:
          keyFormatted = key.replace(' ', '_')
          elem = doc.createElement(keyFormatted)
          parse_element(doc, elem, e)
          root.appendChild(elem)
      else:
        if key.isdigit():
          elem = doc.createElement('item')
          elem.setAttribute('value', key)
        else:
          keyFormatted = key.replace(' ', '_')
          elem = doc.createElement(keyFormatted)
        parse_element(doc, elem, value)
        root.appendChild(elem)
  elif isinstance(j, unicode):
    text = doc.createTextNode(j)
    root.appendChild(text)
  elif isinstance(j, str):
    print("isinstance str") 
    text = doc.createTextNode(j)
    root.appendChild(text)
  elif isinstance(j, numbers.Number):
    text = doc.createTextNode(str(j))
    root.appendChild(text)
  else:
    raise Exception("bad type %s for %s" % (type(j), j,))

def parse_doc(root, j):
  doc = Document()
  if root is None:
    if len(j.keys()) > 1:
      raise Exception('Expected one root element, or use --root to set root')
    root = j.keys()[0]
    elem = doc.createElement(root)
    j = j[root]
  else:
    elem = doc.createElement(root)
  parse_element(doc, elem, j)
  doc.appendChild(elem)
  return doc

def writeXmlFromJson(dataSetUri, outFileName):

    postfix=""
    rows=99
    start=0
    count=100

    domImplementation = DOMImplementation()
    obj_xml_rootDocument = Document()
    root = obj_xml_rootDocument.createElement("root")
    obj_xml_rootDocument.appendChild(root)


    try:

        while(count > (rows+start-100)):

            print("About to create file " + outFileName)
            outputFile = open(outFileName, 'w+')

            print("About to retrieve content at " + dataSetUri + postfix)

            postfix = str.format("&rows="+str(rows)+"&start="+str(start))

            try:
                obj_addinfourl = urllib2.urlopen(dataSetUri+postfix, timeout=5)
            except exceptions.KeyboardInterrupt:
                print "Interrupted - ", sys.exc_info()[0]
                raise
            except:
                print("Exception %s when opening %s" % (sys.exc_info()[0], dataSetUri+postfix))
                return


            print("Retrieved content at "+dataSetUri+postfix)
            assert(obj_addinfourl is not None)
            obj_json_str = (obj_addinfourl.read())
            assert(obj_json_str is not None)
            obj_dict = json.loads(obj_json_str)

            elem = obj_xml_rootDocument.createElement("datasets")
            parse_element(obj_xml_rootDocument, elem, obj_dict)
            root.appendChild(elem)

            #print(obj_xml_rootDocument.toprettyxml())

            countElementList = elem.getElementsByTagName("count")
            if(len(countElementList) == 1):
                assert(len(countElementList[0].childNodes[0].data) > 0)
                count=int(countElementList[0].childNodes[0].data)

            
            print("Remaining: "+str(count-(rows+start)))
            print("Remaining: "+str(count-(rows+start)))

            start+=100

            print("Rows+Start-100: "+str((rows+start-100)))

            if (count <= (rows + start - 100)):
                print("No more to retrieve")

                #obj_StreamReaderWriter.write(obj_xml_Document.toprettyxml(encoding='utf-8', indent=' '))



    except exceptions.KeyboardInterrupt:
        print "Interrupted - ", sys.exc_info()[0]
        raise
    except:
        print "Exception - ", sys.exc_info()[0]
        traceback.print_exc(file=sys.stdout)

    outputFile.write(obj_xml_rootDocument.toprettyxml(encoding='utf-8', indent=' '))

    print("Output written to %s" % outFileName)

    if outputFile is not None:
        outputFile.close()

  

    

        

       


