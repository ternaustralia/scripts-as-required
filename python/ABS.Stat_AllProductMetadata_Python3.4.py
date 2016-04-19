import logging
import Queries
from suds.client import Client
from suds import WebFault
from suds import byte_str_class
import lxml.etree as ET
import os
import sys,traceback
import shlex, subprocess

logging.basicConfig(level=logging.DEBUG)
logging.getLogger('suds.client').setLevel(logging.DEBUG)
logging.getLogger('suds.transport').setLevel(logging.DEBUG)
logging.getLogger('suds.xsd.schema').setLevel(logging.DEBUG)
logging.getLogger('suds.wsdl').setLevel(logging.DEBUG)

url = "http://stat.abs.gov.au/sdmxws/sdmx.asmx?WSDL"

#url = "http://stats.oecd.org/Sdmxws/sdmx.asmx?WSDL"

client = Client(url, retxml=True)
#print(client)

allRifCsXml = open('/home/anucsiro/workspace/scripts-as-required/shell/ForABS/RifCs/ABS_AllRifCs.xml', 'w')

allProductsCsv = open('/home/anucsiro/workspace/scripts-as-required/shell/ForABS/AllProducts.csv', 'w')

try:

    error = 1

    assert(Queries.messageGetDataStructureDefinitionAllProducts_NoSpace is not None)
    print(Queries.messageGetDataStructureDefinitionAllProducts_NoSpace)
    print("Let's go...")
    message = byte_str_class(Queries.messageGetDataStructureDefinitionAllProducts_NoSpace, 'utf-8')

    try:
        print(message)
        rawResultGetDataStructure = client.service.GetDataStructureDefinition(__inject={'msg': message})
        error = 0
    except WebFault as f:
        print("*** Caught WebFault ***")
        print(f.fault)
    except Exception as e:
        print("*** Caught Exception in call ***")
        print(e)

    if(not(error)):

        print(rawResultGetDataStructure)
        rootGetDataStructureDefinition_result = ET.fromstring(rawResultGetDataStructure)

        print("Back again...")
        print(ET.tostring(rootGetDataStructureDefinition_result))

        ET.register_namespace('xml', 'http://www.w3.org/XML/1998/namespace')

        nodeList_KeyFamily = rootGetDataStructureDefinition_result.findall('.//{http://www.SDMX.org/resources/SDMXML/schemas/v2_0/structure}KeyFamily')
        dictAllProducts = {}
        for nodeKeyFamily in nodeList_KeyFamily:
            id = nodeKeyFamily.get('id')
            print('id: ', id)
            nodeList_EnglishName = nodeKeyFamily.findall(".//{http://www.SDMX.org/resources/SDMXML/schemas/v2_0/structure}Name")
            if (len(id) > 0) and (len(nodeList_EnglishName) > 0):
                print('name: ', nodeList_EnglishName[0].text)
                dictAllProducts[id] = nodeList_EnglishName[0].text



        for k, v in iter(dictAllProducts.items()):

            try:
                print("dictAllProducts[{0}] = {1}".format(k, v))
                allProductsCsv.write("{0}|{1}\r\n".format(k, v))

                rawResultGetReferenceMetadata = client.service.GetDatasetMetadata(__inject={'msg': byte_str_class(Queries.messageGetDatasetMetadata_productID.replace('productId', k), 'utf-8')}, retxml=True)
                assert(rawResultGetReferenceMetadata is not None)
                rootGetReferenceMetadata_result = ET.fromstring(rawResultGetReferenceMetadata)
                assert(rootGetReferenceMetadata_result is not None)
                print(ET.tostring(rootGetReferenceMetadata_result, pretty_print=True))

                sdmxXmlFilename = str.format('/home/anucsiro/workspace/scripts-as-required/shell/ForABS/SDMX/%s_SDMX.xml' % k)
                sdmxXmlFile = open(sdmxXmlFilename, 'w')

                treeGetReferenceMetadata = ET.ElementTree(rootGetReferenceMetadata_result)
                assert(treeGetReferenceMetadata is not None)
                print(ET.tostring(treeGetReferenceMetadata, pretty_print=True))
                sdmxXmlFile.write(ET.tostring(rootGetReferenceMetadata_result, encoding="unicode", method="xml", pretty_print=True))
                sdmxXmlFile.flush()
                assert(sdmxXmlFile.__sizeof__() > 0)

                rootTestResult = ET.parse(sdmxXmlFilename)
                sdmxXmlFile.close()


                rifcsXmlFilename = str.format('/home/anucsiro/workspace/scripts-as-required/shell/ForABS/RifCs/%s_RifCs.xml' % k)
                print(rifcsXmlFilename)

                args = str("%s /home/anucsiro/workspace/scripts-as-required/XSLT/SDMX_To_RIFCS/ABS/abs_sdmx_to_rif-cs.xsl -o:%s" % (sdmxXmlFilename, rifcsXmlFilename))
                command = str("java -jar /home/anucsiro/workspace/scripts-as-required/XSLT/saxon9he.jar %s /home/anucsiro/workspace/scripts-as-required/XSLT/SDMX_To_RIFCS/ABS/abs_sdmx_to_rif-cs.xsl -o:%s" % (sdmxXmlFilename, rifcsXmlFilename))
                print(args)
                print(command)
                process = subprocess.check_output(["java", "-jar", "/home/anucsiro/workspace/scripts-as-required/XSLT/saxon9he.jar", str.format("%s" % sdmxXmlFilename), "/home/anucsiro/workspace/scripts-as-required/XSLT/SDMX_To_RIFCS/ABS/abs_sdmx_to_rif-cs.xsl", str.format("-o:%s" % rifcsXmlFilename), str.format("global_productName=%s" % v)])

                rootRifCsTestResult = ET.parse(rifcsXmlFilename)

                allRifCsXml.write(ET.tostring(rootRifCsTestResult, encoding="unicode", method="xml", pretty_print=True))
                allRifCsXml.flush()

            except Exception as e:
                print("*** Caught Exception in loop ***")
                print("-"*60)
                traceback.print_exc(file=sys.stdout)
                print("-"*60)

except Exception as e:
    print("*** Caught Exception ***")
    print("-"*60)
    traceback.print_exc(file=sys.stdout)
    print("-"*60)

if(allRifCsXml is not None):
    allRifCsXml.close()

if(allProductsCsv is not None):
    allProductsCsv.close()







