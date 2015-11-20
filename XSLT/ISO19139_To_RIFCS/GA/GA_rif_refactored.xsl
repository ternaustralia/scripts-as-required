<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gts='http://www.isotc211.org/2005/gts'
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts">
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements='*'/>
    <xsl:param name="global_originatingSource" select="'http://www.ga.gov.au'"/>
    <xsl:param name="global_baseURI" select="'http://www.ga.gov.au'"/>
    <xsl:param name="global_group" select="'Geoscience Australia'"/>
    <xsl:param name="global_publisherName" select="'Geoscience Australia'"/>
    <xsl:param name="global_publisherPlace" select="'Canberra'"/>
    <xsl:variable name="anzsrcCodelist" select="document('anzsrc-codelist.xml')"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
    <xsl:template match="oai:responseDate"/>
    <xsl:template match="oai:request"/>
    <xsl:template match="oai:error"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:setSpec"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:setSpec"/>
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//*:MD_Metadata" mode="collection"/>
            <xsl:apply-templates select="//*:MD_Metadata" mode="party"/>
        </registryObjects>
    </xsl:template>
    
      
    <!-- =========================================== -->
    <!-- Collection RegistryObject Template          -->
    <!-- =========================================== -->
   
    <xsl:template match="gmd:MD_Metadata" mode="collection">
       
        <!-- construct parameters for values that are required in more than one place in the output xml-->
        <xsl:param name="dataSetURI" select="gmd:dataSetURI"/>
        
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$global_group"/>
            </xsl:attribute>
            <xsl:apply-templates select="gmd:fileIdentifier" mode="registryObject_key"/>
           
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            
            <xsl:variable name="scopeCode" select="normalize-space(gmd:hierarchyLevel/*:MD_ScopeCode/@codeListValue)"/>
            
            <xsl:variable name="registryObjectTypeSubType_sequence" as="xs:string*" select="custom:getRegistryObjectTypeSubType($scopeCode)"/>
            <xsl:if test="(count($registryObjectTypeSubType_sequence) = 2)">
                <xsl:element name="{$registryObjectTypeSubType_sequence[1]}">
                    
                    <xsl:attribute name="type">
                        <xsl:value-of select="$registryObjectTypeSubType_sequence[2]"/>
                    </xsl:attribute>
                    
                    <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                        
                        <xsl:variable name="metadataCreationDate">
                            <xsl:if test="string-length(normalize-space(gmd:dateStamp/gco:Date)) > 0">
                                <xsl:value-of select="normalize-space(gmd:dateStamp/gco:Date)"/>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(gmd:dateStamp/gco:DateTime)) > 0">
                                <xsl:value-of select="normalize-space(gmd:dateStamp/gco:DateTime)"/>
                            </xsl:if>
                        </xsl:variable>
                        
                        <xsl:attribute name="dateAccessioned">
                            <xsl:value-of select="$metadataCreationDate"/>
                        </xsl:attribute>
                    </xsl:if>
                
                    <xsl:apply-templates select="gmd:fileIdentifier" 
                         mode="registryObject_identifier"/>
                    
                    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/*:transferOptions/*:MD_DigitalTransferOptions/*:onLine/*:CI_OnlineResource[((contains(lower-case(*:name), 'doi')) and (not(contains(lower-case(*:name), 'associated'))))]/*:linkage/*:URL[contains(text(), 'doi')]"
                        mode="registryObject_identifier"/>
                            
                    <xsl:apply-templates select="gmd:dataSetURI" 
                        mode="registryObject_identifier"/>
                     
                    <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title" 
                         mode="registryObject_name"/>
                     
                     <xsl:apply-templates select="gmd:dataSetURI" 
                         mode="registryObject_location"/>
                    
                    <xsl:apply-templates
                        select="gmd:distributionInfo/gmd:MD_Distribution"
                        mode="registryObject_location_download"/>
                    
                     <xsl:for-each-group select="gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] | 
                         gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                         gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                         gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
                         group-by="gmd:individualName">
                         <xsl:apply-templates select="." 
                             mode="registryObject_related_object"/>
                     </xsl:for-each-group>
                     
                     <xsl:for-each-group select="gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) and not(string-length(normalize-space(gmd:individualName)))) and  
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] | 
                         gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) and not(string-length(normalize-space(gmd:individualName)))) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                         gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) and not(string-length(normalize-space(gmd:individualName)))) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                         gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) and not(string-length(normalize-space(gmd:individualName)))) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
                         group-by="gmd:organisationName">
                         <xsl:apply-templates select="." 
                             mode="registryObject_related_object"/>
                     </xsl:for-each-group>
                     
                     <xsl:apply-templates select="gmd:identificationInfo/*/gmd:topicCategory/gmd:MD_TopicCategoryCode" 
                         mode="registryObject_subject"/>
                     
                     <xsl:apply-templates select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword" 
                         mode="registryObject_subject"/>
                     
                     <xsl:apply-templates select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword" 
                         mode="registryObject_subject_anzsrc"/>
                     
                     <xsl:apply-templates select="gmd:identificationInfo/*/gmd:abstract" 
                         mode="registryObject_description"/>
                     
                     <xsl:apply-templates select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox" 
                         mode="registryObject_coverage_spatial"/>
                    
                    <xsl:apply-templates
                        select="gmd:distributionInfo/gmd:MD_Distribution"
                        mode="registryObject_relatedInfo">
                        <xsl:with-param name="registryObjectType" select="$registryObjectTypeSubType_sequence[2]"/>
                    </xsl:apply-templates>
                    
                     
                     <xsl:variable name="organisationOwnerName">
                         <xsl:apply-templates select="gmd:identificationInfo/*" mode="variable_owner_name"/>
                     </xsl:variable>
                     
                     <xsl:variable name="individualOwnerName">
                         <xsl:apply-templates select="gmd:identificationInfo/*" mode="variable_individual_name"/>
                     </xsl:variable>
                         
                     <xsl:variable name="publishDate">
                         <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation" mode="variable_publish_date"/>
                     </xsl:variable>
                     
                     <xsl:call-template name="registryObject_rights_rightsStatement">
                         <xsl:with-param name="organisationOwnerName" select="$organisationOwnerName"/>
                         <xsl:with-param name="individualOwnerName" select="$individualOwnerName"/>
                         <xsl:with-param name="publishDate" select="$publishDate"/>
                     </xsl:call-template>
                     
                     <xsl:apply-templates select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints[exists(gmd:useConstraints)]"
                         mode="registryObject_rights_licence"/> 
                             
                     <!--xsl:apply-templates select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints[exists(gmd:accessConstraints)]" 
                         mode="registryObject_rights_accessRights"/--> 
                    
                    <xsl:variable name="fees_sequence" select="*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributionOrderProcess/*:MD_StandardOrderProcess/*:fees"/>
                    <xsl:variable name="restrictionCode_sequence" select="*:identificationInfo/*/*:resourceConstraints/*/*/*:MD_RestrictionCode/@codeListValue"/>
                    <xsl:variable name="downloaddataURL_sequence" select="custom:getProtocolURL_sequence('download', *:distributionInfo/*:MD_Distribution/*:transferOptions/*:MD_DigitalTransferOptions)"/>
                    <xsl:variable name="otherConstraints_sequence" select="*:identificationInfo/*/*:resourceConstraints/*/*:otherConstraints"/>
                    <xsl:copy-of select="custom:set_registryObject_accessRights($fees_sequence, $downloaddataURL_sequence, $restrictionCode_sequence, $otherConstraints_sequence)"/>
                     
                    <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                        <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation">
                           <xsl:call-template name="registryObject_citationMetadata_citationInfo">
                               <xsl:with-param name="dataSetURI" select="$dataSetURI"/>
                               <xsl:with-param name="citation" select="."/>
                           </xsl:call-template>
                        </xsl:for-each> 
                    </xsl:if>
                </xsl:element>
            </xsl:if>
        </registryObject>
    </xsl:template>   
    
    <!-- =========================================== -->
    <!-- Party RegistryObject Template          -->
    <!-- =========================================== -->
    
    <xsl:template match="gmd:MD_Metadata" mode="party">
        
        <xsl:for-each-group select="gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] | 
                gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
                group-by="gmd:individualName">
                <xsl:call-template name="party">
                    <xsl:with-param name="type">person</xsl:with-param>
                </xsl:call-template>
            </xsl:for-each-group>
            
            <xsl:for-each-group select="gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] | 
                gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))] |
                gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
                group-by="gmd:organisationName">
                <xsl:call-template name="party">
                    <xsl:with-param name="type">group</xsl:with-param>
                </xsl:call-template>
            </xsl:for-each-group>
    </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- Collection RegistryObject - Child Templates -->
    <!-- =========================================== -->
    
    <!-- Collection - Key Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="registryObject_key">
        <key>
            <xsl:value-of select="normalize-space(.)"/>
        </key>
    </xsl:template>
    
    <!-- Collection - Type Attribute -->
    <xsl:template match="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue" mode="registryObject_type_attribute">
        <xsl:attribute name="type">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Collection - Identifier Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="registryObject_identifier">
        <xsl:if test="string-length(.) > 0">
            <identifier>
                <xsl:attribute name="type">
                     <xsl:text>local</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - Identifier Element  -->
    <xsl:template match="gmd:URL" mode="registryObject_identifier">
        <xsl:if test="string-length(.) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>doi</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gmd:dataSetURI" mode="registryObject_identifier">
        <xsl:if test="string-length(.) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>uri</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - Name Element  -->
    <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title" mode="registryObject_name">
        <name>
            <xsl:attribute name="type">
                 <xsl:text>primary</xsl:text>
            </xsl:attribute>
            <namePart>
                 <xsl:value-of select="."/>
            </namePart>
        </name>
    </xsl:template>
    
    <!-- Collection - Address Electronic Element  -->
    <xsl:template match="gmd:dataSetURI" mode="registryObject_location">
       <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                     <xsl:attribute name="target">
                        <xsl:text>landingPage</xsl:text>
                    </xsl:attribute>
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
       </location>
    </xsl:template>
    
    <!-- RegistryObject - Location Address Electronic Element  -->
    <xsl:template match="gmd:MD_Distribution" mode="registryObject_location_download">
        <xsl:for-each select="*:transferOptions/*:MD_DigitalTransferOptions/*:onLine/*:CI_OnlineResource">
            <xsl:if test="contains(lower-case(*:protocol), 'download')">
                <xsl:if test="string-length(normalize-space(*:linkage/*:URL)) > 0">
                    <xsl:variable name="title" select="*:description"/>
                    <xsl:variable name="notes" select="''"/>
                    <xsl:variable name="mediaType" select="*:name/*:MimeFileType/@type"/>
                    <xsl:variable name="byteSize" select="../../*:transferSize/*:Real"/>
                    <location>
                        <address>
                        <electronic>
                            <xsl:attribute name="type">
                                <xsl:text>url</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>directDownload</xsl:text>
                            </xsl:attribute>
                            <value>
                                <xsl:value-of select="normalize-space(*:linkage/*:URL)"/>
                            </value>
                            <xsl:if test="string-length($title) > 0">
                                <title>
                                    <xsl:value-of select="$title"/>
                                </title>
                            </xsl:if>
                            <xsl:if test="string-length($notes) > 0">
                                <notes>
                                    <xsl:value-of select="$notes"/>
                                </notes>
                            </xsl:if>
                            <xsl:if test="string-length($mediaType) > 0">
                                <mediaType>
                                    <xsl:value-of select="$mediaType"/>
                                </mediaType>
                            </xsl:if>
                            <xsl:if test="string-length($byteSize) > 0">
                                <byteSize>
                                    <xsl:value-of select="$byteSize"/>
                                </byteSize>
                            </xsl:if>
                        </electronic>
                    </address>
                    </location>   
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Collection - Related Object (Organisation or Individual) Element -->
    <xsl:template match="gmd:CI_ResponsibleParty" mode="registryObject_related_object">
        <xsl:variable name="transformedName">
            <xsl:call-template name="transform">
                <xsl:with-param name="inputString" select="current-grouping-key()"/>
            </xsl:call-template>
        </xsl:variable>
        <relatedObject>
            <key>
                <xsl:value-of select="concat($global_baseURI,'/', translate(normalize-space($transformedName),' ',''))"/>
            </key>
            <xsl:for-each-group select="current-group()/gmd:role" group-by="gmd:CI_RoleCode/@codeListValue">
                <xsl:variable name="code">
                    <xsl:value-of select="current-grouping-key()"/>
                </xsl:variable>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:value-of select="$code"/>
                    </xsl:attribute>
                </relation>
            </xsl:for-each-group>
        </relatedObject>
    </xsl:template>
    
   
    <!-- Collection - Subject Element -->
    <xsl:template match="gmd:keyword" mode="registryObject_subject">
        <xsl:call-template name="splitText">
            <xsl:with-param name="string" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="gmd:MD_TopicCategoryCode" mode="registryObject_subject">
        <xsl:call-template name="splitText">
            <xsl:with-param name="string" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Collection - Subject (anzsrc) Element -->
    <xsl:template match="gmd:keyword" mode="registryObject_subject_anzsrc">
        <xsl:variable name="keyword" select="string(gco:CharacterString)"/>
        <xsl:variable name="code"
            select="(normalize-space($anzsrcCodelist//gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='ANZSRCCode']/gmx:codeEntry/gmx:CodeDefinition/gml:identifier[following-sibling::gml:name = $keyword]))[1]"/>
        <xsl:if test="string-length($code)">
            <subject>
                <xsl:attribute name="type">
                    <xsl:value-of select="'anzsrc-for'"/>
                </xsl:attribute>
                <xsl:value-of select="$code"/>
            </subject>
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - Decription Element -->
    <xsl:template match="gmd:abstract" mode="registryObject_description">
        <description type="brief">
           <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <!-- Collection - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial">
        <xsl:if test="
            (string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal))) and
            (string-length(normalize-space(gmd:southBoundLatitude/gco:Decimal))) and
            (string-length(normalize-space(gmd:westBoundLongitude/gco:Decimal))) and
            (string-length(normalize-space(gmd:eastBoundLongitude/gco:Decimal)))">
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>iso19139dcmiBox</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(concat('northlimit=',gmd:northBoundLatitude/gco:Decimal,'; southlimit=',gmd:southBoundLatitude/gco:Decimal,'; westlimit=',gmd:westBoundLongitude/gco:Decimal,'; eastLimit=',gmd:eastBoundLongitude/gco:Decimal))"/>
                    
                    <xsl:if test="
                        (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real))) and
                        (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real)))">
                        <xsl:value-of select="normalize-space(concat('; uplimit=',gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real,'; downlimit=',gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real))"/>
                    </xsl:if>
                    <xsl:text>; projection=WGS84</xsl:text>
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:MD_Distribution" mode="registryObject_relatedInfo">
        <xsl:param name="registryObjectType"/>
        
        <xsl:for-each select="*:transferOptions/*:MD_DigitalTransferOptions/*:onLine/*:CI_OnlineResource">
            <xsl:if test="count(custom:proceed_sequence(.)) > 0">
                <xsl:variable name="protocol" select="normalize-space(*:protocol)"/>
                <xsl:variable name="name" select="normalize-space(*:name)"/>
                <xsl:variable name="url" select="normalize-space(*:linkage/*:URL)"/>
                <!-- metadata-URL was added as electronic address and possibly citation identifier, too
                    (if there was no alternative identifier - e.g. DOI - specified in CI_Citation)
                    Add all other online resources here as relatedInfo -->
                <xsl:if test="not(contains(lower-case($protocol), 'download')) and not(contains(lower-case($protocol), 'metadata-url'))">
                    
                    <xsl:message select="concat('distribution url:', $url)"/>
                    <xsl:if test="string-length($url) > 0">
                        <relatedInfo>
                            <xsl:attribute name="type">
                                <xsl:choose>
                                    <xsl:when test="contains(lower-case($name), 'publication') or
                                        contains(lower-case($name), 'map product')">
                                        <xsl:text>publication</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(lower-case($name), 'data') or contains(lower-case($url), 'metadata-gateway')">
                                        <xsl:text>collection</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(lower-case($url), 'datatool')">
                                        <xsl:text>service</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(lower-case($url), 'rss')">
                                        <xsl:text>service</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(lower-case($url), 'services')">
                                        <xsl:text>service</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(lower-case($url), '?')">
                                        <xsl:text>service</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>website</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            
                            <identifier>
                                <xsl:attribute name="type">
                                    <xsl:choose>
                                        <xsl:when test="contains(lower-case($url), 'doi')">
                                            <xsl:text>doi</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>uri</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:value-of select="custom:serviceURI($url)"/>
                            </identifier>
                            
                            <relation>
                                <xsl:attribute name="type">
                                    <xsl:choose>
                                        <xsl:when test="
                                            (contains(lower-case($name), 'associated') and contains(lower-case($name), 'publication')) or
                                            (contains(lower-case($name), 'link to') and contains(lower-case($name), 'map product'))">
                                            <xsl:text>isReferencedBy</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="
                                            contains(lower-case($registryObjectType), 'publication') and
                                            ((contains(lower-case($name), 'data') and contains(lower-case($name), 'associated')) or
                                            contains(lower-case($name), 'link to gis data') or
                                            contains(lower-case($name), 'link to data'))">
                                            <xsl:text>isSupportedBy</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="
                                            contains(lower-case($name), 'associated software') or
                                            contains(lower-case($name), 'associated service') or
                                            contains(lower-case($url), 'datatool') or 
                                            contains(lower-case($url), 'rss') or 
                                            contains(lower-case($url), 'services') or 
                                            contains(lower-case($url), '?') or
                                            contains(lower-case($protocol), 'ogc:')">
                                            <xsl:text>supports</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>hasAssociationWith</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:if test="custom:serviceURI($url) != $url">
                                    <description>
                                        <xsl:text>Access via service</xsl:text>
                                    </description>
                                    <url>
                                        <xsl:value-of select="$url"/>
                                    </url>
                                </xsl:if> 
                            </relation>
                     
                            
                            <xsl:choose>
                                <!-- Use name as title if we have it... -->
                                <xsl:when test="string-length(normalize-space(*:name)) > 0">
                                    <title>
                                        <xsl:value-of select="normalize-space(*:name)"/>
                                    </title>
                                    <!-- ...and then description as notes -->
                                    <xsl:if
                                        test="(string-length(normalize-space(*:description)) > 0) and
                                        normalize-space(*:description) != normalize-space(*:name)">
                                        <notes>
                                            <xsl:value-of
                                                select="normalize-space(*:description)"/>
                                        </notes>
                                    </xsl:if>
                                </xsl:when>
                                <!-- No name, so use description as title if we have it -->
                                <xsl:otherwise>
                                    <xsl:if
                                        test="string-length(normalize-space(*:description)) > 0">
                                        <title>
                                            <xsl:value-of
                                                select="normalize-space(*:description)"/>
                                        </title>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </relatedInfo>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Variable - Owner Name -->
    <xsl:template match="gmd:MD_DataIdentification | srv:SV_ServiceIdentification" mode="variable_owner_name">
        <xsl:call-template name="childValueForRole">
            <xsl:with-param name="roleSubstring">
                <xsl:text>owner</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="childElementName">
                <xsl:text>organisationName</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Variable - Individual Name -->
    <xsl:template match="gmd:MD_DataIdentification | srv:ServiceIdentification" mode="variable_individual_name">
        <xsl:call-template name="childValueForRole">
            <xsl:with-param name="roleSubstring">
                <xsl:text>owner</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="childElementName">
                <xsl:text>individualName</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Variable - Publish Date -->
    <xsl:template match="gmd:MD_DataIdentification/gmd:citation" mode="variable_publish_date">
        <xsl:for-each select="gmd:CI_Citation/gmd:date/gmd:CI_Date">
            <xsl:variable name="lowerCode">
                <xsl:call-template name="toLower">
                    <xsl:with-param name="inputString" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="contains($lowerCode, 'publication')">
                <xsl:value-of select="normalize-space(gmd:date/gco:Date)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Collection - Rights Licence Element -->
    <xsl:template match="gmd:MD_LegalConstraints" mode="registryObject_rights_licence">
        <!-- Request from GA to use only first useConstraint -->
        <!--xsl:for-each select="gmd:useConstraints"-->
        <xsl:if test="exists(gmd:useConstraints)">
            <xsl:variable name="codevalue" select="normalize-space(gmd:useConstraints[1]/gmd:MD_RestrictionCode/@codeListValue)"/>
            <xsl:variable name="otherConstraints">
                <xsl:value-of select="normalize-space(gmd:otherConstraints/gco:CharacterString)"/>
            </xsl:variable>
            
            <xsl:variable name="lowerCode">
                <xsl:call-template name="toLower">
                    <xsl:with-param name="inputString" select="$codevalue"/>
                </xsl:call-template>
            </xsl:variable>
                
            
            <xsl:variable name="licenceText">
                <!-- If the code value is Licence and there is text in other contraints, use this; otherwise, use codeDescription -->
                <xsl:choose>
                    <xsl:when test="(($lowerCode = 'licence') or ($lowerCode = 'license')) and (string-length($otherConstraints))">
                       <xsl:value-of select="$otherConstraints"/>
                    </xsl:when> 
                    <xsl:otherwise>
                        <!-- in all othercases, use default content (ignore otherConstraints) -->
                        <xsl:text>Please contact copyright@ga.gov.au for permission to use this product</xsl:text> 
                    </xsl:otherwise>
                 </xsl:choose>
            </xsl:variable>
            
            <!-- From GA, the only licence type mapping we currently have...-->
            <xsl:message select="concat('$otherConstraints: ', replace(replace($otherConstraints, 'icence', 'icense', 'i'), '[\d.]+', ''))"/>
            <xsl:variable name="licenceType">
                <xsl:if test="($lowerCode = 'licence') or ($lowerCode = 'license')">
                    <xsl:value-of select="(normalize-space($licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition/gml:identifier[replace(following-sibling::gml:name, '\{n\}', '') = replace(replace($otherConstraints, 'icence', 'icense', 'i'), '[\d.]+', '')]))[1]"/>   
                </xsl:if>
            </xsl:variable>
            
            <xsl:variable name="licenceURI">
                <xsl:if test="($lowerCode = 'licence') or ($lowerCode = 'license')">
                    <xsl:value-of select="(normalize-space($licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition/gml:remarks[replace(preceding-sibling::gml:name, '\{n\}', '') = replace(replace($otherConstraints, 'icence', 'icense', 'i'), '[\d.]+', '')]))[1]"/>   
                </xsl:if>
            </xsl:variable>
            
            <!--xsl:message>Licence type: <xsl:value-of select="$licenceType"></xsl:value-of></xsl:message-->
            
            <xsl:variable name="licenceVersion" as="xs:string*">
                <xsl:analyze-string select="normalize-space(.)"
                    regex="[\d.]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            
            
               
             <xsl:if test="string-length($licenceText)">
                 <rights>
                     <licence>
                         <xsl:if test="string-length($licenceURI) and count($licenceVersion) > 0">
                             <xsl:attribute name="rightsUri">
                                 <xsl:value-of select="replace($licenceURI, '\{n\}', $licenceVersion)"/>
                             </xsl:attribute>
                         </xsl:if>
                         <xsl:if test="string-length($licenceType)">
                              <xsl:attribute name="type">
                                  <xsl:value-of select='$licenceType'/>
                              </xsl:attribute>
                          </xsl:if>
                          <xsl:value-of select='$licenceText'/>
                     </licence>
                 </rights>
             </xsl:if>
            
        <!--/xsl:for-each-->
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - Rights AccessRights Element -->
    <!--xsl:template match="gmd:MD_LegalConstraints" mode="registryObject_rights_accessRights">
        <xsl:for-each select="gmd:accessConstraints">
            <xsl:if test="string-length(normalize-space(../gmd:otherConstraints))">
                <rights>
                    <accessRights>
                        <xsl:value-of select='normalize-space(../gmd:otherConstraints)'/>
                    </accessRights>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template-->
    
    <xsl:template match="gmd:otherConstraints">
        <xsl:value-of select="gco:CharacterString"/>
        <xsl:if test="not(position()=last())">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - RightsStatement -->
    <xsl:template name="registryObject_rights_rightsStatement">
        <xsl:param name="organisationOwnerName"/>
        <xsl:param name="individualOwnerName"/>
        <xsl:param name="publishDate"/>
        
        <xsl:variable name="ownerNameToUse">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space($organisationOwnerName))">
                    <xsl:value-of select="$organisationOwnerName"></xsl:value-of>
                </xsl:when>
                <xsl:when test="string-length(normalize-space($individualOwnerName))">
                    <xsl:value-of select="$individualOwnerName"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Commonwealth of Australia (Geoscience Australia)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="dateToUse">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space($publishDate))">
                    <xsl:value-of select="$publishDate"></xsl:value-of>
                </xsl:when>
                 <xsl:otherwise>
                     <xsl:value-of select="format-date(current-date(), '[Y0001]')"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <rights>
            <rightsStatement>
                <xsl:value-of select="concat('© ', $ownerNameToUse, ' ', $dateToUse)"/>
            </rightsStatement>
        </rights>
    </xsl:template>
  
    <!-- Collection - CitationInfo Element -->
    <xsl:template name="registryObject_citationMetadata_citationInfo">
        <xsl:param name="dataSetURI"/>
        <xsl:param name="citation"/>
        <!-- We can only accept one DOI; howerver, first we will find all -->
        <xsl:variable name = "doiIdentifier_sequence" as="xs:string*">
            <xsl:call-template name="doiFromIdentifiers">
                <xsl:with-param name="identifier_sequence" as="xs:string*" select="gmd:identifier/gmd:MD_Identifier/gmd:code"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and string-length($doiIdentifier_sequence[1])">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dataSetURI"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and string-length($doiIdentifier_sequence[1])">
                    <xsl:text>doi</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <citationInfo>
            <citationMetadata>
                <xsl:if test="string-length($identifierToUse)">
                    <identifier>
                        <xsl:if test="string-length($typeToUse)">
                            <xsl:attribute name="type">
                                <xsl:value-of select='$typeToUse'/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select='$identifierToUse'/>
                    </identifier>
                </xsl:if>
                
                <title>
                    <xsl:value-of select="gmd:title"/>
                </title>
                <xsl:for-each select="gmd:date/gmd:CI_Date">
                    <xsl:variable name="lowerCode">
                        <xsl:call-template name="toLower">
                            <xsl:with-param name="inputString" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:if test="contains($lowerCode, 'publication')">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
                                <xsl:variable name="codevalue" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
                                <xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
                            </xsl:attribute>
                            <xsl:value-of select="gmd:date/gco:Date"/>
                        </date>
                    </xsl:if>
                </xsl:for-each>
                
                <!-- Contributing individuals - note that we are ignoring those individuals where a role has not been specified -->
                <xsl:for-each-group
                    select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and 
                    (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
                    group-by="gmd:individualName">
                    
                    <xsl:variable name="individualName" select="normalize-space(current-grouping-key())"/>
                    <xsl:variable name="isPublisher" as="xs:boolean*">
                        <xsl:for-each-group select="current-group()/gmd:role" group-by="gmd:CI_RoleCode/@codeListValue">
                            <xsl:variable name="lowerCode">
                                <xsl:call-template name="toLower">
                                    <xsl:with-param name="inputString" select="current-grouping-key()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="contains($lowerCode, 'publish')">
                                <xsl:value-of select="true()"/>
                            </xsl:if>
                        </xsl:for-each-group>
                    </xsl:variable>
                    <xsl:if test="count($isPublisher) = 0">
                        <contributor>
                            <namePart>
                                <xsl:value-of select="$individualName"/>
                            </namePart>
                        </contributor>
                    </xsl:if>
                </xsl:for-each-group>
                
                <!-- Contributing organisations - included only when there is no individual name (in which case the individual has been included above) 
                        Note again that we are ignoring organisations where a role has not been specified -->
                <xsl:for-each-group
                    select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[
                            (string-length(normalize-space(gmd:organisationName))) and
                            not(string-length(normalize-space(gmd:individualName))) and
                            (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
                    group-by="gmd:organisationName">
                    
                    <xsl:variable name="transformedOrganisationName">
                        <xsl:call-template name="transform">
                            <xsl:with-param name="inputString" select="normalize-space(current-grouping-key())"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:variable name="isPublisher" as="xs:boolean*">
                        <xsl:for-each-group select="current-group()/gmd:role" group-by="gmd:CI_RoleCode/@codeListValue">
                            <xsl:variable name="lowerCode">
                                <xsl:call-template name="toLower">
                                    <xsl:with-param name="inputString" select="current-grouping-key()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="contains($lowerCode, 'publish')">
                                <xsl:value-of select="true()"/>
                            </xsl:if>
                        </xsl:for-each-group>
                    </xsl:variable>
                    <xsl:if test="count($isPublisher) = 0">
                        <contributor>
                            <namePart>
                                <xsl:value-of select="$transformedOrganisationName"/>
                            </namePart>
                        </contributor>
                    </xsl:if>
                </xsl:for-each-group>
                
                <xsl:variable name="publishName">
                    <xsl:call-template name="publishNameToUse"/>
                </xsl:variable>
                
                <xsl:if test="string-length($publishName)">
                    <publisher>
                        <xsl:value-of select="$publishName"/>
                    </publisher>
                </xsl:if>
                
                <xsl:variable name="publishPlace">
                    <xsl:call-template name="publishPlaceToUse">
                        <xsl:with-param name="publishNameToUse" select="$publishName"/>
                    </xsl:call-template>
                </xsl:variable>
               
                <xsl:if test="string-length($publishPlace)">
                    <placePublished>
                        <xsl:value-of select="$publishPlace"/>
                    </placePublished>
                </xsl:if>
    
            </citationMetadata>
        </citationInfo>
    </xsl:template>
    
    
  
    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->
    
    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="party">
        <xsl:param name="type"/>
        <registryObject group="{$global_group}">
            
            <xsl:variable name="transformedName">
                <xsl:call-template name="transform">
                    <xsl:with-param name="inputString" select="current-grouping-key()"/>
                </xsl:call-template>
            </xsl:variable>
            
            
            <key>
                <xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space($transformedName),' ',''))"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            
            <!-- Use the party type provided, except for exception:
                    Because sometimes Geoscience Australia or GA is used for an author, appearing in individualName,
                    we want to make sure that we use 'group', not 'person', if this anomoly occurs -->
            
            <xsl:variable name="typeToUse">
                <xsl:choose>
                     <xsl:when test="contains($transformedName, 'Geoscience Australia')">
                         <xsl:value-of>group</xsl:value-of>
                     </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$type"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <party type="{$typeToUse}">
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="$transformedName"/>
                    </namePart>
                </name>
                
                <!-- If we have are dealing with individual who has an organisation name:
                    - leave out the address (so that it is on the organisation only); and 
                    - relate the individual to the organisation -->
                
                <!-- If we are dealing with an individual...-->
                <xsl:choose>
                    <xsl:when test="contains($type, 'person')">
                        <xsl:variable name="transformedOrganisationName">
                            <xsl:call-template name="transform">
                                <xsl:with-param name="inputString" select="gmd:organisationName"/>
                            </xsl:call-template>
                        </xsl:variable>
                        
                       
                        <xsl:choose>
                             <xsl:when test="string-length(normalize-space($transformedOrganisationName))">
                                 <!--  Individual has an organisation name, so related the individual to the organisation, and omit the address 
                                        (the address will be included within the organisation to which this individual is related) -->
                                 <relatedObject>
                                     <key>
                                         <xsl:value-of select="concat($global_baseURI,'/', $transformedOrganisationName)"/>
                                     </key>
                                     <relation type="isMemberOf"/>
                                 </relatedObject>
                             </xsl:when>
                             
                            <xsl:otherwise>
                                <!-- Individual does not have an organisation name, so include the address here -->
                                <xsl:call-template name="physicalAddress"/>
                                <xsl:call-template name="phone"/>
                                <xsl:call-template name="electronic"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- We are dealing with an organisation, so always include the address -->
                        <xsl:call-template name="physicalAddress"/>
                        <xsl:call-template name="phone"/>
                        <xsl:call-template name="electronic"/>
                    </xsl:otherwise>
                </xsl:choose>
            </party>
        </registryObject>
    </xsl:template>
    
    <xsl:template name="physicalAddress">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)"
                data-type="number" order="descending"/>
            
            <xsl:if test="position() = 1">
                <xsl:if test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*) > 0">
                
                    <location>
                        <address>
                            <physical type="streetAddress">
                                <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </addressPart>
                                
                                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString[string-length(text()) > 0]">
                                     <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </xsl:for-each>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city))">
                                      <addressPart type="suburbOrPlaceLocality">
                                          <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)"/>
                                      </addressPart>
                                 </xsl:if>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea))">
                                     <addressPart type="stateOrTerritory">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)"/>
                                     </addressPart>
                                 </xsl:if>
                                     
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode))">
                                     <addressPart type="postCode">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)"/>
                                     </addressPart>
                                 </xsl:if>
                                 
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country))">
                                     <addressPart type="country">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)"/>
                                     </addressPart>
                                 </xsl:if>
                            </physical>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
      
      
    <xsl:template name="phone">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/child::*)"
                data-type="number" order="descending"/>
            
            <xsl:if test="position() = 1">
                <xsl:if test="count(gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/child::*) > 0">
                    <location>
                        <address>
                            <physical type="streetAddress">
                                 <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString[string-length(text()) > 0]">
                                     <addressPart type="telephoneNumber">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                 </xsl:for-each>
                                    
                                 <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile/gco:CharacterString[string-length(text()) > 0]">
                                     <addressPart type="faxNumber">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                 </xsl:for-each>
                            </physical>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="electronic">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0])"
                data-type="number" order="descending"/>
            
            <xsl:if test="position() = 1">
                <xsl:if test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0])">
                    <location>
                        <address>
                            <electronic type="email">
                                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0]">
                                    <value>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </value>
                                </xsl:for-each>
                            </electronic>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Modules -->
    
    <xsl:template name="doiFromIdentifiers">
        <xsl:param name="identifier_sequence"/>
        <xsl:for-each select="distinct-values($identifier_sequence)">
            <xsl:if test="contains(lower-case(normalize-space(.)), 'doi')">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="toLower">
        <xsl:param name="inputString"/>
        <xsl:variable name="smallCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
        <xsl:value-of select="translate($inputString,$upperCase,$smallCase)"/>
    </xsl:template>
    
    <xsl:template name="publishNameToUse">
        <!--xsl:message>Module: publishNameToUse</xsl:message-->
        <xsl:variable name="organisationPublisherName">
            <xsl:call-template name="childValueForRole">
                <xsl:with-param name="roleSubstring">
                    <xsl:text>publish</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="childElementName">
                    <xsl:text>organisationName</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <!--xsl:message>Organisation publisher name: <xsl:value-of select="$organisationPublisherName"></xsl:value-of></xsl:message-->
        
        <xsl:variable name="transformedOrganisationPublisherName">
            <xsl:call-template name="transform">
                <xsl:with-param name="inputString" select="$organisationPublisherName"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="individualPublisherName">
            <xsl:call-template name="childValueForRole">
                <xsl:with-param name="roleSubstring">
                    <xsl:text>publish</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="childElementName">
                    <xsl:text>individualName</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <!--xsl:message>Individual publisher name: <xsl:value-of select="$individualPublisherName"></xsl:value-of></xsl:message-->
        
        <xsl:variable name="transformedIndividualPublisherName">
            <xsl:call-template name="transform">
                <xsl:with-param name="inputString" select="$individualPublisherName"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($transformedOrganisationPublisherName))">
                <xsl:value-of select="$transformedOrganisationPublisherName"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($transformedIndividualPublisherName))">
                <xsl:value-of select="$transformedIndividualPublisherName"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$global_publisherName"/>
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <xsl:template name="publishPlaceToUse">
        <xsl:param name="publishNameToUse"/>
        <xsl:variable name="publishCity">
            <xsl:call-template name="childValueForRole">
                <xsl:with-param name="roleSubstring">
                    <xsl:text>publish</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="childElementName">
                    <xsl:text>city</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <!--xsl:message>City: <xsl:value-of select="$publishCity"/></xsl:message-->
        
        <xsl:variable name="publishCountry">
            <xsl:call-template name="childValueForRole">
                <xsl:with-param name="roleSubstring">
                    <xsl:text>publish</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="childElementName">
                    <xsl:text>country</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <!--xsl:message>Country: <xsl:value-of select="$publishCountry"/></xsl:message-->
        
        <xsl:choose>
            <xsl:when test="string-length($publishCity)">
                <xsl:value-of select="$publishCity"/>
            </xsl:when>
            <xsl:when test="string-length($publishCountry)">
                <xsl:value-of select="$publishCity"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Only default publisher place if publisher name is equal to the global value (whether it was set or retrieved) -->
                <xsl:if test="$publishNameToUse = $global_publisherName">
                        <xsl:value-of select="$global_publisherPlace"></xsl:value-of>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="transform">
        <xsl:param name="inputString"/>
        <xsl:choose>
            <xsl:when test="contains($inputString, 'GA')">
                <xsl:text>Geoscience Australia</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$inputString"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Get the values of the child element of the point of contact responsible parties whose role contains this substring provided 
         For example, if you provide roleSubsting as 'publish' and childElementName as 'organisationName',
            you will receive all organisation names within point of contact.  They will be separated by 'commas', with an 'and' between
            the last and second last, where applicable -->
    <xsl:template name="childValueForRole">
        <xsl:param name="roleSubstring"/>
        <xsl:param name="childElementName"/>
        <xsl:variable name="lowerRoleSubstring">
            <xsl:call-template name="toLower">
                <xsl:with-param name="inputString" select="$roleSubstring"/>
            </xsl:call-template>
        </xsl:variable>
        <!--xsl:message>Child element name: <xsl:value-of select="$childElementName"></xsl:value-of></xsl:message-->
        <xsl:variable name="nameSequence" as="xs:string*">
            <xsl:for-each-group
                select="descendant::gmd:CI_ResponsibleParty[
                (string-length(normalize-space(descendant::node()[local-name()=$childElementName]))) and 
                (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
                group-by="descendant::node()[local-name()=$childElementName]">
                 <xsl:choose>
                    <!-- obtain for two locations so far - we don't want for example we don't want
                        responsible parties under citation of thesauruses used -->
                    <xsl:when test="contains(local-name(..), 'pointOfContact') or 
                                    contains(local-name(../../..), 'citation')">
                        <!--xsl:message>Parent: <xsl:value-of select="ancestor::node()"></xsl:value-of></xsl:message-->
                        <xsl:variable name="lowerCode">
                            <xsl:call-template name="toLower">
                                <xsl:with-param name="inputString" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="contains($lowerCode, $lowerRoleSubstring)">
                            <xsl:sequence select="descendant::node()[local-name()=$childElementName]"/> 
                            <!--xsl:message>Child value: <xsl:value-of select="descendant::node()[local-name()=$childElementName]"></xsl:value-of></xsl:message-->
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
             </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="formattedValues">
            <xsl:for-each select="$nameSequence">
                <xsl:if test="position() > 1">
                    <xsl:choose>
                        <xsl:when test="position() = count($nameSequence)">
                            <xsl:text> and </xsl:text>
                        </xsl:when>
                        <xsl:when test="position() &lt; count($nameSequence)">
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <!--xsl:message>Formatted values: <xsl:value-of select="$formattedValues"></xsl:value-of></xsl:message-->
        <xsl:value-of select="$formattedValues"/>
    </xsl:template>
    
    <xsl:template name="splitText">
        <xsl:param name="string"/>
        <xsl:param name="separator" select="', '"/>
        <xsl:choose>
            <xsl:when test="contains($string, $separator)">
                <xsl:if test="not(starts-with($string, $separator))">
                    <subject>
                        <xsl:attribute name="type">
                            <xsl:text>local</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="substring-before($string, $separator)"/>
                    </subject>
                </xsl:if>
                <xsl:call-template name="splitText">
                    <xsl:with-param name="string" select="substring-after($string,$separator)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string-length(normalize-space($string))">
                    <subject>
                        <xsl:attribute name="type">
                            <xsl:text>local</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$string"/>
                    </subject>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="custom:proceed_sequence" as="xs:boolean*">
        <xsl:param name="currentNode" as="node()"/>
        <xsl:variable name="name" select="$currentNode/*:name"/>
        <xsl:message select="concat('name:', $name)"/>
        <xsl:if test="not(contains(lower-case($name), 'doi')) or contains(lower-case($name), 'associated')">
            <xsl:value-of select="true()"/>
        </xsl:if>
     </xsl:function>
    
    <xsl:function name="custom:serviceURI" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:choose>
            <xsl:when test="contains($uri, 'doi')">
                <xsl:value-of select="$uri"/>
            </xsl:when>
            <xsl:when test="contains($uri, '?')">
                <!-- Indicates parameters -->
                <xsl:variable name="serviceIdentifier">
                    <xsl:variable name="baseURL" select="substring-before($uri, '?')"/>
                    <xsl:choose>
                        <xsl:when
                            test="substring($baseURL, string-length($baseURL), 1) = '/'">
                            <xsl:copy-of
                                select="substring($baseURL, 1, string-length($baseURL)-1)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$baseURL"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="$serviceIdentifier"/>
            </xsl:when>
            <xsl:when test="contains($uri, '/')">
                <xsl:variable name="serviceURI" select="string-join(tokenize($uri,'/')[position()!=last()],'/')"/>
                <xsl:variable name="serviceName" select="substring-after($uri, $serviceURI)"/>
                <xsl:choose>
                    <xsl:when test="contains($serviceName, '.')">
                        <xsl:value-of select="$serviceURI"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$uri"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$uri"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:serviceName">
        <xsl:param name="url"/>
             <xsl:for-each select="tokenize($url, '/')">
                <xsl:if test="position() = count(tokenize($url, '/'))">
                    <xsl:value-of select="concat(normalize-space(.), ' service')"/>
                </xsl:if>
            </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="custom:sequence_contains" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="substring" as="xs:string"/>
        
        <!--xsl:message select="concat('match substring:', $substring)"/-->
        
        <xsl:variable name="matches_sequence" as="xs:string*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:if test="contains(lower-case(normalize-space(.)), $substring)">
                        <xsl:copy-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <!--xsl:message select="concat('count matches :', count($matches_sequence))"/-->
        <!--xsl:for-each select="distinct-values($matches_sequence)">
            <xsl:message select="concat('match :', .)"/>
        </xsl:for-each-->
        
        
        <xsl:choose>
            <xsl:when test="count($matches_sequence) > 0">
                <xsl:copy-of select="true()"/>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:getProtocolURL_sequence" as="xs:string*">
        <xsl:param name="protocol"/> 
        <xsl:param name="transferOptions"/>
        <xsl:for-each select="$transferOptions/*:onLine/*:CI_OnlineResource">
            <xsl:if test="contains(lower-case(*:protocol), $protocol)">
                <xsl:variable name="metadataURL" select="normalize-space(*:linkage/*:URL)"/>
                <xsl:if test="string-length($metadataURL) > 0">
                    <xsl:copy-of select="$metadataURL"/>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- RegistryObject - Access Rights Element  -->
    <xsl:function name="custom:set_registryObject_accessRights">
        <xsl:param name="fees_sequence"/>
        <xsl:param name="downloaddataURL_sequence"/>
        <xsl:param name="restrictionCode_sequence"/>
        <xsl:param name="otherConstraints_sequence"/>
        
        <xsl:variable name="totalFee" as="xs:double" select="sum($fees_sequence)"/>
        <!--xsl:message select="concat('Total fee: ', $totalFee)"/-->
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="$totalFee > 0">
                     <xsl:text>conditional</xsl:text>
                </xsl:when>
                <xsl:when test="boolean(custom:sequence_contains($restrictionCode_sequence, 'restricted')) = true()">
                    <xsl:text>restricted</xsl:text>
                </xsl:when>
                <xsl:when test="boolean(custom:sequence_contains($otherConstraints_sequence, 'public access')) = true()">
                    <xsl:text>open</xsl:text>
                </xsl:when>
                <xsl:when test="count($downloaddataURL_sequence) > 0">
                    <xsl:text>open</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- only indicate open datasets at the moment - until we've verified whether fee implies 'conditional' or 'open'-->
        <xsl:if test="string-length($type) > 0">
            <xsl:if test="($type = 'open') or ($type = 'restricted')">
                <rights>
                    <accessRights>
                        <xsl:attribute name="type" select="$type"/>
                    </accessRights>
                </rights>
            </xsl:if>
        </xsl:if>
     </xsl:function>
    
    <xsl:function name="custom:getRegistryObjectTypeSubType" as="xs:string*">
        <xsl:param name="scopeCode"/>
        <xsl:choose>
            <xsl:when test="substring(lower-case($scopeCode), 0, 8) = 'service'">
                <xsl:text>service</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test="substring(lower-case($scopeCode), 0, 21) = 'nongeographicdataset'">
                <xsl:text>collection</xsl:text>
                <xsl:text>publication</xsl:text>
            </xsl:when>
            <xsl:when test="substring(lower-case($scopeCode), 0, 8) = 'dataset'">
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>