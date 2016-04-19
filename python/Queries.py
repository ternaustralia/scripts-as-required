messageGetDataStructureDefinitionPerProduct = \
"""<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body>
        <GetDataStructureDefinition xmlns="http://stats.oecd.org/OECDStatWS/SDMX/">
            <QueryMessage>
                <message:QueryMessage xmlns="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query" xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message" xsi:schemaLocation="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query http://www.sdmx.org/docs/2_0/SDMXQuery.xsd http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message http://www.sdmx.org/docs/2_0/SDMXMessage.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                    <message:Header>
                        <message:ID>none</message:ID>
                        <message:Test>true</message:Test>
                        <message:Prepared>2016-04-05T03:57:40</message:Prepared>
                        <message:Sender id="ABS" />
                        <message:Receiver id="ABS" />
                    </message:Header>
                    <message:Query>
                        <KeyFamilyWhere>
                            <Or>
                                <KeyFamily>CPI</KeyFamily>
                            </Or>
                        </KeyFamilyWhere>
                    </message:Query>
                </message:QueryMessage>
            </QueryMessage>
        </GetDataStructureDefinition>
    </soap:Body>
</soap:Envelope>
"""

messageGetDataStructureDefinitionAllProducts = \
"""<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body>
        <GetDataStructureDefinition xmlns="http://stats.oecd.org/OECDStatWS/SDMX/">
            <QueryMessage>
                <message:QueryMessage xmlns="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query" xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message" xsi:schemaLocation="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query http://www.sdmx.org/docs/2_0/SDMXQuery.xsd http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message http://www.sdmx.org/docs/2_0/SDMXMessage.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                    <message:Header>
                        <message:ID>none</message:ID>
                        <message:Test>false</message:Test>
                        <message:Prepared>2016-04-05T03:57:40</message:Prepared>
                        <message:Sender id="ABS" />
                        <message:Receiver id="ABS" />
                    </message:Header>
                    <message:Query>
                        <KeyFamilyWhere>
                            <Or>
                            </Or>
                        </KeyFamilyWhere>
                    </message:Query>
                </message:QueryMessage>
            </QueryMessage>
        </GetDataStructureDefinition>
    </soap:Body>
</soap:Envelope>
"""
messageGetDataStructureDefinitionAllProducts_NoSpace = \
"""<?xml version="1.0" encoding="utf-8"?>\
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">\
<soap:Body>\
<GetDataStructureDefinition xmlns="http://stats.oecd.org/OECDStatWS/SDMX/">\
<QueryMessage>\
<message:QueryMessage xmlns="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query" xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message" xsi:schemaLocation="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query http://www.sdmx.org/docs/2_0/SDMXQuery.xsd http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message http://www.sdmx.org/docs/2_0/SDMXMessage.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\
<message:Header>\
<message:ID>none</message:ID>\
<message:Test>false</message:Test>\
<message:Prepared>2016-04-05T03:57:40</message:Prepared>\
<message:Sender id="ABS"/>\
<message:Receiver id="ABS"/>\
</message:Header>\
<message:Query>\
<KeyFamilyWhere>\
<Or>\
</Or>\
</KeyFamilyWhere>\
</message:Query>\
</message:QueryMessage>\
</QueryMessage>\
</GetDataStructureDefinition>\
</soap:Body>\
</soap:Envelope>
"""

messageGetDatasetMetadata_productID = \
"""<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body>
        <GetDatasetMetadata xmlns="http://stats.oecd.org/OECDStatWS/SDMX/">
            <QueryMessage>
                <message:GenericMetadataQuery
xmlns:message="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message"
xmlns:structure="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure"
xmlns:query="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/query"
xmlns:common="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="
http://www.sdmx.org/resources/sdmxml/schemas/v2_1/query SDMXQueryMetadata.xsd
http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message SDMXMessage.xsd">
                    <message:Header>
                        <message:ID>none</message:ID>
                        <message:Test>false</message:Test>
                        <message:Prepared>2012-10-17T03:57:40</message:Prepared>
                        <message:Sender id="ABS" />
                        <message:Receiver id="ABS" />
                    </message:Header>
                    <message:Query>
                        <query:ReturnDetails/>
                        <query:MetadataParameters>
                            <query:AttachedDataSet>
                                <common:DataProvider>
                                    <Ref id="ABS" maintainableParentID="" agencyID="ABS"/>
                                </common:DataProvider>
                                <common:ID>productId</common:ID>
                            </query:AttachedDataSet>
                        </query:MetadataParameters>
                    </message:Query>
                </message:GenericMetadataQuery>
            </QueryMessage>
        </GetDatasetMetadata>
    </soap:Body>
</soap:Envelope>
"""

