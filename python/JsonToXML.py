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
import shutil
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


def parse_element(doc, root, j, namespaceUri):
  if j is None:
    return
  if isinstance(j, dict):
    for key in j.keys():

      value = j[key]
      if isinstance(value, list):
        for e in value:
          keyFormatted = key.replace(' ', '_')
          elem = doc.createElementNS(namespaceUri, keyFormatted)
          parse_element(doc, elem, e, namespaceUri)
          root.appendChild(elem)
      else:
        if key.isdigit():
          elem = doc.createElementNS(namespaceUri, 'item')
          elem.setAttribute('value', key)
        else:
          keyFormatted = key.replace(' ', '_')
          elem = doc.createElementNS(namespaceUri, keyFormatted)
        parse_element(doc, elem, value, namespaceUri)
        root.appendChild(elem)
  elif isinstance(j, list):
    print("isinstance list of len ", len(j))
    print(j)
    for e in j:
        parse_element(doc, root, e)
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
    raise Exception("unhandled type %s for %s" % (type(j), j,))


def getSubDirectoryName(splitElement=None):
    if(splitElement != None):
        return str('Records')
    else:
        return str('Pages')


def writeXmlFromJson(dataSetUri, outFileName, splitElement=None):

    postfix=""
    rows=99
    start=0
    count=100

    namespaceUri = "http://json.to.xml"
    namespacePrefix = "jsonXml"

    domImplementation = DOMImplementation()
    obj_xml_rootDocument = Document()
    root = obj_xml_rootDocument.createElementNS(namespaceUri, namespacePrefix + ':' + 'root')
    root.setAttribute('xmlns', namespaceUri)
    root.setAttribute(('xmlns:' + namespacePrefix), namespaceUri)
    obj_xml_rootDocument.appendChild(root)

    domain = dataSetUri.split("//")[-1].split("/")[0].split('?')[0]

    try:

        workingDirectory = os.path.dirname(outFileName)
        print("Working directory " + workingDirectory)
        print("About to create file "+outFileName)
        outputFile = open(outFileName, 'w+')

        subDirectoryName = getSubDirectoryName(splitElement)
        if os.path.exists(workingDirectory + '/' + subDirectoryName):
            shutil.rmtree(workingDirectory + '/' + subDirectoryName)
        os.makedirs(workingDirectory + '/' + subDirectoryName)

        while(count > (start)):

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
            #print(obj_json_str)
            assert(obj_json_str is not None)
            obj_dict = json.loads(obj_json_str)

            elem = obj_xml_rootDocument.createElement("datasets")
            parse_element(obj_xml_rootDocument, elem, obj_dict, namespaceUri)
            root.appendChild(elem)

            #print(obj_xml_rootDocument.toprettyxml())

            countElementList = elem.getElementsByTagNameNS(namespaceUri, 'count')
            if(len(countElementList) == 1):
                assert(len(countElementList[0].childNodes[0].data) > 0)
                count=int(countElementList[0].childNodes[0].data)

            print("Retrieved count %d " % count)

            #obj_StreamReaderWriter.write(obj_xml_Document.toprettyxml(encoding='utf-8', indent=' ')

            if(splitElement != None):

                domImplementation = DOMImplementation()
                obj_xml_rootRecordDocument = Document()
                rootRecord = obj_xml_rootRecordDocument.createElementNS(namespaceUri, namespacePrefix + ':' + 'record')
                rootRecord.setAttribute('xmlns', namespaceUri)
                rootRecord.setAttribute(('xmlns:' + namespacePrefix), namespaceUri)
                obj_xml_rootRecordDocument.appendChild(rootRecord)

               # Create one file per record, with domain name and increment
                resultsList = elem.getElementsByTagNameNS(namespaceUri, splitElement)
                for i in xrange(1, len(resultsList)):

                    results = resultsList[i]

                    rootRecord.appendChild(results)

                    recordFilename = str.format(workingDirectory + '/' + subDirectoryName + '/' + domain + '_' + str(i + start) + '.xml')
                    recordFile = open(recordFilename, 'w+')

                    recordFile.write(rootRecord.toprettyxml(encoding='utf-8', indent=' '))
                    recordFile.close()
                    print("This page of output split per record, and written to %s" % recordFilename)
            else:

                recordFilename = str.format(workingDirectory + '/' + subDirectoryName + '/' + domain + '_' + str(start) + '.xml')
                recordFile = open(recordFilename, 'w+')

                recordFile.write(obj_xml_rootDocument.toprettyxml(encoding='utf-8', indent=' '))
                recordFile.close()
                print("This page of output all written to %s" % recordFilename)

            outputFile.write(obj_xml_rootDocument.toprettyxml(encoding='utf-8', indent=' '))
            print("All output appended to %s" % outFileName)

            start += 100
            print("Continuing if count (%d) greater than start (%d)  " % (count, start))

    except exceptions.KeyboardInterrupt:
        print "Interrupted - ", sys.exc_info()[0]
        raise
    except:
        print "Exception - ", sys.exc_info()[0]
        traceback.print_exc(file=sys.stdout)



    if outputFile is not None:
        outputFile.close()

  

    

        

       


