import urllib2
import json
import io
import sys
import json
import traceback
import getopt
import numbers
import codecs
import exceptions
from xml.dom.minidom import Document

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

def writeXmlFromJson(dataSetUri, outFileName, outputDirectory):

  try:
    obj_addinfourl = urllib2.urlopen(dataSetUri, timeout=5)
  except exceptions.KeyboardInterrupt:
    print "Interrupted - ", sys.exc_info()[0]
    raise
  except:
    print("Exception %s when opening %s" % (sys.exc_info()[0], dataSetUri))
    return

  obj_StreamReaderWriter = None

  try:
    print("Retrieved content at "+dataSetUri)
    assert(obj_addinfourl is not None)
    obj_json_str = (obj_addinfourl.read())
    assert(obj_json_str is not None)
    obj_dict = json.loads(obj_json_str)
    obj_xml_Document = parse_doc("datasets", obj_dict)
    print("About to create file "+outFileName)
    obj_StreamReaderWriter = codecs.open(outFileName, 'w', 'utf-8')
    print("obj_StreamReaderWriter:  " + obj_StreamReaderWriter.__class__.__name__)  
    #obj_StreamReaderWriter.write("<datasets>")
    obj_StreamReaderWriter.write(obj_xml_Document.toprettyxml())  
    #obj_StreamReaderWriter.write(obj_xml_Document.toprettyxml(encoding='utf-8', indent=' '))
    #obj_StreamReaderWriter.write("</datasets>")
    print("Output written to "+outputDirectory+"/JsonXML/%s" % outFileName)
  except exceptions.KeyboardInterrupt:
    print "Interrupted - ", sys.exc_info()[0]
    raise
  except:
    print "Exception - ", sys.exc_info()[0]
    traceback.print_exc(file=sys.stdout)
  finally:
    if obj_StreamReaderWriter is not None:
      obj_StreamReaderWriter.close()
      
  

    

        

       