messageGetDatasetMetadata_CPI = \
"""<?xml version="1.0" encoding="UTF-8"?>\
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"    xmlns:xsd="http://www.w3.org/2001/XMLSchema">\
<soap:Body>\
<GetDatasetMetadata xmlns="http://stats.oecd.org/OECDStatWS/SDMX/">\
<QueryMessage>\
<message:GenericMetadataQuery
xmlns:message="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message"
xmlns:structure="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure"
xmlns:query="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/query"
xmlns:common="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="
http://www.sdmx.org/resources/sdmxml/schemas/v2_1/query SDMXQueryMetadata.xsd
http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message SDMXMessage.xsd">\
<message:Header>\
<message:ID>none</message:ID>\
<message:Test>false</message:Test>\
<message:Prepared>2012-10-17T03:57:40</message:Prepared>\
<message:Sender id="ABS" />\
<message:Receiver id="ABS" />\
</message:Header>\
<message:Query>\
<query:ReturnDetails/>\
<query:MetadataParameters>\
<query:AttachedDataSet>\
<common:DataProvider>\
<Ref id="ABS" maintainableParentID="" agencyID="ABS"/>\
</common:DataProvider>\
<common:ID>CPI</common:ID>\
</query:AttachedDataSet>\
</query:MetadataParameters>\
</message:Query>\
</message:GenericMetadataQuery>\
</QueryMessage>\
</GetDatasetMetadata>\
</soap:Body>\
</soap:Envelope>\
"""

messageGetDataStructureDefinitionAllProducts_FromEmail = \
"""<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
   <soap:Body>
       <GetDataStructureDefinition xmlns="http://stats.oecd.org/OECDStatWS/SDMX/">
           <QueryMessage>
               <message:QueryMessage xmlns="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query" xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message" xsi:schemaLocation="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query http://www.sdmx.org/docs/2_0/SDMXQuery.xsd http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message http://www.sdmx.org/docs/2_0/SDMXMessage.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                   <message:Header>
                       <message:ID>none</message:ID>
                       <message:Test>false</message:Test>
                       <message:Prepared>2012-10-17T03:57:40</message:Prepared>
                       <message:Sender id="ABS" />
                       <message:Receiver id="ABS" />
                   </message:Header>
                   <message:Query>
                       <KeyFamilyWhere>
                           <Or>
                           </Or>
                       </KeyFamilyWhere>
                   </message:Query>
               </message:QueryMessage>
           </QueryMessage>
       </GetDataStructureDefinition>
   </soap:Body>
</soap:Envelope>
"""

messageGetDataStructureDefinitionAllProducts_FromTestInterface = \
"""<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">\
<soap:Body>\
<GetDataStructureDefinition xmlns="http://stats.oecd.org/OECDStatWS/SDMX/">\
<QueryMessage>\
<message:QueryMessage xmlns="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query" xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message" xsi:schemaLocation="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/query http://www.sdmx.org/docs/2_0/SDMXQuery.xsd http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message http://www.sdmx.org/docs/2_0/SDMXMessage.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\
<message:Header>\
<message:ID>none</message:ID>\
<message:Test>false</message:Test>\
<message:Prepared>2012-10-17T03:57:40</message:Prepared>\
<message:Sender id="ABS" />\
<message:Receiver id="ABS" />\
</message:Header>\
<message:Query>\
<KeyFamilyWhere>\
<Or>\
</Or>\
</KeyFamilyWhere>\
</message:Query>\
</message:QueryMessage>\
</QueryMessage>\
</GetDataStructureDefinition>\
</soap:Body>\
</soap:Envelope>\
"""


